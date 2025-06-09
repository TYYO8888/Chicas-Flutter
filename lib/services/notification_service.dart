// 🔔 Flutter Notification Service
// Handles push notifications, WebSocket connections, and real-time updates

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
// import 'package:firebase_core/firebase_core.dart'; // Temporarily disabled for web
// import 'package:firebase_messaging/firebase_messaging.dart'; // Temporarily disabled for web
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../config/api_config.dart';
import '../utils/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Firebase Messaging instance (temporarily disabled for web)
  // FirebaseMessaging? _messaging;
  
  // WebSocket connection
  WebSocketChannel? _channel;
  StreamSubscription? _wsSubscription;
  
  // Notification streams
  final StreamController<Map<String, dynamic>> _notificationController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  final StreamController<Map<String, dynamic>> _orderUpdateController = 
      StreamController<Map<String, dynamic>>.broadcast();

  // Public streams
  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;
  Stream<Map<String, dynamic>> get orderUpdateStream => _orderUpdateController.stream;

  // Current user ID
  String? _currentUserId;

  // 🚀 Initialize notification service
  Future<void> initialize({String? userId}) async {
    try {
      _currentUserId = userId ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
      
      // Initialize Firebase (if available)
      await _initializeFirebase();
      
      // Initialize WebSocket connection
      await _initializeWebSocket();
      
      AppLogger.info('Notification service initialized for user: $_currentUserId');
    } catch (error) {
      AppLogger.error('Failed to initialize notification service: $error');
    }
  }

  // 🔥 Initialize Firebase messaging (temporarily disabled for web)
  Future<void> _initializeFirebase() async {
    try {
      AppLogger.warning('Firebase messaging temporarily disabled for web compatibility');
      // TODO: Re-enable when Firebase web compatibility issues are resolved

      /*
      // Check if Firebase is available
      if (Firebase.apps.isEmpty) {
        AppLogger.warning('Firebase not initialized, skipping FCM setup');
        return;
      }

      _messaging = FirebaseMessaging.instance;

      // Request permission for notifications
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        AppLogger.info('User granted permission for notifications');

        // Get FCM token
        String? token = await _messaging!.getToken();
        if (token != null) {
          await _registerFCMToken(token);
        }

        // Listen for token refresh
        _messaging!.onTokenRefresh.listen(_registerFCMToken);

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle background messages
        FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      } else {
        AppLogger.warning('User declined or has not accepted notification permissions');
      }
      */

    } catch (error) {
      AppLogger.error('Failed to initialize Firebase messaging: $error');
    }
  }

  // 🌐 Initialize WebSocket connection
  Future<void> _initializeWebSocket() async {
    try {
      final wsUrl = ApiConfig.baseUrl.replaceFirst('http', 'ws');
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Register user with WebSocket server
      _channel!.sink.add(jsonEncode({
        'type': 'register',
        'userId': _currentUserId,
      }));

      // Listen for WebSocket messages
      _wsSubscription = _channel!.stream.listen(
        _handleWebSocketMessage,
        onError: _handleWebSocketError,
        onDone: _handleWebSocketClosed,
      );

      AppLogger.info('WebSocket connection established');
    } catch (error) {
      AppLogger.error('Failed to initialize WebSocket: $error');
    }
  }

  // 📱 Register FCM token with backend
  Future<void> _registerFCMToken(String token) async {
    try {
      // TODO: Send token to backend API
      // For now, just log it
      AppLogger.info('FCM Token: $token');
      
      // In a real implementation, you would send this to your backend:
      // await ApiService().post('/api/notifications/register-token', {
      //   'userId': _currentUserId,
      //   'token': token,
      // });
      
    } catch (error) {
      AppLogger.error('Failed to register FCM token: $error');
    }
  }

  // 🔔 Handle foreground messages (temporarily disabled for web)
  // void _handleForegroundMessage(RemoteMessage message) {
  //   AppLogger.info('Received foreground message: ${message.messageId}');
  //
  //   final notification = {
  //     'id': message.messageId ?? '',
  //     'title': message.notification?.title ?? '',
  //     'body': message.notification?.body ?? '',
  //     'data': message.data,
  //     'timestamp': DateTime.now().toIso8601String(),
  //     'type': 'push',
  //   };

  //   _notificationController.add(notification);

  //   // Check if it's an order update
  //   if (message.data['type'] == 'order_status') {
  //     _orderUpdateController.add({
  //       'orderId': message.data['orderId'],
  //       'status': message.data['status'],
  //       'title': message.notification?.title,
  //       'body': message.notification?.body,
  //       'timestamp': DateTime.now().toIso8601String(),
  //     });
  //   }
  // }

  // 🌐 Handle WebSocket messages
  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      AppLogger.info('Received WebSocket message: ${data['type']}');

      _notificationController.add({
        ...data,
        'type': 'websocket',
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Handle order updates
      if (data['type'] == 'notification' && data['data']?['type'] == 'order_status') {
        _orderUpdateController.add({
          'orderId': data['data']['orderId'],
          'status': data['data']['status'],
          'title': data['data']['title'],
          'body': data['data']['body'],
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

    } catch (error) {
      AppLogger.error('Failed to parse WebSocket message: $error');
    }
  }

  // ❌ Handle WebSocket errors
  void _handleWebSocketError(error) {
    AppLogger.error('WebSocket error: $error');
    // Attempt to reconnect after a delay
    Timer(const Duration(seconds: 5), () {
      _initializeWebSocket();
    });
  }

  // 🔌 Handle WebSocket connection closed
  void _handleWebSocketClosed() {
    AppLogger.warning('WebSocket connection closed');
    // Attempt to reconnect after a delay
    Timer(const Duration(seconds: 5), () {
      _initializeWebSocket();
    });
  }

  // 🧹 Dispose resources
  void dispose() {
    _wsSubscription?.cancel();
    _channel?.sink.close(status.goingAway);
    _notificationController.close();
    _orderUpdateController.close();
  }

  // 📊 Get connection status
  bool get isWebSocketConnected => _channel != null;
  bool get isFirebaseInitialized => false; // Temporarily disabled for web
}

// 🔔 Background message handler (temporarily disabled for web)
// @pragma('vm:entry-point')
// Future<void> _handleBackgroundMessage(RemoteMessage message) async {
//   AppLogger.info('Handling background message: ${message.messageId}');
//   // Handle background notification logic here
// }
