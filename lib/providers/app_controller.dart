import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/user_model.dart';

class AppController extends ChangeNotifier {
  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'appTitle': 'StudyFlow',
      'home': 'Home',
      'tasks': 'Tasks',
      'progress': 'Progress',
      'profile': 'Profile',
      'welcome': 'Welcome back',
      'defaultUserName': 'Student',
      'notSet': 'Not set',
      'subjects': 'Subjects',
      'subjectsCount': 'Subjects',
      'completed': 'Completed',
      'overall': 'Overall',
      'tasksCompleted': 'tasks completed',
      'addSubject': 'Add Subject',
      'editSubject': 'Edit Subject',
      'addTask': 'Add Task',
      'editTask': 'Edit Task',
      'taskDetails': 'Task Details',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'name': 'Name',
      'logout': 'Logout',
      'darkMode': 'Dark mode',
      'language': 'Language',
      'about': 'About',
      'emptySubjects': 'No subjects yet. Add your first subject.',
      'emptyTasks': 'No tasks yet. Add your first task.',
      'progressOverview': 'Progress overview',
      'notes': 'Notes',
      'dueDate': 'Due date',
      'priority': 'Priority',
      'save': 'Save',
      'cancel': 'Cancel',
      'searchUnsplash': 'Search Unsplash',
      'selectCover': 'Select cover',
      'searchPrompt': 'Search Unsplash to pick a cover image.',
      'subjectTitle': 'Subject title',
      'subjectDescription': 'Description',
      'taskTitle': 'Task title',
      'selectSubjectFirst': 'Select a subject first.',
      'selectSubject': 'Select a subject.',
      'unknownSubject': 'Unknown subject',
      'noDueDate': 'No due date',
      'markDone': 'Mark as done',
      'markPending': 'Mark as pending',
      'deleteTask': 'Delete task',
    },
    'sr': {
      'appTitle': 'StudyFlow',
      'home': 'Početna',
      'tasks': 'Zadaci',
      'progress': 'Napredak',
      'profile': 'Profil',
      'welcome': 'Dobrodošli nazad',
      'defaultUserName': 'Student',
      'notSet': 'Nije postavljeno',
      'subjects': 'Predmeti',
      'subjectsCount': 'Predmeti',
      'completed': 'Završeno',
      'overall': 'Ukupno',
      'tasksCompleted': 'zadataka završeno',
      'addSubject': 'Dodaj predmet',
      'editSubject': 'Izmeni predmet',
      'addTask': 'Dodaj zadatak',
      'editTask': 'Izmeni zadatak',
      'taskDetails': 'Detalji zadatka',
      'login': 'Prijava',
      'register': 'Registracija',
      'email': 'Email',
      'password': 'Lozinka',
      'name': 'Ime',
      'logout': 'Odjava',
      'darkMode': 'Tamni režim',
      'language': 'Jezik',
      'about': 'O aplikaciji',
      'emptySubjects': 'Nema predmeta. Dodajte prvi predmet.',
      'emptyTasks': 'Nema zadataka. Dodajte prvi zadatak.',
      'progressOverview': 'Pregled napretka',
      'notes': 'Beleške',
      'dueDate': 'Rok',
      'priority': 'Prioritet',
      'save': 'Sačuvaj',
      'cancel': 'Otkaži',
      'searchUnsplash': 'Pretraga Unsplash',
      'selectCover': 'Izaberite naslovnu sliku',
      'searchPrompt': 'Pretražite Unsplash za naslovnu sliku.',
      'subjectTitle': 'Naziv predmeta',
      'subjectDescription': 'Opis',
      'taskTitle': 'Naziv zadatka',
      'selectSubjectFirst': 'Prvo izaberite predmet.',
      'selectSubject': 'Izaberite predmet.',
      'unknownSubject': 'Nepoznat predmet',
      'noDueDate': 'Bez roka',
      'markDone': 'Označi kao završeno',
      'markPending': 'Označi kao nezavršeno',
      'deleteTask': 'Obriši zadatak',
    },
  };

  ThemeMode _themeMode = ThemeMode.system;
  int _currentIndex = 0;
  String _localeCode = 'en';
  bool _isAuthenticated = false;
  UserModel? _user;
  final _uuid = const Uuid();

  ThemeMode get themeMode => _themeMode;
  int get currentIndex => _currentIndex;
  String get localeCode => _localeCode;
  bool get isAuthenticated => _isAuthenticated;
  UserModel? get user => _user;

  String t(String key) {
    return _localizedStrings[_localeCode]?[key] ??
        _localizedStrings['en']?[key] ??
        key;
  }

  void setTab(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void toggleThemeMode(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setLocale(String localeCode) {
    _localeCode = localeCode;
    notifyListeners();
  }

  void login(String name, String email) {
    _isAuthenticated = true;
    _user = UserModel(
      id: _uuid.v4(),
      name: name,
      email: email,
    );
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _user = null;
    _currentIndex = 0;
    notifyListeners();
  }
}
