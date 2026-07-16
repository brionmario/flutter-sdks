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

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunderid_flutter/src/models/flow_models.dart';
import 'package:thunderid_flutter/src/models/thunderid_config.dart';
import 'package:thunderid_flutter/src/widgets/adapters/github_button.dart';
import 'package:thunderid_flutter/src/widgets/adapters/google_button.dart';
import 'package:thunderid_flutter/src/widgets/flow_form.dart';
import 'package:thunderid_flutter/src/widgets/thunderid_provider.dart';

const _config =
    ThunderIDConfig(baseUrl: 'https://localhost:8090', clientId: 'test');
const _sdkChannel = MethodChannel('dev.thunderid/sdk');

final Map<String, dynamic> _flowMeta = <String, dynamic>{
  'i18n': <String, dynamic>{
    'translations': <String, dynamic>{
      'signin': <String, dynamic>{
        'forms.credentials.fields.username.label': 'Username',
        'forms.credentials.fields.username.placeholder': 'Enter your username',
        'forms.credentials.fields.password.label': 'Password',
        'forms.credentials.fields.password.placeholder': 'Enter your password',
        'forms.credentials.links.forgot_password.prefix': '',
        'forms.credentials.links.forgot_password.label': 'Forgot password?',
        'forms.credentials.links.sign_up.prefix': "Don't have an account?",
        'forms.credentials.links.sign_up.label': 'Sign up',
      },
    },
  },
  'application': <String, dynamic>{
    'forgot_password_url': 'https://example.com/forgot-password',
    'sign_up_url': 'https://example.com/sign-up',
  },
};

final Map<String, dynamic> _stepData = <String, dynamic>{
  'inputs': [
    {
      'ref': 'input_001',
      'identifier': 'username',
      'type': 'TEXT_INPUT',
      'required': true,
    },
    {
      'ref': 'input_002',
      'identifier': 'password',
      'type': 'PASSWORD_INPUT',
      'required': true,
    },
  ],
  'actions': [
    {'ref': 'action_001', 'nextNode': 'credentials_auth'},
    {'ref': 'action_xoc0', 'nextNode': 'ID_0e5o'},
    {'ref': 'action_zeye', 'nextNode': 'ID_dbxc'},
  ],
  'meta': <String, dynamic>{
    'components': [
      {
        'align': 'center',
        'category': 'DISPLAY',
        'id': 'text_001',
        'label': 'Login',
        'resourceType': 'ELEMENT',
        'type': 'TEXT',
        'variant': 'HEADING_1',
      },
      {
        'category': 'BLOCK',
        'components': [
          {
            'category': 'FIELD',
            'hint': '',
            'id': 'input_001',
            'inputType': 'text',
            'label': '{{ t(signin:forms.credentials.fields.username.label) }}',
            'placeholder':
                '{{ t(signin:forms.credentials.fields.username.placeholder) }}',
            'ref': 'username',
            'required': true,
            'resourceType': 'ELEMENT',
            'type': 'TEXT_INPUT',
          },
          {
            'category': 'FIELD',
            'hint': '',
            'id': 'input_002',
            'inputType': 'text',
            'label': '{{ t(signin:forms.credentials.fields.password.label) }}',
            'placeholder':
                '{{ t(signin:forms.credentials.fields.password.placeholder) }}',
            'ref': 'password',
            'required': true,
            'resourceType': 'ELEMENT',
            'type': 'PASSWORD_INPUT',
          },
          {
            'category': 'DISPLAY',
            'id': 'rich_text_forgot_password',
            'label':
                '<p class="rich-text-paragraph"><span class="rich-text-pre-wrap">{{ t(signin:forms.credentials.links.forgot_password.prefix) }} </span><a href="{{meta(application.forgot_password_url)}}" target="_blank" rel="noopener noreferrer" class="rich-text-link"><span class="rich-text-pre-wrap">{{ t(signin:forms.credentials.links.forgot_password.label) }}</span></a></p>',
            'resourceType': 'ELEMENT',
            'type': 'RICH_TEXT',
          },
          {
            'category': 'ACTION',
            'eventType': 'SUBMIT',
            'id': 'action_001',
            'label': '{{ t(signin:forms.credentials.actions.submit.label) }}',
            'resourceType': 'ELEMENT',
            'type': 'ACTION',
            'variant': 'PRIMARY',
          },
          {
            'category': 'DISPLAY',
            'id': 'rich_text_signup',
            'label':
                '<p class="rich-text-paragraph"><span class="rich-text-pre-wrap">{{ t(signin:forms.credentials.links.sign_up.prefix) }} </span><a href="{{meta(application.sign_up_url)}}" target="_blank" rel="noopener noreferrer" class="rich-text-link"><span class="rich-text-pre-wrap">{{ t(signin:forms.credentials.links.sign_up.label) }}</span></a></p>',
            'resourceType': 'ELEMENT',
            'type': 'RICH_TEXT',
          },
        ],
        'id': 'block_001',
        'resourceType': 'ELEMENT',
        'type': 'BLOCK',
      },
      {
        'category': 'DISPLAY',
        'id': 'display_tfae',
        'label': 'Or',
        'resourceType': 'ELEMENT',
        'type': 'DIVIDER',
        'variant': 'HORIZONTAL',
      },
      {
        'category': 'ACTION',
        'components': [
          {
            'category': 'ACTION',
            'eventType': 'TRIGGER',
            'id': 'action_xoc0',
            'image': 'assets/images/icons/google.svg',
            'label': 'Continue with Google',
            'resourceType': 'ELEMENT',
            'type': 'ACTION',
            'variant': 'OUTLINED',
          },
        ],
        'eventType': 'TRIGGER',
        'id': 'block_per3',
        'resourceType': 'ELEMENT',
        'type': 'BLOCK',
      },
      {
        'category': 'ACTION',
        'components': [
          {
            'category': 'ACTION',
            'eventType': 'TRIGGER',
            'id': 'action_zeye',
            'image': 'assets/images/icons/github.svg',
            'label': 'Continue with GitHub',
            'resourceType': 'ELEMENT',
            'type': 'ACTION',
            'variant': 'OUTLINED',
          },
        ],
        'eventType': 'TRIGGER',
        'id': 'block_dzuu',
        'resourceType': 'ELEMENT',
        'type': 'BLOCK',
      },
    ],
  },
};

