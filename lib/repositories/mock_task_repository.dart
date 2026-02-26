import 'package:uuid/uuid.dart';

import '../models/subject_model.dart';
import '../models/task_model.dart';
import 'task_repository.dart';

class MockTaskRepository implements TaskRepository {
  final _uuid = const Uuid();
  final List<TaskModel> _tasks = [];
  bool _seeded = false;

  void seedForSubjects(List<SubjectModel> subjects) {
    if (_seeded || subjects.isEmpty) return;
    _seeded = true;

    final subjectA = subjects[0];
    final subjectB = subjects.length > 1 ? subjects[1] : subjects[0];
    final subjectC = subjects.length > 2 ? subjects[2] : subjects[0];

    _tasks.addAll([
      TaskModel(
        id: _uuid.v4(),
        subjectId: subjectA.id,
        title: 'Review lecture notes',
        notes: 'Summarize key formulas and examples.',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        isDone: false,
        priority: TaskPriority.medium,
      ),
      TaskModel(
        id: _uuid.v4(),
        subjectId: subjectA.id,
        title: 'Practice problem set 3',
        notes: 'Focus on integration techniques.',
        dueDate: DateTime.now().add(const Duration(days: 4)),
        isDone: true,
        priority: TaskPriority.high,
      ),
      TaskModel(
        id: _uuid.v4(),
        subjectId: subjectB.id,
        title: 'Lab prep',
        notes: 'Read experiment guide and outline steps.',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        isDone: false,
        priority: TaskPriority.high,
      ),
      TaskModel(
        id: _uuid.v4(),
        subjectId: subjectC.id,
        title: 'Algorithm notes',
        notes: 'Write notes on sorting complexities.',
        dueDate: DateTime.now().add(const Duration(days: 3)),
        isDone: false,
        priority: TaskPriority.low,
      ),
    ]);
  }

  @override
  Future<List<TaskModel>> fetchAll() async {
    return List.unmodifiable(_tasks);
  }

  @override
  Future<List<TaskModel>> fetchBySubjectId(String subjectId) async {
    return _tasks.where((task) => task.subjectId == subjectId).toList();
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
}
