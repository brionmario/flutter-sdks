// Copyright 2026 The ThunderID Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thunderid_flutter/src/models/flow_models.dart';
import 'package:thunderid_flutter/src/models/thunderid_config.dart';
import 'package:thunderid_flutter/src/models/thunderid_error.dart';
import 'package:thunderid_flutter/src/thunderid_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThunderIDClient client;
  final List<MethodCall> log = [];

  setUp(() {
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.thunderid/sdk'),
      (call) async {
        log.add(call);
        switch (call.method) {
          case 'initialize':
            return true;
          case 'isSignedIn':
            return false;
          case 'signOut':
            return '/';
          case 'getAccessToken':
            return 'mock-access-token';
          case 'continueFederatedAuth':
            final args = call.arguments as Map<Object?, Object?>;
            if (args['redirectUrl'] == 'https://cancel.example') {
              throw PlatformException(code: 'FEDERATED_AUTH_CANCELLED', message: 'cancelled');
            }
            return <String, dynamic>{
              'flowId': 'flow-1',
              'flowStatus': 'COMPLETE',
              'assertion': 'mock-assertion',
            };
          default:
            return null;
        }
      },
    );
    client = ThunderIDClient();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('dev.thunderid/sdk'), null);
  });

  group('initialization', () {
    test('initialize calls native channel with config', () async {
      const config = ThunderIDConfig(
        baseUrl: 'https://localhost:8090',
        clientId: 'test-client',
      );
      final result = await client.initialize(config);
      expect(result, true);
      expect(log.any((c) => c.method == 'initialize'), true);
    });

    test('initialize throws ALREADY_INITIALIZED when called twice', () async {
      const config = ThunderIDConfig(baseUrl: 'https://localhost:8090', clientId: 'test');
      await client.initialize(config);
      expect(
        () => client.initialize(config),
        throwsA(isA<IAMException>().having((e) => e.code, 'code', ThunderIDErrorCode.alreadyInitialized)),
      );
    });

    test('operations before init throw SDK_NOT_INITIALIZED', () {
      expect(
        () => client.isSignedIn(),
        throwsA(isA<IAMException>().having((e) => e.code, 'code', ThunderIDErrorCode.sdkNotInitialized)),
      );
    });
  });

  group('isLoading', () {
    test('isLoading returns false when not active', () async {
      const config = ThunderIDConfig(baseUrl: 'https://localhost:8090', clientId: 'test');
      await client.initialize(config);
      expect(client.isLoading(), false);
    });
  });

  group('ThunderIDErrorCode', () {
    test('fromString parses known codes', () {
      expect(ThunderIDErrorCode.fromString('AUTHENTICATION_FAILED'), ThunderIDErrorCode.authenticationFailed);
      expect(ThunderIDErrorCode.fromString('SESSION_EXPIRED'), ThunderIDErrorCode.sessionExpired);
      expect(ThunderIDErrorCode.fromString('SDK_NOT_INITIALIZED'), ThunderIDErrorCode.sdkNotInitialized);
    });

    test('fromString returns unknownError for unknown code', () {
      expect(ThunderIDErrorCode.fromString('NOT_REAL'), ThunderIDErrorCode.unknownError);
    });

    test('IAMException toString includes code', () {
      const e = IAMException(ThunderIDErrorCode.networkError, 'connection refused');
      expect(e.toString(), contains('NETWORK_ERROR'));
    });
  });

  group('ThunderIDConfig', () {
    test('toMap includes required fields', () {
      const config = ThunderIDConfig(
        baseUrl: 'https://localhost:8090',
        clientId: 'client-123',
        scopes: ['openid', 'profile'],
      );
      final map = config.toMap();
      expect(map['baseUrl'], 'https://localhost:8090');
      expect(map['clientId'], 'client-123');
      expect(map['scopes'], ['openid', 'profile']);
    });

    test('toMap omits null optional fields', () {
      const config = ThunderIDConfig(baseUrl: 'https://localhost:8090');
      final map = config.toMap();
      expect(map.containsKey('clientId'), false);
      expect(map.containsKey('afterSignInUrl'), false);
    });

    test('attestation defaults to disabled', () {
      const config = ThunderIDConfig(baseUrl: 'https://localhost:8090');
      final map = config.toMap();
      expect(map['attestationEnabled'], false);
      expect(map.containsKey('cloudProjectNumber'), false);
    });

    test('toMap includes attestation fields when set', () {
      const config = ThunderIDConfig(
        baseUrl: 'https://localhost:8090',
        attestationEnabled: true,
        cloudProjectNumber: 123456789,
      );
      final map = config.toMap();
      expect(map['attestationEnabled'], true);
      expect(map['cloudProjectNumber'], 123456789);
    });
  });

  group('sign-out', () {
    test('signOut delegates to native and returns afterSignOutUrl', () async {
      const config = ThunderIDConfig(baseUrl: 'https://localhost:8090', clientId: 'test');
      await client.initialize(config);
      final result = await client.signOut();
      expect(result, '/');
    });
  });

  group('getAccessToken', () {
    test('returns token from native layer', () async {
      const config = ThunderIDConfig(baseUrl: 'https://localhost:8090', clientId: 'test');
      await client.initialize(config);
      final token = await client.getAccessToken();
      expect(token, 'mock-access-token');
    });
  });

  group('continueFederatedAuth', () {
    test('resubmits the flow with the native-extracted code and returns the response', () async {
      const config = ThunderIDConfig(baseUrl: 'https://localhost:8090', clientId: 'test');
      await client.initialize(config);
      final response = await client.continueFederatedAuth(
        redirectUrl: 'https://idp.example/authorize?state=abc',
        actionId: 'action_2',
        applicationId: 'app-1',
        flowId: 'flow-1',
        challengeToken: 'challenge-1',
      );
      expect(response.flowStatus, FlowStatus.complete);
      expect(response.assertion, 'mock-assertion');
      final call = log.firstWhere((c) => c.method == 'continueFederatedAuth');
      final args = call.arguments as Map<Object?, Object?>;
      expect(args['redirectUrl'], 'https://idp.example/authorize?state=abc');
      expect(args['actionId'], 'action_2');
      expect(args['applicationId'], 'app-1');
      expect(args['flowId'], 'flow-1');
      expect(args['challengeToken'], 'challenge-1');
    });

    test('surfaces user cancellation as federatedAuthCancelled', () async {
      const config = ThunderIDConfig(baseUrl: 'https://localhost:8090', clientId: 'test');
      await client.initialize(config);
      expect(
        () => client.continueFederatedAuth(
          redirectUrl: 'https://cancel.example',
          actionId: 'action_2',
          applicationId: 'app-1',
        ),
        throwsA(isA<IAMException>().having((e) => e.code, 'code', ThunderIDErrorCode.federatedAuthCancelled)),
      );
    });
  });
}
