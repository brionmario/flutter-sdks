// Copyright 2026 The ThunderID Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thunderid_flutter/thunderid_flutter.dart';

// Smoke tests for the styled UserProfile widget itself (the pure evaluation/mapping logic is
// covered by user_profile_fields_test.dart). These exist to catch widget-assembly bugs - missing
// ancestors, layout overflow, broken navigation - that `flutter analyze` cannot.

Widget _wrap(Widget child) => MaterialApp(
      home: ThunderIDProvider(
        config: const ThunderIDConfig(baseUrl: 'https://localhost:8090', clientId: 'test'),
        child: Scaffold(body: child),
      ),
    );

Future<Object?> Function(MethodCall) _handler() => (call) async {
      switch (call.method) {
        case 'initialize':
          return true;
        case 'isSignedIn':
          return false;
        case 'getUserSchema':
          return <Object?, Object?>{
            'email': <Object?, Object?>{'type': 'STRING', 'displayName': 'Email'},
            'username': <Object?, Object?>{
              'type': 'STRING',
              'displayName': 'Username',
              'readOnly': true,
            },
            'address': <Object?, Object?>{'type': 'COMPLEX', 'displayName': 'Address'},
          };
        case 'getUserProfile':
          return <Object?, Object?>{
            'id': 'user-1',
            'isReadOnly': false,
            'attributes': <Object?, Object?>{
              'email': 'ada@example.com',
              'username': 'ada',
              'address': <Object?, Object?>{'city': 'NYC'},
            },
          };
        case 'setCachedUser':
          return null;
        default:
          return null;
      }
    };

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('dev.thunderid/sdk'), _handler());
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('dev.thunderid/sdk'), null);
  });

  group('UserProfile (styled)', () {
    testWidgets('renders a row per editable field and opens its edit page on tap', (tester) async {
      await tester.pumpWidget(_wrap(const UserProfile()));
      await tester.pumpAndSettle();

      expect(find.text('Email'), findsOneWidget);
      // Appears twice: once as the avatar header's subtitle, once as the Email row's value.
      expect(find.text('ada@example.com'), findsWidgets);

      // Regression test: a read-only field like username used to be dropped from the row list
      // entirely rather than shown without an Edit link.
      expect(find.text('Username'), findsOneWidget);
      // Appears twice: once as the avatar header's display name (falls back to username when
      // no first/last name is mapped), once as the Username row's value.
      expect(find.text('ada'), findsWidgets);
      expect(find.text('Edit'), findsOneWidget, reason: 'only the editable Email row gets one');

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('thunderid-field-profile-email')), findsOneWidget);

      await tester.tap(find.byKey(const Key('thunderid-action-cancelProfileField')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('thunderid-field-profile-email')), findsNothing);
    });

    testWidgets('a COMPLEX field renders its entries and gets no Edit link', (tester) async {
      // Regression test: the redesign used to drop the schema's COMPLEX-type check entirely, so
      // a Map-valued field rendered blank with a working Edit link that would have written a
      // plain string over a structured attribute on save.
      await tester.pumpWidget(_wrap(const UserProfile()));
      await tester.pumpAndSettle();

      expect(find.text('Address'), findsOneWidget);
      expect(find.text('city: NYC'), findsOneWidget);

      final addressRow = find.ancestor(
        of: find.text('Address'),
        matching: find.byType(Row),
      );
      expect(find.descendant(of: addressRow, matching: find.text('Edit')), findsNothing);
    });
  });
}
