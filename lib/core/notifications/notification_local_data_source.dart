import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_notification.dart';

class NotificationLocalDataSource {
  NotificationLocalDataSource._();

  static final NotificationLocalDataSource instance =
      NotificationLocalDataSource._();

  static const String _storageKey = 'app_notifications';

  Future<List<AppNotification>> getNotifications() async {
    final preferences = await SharedPreferences.getInstance();

    final rawNotifications = preferences.getStringList(_storageKey) ?? [];

    final notifications = rawNotifications
        .map((item) {
          try {
            final decoded = jsonDecode(item);

            if (decoded is! Map) {
              return null;
            }

            return AppNotification.fromMap(Map<String, dynamic>.from(decoded));
          } catch (_) {
            return null;
          }
        })
        .whereType<AppNotification>()
        .toList();

    notifications.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));

    return notifications;
  }

  Future<void> saveRemoteMessage(RemoteMessage message) async {
    final notification = message.notification;

    if (notification == null) {
      return;
    }

    final title = notification.title ?? '';
    final body = notification.body ?? '';

    if (title.isEmpty && body.isEmpty) {
      return;
    }

    final item = AppNotification(
      id: message.messageId ?? '${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      body: body,
      receivedAt: message.sentTime ?? DateTime.now(),
      data: Map<String, dynamic>.from(message.data),
      isRead: false,
    );

    await saveNotification(item);
  }

  Future<void> saveNotification(AppNotification notification) async {
    final notifications = await getNotifications();

    final alreadyExists = notifications.any(
      (item) => item.id == notification.id,
    );

    if (alreadyExists) {
      return;
    }

    notifications.insert(0, notification);

    await _saveNotifications(notifications);
  }

  Future<void> markAsRead(String id) async {
    final notifications = await getNotifications();

    final updated = notifications
        .map((item) => item.id == id ? item.copyWith(isRead: true) : item)
        .toList();

    await _saveNotifications(updated);
  }

  Future<void> markAllAsRead() async {
    final notifications = await getNotifications();

    final updated = notifications
        .map((item) => item.copyWith(isRead: true))
        .toList();

    await _saveNotifications(updated);
  }

  Future<void> clearAll() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_storageKey);
  }

  Future<int> getUnreadCount() async {
    final notifications = await getNotifications();

    return notifications.where((item) => !item.isRead).length;
  }

  Future<void> _saveNotifications(List<AppNotification> notifications) async {
    final preferences = await SharedPreferences.getInstance();

    final encoded = notifications
        .map((item) => jsonEncode(item.toMap()))
        .toList();

    await preferences.setStringList(_storageKey, encoded);
  }
}
