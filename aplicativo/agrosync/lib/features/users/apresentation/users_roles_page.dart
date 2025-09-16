import 'package:agrosync/core/services/translation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/users_roles_cubit.dart';

class UsersRolesPage extends StatefulWidget {
  const UsersRolesPage({super.key});

  @override
  State<UsersRolesPage> createState() => _UsersRolesPageState();
}

class _UsersRolesPageState extends State<UsersRolesPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<UsersRolesCubit>(
      create: (_) => UsersRolesCubit()..init(),
      child: const _UsersRolesView(),
    );
  }
}

class _UsersRolesView extends StatefulWidget {
  const _UsersRolesView();
  @override
  State<_UsersRolesView> createState() => _UsersRolesViewState();
}

class _UsersRolesViewState extends State<_UsersRolesView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<UsersRolesCubit>().applyFilter(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B8B3B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B8B3B),
        title: const Text('Usuários e Permissões', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          BlocBuilder<UsersRolesCubit, UsersRolesState>(
            buildWhen: (a, b) => a.permissions != b.permissions || a.status != b.status,
            builder: (context, state) {
              final enabled = state.permissions.canList && state.status != UsersRolesStatus.loading;
              return IconButton(
                onPressed: enabled ? context.read<UsersRolesCubit>().refreshUsers : null,
                icon: const Icon(Icons.refresh),
                color: Colors.white,
                tooltip: 'Atualizar',
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: BlocBuilder<UsersRolesCubit, UsersRolesState>(
            buildWhen: (a, b) => a.pendingRoles != b.pendingRoles || a.permissions != b.permissions || a.status != b.status,
            builder: (context, state) {
              final hasPending = state.pendingRoles.isNotEmpty;
              final canSave = state.permissions.canUpdate && hasPending && state.status != UsersRolesStatus.saving;
              return ElevatedButton.icon(
                onPressed: canSave ? context.read<UsersRolesCubit>().applyUpdates : null,
                icon: const Icon(Icons.save),
                label: Text(TranslationService.t('APPLY')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              );
            },
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Filtrar por nome ou email',
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                ),
              ),
            ),
            BlocConsumer<UsersRolesCubit, UsersRolesState>(
              listenWhen: (a, b) => a.errorMessage != b.errorMessage,
              listener: (context, state) {
                if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage!)),
                  );
                }
              },
              builder: (context, state) {
                if (state.status == UsersRolesStatus.loading || state.status == UsersRolesStatus.initial) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                return Expanded(
                  child: state.filtered.isEmpty
                      ? const Center(
                          child: Text('Nenhum usuário encontrado', style: TextStyle(color: Colors.white)),
                        )
                      : ListView.separated(
                          itemCount: state.filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white24),
                          itemBuilder: (context, index) {
                            final row = state.filtered[index];
                            return _userTile(context, row, state);
                          },
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _userTile(BuildContext context, UserRow row, UsersRolesState state) {
    final title = row.name.isNotEmpty ? row.name : row.email;
    final permissions = state.permissions;

    return ExpansionTile(
      key: ValueKey('user_${row.uid}'),
      initiallyExpanded: row.expanded,
      onExpansionChanged: (_) => context.read<UsersRolesCubit>().toggleExpanded(row),
      iconColor: Colors.white,
      collapsedIconColor: Colors.white,
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                if (row.email.isNotEmpty)
                  const SizedBox(height: 2),
                if (row.email.isNotEmpty)
                  Text(row.email, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          if (permissions.canRemove)
            IconButton(
              onPressed: () => _confirmDelete(context, row),
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              tooltip: 'Remover',
            ),
        ],
      ),
      children: [
        if (row.loadedRoles == null)
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Carregando funções...', style: TextStyle(color: Colors.white70)),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: state.availableRoles.map((roleId) {
                final checked = row.loadedRoles!.contains(roleId);
                return CheckboxListTile(
                  value: checked,
                  title: Text(TranslationService.roleLabel(roleId), style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    TranslationService.roleDescription(roleId),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: permissions.canUpdate
                      ? (val) => context.read<UsersRolesCubit>().onRoleChanged(row, roleId, val ?? false)
                      : null,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, UserRow row) async {
    final cubit = context.read<UsersRolesCubit>();
    if (!cubit.state.permissions.canRemove) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover usuário'),
        content: Text('Tem certeza que deseja remover ${row.name.isNotEmpty ? row.name : row.email}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remover')),
        ],
      ),
    );
    if (ok == true) {
      await cubit.removeUser(row);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário removido.')),
        );
      }
    }
  }
}
