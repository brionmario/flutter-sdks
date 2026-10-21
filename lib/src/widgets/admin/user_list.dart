// Copyright 2026 The ThunderID Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/widgets.dart';

import '../../management/management_display.dart';
import '../../models/management/managed_user.dart';
import '../../models/management/management_page.dart';
import '../../models/preferences.dart';
import '../../state/management_resources.dart';
import '../../state/resource_notifiers.dart';
import 'internal/admin_connected.dart';
import 'internal/admin_context.dart';
import 'internal/admin_parts.dart';

/// Presentational user list: renders [users] and reports selection and paging. Supply the
/// data yourself, or use [UserList] to have it fetched.
///
/// Renders no navigation; [onSelect] hands the chosen user to the application, which decides
/// where to go (spec "UI", requirement 6).
class BaseUserList extends StatelessWidget {
  final List<ManagedUser> users;
  final bool isLoading;

  /// An already-translated error message. Never pass the server's text here.
  final String? error;
  final int limit;
  final int offset;
  final int? totalResults;
  final ValueChanged<int>? onPageChange;
  final ValueChanged<ManagedUser>? onSelect;
  final String? selectedUserId;
  final String? title;
  final String? description;
  final List<Widget> actions;
  final ThunderIDPreferences? preferences;

  const BaseUserList({
    super.key,
    required this.users,
    this.isLoading = false,
    this.error,
    this.limit = 20,
    this.offset = 0,
    this.totalResults,
    this.onPageChange,
    this.onSelect,
    this.selectedUserId,
    this.title,
    this.description,
    this.actions = const [],
    this.preferences,
  });

  @override
  Widget build(BuildContext context) {
    final ac = AdminContext.of(context, preferences);
    String name(ManagedUser user) =>
        resolveManagedIdentityName(id: user.id, display: user.display, attributes: user.attributes);
    return AdminSection(
      ac: ac,
      block: 'user-list',
      title: title ?? ac.t('admin.users.list.title'),
      description: description,
      actions: actions,
      children: [
        AdminTable<ManagedUser>(
          ac: ac,
          block: 'user-list',
          rows: users,
          rowId: (user) => user.id,
          isLoading: isLoading,
          error: error,
          emptyText: ac.t('admin.users.list.empty'),
          onRowTap: onSelect,
          selectedRowId: selectedUserId,
          paging: onPageChange == null
              ? null
              : AdminPaging(
                  limit: limit,
                  offset: offset,
                  total: totalResults ?? users.length,
                  onChange: onPageChange!,
                ),
          columns: [
            AdminColumn(
              header: ac.t('admin.users.list.columns.name'),
              build: (user) => Row(
                children: [
                  AdminAvatar(name: name(user)),
                  const SizedBox(width: 10),
                  Flexible(child: Text(name(user), overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
            AdminColumn(header: ac.t('admin.users.list.columns.type'), build: (user) => Text(user.type)),
            AdminColumn(
              header: ac.t('admin.common.columns.organization_unit'),
              build: (user) => Text(user.ouHandle ?? user.ouId),
            ),
          ],
        ),
      ],
    );
  }
}

/// User list that fetches its own pages through the management API.
class UserList extends StatefulWidget {
  /// A server-side filter expression, passed through as `filter`.
  final String? filter;
  final int limit;
  final ValueChanged<ManagedUser>? onSelect;
  final String? selectedUserId;
  final String? title;
  final String? description;
  final List<Widget> actions;
  final ThunderIDPreferences? preferences;

  const UserList({
    super.key,
    this.filter,
    this.limit = 20,
    this.onSelect,
    this.selectedUserId,
    this.title,
    this.description,
    this.actions = const [],
    this.preferences,
  });

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends AdminConnectedState<UserList> {
  int _offset = 0;
  ResourceQuery<ManagementPage<ManagedUser>>? _users;

  @override
  void bind(ManagementResources resources) {
    _users = own(resources.usersQuery(filter: widget.filter, limit: widget.limit, offset: _offset));
  }

  @override
  void didUpdateWidget(UserList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter || oldWidget.limit != widget.limit) {
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
    final query = _users;
    return BaseUserList(
      users: query?.data?.items ?? const [],
      totalResults: query?.data?.totalResults,
      isLoading: query?.isLoading ?? !providerFailed,
      error: providerFailed
          ? ac.t('admin.users.list.error')
          : toManagementErrorMessage(ac.t, query?.error, 'admin.users.list.error'),
      limit: widget.limit,
      offset: _offset,
      onPageChange: _changePage,
      onSelect: widget.onSelect,
      selectedUserId: widget.selectedUserId,
      title: widget.title,
      description: widget.description,
      actions: widget.actions,
      preferences: widget.preferences,
    );
  }
}
