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

/// ThunderID Flutter SDK.
///
/// Provides identity management (sign-in, sign-up, token management, user profile)
/// for Flutter apps by bridging to the native iOS and Android
/// ThunderID Platform SDKs via Flutter platform channels.
library thunderid_flutter;

export 'src/flow_template_resolver.dart';
export 'src/logo/avatar_logo.dart';
export 'src/logo/curated_logo_icons.dart';
export 'src/logo/logo_spec.dart';
export 'src/logo/thunderid_logo.dart';
export 'src/models/flow_models.dart';
export 'src/models/preferences.dart';
export 'src/models/sign_in_options.dart';
export 'src/models/sign_out_options.dart';
export 'src/models/sign_up_options.dart';
export 'src/models/thunderid_config.dart';
export 'src/models/thunderid_error.dart';
export 'src/models/token_exchange_config.dart';
export 'src/models/token_response.dart';
export 'src/models/user.dart';
export 'src/models/user_profile.dart' hide UserProfile;
export 'src/thunderid_client.dart';
export 'src/widgets/callback.dart';
export 'src/widgets/language_switcher.dart';
export 'src/widgets/loading.dart';
export 'src/widgets/sign_in.dart';
export 'src/widgets/sign_in_button.dart';
export 'src/widgets/sign_out_button.dart';
export 'src/widgets/sign_up.dart';
export 'src/widgets/sign_up_button.dart';
export 'src/widgets/signed_in.dart';
export 'src/widgets/signed_out.dart';
export 'src/widgets/thunderid_provider.dart';
export 'src/widgets/user_dropdown.dart';
export 'src/widgets/user_object.dart';
export 'src/widgets/user_profile.dart';
