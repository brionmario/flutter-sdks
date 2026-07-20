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

/// Keys of the curated "anonymous animal" badge icon set (lowercase), matching the
/// `avatar:...,variant=anonymous_animal,content=<key>` logo spec scheme supported by the web
/// SDK's logo picker.
const List<String> kAnonymousAnimalNames = <String>[
  'jackalope',
  'mink',
  'otter',
  'platypus',
  'quagga',
  'raccoon',
  'skunk',
  'chameleon',
  'dingo',
  'hedgehog',
  'dinosaur',
  'capybara',
  'chinchilla',
  'chipmunk',
  'chupacabra',
  'frog',
  'giraffe',
  'hippo',
  'jackal',
];

/// Resolves an `avatar:...,variant=anonymous_animal,content=<name>` spec's animal key to its
/// bundled asset path, or `null` when [name] isn't one of [kAnonymousAnimalNames] (case-sensitive
/// lowercase match — the wire `content` value is always lowercase already).
String? anonymousAnimalAssetPath(String name) =>
    kAnonymousAnimalNames.contains(name)
        ? 'packages/thunderid_flutter/assets/logo-icons/anonymous/$name.png'
        : null;

/// Keys of the curated "anonymous entity" badge icon set (lowercase) — applications,
/// organizations, and resource servers — matching the
/// `avatar:...,variant=anonymous_entity,content=<key>` logo spec scheme supported by the web
/// SDK's logo picker.
const List<String> kAnonymousEntityNames = <String>[
  'hexagon',
  'diamond',
  'cube',
  'pentagon',
  'triangle_stack',
  'chevron',
  'orbit_ring',
  'octagon',
  'star',
  'parallelogram',
  'plus_facet',
  'spiral',
  'townhouse',
  'tower',
  'dome',
  'gate',
  'pavilion',
  'spire',
  'bridge',
  'lighthouse',
  'windmill',
  'silo',
  'arch',
  'obelisk',
  'turbine',
  'anchor',
  'anvil',
  'compass',
  'key',
  'lock',
  'circuit_node',
  'antenna',
  'valve',
];

/// Resolves an `avatar:...,variant=anonymous_entity,content=<name>` spec's entity key to its
/// bundled asset path, or `null` when [name] isn't one of [kAnonymousEntityNames] (case-sensitive
/// lowercase match — the wire `content` value is always lowercase already).
String? anonymousEntityAssetPath(String name) =>
    kAnonymousEntityNames.contains(name)
        ? 'packages/thunderid_flutter/assets/logo-icons/entity/$name.png'
        : null;
