import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import 'user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  FirebaseUserRepository(this._db);

  final FirebaseFirestore _db;

  Future<void> _deleteSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    if (snapshot.docs.isEmpty) return;

    const maxBatchSize = 450;
    for (var i = 0; i < snapshot.docs.length; i += maxBatchSize) {
      final batch = _db.batch();
      final end = (i + maxBatchSize).clamp(0, snapshot.docs.length);
      for (final doc in snapshot.docs.sublist(i, end)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  @override
  Stream<List<UserModel>> watchAll() {
    return _db
        .collection('users')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.id, doc.data()))
              .where((user) => !user.disabled)
              .toList(),
        );
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await _db.collection('users').doc(user.id).update(user.toMap());
  }

  @override
  Future<void> setRole(String userId, String role) async {
    await _db.collection('users').doc(userId).update({'role': role});
  }

  @override
  Future<void> deleteUserData(String userId) async {
    final goals = await _db
        .collection('users')
        .doc(userId)
        .collection('goals')
        .get();
    final tasks = await _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .get();
    await _deleteSnapshot(goals);
    await _deleteSnapshot(tasks);
  }

  @override
  Future<void> disableUser(String userId) async {
    await deleteUserData(userId);
    await _db.collection('users').doc(userId).set({
      'name': 'Deleted user',
      'email': '',
      'avatarUrl': null,
      'role': 'user',
      'disabled': true,
      'deletedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
