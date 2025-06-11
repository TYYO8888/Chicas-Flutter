import 'dart:async';
import 'package:flutter/foundation.dart';

/// 🔄 Real-time WebSocket Service for Chica's Chicken App
/// Handles real-time order tracking and notifications
///
/// Note: This is a simplified implementation for development.
/// In production, you would use packages like 'web_socket_channel' for full WebSocket support.
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

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
  /// Note: This is a mock implementation for development
  Future<void> connect() async {
    if (_isConnected || _isConnecting) return;

    try {
      _isConnecting = true;

      // Simulate connection delay
      await Future.delayed(const Duration(milliseconds: 500));

      debugPrint('🔌 WebSocket: Simulating connection...');

      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;

      _connectionStatusController.add(true);
      _startHeartbeat();

      debugPrint('✅ WebSocket: Mock connection established');

      // Simulate some test messages
      _simulateTestMessages();

    } catch (e) {
      _isConnecting = false;
      _isConnected = false;
      _connectionStatusController.add(false);

      debugPrint('❌ WebSocket connection failed: $e');
      _scheduleReconnect();
    }
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



  /// 📤 Send message to server (Mock implementation)
  void _sendMessage(Map<String, dynamic> message) {
    if (_isConnected) {
      debugPrint('📤 WebSocket: Sending message: ${message['type']}');
      // In a real implementation, this would send to the actual WebSocket
    }
  }

  /// 🎭 Simulate test messages for development
  void _simulateTestMessages() {
    // Simulate order updates after a delay
    Timer(const Duration(seconds: 2), () {
      if (_isConnected) {
        final mockOrderUpdate = OrderUpdate(
          orderId: 'ORDER_123',
          status: 'preparing',
          estimatedTime: 15,
          message: 'Your order is being prepared',
          timestamp: DateTime.now(),
        );
        _orderUpdatesController.add(mockOrderUpdate);
      }
    });

    // Simulate notification after another delay
    Timer(const Duration(seconds: 5), () {
      if (_isConnected) {
        final mockNotification = AppNotification(
          id: 'NOTIF_456',
          type: 'order_ready',
          title: 'Order Ready!',
          message: 'Your delicious order is ready for pickup',
          timestamp: DateTime.now(),
        );
        _notificationsController.add(mockNotification);
      }
    });
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

    _isConnected = false;
    _connectionStatusController.add(false);

    debugPrint('🔌 WebSocket: Disconnected manually');
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
