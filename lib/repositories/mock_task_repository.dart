import 'package:uuid/uuid.dart';

import '../models/goal_model.dart';
import '../models/task_model.dart';
import 'task_repository.dart';

class MockTaskRepository implements TaskRepository {
  final _uuid = const Uuid();
  final List<TaskModel> _tasks = [];
  bool _seeded = false;

  void seedForGoals(List<GoalModel> goals) {
    if (_seeded || goals.isEmpty) return;
    _seeded = true;

    final goalA = goals[0];
    final goalB = goals.length > 1 ? goals[1] : goals[0];
    final goalC = goals.length > 2 ? goals[2] : goals[0];

    _tasks.addAll([
      TaskModel(
        id: _uuid.v4(),
        goalId: goalA.id,
        title: 'Review lecture notes',
        notes: 'Summarize key formulas and examples.',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        isDone: false,
        priority: TaskPriority.medium,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        subtasks: const [],
      ),
      TaskModel(
        id: _uuid.v4(),
        goalId: goalA.id,
        title: 'Practice problem set 3',
        notes: 'Focus on integration techniques.',
        dueDate: DateTime.now().add(const Duration(days: 4)),
        isDone: true,
        priority: TaskPriority.high,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        subtasks: const [],
      ),
      TaskModel(
        id: _uuid.v4(),
        goalId: goalB.id,
        title: 'Lab prep',
        notes: 'Read experiment guide and outline steps.',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        isDone: false,
        priority: TaskPriority.high,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        subtasks: const [],
      ),
      TaskModel(
        id: _uuid.v4(),
        goalId: goalC.id,
        title: 'Algorithm notes',
        notes: 'Write notes on sorting complexities.',
        dueDate: DateTime.now().add(const Duration(days: 3)),
        isDone: false,
        priority: TaskPriority.low,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        subtasks: const [],
      ),
    ]);
  }

  @override
  Future<List<TaskModel>> fetchAll() async {
    return List.unmodifiable(_tasks);
  }

  @override
  Future<List<TaskModel>> fetchByGoalId(String goalId) async {
    return _tasks.where((task) => task.goalId == goalId).toList();
  }

  @override
  Future<TaskModel?> getById(String id) async {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<TaskModel> create(TaskModel task) async {
    final created = task.copyWith(id: _uuid.v4());
    _tasks.add(created);
    return created;
  }

  @override
  Future<void> update(TaskModel task) async {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
  }

  @override
  Future<void> delete(String id) async {
    _tasks.removeWhere((task) => task.id == id);
  }

  @override
  Future<void> deleteByGoalId(String goalId) async {
    _tasks.removeWhere((task) => task.goalId == goalId);
  }

  @override
  Future<void> restore(TaskModel task) async {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index == -1) {
      _tasks.add(task);
    } else {
      _tasks[index] = task;
    }
  }

  @override
  Future<void> clearAll() async {
    _tasks.clear();
  }
}
