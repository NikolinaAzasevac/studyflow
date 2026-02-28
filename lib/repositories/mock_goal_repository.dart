import 'package:uuid/uuid.dart';

import '../models/goal_model.dart';
import 'goal_repository.dart';

class MockGoalRepository implements GoalRepository {
  final _uuid = const Uuid();
  final List<GoalModel> _goals = [];

  MockGoalRepository() {
    _seed();
  }

  void _seed() {
    _goals.add(
      GoalModel(
        id: _uuid.v4(),
        area: 'Mathematics',
        type: 'Midterm',
        description: 'Prepare for the midterm exam with weekly practice.',
        coverUrl: null,
        targetDate: DateTime.now().add(const Duration(days: 18)),
      ),
    );
  }

  @override
  Future<List<GoalModel>> fetchAll() async => List.unmodifiable(_goals);

  @override
  Future<GoalModel?> getActive() async => _goals.isEmpty ? null : _goals.first;

  @override
  Future<GoalModel> create(GoalModel goal) async {
    final created = goal.copyWith(id: _uuid.v4());
    _goals.insert(0, created);
    return created;
  }

  @override
  Future<void> update(GoalModel goal) async {
    final index = _goals.indexWhere((item) => item.id == goal.id);
    if (index != -1) _goals[index] = goal;
  }

  @override
  Future<void> delete(String id) async {
    _goals.removeWhere((goal) => goal.id == id);
  }

  @override
  Future<void> restore(GoalModel goal) async {
    final index = _goals.indexWhere((item) => item.id == goal.id);
    if (index == -1) {
      _goals.insert(0, goal);
    } else {
      _goals[index] = goal;
    }
  }

  @override
  Future<void> clearAll() async {
    _goals.clear();
  }
}
