import 'package:agrosync/features/users/domain/user_entity.dart';

abstract class UsersRepository {
  Future<UserEntity?> getCurrentUser();
  Future<Map<String, dynamic>?> getCurrentUserRaw();
  Future<void> logout();
}
