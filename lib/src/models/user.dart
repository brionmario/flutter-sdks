// Copyright 2026 The ThunderID Authors
// SPDX-License-Identifier: Apache-2.0

/// The authenticated user.
///
/// A deployment's claims are dynamic, so the user *is* the claim set: every claim comes
/// through untouched and is readable by key. The few well known claims mirror the
/// `KnownUser` keys in the JavaScript SDK and are plain getters, not mapped fields, so
/// they read the claim of the same name and nothing else.
class User {
  /// Every claim exactly as the server sent it.
  final Map<String, dynamic> claims;

  const User(this.claims);

  /// Reads any claim by name, including ones this SDK has never heard of.
  dynamic operator [](String claim) => claims[claim];

  String? get sub => this['sub'] as String?;
  String? get username => this['username'] as String?;
  String? get email => this['email'] as String?;
  String? get displayName => this['displayName'] as String?;
  String? get givenName => this['givenName'] as String?;
  String? get familyName => this['familyName'] as String?;

  /// Protocol claims: they describe the token, not the user.
  static const Set<String> reservedClaims = {
    'sub',
    'iss',
    'aud',
    'exp',
    'iat',
    'nbf',
    'jti',
    'azp',
    'nonce',
    'typ',
    'at_hash',
    'c_hash',
    'sid',
    'scope',
    'client_id',
    'acr',
    'amr',
    'auth_time',
  };

  /// Every claim except [reservedClaims].
  Map<String, dynamic> get profileClaims => Map.fromEntries(
        claims.entries.where((entry) => !reservedClaims.contains(entry.key)),
      );

  Map<String, dynamic> toMap() => claims;

  factory User.fromMap(Map<dynamic, dynamic> map) =>
      User(map.cast<String, dynamic>());
}
