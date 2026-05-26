import '../models/user_model.dart';

abstract class UserRepository {
  Stream<List<UserModel>> watchAll();
  Future<void> updateUser(UserModel user);
  Future<void> setRole(String userId, String role);
  Future<void> deleteUserData(String userId);
  Future<void> disableUser(String userId);
}
