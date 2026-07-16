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

import 'outlined_trigger_button.dart';
import 'svg_icon_path.dart';

const Size _viewBox = Size(512, 512);

/// Facebook "f" glyph, ported from the SVG path data used by the web SDK's `FacebookButton`
/// icon adapter (viewBox 512 x 512).
class _FacebookGlyph extends StatelessWidget {
  const _FacebookGlyph();

  @override
  Widget build(BuildContext context) => const MultiColorSvgIcon(
        viewBox: _viewBox,
        size: 18,
        paths: [
          SvgPathSpec(
            pathData:
                'M448,0H64C28.704,0,0,28.704,0,64v384c0,35.296,28.704,64,64,64h384c35.296,0,64-28.704,64-64V64C512,28.704,483.296,0,448,0z',
            color: Color(0xFF1976D2),
          ),
          SvgPathSpec(
            pathData:
                'M432,256h-80v-64c0-17.664,14.336-16,32-16h32V96h-64l0,0c-53.024,0-96,42.976-96,96v64h-64v80h64v176h96V336h48L432,256z',
            color: Color(0xFFFAFAFA),
          ),
        ],
      );
}

/// "Continue with Facebook" federated sign-in trigger, styled to match the outlined action
/// buttons rendered below a SignIn form's "Or" divider.
class FacebookButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const FacebookButton({
    super.key,
    required this.onPressed,
    this.label = 'Continue with Facebook',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) => OutlinedTriggerButton(
        label: label,
        isLoading: isLoading,
        onPressed: onPressed,
        icon: const _FacebookGlyph(),
      );
}
