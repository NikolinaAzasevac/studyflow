import '../models/task_model.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> fetchAll();
  Future<List<TaskModel>> fetchBySubjectId(String subjectId);
  Future<TaskModel?> getById(String id);
  Future<TaskModel> create(TaskModel task);
  Future<void> update(TaskModel task);
  Future<void> delete(String id);
}
