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

const Size _viewBox = Size(67.91, 67.901);

/// Multi-color Google "G" glyph, ported from the SVG path data used by the web SDK's
/// `GoogleButton` icon adapter (viewBox 67.91 x 67.901). Matches the iOS `GoogleGlyph`
/// (`GoogleButton.swift`) and Android `googleLogo()` (`GoogleButton.kt`) ports.
class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) => const MultiColorSvgIcon(
        viewBox: _viewBox,
        size: 18,
        paths: [
          SvgPathSpec(
            pathData:
                'M15.049,160.965l-2.364,8.824-8.639.183a34.011,34.011,0,0,1,-.25,-31.7h0l7.691,1.41,3.369,7.645a20.262,20.262,0,0,0,.19,13.642Z',
            color: Color(0xFFFBBB00),
            translate: Offset(0, -119.93),
          ),
          SvgPathSpec(
            pathData:
                'M294.24,208.176A33.939,33.939,0,0,1,282.137,241h0l-9.687,-.494,-1.371,-8.559a20.235,20.235,0,0,0,8.706,-10.333H261.628V208.176Z',
            color: Color(0xFF518EF8),
            translate: Offset(-226.93, -180.567),
          ),
          SvgPathSpec(
            pathData:
                'M81.668,328.8h0a33.962,33.962,0,0,1,-51.161,-10.387l11,-9.006a20.192,20.192,0,0,0,29.1,10.338Z',
            color: Color(0xFF28B446),
            translate: Offset(-26.463, -268.374),
          ),
          SvgPathSpec(
            pathData:
                'M80.451,7.816l-11,9A20.19,20.19,0,0,0,39.686,27.393l-11.06,-9.055h0A33.959,33.959,0,0,1,80.451,7.816Z',
            color: Color(0xFFF14336),
            translate: Offset(-24.828, 0),
          ),
        ],
      );
}

/// "Continue with Google" federated sign-in trigger, styled to match the outlined action
/// buttons rendered below a SignIn form's "Or" divider.
class GoogleButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool disabled;
  final VoidCallback onPressed;

  const GoogleButton({
    super.key,
    required this.onPressed,
    this.label = 'Continue with Google',
    this.isLoading = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) => OutlinedTriggerButton(
        label: label,
        isLoading: isLoading,
        disabled: disabled,
        onPressed: onPressed,
        icon: const _GoogleGlyph(),
      );
}
