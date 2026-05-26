import 'dart:async';

import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationController extends ChangeNotifier {
  NotificationController(this._repository);

  final NotificationRepository _repository;
  List<NotificationModel> _notifications = [];
  final bool _isLoading = false;
  String? _userId;
  StreamSubscription<List<NotificationModel>>? _sub;
  bool get _isGuest => _userId == 'guest';
  bool get _usingStream => _sub != null;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> setUserId(String? userId) async {
    if (_userId == userId) return;
    _userId = userId;
    _repository.setUserId(userId);
    await _sub?.cancel();
    _sub = null;
    if (_userId == null) {
      _notifications = [];
      notifyListeners();
      return;
    }
    if (_isGuest) {
      notifyListeners();
      return;
    }
    _sub = _repository.watchAll().listen((items) {
      _notifications = items;
      notifyListeners();
    });
  }

  Future<void> addNotification({
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    if (_userId == null) return;
    final notification = NotificationModel(
      id: '', // Firestore će generisati
      userId: _userId!,
      title: title,
      message: message,
      type: type,
      isRead: false,
      createdAt: DateTime.now(),
      data: data,
    );
    if (_isGuest) {
      _notifications = [
        notification.copyWith(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
        ),
        ..._notifications,
      ];
      notifyListeners();
      return;
    }
    await _repository.add(notification);
  }

  Future<void> markAsRead(String id) async {
    if (_userId == null) return;
    if (_isGuest) {
      _notifications = _notifications.map((n) {
        if (n.id == id) return n.copyWith(isRead: true);
        return n;
      }).toList();
      notifyListeners();
      return;
    }
    await _repository.markAsRead(id);
    if (!_usingStream) {
      _notifications = _notifications.map((n) {
        if (n.id == id) return n.copyWith(isRead: true);
        return n;
      }).toList();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    if (_userId == null) return;
    if (_isGuest) {
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      notifyListeners();
      return;
    }
    await _repository.markAllAsRead();
    if (!_usingStream) {
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String id) async {
    if (_userId == null) return;
    if (_isGuest) {
      _notifications = _notifications.where((n) => n.id != id).toList();
      notifyListeners();
      return;
    }
    await _repository.delete(id);
    if (!_usingStream) {
      _notifications = _notifications.where((n) => n.id != id).toList();
      notifyListeners();
    }
  }

  Future<void> clearAll() async {
    if (_userId == null) return;
    if (_isGuest) {
      _notifications = [];
      notifyListeners();
      return;
    }
    await _repository.clearAll();
    if (!_usingStream) {
      _notifications = [];
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
