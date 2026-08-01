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

/// Shared outlined-button chrome for `eventType: TRIGGER` (federated login) actions: an
/// optional icon slot, a label, and a rounded-rect stroke — matching the "Continue with X"
/// buttons rendered below a SignIn form's "Or" divider. Mirrors `TriggerButtonStyle` (iOS) /
/// `OutlinedTriggerButton` (Android).
class OutlinedTriggerButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  /// Disables the button without showing a spinner, e.g. while a sibling
  /// button's submission is in flight.
  final bool disabled;
  final VoidCallback onPressed;
  final Widget? icon;

  const OutlinedTriggerButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.disabled = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Semantics(
        label: label,
        button: true,
        child: SizedBox(
          height: 48,
          child: OutlinedButton(
            onPressed: (isLoading || disabled) ? null : onPressed,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.4),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size.fromHeight(44),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[icon!, const SizedBox(width: 10)],
                      Flexible(
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
