/*
 * Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com).
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package dev.thunderid.flutter

import android.content.Context
import com.google.android.gms.tasks.Task
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.StandardIntegrityManager.PrepareIntegrityTokenRequest
import com.google.android.play.core.integrity.StandardIntegrityManager.StandardIntegrityTokenProvider
import com.google.android.play.core.integrity.StandardIntegrityManager.StandardIntegrityTokenRequest
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

/**
 * Mints Google Play Integrity tokens for the native SDK's attestationTokenProvider.
 * The warm-up token provider is cached and reused across requests.
 */
class PlayIntegrityTokenProvider(
    private val context: Context,
    private val cloudProjectNumber: Long,
) {
    private var tokenProvider: StandardIntegrityTokenProvider? = null

    suspend fun requestToken(): String {
        return try {
            obtainProvider().requestIntegrityToken()
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            // The cached provider can become invalid (e.g. it expires); re-prepare once and retry.
            tokenProvider = null
            try {
                obtainProvider().requestIntegrityToken()
            } catch (retryError: Exception) {
                retryError.addSuppressed(e)
                throw retryError
            }
        }
    }

    private suspend fun obtainProvider(): StandardIntegrityTokenProvider =
        tokenProvider ?: prepareTokenProvider().also { tokenProvider = it }

    private suspend fun StandardIntegrityTokenProvider.requestIntegrityToken(): String =
        request(StandardIntegrityTokenRequest.builder().build()).await().token()

    private suspend fun prepareTokenProvider(): StandardIntegrityTokenProvider =
        IntegrityManagerFactory.createStandard(context)
            .prepareIntegrityToken(
                PrepareIntegrityTokenRequest.builder()
                    .setCloudProjectNumber(cloudProjectNumber)
                    .build(),
            ).await()
}

private suspend fun <T> Task<T>.await(): T =
    suspendCancellableCoroutine { cont ->
        addOnSuccessListener { cont.resume(it) }
        addOnFailureListener { cont.resumeWithException(it) }
        addOnCanceledListener { cont.cancel() }
    }
