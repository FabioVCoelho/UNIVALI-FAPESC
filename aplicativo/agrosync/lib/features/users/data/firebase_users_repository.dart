import 'package:agrosync/features/users/domain/user_entity.dart';
import 'package:agrosync/features/users/domain/users_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_database/firebase_database.dart';

class FirebaseUsersRepository implements UsersRepository {
  final auth.FirebaseAuth _auth;
  final FirebaseDatabase _db;
  FirebaseUsersRepository({auth.FirebaseAuth? authInstance, FirebaseDatabase? database})
      : _auth = authInstance ?? auth.FirebaseAuth.instance,
        _db = database ?? FirebaseDatabase.instance;

  @override
  Future<UserEntity?> getCurrentUser() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    final raw = await getCurrentUserRaw();
    return UserEntity(
      id: u.uid,
      email: u.email,
      firstName: raw?['firstName']?.toString(),
      role: raw?['role']?.toString(),
    );
  }

  @override
  Future<Map<String, dynamic>?> getCurrentUserRaw() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    final ref = _db.ref('users/${u.uid}');
    final snap = await ref.get();
    if (!snap.exists) return null;
    return Map<String, dynamic>.from(snap.value as Map);
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (_) {}
  }
}
