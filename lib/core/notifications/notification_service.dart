import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../firebase_options.dart';
import 'notification_local_data_source.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationLocalDataSource.instance.saveRemoteMessage(message);
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String newContentTopic = 'new_content';

  static const String _newContentChannelId = 'new_content';
  static const String _newContentChannelName = 'New Content';
  static const String _newContentChannelDescription =
      'Notifications for newly added content';

  static const String _continueReminderChannelId = 'continue_reminders';
  static const String _continueReminderChannelName = 'Continue Reminders';
  static const String _continueReminderChannelDescription =
      'Reminders to continue unfinished content';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final StreamController<Map<String, dynamic>> _notificationTapController =
      StreamController<Map<String, dynamic>>.broadcast();

  final StreamController<void> _notificationChangedController =
      StreamController<void>.broadcast();

  Stream<Map<String, dynamic>> get notificationTapStream =>
      _notificationTapController.stream;

  Stream<void> get notificationChangedStream =>
      _notificationChangedController.stream;

  Map<String, dynamic>? _pendingNotificationData;

  static const AndroidNotificationChannel _newContentChannel =
      AndroidNotificationChannel(
        _newContentChannelId,
        _newContentChannelName,
        description: _newContentChannelDescription,
        importance: Importance.high,
      );

  static const AndroidNotificationChannel _continueReminderChannel =
      AndroidNotificationChannel(
        _continueReminderChannelId,
        _continueReminderChannelName,
        description: _continueReminderChannelDescription,
        importance: Importance.defaultImportance,
      );

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    tz.initializeTimeZones();

    await _initializeLocalNotifications();
    await _requestPermission();
    await _configureForegroundPresentation();

    _configureForegroundMessages();
    _configureNotificationTaps();
    _configureTokenRefresh();

    await subscribeToNewContent();

    await _handleInitialLocalNotification();
    await _handleInitialRemoteMessage();

    final token = await getTokenSafely();

    debugPrint('FCM TOKEN: $token');
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(_newContentChannel);

    await androidPlugin?.createNotificationChannel(_continueReminderChannel);
  }

  Future<NotificationSettings> _requestPermission() {
    return _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
  }

  Future<void> _configureForegroundPresentation() {
    return _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );
  }

  void _configureForegroundMessages() {
    FirebaseMessaging.onMessage.listen((message) async {
      await NotificationLocalDataSource.instance.saveRemoteMessage(message);

      _notificationChangedController.add(null);

      await _showForegroundNotification(message);
    });
  }

  void _configureNotificationTaps() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      await NotificationLocalDataSource.instance.saveRemoteMessage(message);

      _notificationChangedController.add(null);

      _handleNotificationData(message.data);
    });
  }

  void _configureTokenRefresh() {
    _messaging.onTokenRefresh.listen((token) async {
      debugPrint('FCM TOKEN REFRESHED');

      await subscribeToNewContent();
    });
  }

  Future<void> _handleInitialRemoteMessage() async {
    final message = await _messaging.getInitialMessage();

    if (message == null) {
      return;
    }

    await NotificationLocalDataSource.instance.saveRemoteMessage(message);

    _notificationChangedController.add(null);

    _handleNotificationData(message.data);
  }

  Future<void> _handleInitialLocalNotification() async {
    final launchDetails = await _localNotifications
        .getNotificationAppLaunchDetails();

    if (launchDetails == null ||
        launchDetails.didNotificationLaunchApp != true) {
      return;
    }

    final response = launchDetails.notificationResponse;

    if (response == null) {
      return;
    }

    _handleLocalNotificationPayload(response.payload);
  }

  Future<void> subscribeToNewContent() async {
    try {
      await _messaging.subscribeToTopic(newContentTopic);

      debugPrint('SUBSCRIBED TO TOPIC: $newContentTopic');
    } catch (error) {
      debugPrint('TOPIC SUBSCRIBE ERROR: $error');
    }
  }

  Future<void> unsubscribeFromNewContent() async {
    try {
      await _messaging.unsubscribeFromTopic(newContentTopic);

      debugPrint('UNSUBSCRIBED FROM TOPIC: $newContentTopic');
    } catch (error) {
      debugPrint('TOPIC UNSUBSCRIBE ERROR: $error');
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;

    if (notification == null) {
      return;
    }

    final title = notification.title;
    final body = notification.body;

    if (title == null && body == null) {
      return;
    }

    final payload = message.data.isEmpty ? null : jsonEncode(message.data);

    const androidDetails = AndroidNotificationDetails(
      _newContentChannelId,
      _newContentChannelName,
      channelDescription: _newContentChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _localNotifications.show(
      message.messageId.hashCode,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> scheduleContinueReminder({
    required int id,
    required String title,
    required String body,
    required Duration delay,
    required Map<String, dynamic> data,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    await _localNotifications.cancel(id);

    final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);

    final payload = jsonEncode(data);

    const androidDetails = AndroidNotificationDetails(
      _continueReminderChannelId,
      _continueReminderChannelName,
      channelDescription: _continueReminderChannelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> cancelLocalNotification(int id) async {
    if (!_initialized) {
      await initialize();
    }

    await _localNotifications.cancel(id);
  }

  Future<void> cancelLocalNotifications(Iterable<int> ids) async {
    if (!_initialized) {
      await initialize();
    }

    for (final id in ids) {
      await _localNotifications.cancel(id);
    }
  }

  void _onLocalNotificationTapped(NotificationResponse response) {
    _handleLocalNotificationPayload(response.payload);
  }

  void _handleLocalNotificationPayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(payload);

      if (decoded is! Map) {
        return;
      }

      final data = Map<String, dynamic>.from(decoded);

      _handleNotificationData(data);
    } catch (error) {
      debugPrint('NOTIFICATION PAYLOAD ERROR: $error');
    }
  }

  void _handleNotificationData(Map<String, dynamic> data) {
    if (data.isEmpty) {
      return;
    }

    debugPrint('NOTIFICATION OPENED: $data');

    if (!_notificationTapController.hasListener) {
      _pendingNotificationData = data;
      return;
    }

    _notificationTapController.add(data);
  }

  void openNotificationData(Map<String, dynamic> data) {
    if (data.isEmpty) {
      return;
    }

    _handleNotificationData(data);
  }

  Map<String, dynamic>? consumePendingNotificationData() {
    final data = _pendingNotificationData;

    _pendingNotificationData = null;

    return data;
  }

  Future<String?> getTokenSafely() async {
    try {
      if (Platform.isIOS) {
        final apnsToken = await _messaging.getAPNSToken();

        if (apnsToken == null) {
          debugPrint('APNS TOKEN: not available yet');

          return null;
        }
      }

      return await _messaging.getToken();
    } catch (error) {
      debugPrint('FCM TOKEN ERROR: $error');

      return null;
    }
  }
}
