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
import 'package:url_launcher/url_launcher.dart';

import '../flow_template_resolver.dart';
import '../models/flow_models.dart';
import 'adapters/facebook_button.dart';
import 'adapters/github_button.dart';
import 'adapters/google_button.dart';
import 'adapters/linkedin_button.dart';
import 'adapters/microsoft_button.dart';
import 'adapters/outlined_trigger_button.dart';
import 'thunderid_provider.dart';

/// Internal widget used by [ThunderIDSignIn] and [ThunderIDSignUp] to render a
/// server-driven flow step. Supports `meta.components` layout when present,
/// with a plain `inputs`/`actions` fallback.
class FlowForm extends StatefulWidget {
  final String applicationId;
  final EmbeddedFlowResponse? currentStep;
  final bool isLoading;
  final String? error;
  final Future<void> Function(String actionId, Map<String, String> inputs)
      submit;
  final String submitLabel;

  const FlowForm({
    super.key,
    required this.applicationId,
    required this.currentStep,
    required this.isLoading,
    required this.error,
    required this.submit,
    this.submitLabel = 'Submit',
  });

  @override
  State<FlowForm> createState() => _FlowFormState();
}

class _FlowFormState extends State<FlowForm> {
  final _controllers = <String, TextEditingController>{};
  final _linkRecognizers = <TapGestureRecognizer>[];
  FlowTemplateResolver? _resolver;

  @override
  void initState() {
    super.initState();
    if (widget.applicationId.isNotEmpty) {
      Future.microtask(_fetchMeta);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      {
      c.dispose();
    }
    for (final r in _linkRecognizers) {
      r.dispose();
    }
    }
    super.dispose();
  }

