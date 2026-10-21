import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'notifications/push_helper.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final CollectionReference _notifications =
      FirebaseFirestore.instance.collection('notifications');

  /// Send a notification document to Firestore
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    String? complaintId,
    String? lab,
    String? type,
  }) async {
    if (userId.isEmpty || userId == 'Not Assigned') return;

    try {
      final docRef = _notifications.doc();
      await docRef.set({
        'id': docRef.id,
        'userId': userId,
        'title': title,
        'message': message,
        'complaintId': complaintId ?? '',
        'lab': lab ?? '',
        'type': type ?? 'info',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Failed to send notification: $e");
    }
  }

  /// Real-time stream of all notifications for a specific user
  Stream<List<Map<String, dynamic>>> getUserNotificationsStream(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }
    return _notifications
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              data['id'] = d.id;
              return data;
            }).toList());
  }

  /// Real-time stream of unread notification count
  Stream<int> getUnreadCountStream(String userId) {
    if (userId.isEmpty) {
      return Stream.value(0);
    }
    return _notifications
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  /// Mark single notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notifications.doc(notificationId).update({'isRead': true});
    } catch (e) {
      debugPrint("Error marking notification read: $e");
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    try {
      final snap = await _notifications
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in snap.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint("Error marking all read: $e");
    }
  }

  /// Clear/delete all notifications for a user
  Future<void> clearAll(String userId) async {
    try {
      final snap =
          await _notifications.where('userId', isEqualTo: userId).get();
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint("Error clearing notifications: $e");
    }
  }

  /// Request browser/device push permission
  Future<void> requestPermission() async {
    await requestPushPermission();
  }

  /// Dispatch platform push notification
  Future<void> showPushNotification(String title, String body) async {
    await showPlatformNotification(title, body);
  }

  /// Send broadcast notification to a target audience ('everyone', 'faculty', 'it')
  Future<int> sendBroadcastNotification({
    required String title,
    required String message,
    required String targetAudience, // 'everyone', 'faculty', 'it'
    String? senderName,
    String? priority, // 'normal', 'urgent', 'critical'
  }) async {
    try {
      final usersCol = FirebaseFirestore.instance.collection('users');
      QuerySnapshot userSnapshot;

      final normalizedAudience = targetAudience.trim().toLowerCase();
      if (normalizedAudience == 'faculty') {
        userSnapshot = await usersCol.where('role', isEqualTo: 'Faculty').get();
      } else if (normalizedAudience == 'it') {
        userSnapshot =
            await usersCol.where('role', isEqualTo: 'IT Technician').get();
      } else {
        // 'everyone'
        userSnapshot = await usersCol.get();
      }

      final docs = userSnapshot.docs;
      if (docs.isEmpty) return 0;

      final batch = FirebaseFirestore.instance.batch();
      int count = 0;

      for (var userDoc in docs) {
        final targetUid = userDoc.id;
        final notifDoc = _notifications.doc();
        batch.set(notifDoc, {
          'id': notifDoc.id,
          'userId': targetUid,
          'title': title,
          'message': message,
          'type': 'broadcast',
          'priority': priority ?? 'urgent',
          'senderName': senderName ?? 'IT Support',
          'targetAudience': targetAudience,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        count++;
      }

      await batch.commit();

      // Trigger local platform push alert for immediate confirmation
      await showPlatformNotification(title, message);

      return count;
    } catch (e) {
      debugPrint("Failed to send broadcast notification: $e");
      rethrow;
    }
  }
}
