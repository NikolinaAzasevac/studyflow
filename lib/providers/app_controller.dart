import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../models/task_model.dart';
import '../models/goal_model.dart';
import 'notification_controller.dart';

class AppController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  int _currentIndex = 0;
  String _localeCode = 'en';
  bool _isAuthenticated = false;
  bool _isGuest = false;
  bool _hasSeenOnboarding = false;
  int _avatarColorIndex = 0;
  UserModel? _user;
  SharedPreferences? _prefs;
  List<String> _activityDates = [];
  String _role = 'guest';
  String? _authStatusMessage;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSub;
  NotificationController? notificationController;

  ThemeMode get themeMode => _themeMode;
  int get currentIndex => _currentIndex;
  String get localeCode => _localeCode;
  bool get isAuthenticated => _isAuthenticated;
  bool get isGuest => _isGuest;
  bool get isLoggedIn => _isAuthenticated || _isGuest;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
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
  String get role => _role;
  bool get isAdmin => _role == 'admin';
  String? get authStatusMessage => _authStatusMessage;

  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'about': 'About',
      'addGoal': 'Add goal',
      'addSubtask': 'Add subtask',
      'addTask': 'Add task',
      'adminPanel': 'Admin panel',
      'all': 'All',
      'avatarUpdated': 'Avatar updated.',
      'byDueDate': 'By due date',
      'byNewest': 'By newest',
      'byPriority': 'By priority',
      'camera': 'Camera',
      'cancel': 'Cancel',
      'changesSaved': 'Changes saved.',
      'completed': 'completed',
      'completedFilter': 'Completed',
      'confirmPassword': 'Confirm password',
      'continueGuest': 'Continue as guest',
      'createdAt': 'Created',
      'darkMode': 'Dark mode',
      'daysLeft': 'days left',
      'defaultUserName': 'Student',
      'delete': 'Delete',
      'deleteGoal': 'Delete goal',
      'deleteGoalConfirm': 'Delete this goal and its tasks?',
      'deleteTask': 'Delete task',
      'deleteTaskConfirm': 'Delete this task?',
      'deleteUserData': 'Delete user data',
      'demoModeAction': 'Sign in to save',
      'demoModeMessage':
          'You are using sample data. Sign in to save your own goals and tasks.',
      'demoModeTitle': 'Guest mode',
      'disableUser': 'Disable user',
      'disableUserConfirm': 'Disable this user and remove their data?',
      'editUser': 'Edit user',
      'email': 'Email',
      'emptyGoals': 'No goals yet.',
      'emptyTasks': 'No tasks yet.',
      'fieldRequired': 'This field is required.',
      'files': 'Files',
      'filter': 'Filter',
      'forgotPassword': 'Forgot password?',
      'getStarted': 'Get started',
      'goalDeleted': 'Goal deleted.',
      'goalDetails': 'Goal details',
      'goals': 'Goals',
      'goalsCount': 'Goals',
      'home': 'Home',
      'invalidEmail': 'Enter a valid email address.',
      'language': 'Language',
      'lastWeek': 'Last week',
      'login': 'Log in',
      'loginRequired': 'Please log in to continue.',
      'logout': 'Log out',
      'manageData': 'Manage data',
      'markDone': 'Mark done',
      'markAllRead': 'Mark all read',
      'markPending': 'Mark pending',
      'name': 'Name',
      'nextGoal': 'Next goal',
      'nextUp': 'Next up',
      'no': 'No',
      'noDueDate': 'No due date',
      'noNotifications': 'No notifications yet.',
      'noSubtasks': 'No subtasks yet.',
      'noUsers': 'No users found.',
      'notAuthorized': 'You are not authorized.',
      'notSet': 'Not set',
      'notifications': 'Notifications',
      'onboardingDesc1':
          'Turn study goals into clear tasks with deadlines and priorities.',
      'onboardingDesc2':
          'Keep track of what is due today, overdue, and already done.',
      'onboardingDesc3':
          'Watch your weekly progress and keep a steady study rhythm.',
      'onboardingTitle1': 'Plan your semester',
      'onboardingTitle2': 'Stay on top of tasks',
      'onboardingTitle3': 'Track your progress',
      'overall': 'Overall',
      'overdue': 'Overdue',
      'overdueFilter': 'Overdue',
      'password': 'Password',
      'passwordRequirements':
          'Use at least 8 characters, including upper/lowercase letters, a number, and a special character.',
      'passwordsDoNotMatch': 'Passwords do not match.',
      'photoLibrary': 'Photo library',
      'profile': 'Profile',
      'progress': 'Progress',
      'progressOverview': 'Progress overview',
      'register': 'Register',
      'reset': 'Reset',
      'resetEmailSent': 'Password reset email sent.',
      'resetPassword': 'Reset password',
      'resetProgress': 'Reset progress',
      'resetProgressConfirm': 'Reset all saved activity progress?',
      'resetProgressConfirmShort': 'Clear streak and weekly activity.',
      'role': 'Role',
      'roleAdmin': 'Admin',
      'roleUser': 'User',
      'save': 'Save',
      'saveFailed': 'Save failed. Check your connection or permissions.',
      'saveFailedWithReason': 'Save failed: {reason}',
      'searchTasks': 'Search tasks',
      'sendResetLink': 'Send reset link',
      'sort': 'Sort',
      'streak': 'Streak',
      'subtaskHint': 'What needs to be done?',
      'subtasks': 'Subtasks',
      'taskDeleted': 'Task deleted.',
      'taskDetails': 'Task details',
      'tasks': 'Tasks',
      'tasksCompleted': 'tasks completed',
      'thisWeek': 'This week',
      'today': 'Today',
      'trendDown': 'Down from last week',
      'trendUp': 'Up from last week',
      'undo': 'Undo',
      'unknownGoal': 'Unknown goal',
      'upcoming': 'Upcoming',
      'welcome': 'Welcome',
      'yes': 'Yes',
    },
  };

  String t(String key) {
    return _localizedStrings[_localeCode]?[key] ??
        _localizedStrings['en']?[key] ??
        key;
  }

  Future<void> initialize() async {
    await loadPreferences();
    _authSub?.cancel();
    _authSub = _auth.authStateChanges().listen(_handleAuthChanged);
  }

  Future<void> loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _hasSeenOnboarding = _prefs?.getBool('hasSeenOnboarding') ?? false;
    _localeCode = _prefs?.getString('localeCode') ?? _localeCode;
    final theme = _prefs?.getString('themeMode');
    if (theme == 'dark') _themeMode = ThemeMode.dark;
    if (theme == 'light') _themeMode = ThemeMode.light;
    _avatarColorIndex = _prefs?.getInt('avatarColorIndex') ?? 0;
    _activityDates = [];
  }

  String _activityDatesKey(String? scope) =>
      'activityDates_${scope ?? 'signed_out'}';

  Future<void> _loadActivityForScope(String? scope) async {
    _activityDates = _prefs?.getStringList(_activityDatesKey(scope)) ?? [];
  }

  Future<void> _persistActivityForCurrentScope() async {
    final scope = _isGuest ? 'guest' : _user?.id;
    await _prefs?.setStringList(_activityDatesKey(scope), _activityDates);
  }

  void recordActivity(DateTime date, {TaskModel? task}) {
    final dateStr = '${date.year}-${date.month}-${date.day}';
    if (!_activityDates.contains(dateStr)) {
      _activityDates.add(dateStr);
      _persistActivityForCurrentScope();
      notifyListeners();

      // Check streak
      final streak = _calculateCurrentStreak();
      if (streak == 7 || streak == 14 || streak == 30) {
        notificationController?.addNotification(
          title: 'Streak milestone!',
          message: 'Amazing! You have a $streak day streak!',
          type: 'streak',
        );
      }
    }

    // Add task completed notification
    if (task != null) {
      notificationController?.addNotification(
        title: 'Task completed!',
        message: 'Great job! You completed "${task.title}".',
        type: 'task_reminder',
        data: {'taskId': task.id},
      );
    }
  }

  int _calculateCurrentStreak() {
    if (_activityDates.isEmpty) return 0;
    final sortedDates = _activityDates.map((d) => DateTime.parse(d)).toList()
      ..sort((a, b) => b.compareTo(a)); // newest first

    int streak = 0;
    DateTime current = DateTime.now();
    current = DateTime(current.year, current.month, current.day);

    for (final date in sortedDates) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      if (dateOnly == current) {
        streak++;
        current = current.subtract(const Duration(days: 1));
      } else if (dateOnly.isBefore(current)) {
        break; // gap in streak
      }
    }
    return streak;
  }

  void addGoalNotification(GoalModel goal) {
    notificationController?.addNotification(
      title: 'New goal added!',
      message: 'You added a new goal: ${goal.displayTitle}',
      type: 'goal_deadline',
      data: {'goalId': goal.id},
    );
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

  void cycleAvatarColor() {
    _avatarColorIndex += 1;
    _prefs?.setInt('avatarColorIndex', _avatarColorIndex);
    notifyListeners();
  }

  Future<void> _handleAuthChanged(User? firebaseUser) async {
    _userDocSub?.cancel();
    if (firebaseUser == null) {
      if (_isGuest) {
        await _loadActivityForScope('guest');
        notifyListeners();
        return;
      }
      _isAuthenticated = false;
      _role = 'guest';
      _user = null;
      await _loadActivityForScope(null);
      notifyListeners();
      return;
    }

    _isGuest = false;
    final docRef = _db.collection('users').doc(firebaseUser.uid);
    final email = firebaseUser.email ?? '';
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      final name =
          firebaseUser.displayName ??
          (email.isNotEmpty ? email.split('@').first : 'Guest');
      final model = UserModel(
        id: firebaseUser.uid,
        name: name,
        email: email,
        role: 'user',
      );
      await docRef.set(model.toMap());
      _user = model;
      _role = model.role;
      await _loadActivityForScope(model.id);
    } else {
      final data = snapshot.data() as Map<String, dynamic>;
      final model = UserModel.fromMap(firebaseUser.uid, data);
      if (model.disabled) {
        _authStatusMessage = 'This account has been disabled.';
        _isAuthenticated = false;
        _role = 'guest';
        _user = null;
        await _auth.signOut();
        notifyListeners();
        return;
      }
      _user = model;
      _role = model.role;
      await _loadActivityForScope(model.id);
    }
    _isAuthenticated = true;
    _authStatusMessage = null;
    notifyListeners();

    _userDocSub = docRef.snapshots().listen((doc) {
      if (!doc.exists) return;
      final data = doc.data();
      if (data == null) return;
      final updated = UserModel.fromMap(doc.id, data);
      if (updated.disabled) {
        _authStatusMessage = 'This account has been disabled.';
        logout();
        return;
      }
      if (_user?.name != updated.name ||
          _role != updated.role ||
          _user?.avatarUrl != updated.avatarUrl) {
        _user = updated;
        _role = updated.role;
        notifyListeners();
      }
    });
  }

  Future<String?> signIn(String email, String password) async {
    try {
      _authStatusMessage = null;
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final snapshot = await _db
          .collection('users')
          .doc(credential.user!.uid)
          .get();
      if (snapshot.exists) {
        final user = UserModel.fromMap(credential.user!.uid, snapshot.data()!);
        if (user.disabled) {
          await _auth.signOut();
          _authStatusMessage = 'This account has been disabled.';
          notifyListeners();
          return _authStatusMessage;
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e);
    } catch (_) {
      return 'Authentication failed.';
    }
  }

  Future<String?> register(String name, String email, String password) async {
    if (!isStrongPassword(password)) {
      return 'Use at least 8 characters, including upper/lowercase letters, a number, and a special character.';
    }
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final model = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        role: 'user',
        disabled: false,
      );
      await _db.collection('users').doc(model.id).set(model.toMap());
      await credential.user!.updateDisplayName(name);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e);
    } catch (_) {
      return 'Authentication failed.';
    }
  }

  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e);
    } catch (_) {
      return 'Authentication failed.';
    }
  }

  Future<void> loginGuest() async {
    await _userDocSub?.cancel();
    await _auth.signOut();
    _isGuest = true;
    _isAuthenticated = false;
    _role = 'guest';
    _currentIndex = 0;
    _authStatusMessage = null;
    _user = UserModel(
      id: 'guest',
      name: 'Guest',
      email: '',
      role: 'guest',
      disabled: false,
    );
    await _loadActivityForScope('guest');
    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    if (_user == null) {
      _user = UserModel(id: 'guest', name: name, email: '', role: 'guest');
    } else {
      _user = _user!.copyWith(name: name);
    }
    if (_isAuthenticated && _user != null) {
      await _db.collection('users').doc(_user!.id).update({'name': name});
      await _auth.currentUser?.updateDisplayName(name);
    }
    notifyListeners();
  }

  String _contentTypeForFileName(String fileName) {
    final normalized = fileName.toLowerCase();
    if (normalized.endsWith('.png')) return 'image/png';
    if (normalized.endsWith('.webp')) return 'image/webp';
    if (normalized.endsWith('.gif')) return 'image/gif';
    if (normalized.endsWith('.heic') || normalized.endsWith('.heif')) {
      return 'image/heic';
    }
    return 'image/jpeg';
  }

  String _extensionForFileName(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) return 'jpg';
    final extension = fileName.substring(dotIndex + 1).toLowerCase();
    return RegExp(r'^[a-z0-9]+$').hasMatch(extension) ? extension : 'jpg';
  }

  Future<void> uploadUserAvatar({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (!_isAuthenticated || _user == null) {
      throw StateError('Login required');
    }

    final previousAvatarUrl = _user!.avatarUrl;
    final extension = _extensionForFileName(fileName);
    final ref = _storage.ref().child(
      'users/${_user!.id}/avatars/avatar_${DateTime.now().millisecondsSinceEpoch}.$extension',
    );

    await ref.putData(
      bytes,
      SettableMetadata(contentType: _contentTypeForFileName(fileName)),
    );
    final avatarUrl = await ref.getDownloadURL();
    await _db.collection('users').doc(_user!.id).update({
      'avatarUrl': avatarUrl,
    });
    _user = _user!.copyWith(avatarUrl: avatarUrl);
    notifyListeners();

    if (previousAvatarUrl != null && previousAvatarUrl.isNotEmpty) {
      try {
        await _storage.refFromURL(previousAvatarUrl).delete();
      } catch (_) {}
    }
  }

  Future<void> logout() async {
    _isGuest = false;
    _currentIndex = 0;
    await _userDocSub?.cancel();
    await _auth.signOut();
    await _loadActivityForScope(null);
    notifyListeners();
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'Email is already in use.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      default:
        return 'Authentication failed.';
    }
  }

  bool isStrongPassword(String password) {
    final hasMinLength = password.length >= 8;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasLower = RegExp(r'[a-z]').hasMatch(password);
    final hasDigit = RegExp(r'\d').hasMatch(password);
    final hasSpecial = RegExp(
      r'[!@#$%^&*(),.?":{}|<>_\-+=/\\\[\];`~]',
    ).hasMatch(password);
    return hasMinLength && hasUpper && hasLower && hasDigit && hasSpecial;
  }

  void completeOnboarding() {
    _hasSeenOnboarding = true;
    _prefs?.setBool('hasSeenOnboarding', true);
    notifyListeners();
  }

  void clearActivity() {
    _activityDates = [];
    _persistActivityForCurrentScope();
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
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final startOfLastWeek = startOfWeek.subtract(const Duration(days: 7));
    final endOfLastWeek = startOfWeek.subtract(const Duration(milliseconds: 1));

    int thisWeek = 0;
    int lastWeek = 0;
    for (final dateStr in _activityDates) {
      final date = DateTime.parse(dateStr);
      if (!date.isBefore(startOfWeek)) {
        thisWeek += 1;
      } else if (!date.isBefore(startOfLastWeek) &&
          date.isBefore(endOfLastWeek)) {
        lastWeek += 1;
      }
    }
    return {'thisWeek': thisWeek, 'lastWeek': lastWeek};
  }

  List<int> weeklySeries() {
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final counts = List<int>.filled(7, 0);
    for (final dateStr in _activityDates) {
      final date = DateTime.parse(dateStr);
      final normalized = DateTime(date.year, date.month, date.day);
      final index = normalized.difference(startOfWeek).inDays;
      if (index >= 0 && index < 7) counts[index] += 1;
    }
    return counts;
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _userDocSub?.cancel();
    super.dispose();
  }
}
