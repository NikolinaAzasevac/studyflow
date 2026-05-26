import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task_model.dart';
import 'task_repository.dart';

class FirebaseTaskRepository implements TaskRepository {
  FirebaseTaskRepository(this._db);

  final FirebaseFirestore _db;
  String? _userId;

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
  void setUserId(String? userId) {
    _userId = userId;
  }

  CollectionReference<Map<String, dynamic>> _collection() {
    if (_userId == null) {
      throw StateError('No user set for TaskRepository');
    }
    return _db.collection('users').doc(_userId).collection('tasks');
  }

  @override
  Stream<List<TaskModel>> watchAll() {
    if (_userId == null) return Stream.value([]);
    return _collection().snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => TaskModel.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  @override
  Future<List<TaskModel>> fetchAll() async {
    if (_userId == null) return [];
    final snapshot = await _collection().get();
    return snapshot.docs
        .map((doc) => TaskModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<TaskModel>> fetchByGoalId(String goalId) async {
    if (_userId == null) return [];
    final snapshot = await _collection()
        .where('goalId', isEqualTo: goalId)
        .get();
    return snapshot.docs
        .map((doc) => TaskModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<TaskModel?> getById(String id) async {
    if (_userId == null) return null;
    final doc = await _collection().doc(id).get();
    if (!doc.exists) return null;
    return TaskModel.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<TaskModel> create(TaskModel task) async {
    if (_userId == null) return task;
    await _collection().doc(task.id).set(task.toMap());
    return task;
  }

  @override
  Future<void> update(TaskModel task) async {
    if (_userId == null) return;
    await _collection().doc(task.id).set(task.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> delete(String id) async {
    if (_userId == null) return;
    await _collection().doc(id).delete();
  }

  @override
  Future<void> deleteByGoalId(String goalId) async {
    if (_userId == null) return;
    final snapshot = await _collection()
        .where('goalId', isEqualTo: goalId)
        .get();
    await _deleteSnapshot(snapshot);
  }

  @override
  Future<void> restore(TaskModel task) async {
    if (_userId == null) return;
    await _collection().doc(task.id).set(task.toMap());
  }

  @override
  Future<void> clearAll() async {
    if (_userId == null) return;
    final snapshot = await _collection().get();
    await _deleteSnapshot(snapshot);
  }
}
