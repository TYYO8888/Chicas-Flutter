import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/order.dart';

/// 🔄 Real-time WebSocket Service for Chica's Chicken App
/// Handles real-time order tracking and notifications
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  
  bool _isConnected = false;
  bool _isConnecting = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _reconnectDelay = Duration(seconds: 5);

  // Stream controllers for different types of updates
  final StreamController<OrderUpdate> _orderUpdatesController = 
      StreamController<OrderUpdate>.broadcast();
  final StreamController<AppNotification> _notificationsController = 
      StreamController<AppNotification>.broadcast();
  final StreamController<bool> _connectionStatusController = 
      StreamController<bool>.broadcast();

  // Public streams
  Stream<OrderUpdate> get orderUpdates => _orderUpdatesController.stream;
  Stream<AppNotification> get notifications => _notificationsController.stream;
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  bool get isConnected => _isConnected;

  /// 🔌 Connect to WebSocket server
  Future<void> connect() async {
    if (_isConnected || _isConnecting) return;

    try {
      _isConnecting = true;
      
      // Get authentication token
      final authService = AuthService();
      final token = await authService.getToken();
      
      if (token == null) {
        throw Exception('No authentication token available');
      }

      // Build WebSocket URL
      final wsUrl = _buildWebSocketUrl(token);
      
      debugPrint('Connecting to WebSocket: $wsUrl');
      
      // Create WebSocket connection
      _channel = IOWebSocketChannel.connect(
        wsUrl,
        protocols: ['echo-protocol'],
      );

      // Listen to messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );

      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;
      
      _connectionStatusController.add(true);
      _startHeartbeat();
      
      debugPrint('WebSocket connected successfully');
      
    } catch (e) {
      _isConnecting = false;
      _isConnected = false;
      _connectionStatusController.add(false);
      
      debugPrint('WebSocket connection failed: $e');
      _scheduleReconnect();
    }
  }

  /// 🔗 Build WebSocket URL with authentication
  String _buildWebSocketUrl(String token) {
    const baseUrl = kDebugMode 
        ? 'ws://localhost:3000/ws'
        : 'wss://your-production-domain.com/ws';
    
    return '$baseUrl?token=$token';
  }

  /// 📨 Handle incoming messages
  void _handleMessage(dynamic data) {
    try {
      final message = jsonDecode(data as String);
      debugPrint('WebSocket message received: $message');
      
      switch (message['type']) {
        case 'connection':
          debugPrint('WebSocket connection confirmed');
          break;
          
        case 'order_update':
          _handleOrderUpdate(message);
          break;
          
        case 'notification':
          _handleNotification(message);
          break;
          
        case 'pong':
          // Heartbeat response
          break;
          
        case 'error':
          debugPrint('WebSocket error: ${message['message']}');
          break;
          
        default:
          debugPrint('Unknown message type: ${message['type']}');
      }
    } catch (e) {
      debugPrint('Error parsing WebSocket message: $e');
    }
  }

  /// 🛒 Handle order update messages
  void _handleOrderUpdate(Map<String, dynamic> message) {
    try {
      final orderId = message['orderId'] as String;
      final update = message['update'] as Map<String, dynamic>;
      final timestamp = DateTime.parse(message['timestamp'] as String);
      
      final orderUpdate = OrderUpdate(
        orderId: orderId,
        status: update['status'] as String,
        estimatedTime: update['estimatedTime'] as int?,
        message: update['message'] as String?,
        timestamp: timestamp,
      );
      
      _orderUpdatesController.add(orderUpdate);
    } catch (e) {
      debugPrint('Error handling order update: $e');
    }
  }

  /// 🔔 Handle notification messages
  void _handleNotification(Map<String, dynamic> message) {
    try {
      final notification = message['notification'] as Map<String, dynamic>;
      final timestamp = DateTime.parse(message['timestamp'] as String);
      
      final appNotification = AppNotification(
        id: notification['id'] as String,
        type: notification['type'] as String,
        title: notification['title'] as String,
        message: notification['message'] as String,
        timestamp: timestamp,
        data: notification['data'] as Map<String, dynamic>?,
      );
      
      _notificationsController.add(appNotification);
    } catch (e) {
      debugPrint('Error handling notification: $e');
    }
  }

  /// ❌ Handle WebSocket errors
  void _handleError(dynamic error) {
    debugPrint('WebSocket error: $error');
    _isConnected = false;
    _connectionStatusController.add(false);
    _scheduleReconnect();
  }

  /// 🔌 Handle disconnection
  void _handleDisconnection() {
    debugPrint('WebSocket disconnected');
    _isConnected = false;
    _connectionStatusController.add(false);
    _stopHeartbeat();
    _scheduleReconnect();
  }

  /// 🔄 Schedule reconnection
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('Max reconnection attempts reached');
      return;
    }

    _reconnectAttempts++;
    final delay = _reconnectDelay * _reconnectAttempts;
    
    debugPrint('Scheduling reconnection attempt $_reconnectAttempts in ${delay.inSeconds}s');
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (!_isConnected) {
        connect();
      }
    });
  }

  /// 💓 Start heartbeat to keep connection alive
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_isConnected) {
        _sendMessage({'type': 'ping'});
      }
    });
  }

  /// 💓 Stop heartbeat
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// 📤 Send message to server
  void _sendMessage(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  /// 🛒 Join order room for real-time updates
  void joinOrderRoom(String orderId) {
    _sendMessage({
      'type': 'join_order',
      'orderId': orderId,
    });
  }

  /// 🚪 Leave order room
  void leaveOrderRoom(String orderId) {
    _sendMessage({
      'type': 'leave_order',
      'orderId': orderId,
    });
  }

  /// 🔔 Subscribe to notifications
  void subscribeToNotifications() {
    _sendMessage({
      'type': 'subscribe_notifications',
    });
  }

  /// 🔌 Disconnect from WebSocket
  void disconnect() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    
    _channel?.sink.close();
    _channel = null;
    
    _isConnected = false;
    _connectionStatusController.add(false);
    
    debugPrint('WebSocket disconnected manually');
  }

  /// 🧹 Dispose resources
  void dispose() {
    disconnect();
    _orderUpdatesController.close();
    _notificationsController.close();
    _connectionStatusController.close();
  }
}

/// 🛒 Order Update Model
class OrderUpdate {
  final String orderId;
  final String status;
  final int? estimatedTime;
  final String? message;
  final DateTime timestamp;

  OrderUpdate({
    required this.orderId,
    required this.status,
    this.estimatedTime,
    this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'status': status,
      'estimatedTime': estimatedTime,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory OrderUpdate.fromJson(Map<String, dynamic> json) {
    return OrderUpdate(
      orderId: json['orderId'],
      status: json['status'],
      estimatedTime: json['estimatedTime'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// 🔔 App Notification Model
class AppNotification {
  final String id;
  final String type;
  final String title;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      data: json['data'],
    );
  }
}
