import 'package:flutter/material.dart';

import '../models/subject_model.dart';
import '../repositories/subject_repository.dart';
import '../services/unsplash_service.dart';

class SubjectController extends ChangeNotifier {
  SubjectController(this._repository, this._unsplashService) {
    loadSubjects();
  }

  final SubjectRepository _repository;
  final UnsplashService _unsplashService;

  List<SubjectModel> _subjects = [];
  List<UnsplashImage> _searchResults = [];
  bool _isLoading = false;

  List<SubjectModel> get subjects => _subjects;
  List<UnsplashImage> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  Future<void> loadSubjects() async {
    _isLoading = true;
    notifyListeners();
    _subjects = await _repository.fetchAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSubject(SubjectModel subject) async {
    final created = await _repository.create(subject);
    _subjects = [..._subjects, created];
    notifyListeners();
  }

  Future<void> updateSubject(SubjectModel subject) async {
    await _repository.update(subject);
    _subjects = _subjects
        .map((item) => item.id == subject.id ? subject : item)
        .toList();
    notifyListeners();
  }

  Future<void> deleteSubject(String id) async {
    await _repository.delete(id);
    _subjects = _subjects.where((subject) => subject.id != id).toList();
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
