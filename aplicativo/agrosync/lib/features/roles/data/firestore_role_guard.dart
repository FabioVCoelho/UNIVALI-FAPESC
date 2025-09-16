import 'package:agrosync/core/services/rbac_service.dart' as core_rbac;
import 'package:agrosync/features/roles/domain/role_guard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Adapter that delegates to existing core RBAC utilities for minimal churn.
class FirestoreRoleGuard implements RoleGuard {
  final FirebaseFirestore _firestore;
  FirestoreRoleGuard({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  FirebaseFirestore get firestore => _firestore;

  @override
  Future<bool> canAccess({required String? userEmail, required List<String> requiredRoles}) {
    return core_rbac.Roles.canAccess(_firestore, userEmail: userEmail, requiredRoles: requiredRoles);
  }

  @override
  Future<Set<String>> fetchUserRoles(String? userEmail) {
    return core_rbac.Roles.fetchUserRoles(_firestore, userEmail);
  }

  @override
  Future<bool> isRolePublic(String roleId) {
    return core_rbac.Roles.isRolePublic(_firestore, roleId);
  }
}
