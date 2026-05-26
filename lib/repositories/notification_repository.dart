import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';

class NotificationRepository {
  NotificationRepository(this._db);

  final FirebaseFirestore _db;
  String? _userId;

  void setUserId(String? userId) {
    _userId = userId;
  }

  CollectionReference<Map<String, dynamic>> _collection() {
    if (_userId == null) {
      throw StateError('No user set for NotificationRepository');
    }
    return _db.collection('users').doc(_userId).collection('notifications');
  }

  Stream<List<NotificationModel>> watchAll() {
    if (_userId == null) return Stream.value([]);
    return _collection()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> add(NotificationModel notification) async {
    await _collection().add(notification.toMap());
  }

  Future<void> update(String id, NotificationModel updated) async {
    await _collection().doc(id).update(updated.toMap());
  }

  Future<void> delete(String id) async {
    await _collection().doc(id).delete();
  }

  Future<void> markAsRead(String id) async {
    await _collection().doc(id).update({'isRead': true});
  }

  Future<void> markAllAsRead() async {
    final batch = _db.batch();
    final snapshot = await _collection()
        .where('isRead', isEqualTo: false)
        .get();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> clearAll() async {
    final snapshot = await _collection().get();
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
