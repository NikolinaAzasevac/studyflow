import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/goal_model.dart';
import 'goal_repository.dart';

class FirebasePublicGoalRepository implements GoalRepository {
  FirebasePublicGoalRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _collection() {
    return _db.collection('public_goals');
  }

  @override
  void setUserId(String? userId) {}

  @override
  Stream<List<GoalModel>> watchAll() {
    return _collection().snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => GoalModel.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  @override
  Future<List<GoalModel>> fetchAll() async {
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
  Future<GoalModel> create(GoalModel goal) async => goal;

  @override
  Future<void> update(GoalModel goal) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> restore(GoalModel goal) async {}

  @override
  Future<void> clearAll() async {}
}
