import 'package:agrosync/features/users/data/firebase_users_repository.dart';
import 'package:agrosync/features/users/domain/users_repository.dart';

/// Thin façade to avoid scattering imports in UI.
class UsersApi {
  static final UsersRepository _repo = FirebaseUsersRepository();

  static Future<Map<String, dynamic>?> currentUserRaw() => _repo.getCurrentUserRaw();
  static Future<void> logout() => _repo.logout();
}
