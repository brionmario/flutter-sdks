// Copyright 2026 The ThunderID Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/widgets.dart';

import '../../management/management_display.dart';
import '../../models/management/agent.dart';
import '../../models/management/management_page.dart';
import '../../models/preferences.dart';
import '../../state/management_resources.dart';
import '../../state/resource_notifiers.dart';
import 'internal/admin_connected.dart';
import 'internal/admin_context.dart';
import 'internal/admin_parts.dart';

/// Presentational agent list: renders [agents] and reports selection and paging.
class BaseAgentList extends StatelessWidget {
  final List<Agent> agents;
  final bool isLoading;

  /// An already-translated error message. Never pass the server's text here.
  final String? error;
  final int limit;
  final int offset;
  final int? totalResults;
  final ValueChanged<int>? onPageChange;
  final ValueChanged<Agent>? onSelect;
  final String? selectedAgentId;
  final String? title;
  final String? description;
  final List<Widget> actions;
  final ThunderIDPreferences? preferences;

  const BaseAgentList({
    super.key,
    required this.agents,
    this.isLoading = false,
    this.error,
    this.limit = 20,
    this.offset = 0,
    this.totalResults,
    this.onPageChange,
    this.onSelect,
    this.selectedAgentId,
    this.title,
    this.description,
    this.actions = const [],
    this.preferences,
  });

  @override
  Widget build(BuildContext context) {
    final ac = AdminContext.of(context, preferences);
    return AdminSection(
      ac: ac,
      block: 'agent-list',
      title: title ?? ac.t('admin.agents.list.title'),
      description: description,
      actions: actions,
      children: [
        AdminTable<Agent>(
          ac: ac,
          block: 'agent-list',
          rows: agents,
          rowId: (agent) => agent.id,
          isLoading: isLoading,
          error: error,
          emptyText: ac.t('admin.agents.list.empty'),
          onRowTap: onSelect,
          selectedRowId: selectedAgentId,
          paging: onPageChange == null
              ? null
              : AdminPaging(
                  limit: limit,
                  offset: offset,
                  total: totalResults ?? agents.length,
                  onChange: onPageChange!,
                ),
          columns: [
            AdminColumn(header: ac.t('admin.agents.list.columns.name'), build: (agent) => Text(agent.name)),
            AdminColumn(header: ac.t('admin.agents.list.columns.type'), build: (agent) => Text(agent.type)),
            AdminColumn(
              header: ac.t('admin.agents.list.columns.client_id'),
              build: (agent) => Text(agent.clientId ?? '', style: const TextStyle(fontFamily: 'monospace')),
            ),
            AdminColumn(
              header: ac.t('admin.common.columns.organization_unit'),
              build: (agent) => Text(agent.ouHandle ?? agent.ouId),
            ),
          ],
        ),
      ],
    );
  }
}

/// Agent list that fetches its own pages through the management API.
class AgentList extends StatefulWidget {
  final int limit;
  final ValueChanged<Agent>? onSelect;
  final String? selectedAgentId;
  final String? title;
  final String? description;
  final List<Widget> actions;
  final ThunderIDPreferences? preferences;

  const AgentList({
    super.key,
    this.limit = 20,
    this.onSelect,
    this.selectedAgentId,
    this.title,
    this.description,
    this.actions = const [],
    this.preferences,
  });

  @override
  State<AgentList> createState() => _AgentListState();
}

class _AgentListState extends AdminConnectedState<AgentList> {
  int _offset = 0;
  ResourceQuery<ManagementPage<Agent>>? _agents;

  @override
  void bind(ManagementResources resources) {
    _agents = own(resources.agentsQuery(limit: widget.limit, offset: _offset));
  }

  @override
  void didUpdateWidget(AgentList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.limit != widget.limit) {
      _offset = 0;
      rebind();
    }
  }

  void _changePage(int offset) {
    setState(() => _offset = offset);
    rebind();
  }

  @override
  Widget build(BuildContext context) {
    final ac = AdminContext.of(context, widget.preferences);
    final query = _agents;
    return BaseAgentList(
      agents: query?.data?.items ?? const [],
      totalResults: query?.data?.totalResults,
      isLoading: query?.isLoading ?? !providerFailed,
      error: providerFailed
          ? ac.t('admin.agents.list.error')
          : toManagementErrorMessage(ac.t, query?.error, 'admin.agents.list.error'),
      limit: widget.limit,
      offset: _offset,
      onPageChange: _changePage,
      onSelect: widget.onSelect,
      selectedAgentId: widget.selectedAgentId,
      title: widget.title,
      description: widget.description,
      actions: widget.actions,
      preferences: widget.preferences,
    );
  }
}
