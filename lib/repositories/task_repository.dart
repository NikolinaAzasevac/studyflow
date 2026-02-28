import '../models/task_model.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> fetchAll();
  Future<List<TaskModel>> fetchByGoalId(String goalId);
  Future<TaskModel?> getById(String id);
  Future<TaskModel> create(TaskModel task);
  Future<void> update(TaskModel task);
  Future<void> delete(String id);
  Future<void> deleteByGoalId(String goalId);
  Future<void> restore(TaskModel task);
  Future<void> clearAll();
}
