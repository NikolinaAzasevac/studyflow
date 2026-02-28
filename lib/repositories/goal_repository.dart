import '../models/goal_model.dart';

abstract class GoalRepository {
  Future<List<GoalModel>> fetchAll();
  Future<GoalModel?> getActive();
  Future<GoalModel> create(GoalModel goal);
  Future<void> update(GoalModel goal);
  Future<void> delete(String id);
  Future<void> restore(GoalModel goal);
  Future<void> clearAll();
}
