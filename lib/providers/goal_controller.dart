import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/goal_model.dart';
import '../repositories/goal_repository.dart';
import '../services/unsplash_service.dart';

class GoalController extends ChangeNotifier {
  GoalController(this._repository, this._unsplashService, {this.onGoalAdded}) {
    loadGoals();
  }

  final GoalRepository _repository;
  final UnsplashService _unsplashService;
  final void Function(GoalModel goal)? onGoalAdded;
  final _uuid = const Uuid();
  List<GoalModel> _goals = [];
  List<UnsplashImage> _searchResults = [];
  String? _searchError;
  bool _isLoading = false;
  String? _userId;
  StreamSubscription<List<GoalModel>>? _sub;
  bool get _usingStream => _sub != null;
  bool get _canWrite => _userId != null && _userId != 'guest';

  List<GoalModel> get goals => _goals;
  GoalModel? get activeGoal => _goals.isEmpty ? null : _goals.first;
  List<UnsplashImage> get searchResults => _searchResults;
  String? get searchError => _searchError;
  bool get isLoading => _isLoading;

  Future<void> setUserId(String? userId) async {
    if (_userId == userId) return;
    _userId = userId;
    _repository.setUserId(userId);
    await _sub?.cancel();
    if (_userId == null) {
      _goals = [];
      notifyListeners();
      return;
    }
    _sub = _repository.watchAll().listen((items) {
      _goals = items;
      notifyListeners();
    });
    await loadGoals();
  }

  Future<void> loadGoals() async {
    if (_userId == null) {
      _goals = [];
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    _goals = await _repository.fetchAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addGoal(GoalModel goal) async {
    if (!_canWrite) return;
    final created = await _repository.create(
      goal.id.isEmpty ? goal.copyWith(id: _uuid.v4()) : goal,
    );
    onGoalAdded?.call(created);
    if (_usingStream) return;
    _goals = [created, ..._goals];
    notifyListeners();
  }

  Future<void> updateGoal(GoalModel goal) async {
    if (!_canWrite) return;
    await _repository.update(goal);
    if (_usingStream) return;
    _goals = _goals.map((g) => g.id == goal.id ? goal : g).toList();
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
    if (!_canWrite) return;
    await _repository.delete(id);
    if (_usingStream) return;
    _goals = _goals.where((g) => g.id != id).toList();
    notifyListeners();
  }

  Future<void> restoreGoal(GoalModel goal) async {
    if (!_canWrite) return;
    await _repository.restore(goal);
    if (_usingStream) return;
    _goals = [..._goals.where((g) => g.id != goal.id), goal];
    notifyListeners();
  }

  Future<void> clearAll() async {
    if (!_canWrite) return;
    await _repository.clearAll();
    if (_usingStream) return;
    _goals = [];
    notifyListeners();
  }

  Future<void> searchUnsplash(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _searchError = null;
      notifyListeners();
      return;
    }
    try {
      _searchResults = await _unsplashService.searchPhotos(query);
      _searchError = null;
    } catch (e) {
      _searchResults = [];
      _searchError = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
