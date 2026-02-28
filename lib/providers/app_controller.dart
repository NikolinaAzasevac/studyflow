import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      'defaultUserName': 'Guest',
      'notSet': 'Not set',
      'goals': 'Goals',
      'goalsCount': 'Goals',
      'completed': 'Completed',
      'overall': 'Overall',
      'tasksCompleted': 'tasks completed',
      'all': 'All',
      'addGoal': 'Add Goal',
      'editGoal': 'Edit Goal',
      'addTask': 'Add Task',
      'editTask': 'Edit Task',
      'taskDetails': 'Task Details',
      'goalDetails': 'Goal Details',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'name': 'Name',
      'logout': 'Logout',
      'darkMode': 'Dark mode',
      'language': 'Language',
      'about': 'About',
      'nextUp': 'Next up',
      'overdue': 'Overdue',
      'emptyGoals': 'No goals yet. Add your first goal.',
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
      'goalArea': 'Area',
      'goalType': 'Type',
      'goalDescription': 'Description',
      'goalDate': 'Target date',
      'taskTitle': 'Task title',
      'selectGoalFirst': 'Select a goal first.',
      'selectGoal': 'Select a goal.',
      'deleteGoal': 'Delete goal',
      'deleteGoalConfirm':
          'Deleting this goal will also remove its tasks. Continue?',
      'delete': 'Delete',
      'searchTasks': 'Search tasks',
      'filter': 'Filter',
      'sort': 'Sort',
      'today': 'Today',
      'upcoming': 'Upcoming',
      'overdueFilter': 'Overdue',
      'completedFilter': 'Completed',
      'byDueDate': 'By due date',
      'byNewest': 'By newest',
      'byPriority': 'By priority',
      'unknownGoal': 'Unknown goal',
      'noDueDate': 'No due date',
      'markDone': 'Mark as done',
      'markPending': 'Mark as pending',
      'deleteTask': 'Delete task',
      'deleteTaskConfirm': 'Delete this task?',
      'taskDeleted': 'Task deleted',
      'goalDeleted': 'Goal deleted',
      'undo': 'Undo',
      'createdAt': 'Created',
      'subtasks': 'Subtasks',
      'addSubtask': 'Add subtask',
      'subtaskHint': 'New subtask',
      'noSubtasks': 'No subtasks yet.',
      'streak': 'Streak',
      'thisWeek': 'This week',
      'lastWeek': 'Last week',
      'trendUp': 'Up',
      'trendDown': 'Down',
      'notifications': 'Notifications',
      'resetProgress': 'Reset progress',
      'resetProgressConfirm': 'This will clear tasks, goals, and activity data. Continue?',
      'resetProgressConfirmShort': 'This will remove tasks, goals, and streak data.',
      'reset': 'Reset',
      'yes': 'Yes',
      'no': 'No',
      'changeAvatar': 'Change avatar',
      'onboardingTitle1': 'Plan goals',
      'onboardingDesc1': 'Organize your study areas and keep everything tidy.',
      'onboardingTitle2': 'Add tasks',
      'onboardingDesc2': 'Break work into clear steps and track progress.',
      'onboardingTitle3': 'Track progress',
      'onboardingDesc3': 'Build habits with streaks and weekly insights.',
      'getStarted': 'Get started',
      'continueGuest': 'Continue as guest',
      'daysLeft': 'days left',
      'nextGoal': 'Next goal',
    },
    'sr': {
      'appTitle': 'StudyFlow',
      'home': 'Početna',
      'tasks': 'Zadaci',
      'progress': 'Napredak',
      'profile': 'Profil',
      'welcome': 'Dobrodošli nazad',
      'defaultUserName': 'Gost',
      'notSet': 'Nije postavljeno',
      'goals': 'Ciljevi',
      'goalsCount': 'Ciljevi',
      'completed': 'Završeno',
      'overall': 'Ukupno',
      'tasksCompleted': 'zadataka završeno',
      'all': 'Sve',
      'addGoal': 'Dodaj cilj',
      'editGoal': 'Izmeni cilj',
      'addTask': 'Dodaj zadatak',
      'editTask': 'Izmeni zadatak',
      'taskDetails': 'Detalji zadatka',
      'goalDetails': 'Detalji cilja',
      'login': 'Prijava',
      'register': 'Registracija',
      'email': 'Email',
      'password': 'Lozinka',
      'name': 'Ime',
      'logout': 'Odjava',
      'darkMode': 'Tamni režim',
      'language': 'Jezik',
      'about': 'O aplikaciji',
      'nextUp': 'Sledeće',
      'overdue': 'Kasni',
      'emptyGoals': 'Nema ciljeva. Dodajte prvi cilj.',
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
      'goalArea': 'Oblast',
      'goalType': 'Vrsta',
      'goalDescription': 'Opis',
      'goalDate': 'Datum cilja',
      'taskTitle': 'Naziv zadatka',
      'selectGoalFirst': 'Prvo izaberite cilj.',
      'selectGoal': 'Izaberite cilj.',
      'deleteGoal': 'Obriši cilj',
      'deleteGoalConfirm':
          'Brisanjem cilja brišu se i njegovi zadaci. Nastaviti?',
      'delete': 'Obriši',
      'searchTasks': 'Pretraga zadataka',
      'filter': 'Filter',
      'sort': 'Sortiraj',
      'today': 'Danas',
      'upcoming': 'Uskoro',
      'overdueFilter': 'Kasni',
      'completedFilter': 'Završeno',
      'byDueDate': 'Po roku',
      'byNewest': 'Najnovije',
      'byPriority': 'Po prioritetu',
      'unknownGoal': 'Nepoznat cilj',
      'noDueDate': 'Bez roka',
      'markDone': 'Označi kao završeno',
      'markPending': 'Označi kao nezavršeno',
      'deleteTask': 'Obriši zadatak',
      'deleteTaskConfirm': 'Obrisati ovaj zadatak?',
      'taskDeleted': 'Zadatak obrisan',
      'goalDeleted': 'Cilj obrisan',
      'undo': 'Poništi',
      'createdAt': 'Kreirano',
      'subtasks': 'Podzadaci',
      'addSubtask': 'Dodaj podzadatak',
      'subtaskHint': 'Novi podzadatak',
      'noSubtasks': 'Nema podzadataka.',
      'streak': 'Niz',
      'thisWeek': 'Ova nedelja',
      'lastWeek': 'Prošla nedelja',
      'trendUp': 'Rast',
      'trendDown': 'Pad',
      'notifications': 'Notifikacije',
      'resetProgress': 'Resetuj napredak',
      'resetProgressConfirm': 'Ovo briše zadatke, ciljeve i aktivnost. Nastaviti?',
      'resetProgressConfirmShort': 'Ovo uklanja zadatke, ciljeve i niz dana.',
      'reset': 'Resetuj',
      'yes': 'Da',
      'no': 'Ne',
      'changeAvatar': 'Promeni avatar',
      'onboardingTitle1': 'Planiraj ciljeve',
      'onboardingDesc1': 'Organizuj oblasti učenja na jednom mestu.',
      'onboardingTitle2': 'Dodaj zadatke',
      'onboardingDesc2': 'Razbij obaveze na jasne korake.',
      'onboardingTitle3': 'Prati napredak',
      'onboardingDesc3': 'Gradi navike kroz niz i nedeljne uvide.',
      'getStarted': 'Započni',
      'continueGuest': 'Nastavi kao gost',
      'daysLeft': 'dana do',
      'nextGoal': 'Sledeći cilj',
    },
  };

  ThemeMode _themeMode = ThemeMode.system;
  int _currentIndex = 0;
  String _localeCode = 'en';
  bool _isAuthenticated = false;
  bool _hasSeenOnboarding = false;
  bool _notificationsEnabled = true;
  int _avatarColorIndex = 0;
  UserModel? _user;
  final _uuid = const Uuid();
  SharedPreferences? _prefs;
  List<String> _activityDates = [];

  ThemeMode get themeMode => _themeMode;
  int get currentIndex => _currentIndex;
  String get localeCode => _localeCode;
  bool get isAuthenticated => _isAuthenticated;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get notificationsEnabled => _notificationsEnabled;
  Color get avatarColor {
    const palette = [
      Color(0xFF6A5AE0),
      Color(0xFF9B5DE5),
      Color(0xFF5E60CE),
      Color(0xFF4EA8DE),
      Color(0xFF48BFE3),
    ];
    return palette[_avatarColorIndex % palette.length];
  }
  UserModel? get user => _user;
  List<String> get activityDates => _activityDates;

  Future<void> loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _hasSeenOnboarding = _prefs?.getBool('hasSeenOnboarding') ?? false;
    _localeCode = _prefs?.getString('localeCode') ?? _localeCode;
    final theme = _prefs?.getString('themeMode');
    if (theme == 'dark') _themeMode = ThemeMode.dark;
    if (theme == 'light') _themeMode = ThemeMode.light;
    _notificationsEnabled = _prefs?.getBool('notificationsEnabled') ?? true;
    _avatarColorIndex = _prefs?.getInt('avatarColorIndex') ?? 0;
    _activityDates = _prefs?.getStringList('activityDates') ?? [];
  }

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
    _prefs?.setString('themeMode', isDark ? 'dark' : 'light');
    notifyListeners();
  }

  void setLocale(String localeCode) {
    _localeCode = localeCode;
    _prefs?.setString('localeCode', localeCode);
    notifyListeners();
  }

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    _prefs?.setBool('notificationsEnabled', value);
    notifyListeners();
  }

  void cycleAvatarColor() {
    _avatarColorIndex += 1;
    _prefs?.setInt('avatarColorIndex', _avatarColorIndex);
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

  void loginGuest() {
    _isAuthenticated = true;
    _user = UserModel(
      id: _uuid.v4(),
      name: t('defaultUserName'),
      email: '',
    );
    notifyListeners();
  }

  void updateUserName(String name) {
    if (_user == null) {
      _user = UserModel(id: _uuid.v4(), name: name, email: '');
    } else {
      _user = _user!.copyWith(name: name);
    }
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _user = null;
    _currentIndex = 0;
    notifyListeners();
  }

  void completeOnboarding() {
    _hasSeenOnboarding = true;
    _prefs?.setBool('hasSeenOnboarding', true);
    notifyListeners();
  }

  void recordActivity(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    _activityDates = [..._activityDates, normalized.toIso8601String()];
    _prefs?.setStringList('activityDates', _activityDates);
    notifyListeners();
  }

  void clearActivity() {
    _activityDates = [];
    _prefs?.setStringList('activityDates', _activityDates);
    notifyListeners();
  }

  int streakDays() {
    final uniqueDays = _activityDates
        .map(DateTime.parse)
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
    if (uniqueDays.isEmpty) return 0;
    int streak = 0;
    var current = DateTime.now();
    current = DateTime(current.year, current.month, current.day);
    while (uniqueDays.contains(current)) {
      streak += 1;
      current = current.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Map<String, int> weeklyTrend() {
    final now = DateTime.now();
    final startOfWeek =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final startOfLastWeek = startOfWeek.subtract(const Duration(days: 7));
    final endOfLastWeek = startOfWeek.subtract(const Duration(milliseconds: 1));

    int thisWeek = 0;
    int lastWeek = 0;
    for (final dateStr in _activityDates) {
      final date = DateTime.parse(dateStr);
      if (!date.isBefore(startOfWeek)) {
        thisWeek += 1;
      } else if (!date.isBefore(startOfLastWeek) && date.isBefore(endOfLastWeek)) {
        lastWeek += 1;
      }
    }
    return {'thisWeek': thisWeek, 'lastWeek': lastWeek};
  }

  List<int> weeklySeries() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    final counts = List<int>.filled(7, 0);
    for (final dateStr in _activityDates) {
      final date = DateTime.parse(dateStr);
      final normalized = DateTime(date.year, date.month, date.day);
      final index = normalized.difference(start).inDays;
      if (index >= 0 && index < 7) counts[index] += 1;
    }
    if (counts.every((v) => v == 0)) {
      return [1, 0, 2, 1, 3, 1, 2];
    }
    return counts;
  }
}
