// Copyright 2026 The ThunderID Authors
// SPDX-License-Identifier: Apache-2.0

class UserProfile {
  final String id;
  final Map<String, dynamic> claims;

  const UserProfile({required this.id, this.claims = const {}});

  factory UserProfile.fromMap(Map<dynamic, dynamic> map) => UserProfile(
        id: map['id'] as String,
        claims: (map['claims'] as Map?)?.cast<String, dynamic>() ?? {},
      );
}
