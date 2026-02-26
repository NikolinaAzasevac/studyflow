import 'package:uuid/uuid.dart';

import '../models/subject_model.dart';
import 'subject_repository.dart';

class MockSubjectRepository implements SubjectRepository {
  final _uuid = const Uuid();
  final List<SubjectModel> _subjects = [];

  MockSubjectRepository() {
    _seed();
  }

  void _seed() {
    _subjects.addAll([
      SubjectModel(
        id: _uuid.v4(),
        title: 'Mathematics',
        description: 'Calculus, algebra, and discrete structures.',
        coverUrl: null,
        totalTasks: 8,
        completedTasks: 5,
      ),
      SubjectModel(
        id: _uuid.v4(),
        title: 'Physics',
        description: 'Mechanics and electromagnetism notes.',
        coverUrl: null,
        totalTasks: 6,
        completedTasks: 3,
      ),
      SubjectModel(
        id: _uuid.v4(),
        title: 'Computer Science',
        description: 'Data structures, algorithms, and systems.',
        coverUrl: null,
        totalTasks: 10,
        completedTasks: 7,
      ),
    ]);
  }

  @override
  Future<List<SubjectModel>> fetchAll() async {
    return List.unmodifiable(_subjects);
  }

  @override
  Future<SubjectModel?> getById(String id) async {
    try {
      return _subjects.firstWhere((subject) => subject.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<SubjectModel> create(SubjectModel subject) async {
    final created = subject.copyWith(id: _uuid.v4());
    _subjects.add(created);
    return created;
  }

  @override
  Future<void> update(SubjectModel subject) async {
    final index = _subjects.indexWhere((item) => item.id == subject.id);
    if (index != -1) {
      _subjects[index] = subject;
    }
  }

  @override
  Future<void> delete(String id) async {
    _subjects.removeWhere((subject) => subject.id == id);
  }
}
