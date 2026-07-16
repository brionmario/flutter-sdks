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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thunderid_flutter/src/widgets/adapters/github_button.dart';
import 'package:thunderid_flutter/src/widgets/adapters/google_button.dart';
import 'package:thunderid_flutter/src/widgets/adapters/outlined_trigger_button.dart';

void main() {
  testWidgets('GoogleButton renders its brand glyph and label without throwing',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GoogleButton(onPressed: () => tapped = true),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Continue with Google'), findsOneWidget);

    await tester.tap(find.byType(OutlinedButton));
    expect(tapped, true);
  });

  testWidgets('GitHubButton renders its brand glyph and label without throwing',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GitHubButton(onPressed: () {}),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Continue with GitHub'), findsOneWidget);
  });

  testWidgets(
      'OutlinedTriggerButton falls back to the schema label when loading',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OutlinedTriggerButton(
            label: 'Continue with Acme',
            isLoading: true,
            onPressed: () {},
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    expect(button.onPressed, isNull);
  });
}
