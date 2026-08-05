// Copyright 2026 The ThunderID Authors
// SPDX-License-Identifier: Apache-2.0

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
