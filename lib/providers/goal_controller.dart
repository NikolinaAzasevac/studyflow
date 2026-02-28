import 'package:flutter/material.dart';

import '../models/goal_model.dart';
import '../repositories/goal_repository.dart';
import '../services/unsplash_service.dart';

class GoalController extends ChangeNotifier {
  GoalController(this._repository, this._unsplashService) {
    loadGoals();
  }

  final GoalRepository _repository;
  final UnsplashService _unsplashService;
  List<GoalModel> _goals = [];
  List<UnsplashImage> _searchResults = [];
  bool _isLoading = false;

  List<GoalModel> get goals => _goals;
  GoalModel? get activeGoal => _goals.isEmpty ? null : _goals.first;
  List<UnsplashImage> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();
    _goals = await _repository.fetchAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addGoal(GoalModel goal) async {
    final created = await _repository.create(goal);
    _goals = [created, ..._goals];
    notifyListeners();
  }

  Future<void> updateGoal(GoalModel goal) async {
    await _repository.update(goal);
    _goals = _goals.map((g) => g.id == goal.id ? goal : g).toList();
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
    await _repository.delete(id);
    _goals = _goals.where((g) => g.id != id).toList();
    notifyListeners();
  }

  Future<void> restoreGoal(GoalModel goal) async {
    await _repository.restore(goal);
    _goals = [
      ..._goals.where((g) => g.id != goal.id),
      goal,
    ];
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _repository.clearAll();
    _goals = [];
    notifyListeners();
  }

  Future<void> searchUnsplash(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    _searchResults = await _unsplashService.searchPhotos(query);
    notifyListeners();
  }
}
