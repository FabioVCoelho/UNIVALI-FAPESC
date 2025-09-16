import 'package:cloud_firestore/cloud_firestore.dart';

/// RBAC roles used across the app. Keep these in sync with .junie/guidelines.md
class Roles {
  // Page-level roles
  static const viewPlants = 'VIEW_PLANTS';
  static const registerPlants = 'REGISTER_PLANTS';
  static const exportPdf = 'EXPORT_PDF';
  static const viewGraph = 'VIEW_GRAPH';
  static const viewCredits = 'VIEW_CREDITS';
  static const addNewFields = 'ADD_NEW_FIELDS';
  static const approveMergeContent = 'APPROVE_MERGE_CONTENT';

  // Offline-known public roles (fallback when Firestore is unreachable)
  static const Set<String> publicDefaults = { viewCredits };

  // Roles that can still show cached data offline for guests (read-only access)
  static const Set<String> offlineCacheAllowed = {
    viewPlants,
    searchPlant,
  };

  // Users management page roles
  static const listUser = 'LIST_USER';
  static const addUser = 'ADD_USER';
  static const updateUser = 'UPDATE_USER';
  static const removeUser = 'REMOVE_USER';

  // Macro roles (aliases for feature access)
  static const addPlant = 'ADD_PLANT';
  static const searchPlant = 'SEARCH_PLANT';

  // Fine-grained action roles
  static const deletePlant = 'DELETE_PLANT';

  static const all = <String>{
    viewPlants,
    registerPlants,
    exportPdf,
    viewGraph,
    viewCredits,
    addNewFields,
    approveMergeContent,
    listUser,
    addUser,
    updateUser,
    removeUser,
    addPlant,
    searchPlant,
    deletePlant,
  };
  
  /// Utility: returns whether a role is public by consulting the roles collection.
  static Future<bool> isRolePublic(FirebaseFirestore firestore, String roleId) async {
    final doc = await firestore.collection('roles').doc(roleId).get();
    return (doc.data() ?? const {})['is_public'] == true;
  }

  /// Utility: fetch roles granted to a user (by email) from role_user collection.
  static Future<Set<String>> fetchUserRoles(FirebaseFirestore firestore, String? userEmail) async {
    if (userEmail == null || userEmail.isEmpty) return <String>{};
    final doc = await firestore.collection('role_user').doc(userEmail).get();
    final data = doc.data() ?? const {};
    final list = (data['roles'] as List?)?.whereType<String>().toSet() ?? <String>{};
    return list;
  }

  /// Utility: checks if the user has at least one of required roles, or the role is public.
  static Future<bool> canAccess(
    FirebaseFirestore firestore, {
    required String? userEmail,
    required List<String> requiredRoles,
  }) async {
    // If any required role is marked public, allow.
    for (final role in requiredRoles) {
      if (await isRolePublic(firestore, role)) return true;
    }
    final userRoles = await fetchUserRoles(firestore, userEmail);
    return requiredRoles.any((r) => userRoles.contains(r));
  }
}

/// Seeds the roles and role_user collections in Firestore.
///
/// Collections created/updated (idempotent):
/// - roles: one document per role with metadata (is_public)
/// - role_user: documents mapping user identifiers (email) to granted roles
/// - meta/seeds: rbac_seeded flag (best-effort; seeding remains idempotent)
Future<void> seedRbac(FirebaseFirestore firestore) async {
  // Quick check to avoid repeated heavy writes; still keep logic idempotent
  final metaDoc = firestore.collection('meta').doc('seeds');
  final metaSnap = await metaDoc.get();
  final alreadySeeded = (metaSnap.data() ?? const {})['rbac_seeded'] == true;

  // Roles and which are public per guideline (Register Plants and Credits are public)
  final roleDefinitions = <String, bool>{
    Roles.viewPlants: true,
    Roles.registerPlants: true, // keep non-public; use macro if you want public
    Roles.exportPdf: false,
    Roles.viewGraph: false,
    Roles.viewCredits: true, // Public page
    Roles.addNewFields: false,
    Roles.approveMergeContent: false,
    // Users management roles
    Roles.listUser: false,
    Roles.addUser: false,
    Roles.updateUser: false,
    Roles.removeUser: false,
    // Macro roles
    Roles.addPlant: true,
    Roles.searchPlant: true,
    // Fine-grained actions
    Roles.deletePlant: false,
  };

  final rolesColl = firestore.collection('roles');
  final roleUserColl = firestore.collection('role_user');

  // Upsert roles
  for (final entry in roleDefinitions.entries) {
    final roleId = entry.key;
    await rolesColl.doc(roleId).set({
      'name': roleId,
      'is_public': entry.value,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Assign all roles to admin
  const adminEmail = 'admin@email.com';
  await roleUserColl.doc(adminEmail).set({
    'user_email': adminEmail,
    'roles': Roles.all.toList(),
    'updated_at': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  // Mark as seeded
  if (!alreadySeeded) {
    await metaDoc.set({
      'rbac_seeded': true,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
