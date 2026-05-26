import '../models/goal_model.dart';
import 'goal_repository.dart';

class HybridGoalRepository implements GoalRepository {
  HybridGoalRepository(this._remote, this._local);

  final GoalRepository _remote;
  final GoalRepository _local;
  String? _userId;

  GoalRepository get _current => _userId == 'guest' ? _local : _remote;

  @override
  void setUserId(String? userId) {
    _userId = userId;
    _remote.setUserId(userId == 'guest' ? null : userId);
    _local.setUserId(userId == 'guest' ? userId : null);
  }

  @override
  Stream<List<GoalModel>> watchAll() => _current.watchAll();

  @override
  Future<List<GoalModel>> fetchAll() => _current.fetchAll();

  @override
  Future<GoalModel?> getActive() => _current.getActive();

  @override
  Future<GoalModel> create(GoalModel goal) => _current.create(goal);

  @override
  Future<void> update(GoalModel goal) => _current.update(goal);

  @override
  Future<void> delete(String id) => _current.delete(id);

  @override
  Future<void> restore(GoalModel goal) => _current.restore(goal);

  @override
  Future<void> clearAll() => _current.clearAll();
}
