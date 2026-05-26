import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/goal_model.dart';
import 'goal_repository.dart';

class FirebaseGoalRepository implements GoalRepository {
  FirebaseGoalRepository(this._db);

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
      throw StateError('No user set for GoalRepository');
    }
    return _db.collection('users').doc(_userId).collection('goals');
  }

  @override
  Stream<List<GoalModel>> watchAll() {
    if (_userId == null) return Stream.value([]);
    return _collection().snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => GoalModel.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  @override
  Future<List<GoalModel>> fetchAll() async {
    if (_userId == null) return [];
    final snapshot = await _collection().get();
    return snapshot.docs
        .map((doc) => GoalModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<GoalModel?> getActive() async {
    final all = await fetchAll();
    return all.isEmpty ? null : all.first;
  }

  @override
  Future<GoalModel> create(GoalModel goal) async {
    if (_userId == null) return goal;
    await _collection().doc(goal.id).set(goal.toMap());
    return goal;
  }

  @override
  Future<void> update(GoalModel goal) async {
    if (_userId == null) return;
    await _collection().doc(goal.id).set(goal.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> delete(String id) async {
    if (_userId == null) return;
    await _collection().doc(id).delete();
  }

  @override
  Future<void> restore(GoalModel goal) async {
    if (_userId == null) return;
    await _collection().doc(goal.id).set(goal.toMap());
  }

  @override
  Future<void> clearAll() async {
    if (_userId == null) return;
    final snapshot = await _collection().get();
    await _deleteSnapshot(snapshot);
  }
}
