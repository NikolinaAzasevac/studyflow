import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/subtask_model.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

class TaskController extends ChangeNotifier {
  TaskController(this._repository, {this.onTaskCompleted}) {
    loadTasks();
  }

  final TaskRepository _repository;
  final void Function(DateTime date)? onTaskCompleted;
  final _uuid = const Uuid();

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

  List<TaskModel> tasksForGoal(String goalId) {
    return _tasks.where((task) => task.goalId == goalId).toList();
  }

  List<TaskModel> tasksForDate(DateTime date) {
    return _tasks.where((task) {
      final due = task.dueDate;
      if (due == null) return false;
      return due.year == date.year &&
          due.month == date.month &&
          due.day == date.day;
    }).toList();
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
    final toggledDone = !task.isDone;
    final updatedSubtasks = task.subtasks
        .map((subtask) => subtask.copyWith(isDone: toggledDone))
        .toList();
    final updated = task.copyWith(
      isDone: toggledDone,
      subtasks: updatedSubtasks,
    );
    await _repository.update(updated);
    _tasks = _tasks.map((item) => item.id == task.id ? updated : item).toList();
    notifyListeners();
    if (toggledDone) {
      onTaskCompleted?.call(DateTime.now());
    }
  }

  Future<TaskModel?> deleteTask(String id) async {
    TaskModel? toRemove;
    for (final item in _tasks) {
      if (item.id == id) {
        toRemove = item;
        break;
      }
    }
    await _repository.delete(id);
    _tasks = _tasks.where((task) => task.id != id).toList();
    notifyListeners();
    return toRemove;
  }

  Future<void> restoreTask(TaskModel task) async {
    await _repository.restore(task);
    _tasks = [
      ..._tasks.where((item) => item.id != task.id),
      task,
    ];
    notifyListeners();
  }

  Future<List<TaskModel>> deleteTasksForGoal(String goalId) async {
    final removed = _tasks.where((task) => task.goalId == goalId).toList();
    await _repository.deleteByGoalId(goalId);
    _tasks = _tasks.where((task) => task.goalId != goalId).toList();
    notifyListeners();
    return removed;
  }

  Future<void> restoreTasks(List<TaskModel> tasks) async {
    for (final task in tasks) {
      await _repository.restore(task);
    }
    final existingIds = _tasks.map((e) => e.id).toSet();
    _tasks = [
      ..._tasks,
      ...tasks.where((task) => !existingIds.contains(task.id)),
    ];
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _repository.clearAll();
    _tasks = [];
    notifyListeners();
  }

  Future<void> addSubtask(String taskId, String title) async {
    final task = _tasks.firstWhere((item) => item.id == taskId);
    final updated = task.copyWith(
      subtasks: [
        ...task.subtasks,
        SubtaskModel(id: _uuid.v4(), title: title, isDone: false),
      ],
      isDone: false,
    );
    await _repository.update(updated);
    _tasks = _tasks.map((item) => item.id == taskId ? updated : item).toList();
    notifyListeners();
  }

  Future<void> toggleSubtask(String taskId, String subtaskId) async {
    final task = _tasks.firstWhere((item) => item.id == taskId);
    final updatedSubtasks = task.subtasks.map((subtask) {
      if (subtask.id != subtaskId) return subtask;
      return subtask.copyWith(isDone: !subtask.isDone);
    }).toList();
    final allDone =
        updatedSubtasks.isNotEmpty && updatedSubtasks.every((s) => s.isDone);
    final updated = task.copyWith(
      subtasks: updatedSubtasks,
      isDone: allDone,
    );
    await _repository.update(updated);
    _tasks = _tasks.map((item) => item.id == taskId ? updated : item).toList();
    notifyListeners();
    if (allDone) {
      onTaskCompleted?.call(DateTime.now());
    }
  }

  Future<void> deleteSubtask(String taskId, String subtaskId) async {
    final task = _tasks.firstWhere((item) => item.id == taskId);
    final updatedSubtasks =
        task.subtasks.where((subtask) => subtask.id != subtaskId).toList();
    final allDone =
        updatedSubtasks.isNotEmpty && updatedSubtasks.every((s) => s.isDone);
    final updated = task.copyWith(
      subtasks: updatedSubtasks,
      isDone: allDone,
    );
    await _repository.update(updated);
    _tasks = _tasks.map((item) => item.id == taskId ? updated : item).toList();
    notifyListeners();
  }
}
