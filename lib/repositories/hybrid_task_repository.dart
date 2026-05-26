import '../models/task_model.dart';
import 'task_repository.dart';

class HybridTaskRepository implements TaskRepository {
  HybridTaskRepository(this._remote, this._local);

  final TaskRepository _remote;
  final TaskRepository _local;
  String? _userId;

  TaskRepository get _current => _userId == 'guest' ? _local : _remote;

  @override
  void setUserId(String? userId) {
    _userId = userId;
    _remote.setUserId(userId == 'guest' ? null : userId);
    _local.setUserId(userId == 'guest' ? userId : null);
  }

  @override
  Stream<List<TaskModel>> watchAll() => _current.watchAll();

  @override
  Future<List<TaskModel>> fetchAll() => _current.fetchAll();

  @override
  Future<List<TaskModel>> fetchByGoalId(String goalId) =>
      _current.fetchByGoalId(goalId);

  @override
  Future<TaskModel?> getById(String id) => _current.getById(id);

  @override
  Future<TaskModel> create(TaskModel task) => _current.create(task);

  @override
  Future<void> update(TaskModel task) => _current.update(task);

  @override
  Future<void> delete(String id) => _current.delete(id);

  @override
  Future<void> deleteByGoalId(String goalId) => _current.deleteByGoalId(goalId);

  @override
  Future<void> restore(TaskModel task) => _current.restore(task);

  @override
  Future<void> clearAll() => _current.clearAll();
}
