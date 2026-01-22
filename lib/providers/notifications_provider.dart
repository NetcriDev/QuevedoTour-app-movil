import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';
import '../services/auth_service.dart';
import '../services/local_storage.dart';
import '../models/notification_model.dart';

class NotificationsProvider with ChangeNotifier {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final AuthService _authService = AuthService();
  final LocalStorage _localStorage = LocalStorage();
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  String? _token;
  String? get token => _token;

  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  bool _isInitialized = false;

  Future<void> initNotifications(String? userId) async {
    // Always load local notifications even if FCM is already initialized
    await _loadLocalNotifications();

    if (_isInitialized) return;

    // 1. Request Permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permissions');
      
      // 2. Initialize Local Notifications for Foreground
      await _initLocalNotifications();

      // 3. Get FCM Token
      try {
        _token = await _fcm.getToken();
        debugPrint('FCM Token: $_token');
        
        if (userId != null && _token != null) {
          await _authService.updateNotificationToken(userId, _token!);
        }
      } catch (e) {
        debugPrint('Error getting FCM token: $e');
      }

      // 4. Handle Incoming Messages
      _setupMessageHandlers();

      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _loadLocalNotifications() async {
    final data = await _localStorage.getNotifications();
    _notifications = data.map((json) => AppNotification.fromJson(json)).toList();
    notifyListeners();
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        debugPrint('Notification tapped: ${details.payload}');
      },
    );

    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  void _setupMessageHandlers() {
    // 1. Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('Got a message whilst in the foreground!');
      
      if (message.notification != null) {
        await _handleIncomingNotification(message);
        _showLocalNotification(message);
      }
    });

    // 2. When app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
    });
  }

  Future<void> _handleIncomingNotification(RemoteMessage message) async {
    final notification = AppNotification(
      id: message.messageId ?? const Uuid().v4(),
      title: message.notification?.title ?? 'Nueva notificación',
      body: message.notification?.body ?? '',
      timestamp: DateTime.now(),
      payload: message.data,
    );

    await _localStorage.saveNotification(notification.toJson());
    // Add to top of list
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  }

  Future<void> markAsRead(String id) async {
    await _localStorage.markNotificationAsRead(id);
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  Future<void> clearAll() async {
    await _localStorage.clearNotifications();
    _notifications = [];
    notifyListeners();
  }

  Future<void> updateToken(String userId) async {
    if (_token != null) {
      await _authService.updateNotificationToken(userId, _token!);
    }
  }
}
