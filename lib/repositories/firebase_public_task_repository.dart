import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task_model.dart';
import 'task_repository.dart';

class FirebasePublicTaskRepository implements TaskRepository {
  FirebasePublicTaskRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _collection() {
    return _db.collection('public_tasks');
  }

  @override
  void setUserId(String? userId) {}

  @override
  Stream<List<TaskModel>> watchAll() {
    return _collection().snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => TaskModel.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  @override
  Future<List<TaskModel>> fetchAll() async {
    final snapshot = await _collection().get();
    return snapshot.docs
        .map((doc) => TaskModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<TaskModel>> fetchByGoalId(String goalId) async {
    final snapshot = await _collection()
        .where('goalId', isEqualTo: goalId)
        .get();
    return snapshot.docs
        .map((doc) => TaskModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<TaskModel?> getById(String id) async {
    final doc = await _collection().doc(id).get();
    if (!doc.exists) return null;
    return TaskModel.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<TaskModel> create(TaskModel task) async => task;

  @override
  Future<void> update(TaskModel task) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> deleteByGoalId(String goalId) async {}

  @override
  Future<void> restore(TaskModel task) async {}

  @override
  Future<void> clearAll() async {}
}