  Future<void> _fetchMeta() async {
    try {
      final thunder = ThunderIDProvider.of(context);
      final meta = await thunder.client.getFlowMeta(widget.applicationId);
      if (mounted) setState(() => _resolver = FlowTemplateResolver(meta));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.currentStep == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final step = widget.currentStep;
    if (step != null &&
        (step.flowStatus == FlowStatus.complete ||
            (step.assertion?.isNotEmpty ?? false))) {
      return const Center(child: CircularProgressIndicator());
    }

    // _renderRichText appends a fresh TapGestureRecognizer per link on every build; dispose the
    // previous build's recognizers first so they don't accumulate across rebuilds.
    for (final r in _linkRecognizers) {
      r.dispose();
    }
    _linkRecognizers.clear();

    final data = step?.data;
    final rawMeta = data?['meta'];
    final components = rawMeta is Map
        ? _readList(rawMeta['components'])
        : const <Map<String, dynamic>>[];
    final inputs = _readList(data?['inputs']);
    final actions = _readList(data?['actions']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (components.isNotEmpty) ...[
          ...components.map((c) => _renderComponent(context, c, actions)),
          ..._missingInputWidgets(context, inputs, components),
          if (!_hasActionComponent(components) && actions.isNotEmpty)
            ...actions.map((a) => _renderAction(context, a, actions)),
        ] else ...[
          ...inputs.map(
            (i) => _renderField(
              context,
              {'ref': _inputRef(i), 'label': '', 'type': i['type']},
              _str(i['type']),
            ),
          ),
          if (actions.isNotEmpty)
            ...actions.map((a) => _renderAction(context, a, actions))
          else
            _renderAction(
              context,
              {'label': widget.submitLabel, 'id': 'init'},
              const [],
            ),
        ],
        if (widget.error != null) ...[
          const SizedBox(height: 12),
          Text(
            widget.error!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _missingInputWidgets(
    BuildContext context,
    List<Map<String, dynamic>> inputs,
    List<Map<String, dynamic>> components,
  ) {
    final fieldRefs = _componentFieldRefs(components);
    return inputs.where((i) {
      final ref = _inputRef(i);
      return ref.isNotEmpty && !fieldRefs.contains(ref);
    }).map((i) {
      final ref = _inputRef(i);
      return _renderField(
        context,
        {'ref': ref, 'label': _capitalize(ref), 'type': i['type']},
        _str(i['type']),
      );
    }).toList();
  }

  String _effectiveCategory(Map<String, dynamic> comp) {
    final category = _str(comp['category']);
    if (category.isNotEmpty) return category;
    switch (_str(comp['type'])) {
      case 'DIVIDER':
        return 'DIVIDER';
      case 'RICH_TEXT':
        return 'RICH_TEXT';
      case 'TEXT':
      case 'IMAGE':
        return 'DISPLAY';
      case 'BLOCK':
        return 'BLOCK';
      case 'TEXT_INPUT':
      case 'PASSWORD_INPUT':
      case 'EMAIL_INPUT':
      case 'NUMBER_INPUT':
        return 'FIELD';
      case 'ACTION':
        return 'ACTION';
      default:
        return '';
    }
  }

  Widget _renderComponent(
    BuildContext context,
    Map<String, dynamic> comp,
    List<Map<String, dynamic>> actions,
  ) {
    switch (_effectiveCategory(comp)) {
      case 'DISPLAY':
        return _renderDisplay(context, comp);
      case 'DIVIDER':
        return _renderDivider(context, comp);
      case 'RICH_TEXT':
        return _renderRichText(context, comp);
      case 'BLOCK':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: _readList(comp['components'])
              .map((c) => _renderComponent(context, c, actions))
              .toList(),
        );
      case 'FIELD':
        return _renderField(context, comp, _str(comp['type']));
      case 'ACTION':
        final nested = _readList(comp['components']);
        if (nested.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children:
                nested.map((c) => _renderComponent(context, c, actions)).toList(),
          );
        }
        return _renderAction(context, comp, actions);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _renderDisplay(BuildContext context, Map<String, dynamic> comp) {
    final type = _str(comp['type']);
    // The real backend sends an explicit `category: "DISPLAY"` on DIVIDER
    // and RICH_TEXT components too, so `_effectiveCategory` short-circuits
    // to 'DISPLAY' before ever consulting `type`. Dispatch on `type` here
    // so those components still render correctly instead of being dropped.
    if (type == 'DIVIDER') {
      return _renderDivider(context, comp);
    }
    if (type == 'RICH_TEXT') {
      return _renderRichText(context, comp);
    }
    if (type == 'TEXT') {
      final label = _resolve(comp['label']);
      if (label.isEmpty) return const SizedBox.shrink();
      final style = _str(comp['variant']) == 'HEADING_1'
          ? Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold)
          : Theme.of(context).textTheme.bodyMedium;
      final align =
          _str(comp['align']) == 'center' ? TextAlign.center : TextAlign.start;
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(label, style: style, textAlign: align),
      );
    }
    if (type == 'IMAGE') {
      final src = _str(comp['src']);
      if (src.isEmpty || src.startsWith('{{')) return const SizedBox.shrink();
      final h = double.tryParse(_str(comp['height']));
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Image.network(src, height: h),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _renderDivider(BuildContext context, Map<String, dynamic> comp) {
    final label = _resolve(comp['label'], fallback: 'Or');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _renderRichText(BuildContext context, Map<String, dynamic> comp) {
    final html = _resolve(comp['label']);
    if (html.isEmpty) return const SizedBox.shrink();

    final linkPattern = RegExp(
      r'<a[^>]*href="([^"]*)"[^>]*>(.*?)</a>',
      dotAll: true,
    );
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in linkPattern.allMatches(html)) {
      if (match.start > cursor) {
        final plain = _stripTags(html.substring(cursor, match.start));
        if (plain.trim().isNotEmpty) spans.add(TextSpan(text: plain));
      }
      final href = match.group(1) ?? '';
      final linkText = _stripTags(match.group(2) ?? '').trim();
      final recognizer = TapGestureRecognizer()..onTap = () => _openLink(href);
      _linkRecognizers.add(recognizer);
      spans.add(
        TextSpan(
          text: linkText,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
          recognizer: recognizer,
        ),
      );
      cursor = match.end;
    }
    if (cursor < html.length) {
      final plain = _stripTags(html.substring(cursor));
      if (plain.trim().isNotEmpty) spans.add(TextSpan(text: plain));
    }
    if (spans.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text.rich(
        TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: spans,
        ),
      ),
    );
  }

  String _stripTags(String value) => value.replaceAll(RegExp(r'<[^>]+>'), '');

  Future<void> _openLink(String url) async {
    if (url.isEmpty || url.startsWith('{{')) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (uri.scheme.toLowerCase() != 'http' && uri.scheme.toLowerCase() != 'https') {
      return;
    }
    await launchUrl(uri);
  }

  Widget _renderField(
    BuildContext context,
    Map<String, dynamic> comp,
    String type,
  ) {
    final ref = _fieldRef(comp);
    if (ref.isEmpty) return const SizedBox.shrink();
    _controllers.putIfAbsent(ref, TextEditingController.new);
    final isPassword = type.toLowerCase().contains('password');
    final label = _resolve(comp['label'], fallback: _capitalize(ref));
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        key: Key('thunderid-field-$ref'),
        controller: _controllers[ref],
        decoration: InputDecoration(
          labelText: label,
          hintText: _resolve(comp['placeholder'], fallback: _capitalize(ref)),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: const OutlineInputBorder(),
        ),
        obscureText: isPassword,
        keyboardType: isPassword
            ? TextInputType.visiblePassword
            : TextInputType.emailAddress,
        autocorrect: false,
      ),
    );
  }

  Widget _renderAction(
    BuildContext context,
    Map<String, dynamic> comp,
    List<Map<String, dynamic>> actions,
  ) {
    final label = _resolve(comp['label'], fallback: widget.submitLabel);
    final metaActionId = _str(comp['ref'], fallback: _str(comp['id']));
    final actionId = _findActionId(metaActionId, actions);
    final eventType = _str(
      comp['eventType'],
      fallback: _str(_actionForId(metaActionId, actions)?['eventType']),
    );

    if (eventType.toUpperCase() == 'TRIGGER') {
      void onPressed() => widget.submit(
            actionId,
            _controllers.map((k, v) => MapEntry(k, v.text)),
          );
      final hint =
          '$metaActionId $label ${_str(comp['icon'])}'.toLowerCase();
      if (hint.contains('google')) {
        return GoogleButton(
          label: label,
          isLoading: widget.isLoading,
          onPressed: onPressed,
        );
      }
      if (hint.contains('github')) {
        return GitHubButton(
          label: label,
          isLoading: widget.isLoading,
          onPressed: onPressed,
        );
      }
      if (hint.contains('facebook')) {
        return FacebookButton(
          label: label,
          isLoading: widget.isLoading,
          onPressed: onPressed,
        );
      }
      if (hint.contains('microsoft')) {
        return MicrosoftButton(
          label: label,
          isLoading: widget.isLoading,
          onPressed: onPressed,
        );
      }
      if (hint.contains('linkedin')) {
        return LinkedInButton(
          label: label,
          isLoading: widget.isLoading,
          onPressed: onPressed,
        );
      }
      return OutlinedTriggerButton(
        label: label,
        isLoading: widget.isLoading,
        onPressed: onPressed,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: FilledButton(
        key: Key('thunderid-action-$actionId'),
        onPressed: widget.isLoading
            ? null
            : () => widget.submit(
                  actionId,
                  _controllers.map((k, v) => MapEntry(k, v.text)),
                ),
        child: widget.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }

  Map<String, dynamic>? _actionForId(
    String metaActionId,
    List<Map<String, dynamic>> actions,
  ) {
    for (final a in actions) {
      if (_str(a['ref']) == metaActionId || _str(a['id']) == metaActionId) {
        return a;
      }
    }
    return null;
  }

  String _findActionId(
    String metaActionId,
    List<Map<String, dynamic>> actions,
  ) {
    if (actions.isEmpty) return 'submit';
    final byRef = actions.firstWhere(
      (a) => _str(a['ref']) == metaActionId,
      orElse: () => const {},
    );
    if (byRef.isNotEmpty) return _actionSubmitId(byRef);
    final byId = actions.firstWhere(
      (a) => _str(a['id']) == metaActionId,
      orElse: () => const {},
    );
    if (byId.isNotEmpty) return _actionSubmitId(byId);
    final idx = _actionIndex(metaActionId);
    if (idx != null && idx >= 0 && idx < actions.length) {
      return _actionSubmitId(actions[idx]);
    }
    return _actionSubmitId(actions.first);
  }

  String _actionSubmitId(Map<String, dynamic> a) => _str(
        a['ref'],
        fallback: _str(
          a['id'],
          fallback: _str(a['nextNode'], fallback: 'submit'),
        ),
      );

  int? _actionIndex(String id) {
    if (!id.startsWith('action_')) return null;
    final parsed = int.tryParse(id.substring('action_'.length));
    return (parsed != null && parsed > 0) ? parsed - 1 : null;
  }

  Set<String> _componentFieldRefs(List<Map<String, dynamic>> comps) {
    final refs = <String>{};
    void walk(List<Map<String, dynamic>> list) {
      for (final c in list) {
        if (_effectiveCategory(c) == 'FIELD') {
          final ref = _fieldRef(c);
          if (ref.isNotEmpty) refs.add(ref);
        }
        walk(_readList(c['components']));
      }
    }

    walk(comps);
    return refs;
  }

  bool _hasActionComponent(List<Map<String, dynamic>> comps) {
    bool found = false;
    void walk(List<Map<String, dynamic>> list) {
      for (final c in list) {
        if (_effectiveCategory(c) == 'ACTION') {
          found = true;
          return;
        }
        walk(_readList(c['components']));
        if (found) return;
      }
    }

    walk(comps);
    return found;
  }

  List<Map<String, dynamic>> _readList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((m) => m.map((k, v) => MapEntry('$k', v)))
        .toList();
  }

  String _str(dynamic v, {String fallback = ''}) =>
      (v is String && v.isNotEmpty) ? v : fallback;

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _fieldRef(Map<String, dynamic> comp) => _str(
        comp['ref'],
        fallback: _str(
          comp['identifier'],
          fallback: _str(comp['name'], fallback: _str(comp['id'])),
        ),
      );

  String _inputRef(Map<String, dynamic> input) => _str(
        input['name'],
        fallback: _str(
          input['identifier'],
          fallback: _str(input['ref'], fallback: _str(input['id'])),
        ),
      );

  String _resolve(dynamic value, {String fallback = ''}) {
    final s = value is String ? value.trim() : '';
    if (s.isEmpty) return fallback;
    final resolved = _resolver?.resolve(s) ?? s;
    return resolved.isEmpty ? fallback : resolved;
  }
}
