import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/models/goal_model.dart';
import 'package:studyflow/models/task_model.dart';
import 'package:studyflow/repositories/goal_repository.dart';
import 'package:studyflow/repositories/hybrid_goal_repository.dart';
import 'package:studyflow/repositories/hybrid_task_repository.dart';
import 'package:studyflow/repositories/task_repository.dart';

void main() {
  group('Hybrid repositories', () {
    test(
      'HybridGoalRepository routes guest traffic to public repository',
      () async {
        final remote = _FakeGoalRepository();
        final local = _FakeGoalRepository();
        final repository = HybridGoalRepository(remote, local);
        final goal = GoalModel(
          id: 'goal-1',
          area: 'Math',
          type: 'Exam',
          description: 'Prepare chapters 1-3.',
          coverUrl: null,
          targetDate: DateTime(2026, 5, 1),
        );

        repository.setUserId('guest');
        await repository.create(goal);

        expect(remote.lastUserId, isNull);
        expect(local.lastUserId, 'guest');
        expect(local.createdGoals.single.id, goal.id);
        expect(remote.createdGoals, isEmpty);
      },
    );

    test(
      'HybridTaskRepository routes authenticated traffic to remote repository',
      () async {
        final remote = _FakeTaskRepository();
        final local = _FakeTaskRepository();
        final repository = HybridTaskRepository(remote, local);
        final task = TaskModel(
          id: 'task-1',
          goalId: 'goal-1',
          title: 'Solve exercises',
          notes: 'Focus on derivatives.',
          dueDate: DateTime(2026, 5, 2),
          isDone: false,
          priority: TaskPriority.medium,
          createdAt: DateTime(2026, 3, 18),
          subtasks: const [],
        );

        repository.setUserId('user-123');
        await repository.create(task);

        expect(remote.lastUserId, 'user-123');
        expect(local.lastUserId, isNull);
        expect(remote.createdTasks.single.id, task.id);
        expect(local.createdTasks, isEmpty);
      },
    );
  });
}

class _FakeGoalRepository implements GoalRepository {
  String? lastUserId;
  final List<GoalModel> createdGoals = [];

  @override
  void setUserId(String? userId) {
    lastUserId = userId;
  }

  @override
  Stream<List<GoalModel>> watchAll() => const Stream.empty();

  @override
  Future<List<GoalModel>> fetchAll() async => [];

  @override
  Future<GoalModel?> getActive() async => null;

  @override
  Future<GoalModel> create(GoalModel goal) async {
    createdGoals.add(goal);
    return goal;
  }

  @override
  Future<void> update(GoalModel goal) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> restore(GoalModel goal) async {}

  @override
  Future<void> clearAll() async {}
}

class _FakeTaskRepository implements TaskRepository {
  String? lastUserId;
  final List<TaskModel> createdTasks = [];

  @override
  void setUserId(String? userId) {
    lastUserId = userId;
  }

  @override
  Stream<List<TaskModel>> watchAll() => const Stream.empty();

  @override
  Future<List<TaskModel>> fetchAll() async => [];

  @override
  Future<List<TaskModel>> fetchByGoalId(String goalId) async => [];

  @override
  Future<TaskModel?> getById(String id) async => null;

  @override
  Future<TaskModel> create(TaskModel task) async {
    createdTasks.add(task);
    return task;
  }

  @override
  Future<void> update(TaskModel task) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> deleteByGoalId(String goalId) async {}

  @override
  Future<void> restore(TaskModel task) async {}

  @override
  Future<void> clearAll() async {}
}
