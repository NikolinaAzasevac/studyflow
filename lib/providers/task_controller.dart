import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../repositories/task_repository.dart';

class TaskController extends ChangeNotifier {
  TaskController(this._repository) {
    loadTasks();
  }

  final TaskRepository _repository;

  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    _tasks = await _repository.fetchAll();
    _isLoading = false;
    notifyListeners();
  }

  List<TaskModel> tasksForSubject(String subjectId) {
    return _tasks.where((task) => task.subjectId == subjectId).toList();
  }

  Future<void> addTask(TaskModel task) async {
    final created = await _repository.create(task);
    _tasks = [..._tasks, created];
    notifyListeners();
  }

  Future<void> updateTask(TaskModel task) async {
    await _repository.update(task);
    _tasks = _tasks.map((item) => item.id == task.id ? task : item).toList();
    notifyListeners();
  }

  Future<void> toggleTask(TaskModel task) async {
    final updated = task.copyWith(isDone: !task.isDone);
    await _repository.update(updated);
    _tasks = _tasks.map((item) => item.id == task.id ? updated : item).toList();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _repository.delete(id);
    _tasks = _tasks.where((task) => task.id != id).toList();
    notifyListeners();
  }
}