final _step = EmbeddedFlowResponse(
  flowStatus: FlowStatus.promptOnly,
  data: _stepData,
  challengeToken:
      'efb3706d1a8db1a291da65cd49e213af6e63fe6379006dfbd96d545d3a920119',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_sdkChannel, null);
  });

  Widget buildForm() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_sdkChannel, (call) async {
      switch (call.method) {
        case 'initialize':
          return true;
        case 'isSignedIn':
          return false;
        case 'getFlowMeta':
          return _flowMeta;
        default:
          return null;
      }
    });

    return MaterialApp(
      home: Scaffold(
        body: ThunderIDProvider(
          config: _config,
          child: FlowForm(
            applicationId: 'app-1',
            currentStep: _step,
            isLoading: false,
            error: null,
            submit: (actionId, inputs) async {},
          ),
        ),
      ),
    );
  }

  group('FlowForm meta.components rendering', () {
    testWidgets('renders a Divider for DIVIDER components', (tester) async {
      await tester.pumpWidget(buildForm());
      await tester.pumpAndSettle();

      expect(find.byType(Divider), findsWidgets);
    });

    testWidgets('renders tappable rich-text links for RICH_TEXT components',
        (tester) async {
      await tester.pumpWidget(buildForm());
      await tester.pumpAndSettle();

      final richTextFinder = find.byWidgetPredicate((widget) {
        if (widget is! Text) return false;
        final span = widget.textSpan;
        if (span == null) return false;
        var hasLink = false;
        span.visitChildren((child) {
          if (child is TextSpan && child.recognizer is TapGestureRecognizer) {
            hasLink = true;
          }
          return true;
        });
        return hasLink;
      });
      expect(richTextFinder, findsWidgets);
    });

    testWidgets('resolves the field placeholder instead of the capitalized ref',
        (tester) async {
      await tester.pumpWidget(buildForm());
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(find.byType(TextField).first);
      final hintText = field.decoration?.hintText;
      expect(hintText, isNotNull);
      expect(hintText, isNot(contains('{{')));
      expect(hintText, 'Enter your username');
    });

    testWidgets(
        'renders branded buttons for ACTION components nested inside a '
        'category:ACTION wrapper block', (tester) async {
      await tester.pumpWidget(buildForm());
      await tester.pumpAndSettle();

      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with GitHub'), findsOneWidget);
      expect(find.byType(GoogleButton), findsOneWidget);
      expect(find.byType(GitHubButton), findsOneWidget);
    });
  });
}
