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

import 'avatar_logo.dart';
import 'logo_spec.dart';

/// Renders an application logo spec string — `emoji:<glyph>`,
/// `avatar:shape=...,variant=...,content=...,colors=...,bg=...`, or a bare URL — as the
/// appropriate widget.
///
/// This is the one-stop widget most callers want; use [resolveLogoSpec] directly if you need to
/// branch on the resolved kind yourself (e.g. to lay out an emoji glyph differently from an
/// image).
class ThunderIDLogo extends StatelessWidget {
  /// The stored logo spec string.
  final String spec;

  /// Seed text used to derive an `avatar:` spec's colors/content when the spec itself doesn't
  /// carry a `content` param (e.g. an app name, to keep the avatar in sync as it changes).
  final String fallbackSeedText;

  /// Side length of the rendered logo, in logical pixels.
  final double size;

  const ThunderIDLogo({
    super.key,
    required this.spec,
    this.fallbackSeedText = '',
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = resolveLogoSpec(spec, fallbackSeedText: fallbackSeedText);
    return switch (resolved) {
      EmojiLogo(glyph: final glyph) => Semantics(
          label: 'App logo',
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Text(glyph, style: TextStyle(fontSize: size * 0.75)),
            ),
          ),
        ),
      AvatarLogo() => AvatarLogoBadge.fromLogo(resolved, size: size),
      AssetLogo(assetPath: final assetPath) => Image.asset(
          assetPath,
          width: size,
          height: size,
          semanticLabel: 'App logo',
        ),
      UrlLogo(url: final url) => Image.network(
          url,
          width: size,
          height: size,
          semanticLabel: 'App logo',
          errorBuilder: (context, error, stackTrace) => SizedBox(
            width: size,
            height: size,
          ),
        ),
    };
  }
}
