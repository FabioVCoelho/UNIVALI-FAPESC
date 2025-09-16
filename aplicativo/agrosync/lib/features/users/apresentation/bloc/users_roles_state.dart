part of 'users_roles_cubit.dart';

enum UsersRolesStatus { initial, loading, ready, saving }

class UsersRolesState extends Equatable {
  final UsersRolesStatus status;
  final Permissions permissions;
  final List<UserRow> allUsers;
  final List<UserRow> filtered;
  final List<String> availableRoles;
  final Map<String, Set<String>> pendingRoles;
  final String? errorMessage;

  const UsersRolesState({
    required this.status,
    required this.permissions,
    required this.allUsers,
    required this.filtered,
    required this.availableRoles,
    required this.pendingRoles,
    this.errorMessage,
  });

  const UsersRolesState.initial()
      : status = UsersRolesStatus.initial,
        permissions = const Permissions(canList: false, canUpdate: false, canRemove: false),
        allUsers = const [],
        filtered = const [],
        availableRoles = const [],
        pendingRoles = const {},
        errorMessage = null;

  UsersRolesState copyWith({
    UsersRolesStatus? status,
    Permissions? permissions,
    List<UserRow>? allUsers,
    List<UserRow>? filtered,
    List<String>? availableRoles,
    Map<String, Set<String>>? pendingRoles,
    String? errorMessage,
  }) {
    return UsersRolesState(
      status: status ?? this.status,
      permissions: permissions ?? this.permissions,
      allUsers: allUsers ?? this.allUsers,
      filtered: filtered ?? this.filtered,
      availableRoles: availableRoles ?? this.availableRoles,
      pendingRoles: pendingRoles ?? this.pendingRoles,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, permissions, allUsers, filtered, availableRoles, pendingRoles, errorMessage];
}

class Permissions extends Equatable {
  final bool canList;
  final bool canUpdate;
  final bool canRemove;
  const Permissions({required this.canList, required this.canUpdate, required this.canRemove});

  @override
  List<Object?> get props => [canList, canUpdate, canRemove];
}

class UserRow extends Equatable {
  final String uid;
  final String name;
  final String email;
  final bool expanded;
  final Set<String>? loadedRoles;

  const UserRow({required this.uid, required this.name, required this.email, this.expanded = false, this.loadedRoles});

  UserRow copyWith({String? uid, String? name, String? email, bool? expanded, Set<String>? loadedRoles}) {
    return UserRow(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      expanded: expanded ?? this.expanded,
      loadedRoles: loadedRoles ?? this.loadedRoles,
    );
  }

  @override
  List<Object?> get props => [uid, name, email, expanded, loadedRoles];
}
