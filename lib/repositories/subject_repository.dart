import '../models/subject_model.dart';

abstract class SubjectRepository {
  Future<List<SubjectModel>> fetchAll();
  Future<SubjectModel?> getById(String id);
  Future<SubjectModel> create(SubjectModel subject);
  Future<void> update(SubjectModel subject);
  Future<void> delete(String id);
}
