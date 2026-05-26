import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class AdminController extends ChangeNotifier {
  AdminController(this._repository);

  final UserRepository _repository;

  Stream<List<UserModel>> watchUsers() => _repository.watchAll();

  Future<void> setRole(String userId, String role) async {
    await _repository.setRole(userId, role);
  }

  Future<void> updateUser(UserModel user) async {
    await _repository.updateUser(user);
  }

  Future<void> deleteUserData(String userId) async {
    await _repository.deleteUserData(userId);
  }

  Future<void> disableUser(String userId) async {
    await _repository.disableUser(userId);
  }
}
