import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

part 'users_roles_state.dart';

class UsersRolesCubit extends Cubit<UsersRolesState> {
  final FirebaseDatabase rtdb;
  final FirebaseFirestore fs;
  final FirebaseAuth auth;

  UsersRolesCubit({FirebaseDatabase? rtdb, FirebaseFirestore? fs, FirebaseAuth? auth})
      : rtdb = rtdb ?? FirebaseDatabase.instance,
        fs = fs ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance,
        super(const UsersRolesState.initial());

  Future<void> init() async {
    emit(state.copyWith(status: UsersRolesStatus.loading));
    final email = auth.currentUser?.email;
    final canList = await _can(['LIST_USER']);
    final canUpdate = await _can(['UPDATE_USER']);
    final canRemove = await _can(['REMOVE_USER']);
    final perms = Permissions(canList: canList, canUpdate: canUpdate, canRemove: canRemove);
    List<UserRow> users = [];
    if (perms.canList) {
      users = await _loadUsers();
    }
    final roles = await _loadAvailableRoles();
    emit(state.copyWith(
      status: UsersRolesStatus.ready,
      permissions: perms,
      allUsers: users,
      filtered: users,
      availableRoles: roles,
    ));
  }

  Future<bool> _can(List<String> roles) async {
    try {
      // Simple check against role_user using email
      final email = auth.currentUser?.email;
      if (email == null) return false;
      final doc = await fs.collection('role_user').doc(email).get();
      final data = doc.data() ?? {};
      final assigned = (data['roles'] as List?)?.whereType<String>().toSet() ?? <String>{};
      return roles.any(assigned.contains);
    } catch (_) {
      return false;
    }
  }

  Future<List<UserRow>> _loadUsers() async {
    try {
      final snap = await rtdb.ref('users').get();
      final List<UserRow> rows = [];
      if (snap.exists && snap.value is Map) {
        final map = Map<String, dynamic>.from(snap.value as Map);
        map.forEach((uid, data) {
          final m = Map<String, dynamic>.from(data as Map);
          final name = (m['firstName'] ?? '').toString();
          final email = (m['email'] ?? '').toString();
          rows.add(UserRow(uid: uid, name: name, email: email));
        });
      }
      rows.sort((a, b) => (a.name.isNotEmpty ? a.name : a.email).toLowerCase().compareTo((b.name.isNotEmpty ? b.name : b.email).toLowerCase()));
      return rows;
    } catch (_) {
      return [];
    }
  }

  Future<List<String>> _loadAvailableRoles() async {
    try {
      final snapshot = await fs.collection('roles').get();
      final roles = snapshot.docs.map((d) => d.id).toList()..sort();
      return roles;
    } catch (_) {
      return [];
    }
  }

  void applyFilter(String q) {
    final query = q.trim().toLowerCase();
    final filtered = query.isEmpty
        ? List<UserRow>.from(state.allUsers)
        : state.allUsers
            .where((u) => u.name.toLowerCase().contains(query) || u.email.toLowerCase().contains(query))
            .toList();
    emit(state.copyWith(filtered: filtered));
  }

  Future<void> refreshUsers() async {
    emit(state.copyWith(status: UsersRolesStatus.loading));
    final users = await _loadUsers();
    emit(state.copyWith(status: UsersRolesStatus.ready, allUsers: users, filtered: users));
  }

  Future<Set<String>> fetchUserRoles(String email) async {
    try {
      final doc = await fs.collection('role_user').doc(email).get();
      final data = doc.data() ?? {};
      return (data['roles'] as List?)?.whereType<String>().toSet() ?? <String>{};
    } catch (_) {
      return <String>{};
    }
  }

  void toggleExpanded(UserRow row) async {
    final expanded = !row.expanded;
    row = row.copyWith(expanded: expanded);
    // ensure row in filtered list is updated
    _updateRow(row);
    if (expanded && row.loadedRoles == null && row.email.isNotEmpty) {
      final roles = await fetchUserRoles(row.email);
      row = row.copyWith(loadedRoles: roles);
      _updateRow(row);
    }
  }

  void onRoleChanged(UserRow row, String role, bool selected) {
    final current = row.loadedRoles ?? <String>{};
    final newSet = {...current};
    if (selected) {
      newSet.add(role);
    } else {
      newSet.remove(role);
    }
    row = row.copyWith(loadedRoles: newSet);
    final pending = Map<String, Set<String>>.from(state.pendingRoles);
    pending[row.email] = newSet;
    emit(state.copyWith(pendingRoles: pending));
    _updateRow(row);
  }

  bool get hasPending => state.pendingRoles.isNotEmpty;

  Future<void> applyUpdates() async {
    if (!state.permissions.canUpdate || !hasPending) return;
    emit(state.copyWith(status: UsersRolesStatus.saving));
    try {
      final batch = fs.batch();
      state.pendingRoles.forEach((email, roles) {
        final ref = fs.collection('role_user').doc(email);
        batch.set(ref, {
          'user_email': email,
          'roles': roles.toList(),
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });
      await batch.commit();
      emit(state.copyWith(pendingRoles: {}));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Falha ao atualizar: $e'));
    } finally {
      emit(state.copyWith(status: UsersRolesStatus.ready));
    }
  }

  Future<void> removeUser(UserRow row) async {
    if (!state.permissions.canRemove) return;
    emit(state.copyWith(status: UsersRolesStatus.loading));
    try {
      await rtdb.ref('users/${row.uid}').remove();
      if (row.email.isNotEmpty) {
        await fs.collection('role_user').doc(row.email).delete();
      }
      final users = await _loadUsers();
      emit(state.copyWith(status: UsersRolesStatus.ready, allUsers: users, filtered: users));
    } catch (e) {
      emit(state.copyWith(status: UsersRolesStatus.ready, errorMessage: 'Falha ao remover: $e'));
    }
  }

  void _updateRow(UserRow row) {
    final update = (List<UserRow> list) {
      final idx = list.indexWhere((r) => r.uid == row.uid);
      if (idx != -1) list[idx] = row;
    };
    final all = List<UserRow>.from(state.allUsers);
    final filtered = List<UserRow>.from(state.filtered);
    update(all);
    update(filtered);
    emit(state.copyWith(allUsers: all, filtered: filtered));
  }
}
