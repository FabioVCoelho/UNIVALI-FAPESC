import 'package:agrosync/features/roles/data/firestore_role_guard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:agrosync/core/services/guest_auth_service.dart';
import 'package:agrosync/core/services/rbac_service.dart';

/// UI helper to guard navigation by roles in a reusable way.
class RoleNavigator {
  static final _guard = FirestoreRoleGuard();

  static Future<dynamic> guardAndNavigate(
    BuildContext context, {
    required List<String> requiredRoles,
    required Widget page,
  }) async {
    // Offline guest fallback: allow access if all required roles are public by default
    if (GuestAuthService.isGuest()) {
      final allPublic = requiredRoles.every((r) => Roles.publicDefaults.contains(r));
      if (allPublic) {
        // ignore: use_build_context_synchronously
        return await Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      }
      // Allow offline cached views for certain features (e.g., plant consultation)
      final allowsCache = requiredRoles.any((r) => Roles.offlineCacheAllowed.contains(r));
      if (allowsCache) {
        // Inform user we're showing cached data
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sem internet: exibindo dados locais do dispositivo.')),
        );
        // ignore: use_build_context_synchronously
        return await Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      }
      // If guest tries to access non-public feature, deny without network call
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acesso negado: recurso não disponível para convidado offline.')),
      );
      return null;
    }

    final email = FirebaseAuth.instance.currentUser?.email;
    final allowed = await _guard.canAccess(userEmail: email, requiredRoles: requiredRoles);
    if (allowed) {
      // ignore: use_build_context_synchronously
      return await Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acesso negado: você não possui permissão para esta ação.')),
      );
      return null;
    }
  }
}
