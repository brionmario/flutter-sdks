// Copyright 2026 The ThunderID Authors
// SPDX-License-Identifier: Apache-2.0

class SignUpOptions {
  final String? appId;
  final Map<String, dynamic> extra;

  const SignUpOptions({this.appId, this.extra = const {}});

  Map<String, dynamic> toMap() => {
        if (appId != null) 'appId': appId,
        ...extra,
      };
}
