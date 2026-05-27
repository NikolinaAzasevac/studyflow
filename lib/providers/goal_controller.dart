import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool get canWrite => _canWrite;

  List<GoalModel> get goals => _goals;
  GoalModel? get activeGoal => _goals.isEmpty ? null : _goals.first;
  List<UnsplashImage> get searchResults => _searchResults;
  String? get searchError => _searchError;
  bool get isLoading => _isLoading;

  List<GoalModel> _sortGoals(Iterable<GoalModel> goals) {
    final sorted = goals.toList();
    sorted.sort((a, b) {
      final dateComparison = a.targetDate.compareTo(b.targetDate);
      if (dateComparison != 0) return dateComparison;
      return a.displayTitle.toLowerCase().compareTo(
        b.displayTitle.toLowerCase(),
      );
    });
    return sorted;
  }

  void _ensureWritable() {
    if (_userId == null) {
      throw StateError('User session is not ready yet.');
    }
    if (_userId == 'guest') {
      throw StateError('Guest mode cannot modify goals.');
    }
  }

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
      _goals = _sortGoals(items);
      notifyListeners();
    }, onError: (_) {
      _goals = [];
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
    try {
      _goals = _sortGoals(await _repository.fetchAll());
    } on FirebaseException {
      _goals = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGoal(GoalModel goal) async {
    _ensureWritable();
    final created = await _repository.create(
      goal.id.isEmpty ? goal.copyWith(id: _uuid.v4()) : goal,
    );
    onGoalAdded?.call(created);
    if (_usingStream) return;
    _goals = _sortGoals([created, ..._goals]);
    notifyListeners();
  }

  Future<void> updateGoal(GoalModel goal) async {
    _ensureWritable();
    await _repository.update(goal);
    if (_usingStream) return;
    _goals = _sortGoals(_goals.map((g) => g.id == goal.id ? goal : g));
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
    _ensureWritable();
    await _repository.delete(id);
    if (_usingStream) return;
    _goals = _goals.where((g) => g.id != id).toList();
    notifyListeners();
  }

  Future<void> restoreGoal(GoalModel goal) async {
    _ensureWritable();
    await _repository.restore(goal);
    if (_usingStream) return;
    _goals = _sortGoals([..._goals.where((g) => g.id != goal.id), goal]);
    notifyListeners();
  }

  Future<void> clearAll() async {
    _ensureWritable();
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
