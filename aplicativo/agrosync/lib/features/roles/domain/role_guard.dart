import 'package:cloud_firestore/cloud_firestore.dart';

/// Contract for checking role-based access.
abstract class RoleGuard {
  Future<bool> canAccess({required String? userEmail, required List<String> requiredRoles});
  Future<Set<String>> fetchUserRoles(String? userEmail);
  Future<bool> isRolePublic(String roleId);
  FirebaseFirestore get firestore;
}
