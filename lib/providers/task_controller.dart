import 'dart:async';

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
  final void Function(TaskModel? task, DateTime date)? onTaskCompleted;
  final _uuid = const Uuid();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _userId;
  StreamSubscription<List<TaskModel>>? _sub;
  bool get _usingStream => _sub != null;
  bool get _canWrite => _userId != null && _userId != 'guest';

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  TaskModel? _findTask(String id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  Future<void> setUserId(String? userId) async {
    if (_userId == userId) return;
    _userId = userId;
    _repository.setUserId(userId);
    await _sub?.cancel();
    if (_userId == null) {
      _tasks = [];
      notifyListeners();
      return;
    }
    _sub = _repository.watchAll().listen((items) {
      _tasks = items;
      notifyListeners();
    });
    await loadTasks();
  }

  Future<void> loadTasks() async {
    if (_userId == null) {
      _tasks = [];
      notifyListeners();
      return;
    }
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
    if (!_canWrite) return;
    final created = await _repository.create(
      task.id.isEmpty ? task.copyWith(id: _uuid.v4()) : task,
    );
    if (_usingStream) return;
    _tasks = [..._tasks, created];
    notifyListeners();
  }

  Future<void> updateTask(TaskModel task) async {
    if (!_canWrite) return;
    await _repository.update(task);
    if (_usingStream) return;
    _tasks = _tasks.map((item) => item.id == task.id ? task : item).toList();
    notifyListeners();
  }

  Future<void> toggleTask(TaskModel task) async {
    if (!_canWrite) return;
    final toggledDone = !task.isDone;
    final updatedSubtasks = task.subtasks
        .map((subtask) => subtask.copyWith(isDone: toggledDone))
        .toList();
    final updated = task.copyWith(
      isDone: toggledDone,
      subtasks: updatedSubtasks,
    );
    await _repository.update(updated);
    if (!_usingStream) {
      _tasks = _tasks
          .map((item) => item.id == task.id ? updated : item)
          .toList();
      notifyListeners();
    }
    if (toggledDone) {
      onTaskCompleted?.call(updated, DateTime.now());
    }
  }

  Future<TaskModel?> deleteTask(String id) async {
    if (!_canWrite) return null;
    TaskModel? toRemove;
    for (final item in _tasks) {
      if (item.id == id) {
        toRemove = item;
        break;
      }
    }
    await _repository.delete(id);
    if (!_usingStream) {
      _tasks = _tasks.where((task) => task.id != id).toList();
      notifyListeners();
    }
    return toRemove;
  }

  Future<void> restoreTask(TaskModel task) async {
    if (!_canWrite) return;
    await _repository.restore(task);
    if (_usingStream) return;
    _tasks = [..._tasks.where((item) => item.id != task.id), task];
    notifyListeners();
  }

  Future<List<TaskModel>> deleteTasksForGoal(String goalId) async {
    if (!_canWrite) return [];
    final removed = _tasks.where((task) => task.goalId == goalId).toList();
    await _repository.deleteByGoalId(goalId);
    if (!_usingStream) {
      _tasks = _tasks.where((task) => task.goalId != goalId).toList();
      notifyListeners();
    }
    return removed;
  }

  Future<void> restoreTasks(List<TaskModel> tasks) async {
    if (!_canWrite) return;
    for (final task in tasks) {
      await _repository.restore(task);
    }
    if (_usingStream) return;
    final existingIds = _tasks.map((e) => e.id).toSet();
    _tasks = [
      ..._tasks,
      ...tasks.where((task) => !existingIds.contains(task.id)),
    ];
    notifyListeners();
  }

  Future<void> clearAll() async {
    if (!_canWrite) return;
    await _repository.clearAll();
    if (_usingStream) return;
    _tasks = [];
    notifyListeners();
  }

  Future<void> addSubtask(String taskId, String title) async {
    if (!_canWrite) return;
    final task = _findTask(taskId);
    if (task == null) return;
    final updated = task.copyWith(
      subtasks: [
        ...task.subtasks,
        SubtaskModel(id: _uuid.v4(), title: title, isDone: false),
      ],
      isDone: false,
    );
    await _repository.update(updated);
    if (_usingStream) return;
    _tasks = _tasks.map((item) => item.id == taskId ? updated : item).toList();
    notifyListeners();
  }

  Future<void> toggleSubtask(String taskId, String subtaskId) async {
    if (!_canWrite) return;
    final task = _findTask(taskId);
    if (task == null) return;
    final updatedSubtasks = task.subtasks.map((subtask) {
      if (subtask.id != subtaskId) return subtask;
      return subtask.copyWith(isDone: !subtask.isDone);
    }).toList();
    final allDone =
        updatedSubtasks.isNotEmpty && updatedSubtasks.every((s) => s.isDone);
    final updated = task.copyWith(subtasks: updatedSubtasks, isDone: allDone);
    await _repository.update(updated);
    if (!_usingStream) {
      _tasks = _tasks
          .map((item) => item.id == taskId ? updated : item)
          .toList();
      notifyListeners();
    }
    if (allDone && !task.isDone) {
      onTaskCompleted?.call(updated, DateTime.now());
    }
  }

  Future<void> updateSubtask(
    String taskId,
    String subtaskId,
    String title,
  ) async {
    if (!_canWrite) return;
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) return;
    final task = _findTask(taskId);
    if (task == null) return;
    final updatedSubtasks = task.subtasks.map((subtask) {
      if (subtask.id != subtaskId) return subtask;
      return subtask.copyWith(title: trimmedTitle);
    }).toList();
    final updated = task.copyWith(subtasks: updatedSubtasks);
    await _repository.update(updated);
    if (_usingStream) return;
    _tasks = _tasks.map((item) => item.id == taskId ? updated : item).toList();
    notifyListeners();
  }

  Future<void> deleteSubtask(String taskId, String subtaskId) async {
    if (!_canWrite) return;
    final task = _findTask(taskId);
    if (task == null) return;
    final updatedSubtasks = task.subtasks
        .where((subtask) => subtask.id != subtaskId)
        .toList();
    final allDone =
        updatedSubtasks.isNotEmpty && updatedSubtasks.every((s) => s.isDone);
    final updated = task.copyWith(subtasks: updatedSubtasks, isDone: allDone);
    await _repository.update(updated);
    if (_usingStream) return;
    _tasks = _tasks.map((item) => item.id == taskId ? updated : item).toList();
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
