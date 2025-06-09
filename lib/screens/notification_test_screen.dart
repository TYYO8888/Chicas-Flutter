// 🔔 Notification Test Screen
// Test and demonstrate push notification functionality

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../services/notification_service.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';
import '../utils/logger.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _orderIdController = TextEditingController();
  
  bool _isLoading = false;
  String _status = 'Ready to test notifications';
  List<Map<String, dynamic>> _receivedNotifications = [];

  @override
  void initState() {
    super.initState();
    _userIdController.text = 'test_user_${DateTime.now().millisecondsSinceEpoch}';
    _orderIdController.text = 'ORD${DateTime.now().millisecondsSinceEpoch}';
    
    // Initialize notification service
    _initializeNotifications();
    
    // Listen for notifications
    _notificationService.notificationStream.listen(_onNotificationReceived);
    _notificationService.orderUpdateStream.listen(_onOrderUpdateReceived);
  }

  Future<void> _initializeNotifications() async {
    setState(() {
      _status = 'Initializing notification service...';
    });

    try {
      await _notificationService.initialize(userId: _userIdController.text);
      setState(() {
        _status = 'Notification service initialized ✅';
      });
    } catch (error) {
      setState(() {
        _status = 'Failed to initialize: $error';
      });
    }
  }

  void _onNotificationReceived(Map<String, dynamic> notification) {
    setState(() {
      _receivedNotifications.insert(0, {
        ...notification,
        'receivedAt': DateTime.now().toIso8601String(),
      });
    });
    AppLogger.info('Notification received: ${notification['title']}');
  }

  void _onOrderUpdateReceived(Map<String, dynamic> orderUpdate) {
    setState(() {
      _receivedNotifications.insert(0, {
        ...orderUpdate,
        'type': 'order_update',
        'receivedAt': DateTime.now().toIso8601String(),
      });
    });
    AppLogger.info('Order update received: ${orderUpdate['orderId']} -> ${orderUpdate['status']}');
  }

  Future<void> _sendTestNotification() async {
    setState(() {
      _isLoading = true;
      _status = 'Sending test notification...';
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications/test'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': _userIdController.text,
          'title': '🍗 Test Notification',
          'body': 'This is a test notification from Chica\'s Chicken!',
          'data': {
            'type': 'test',
            'timestamp': DateTime.now().toIso8601String(),
          },
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _status = 'Test notification sent successfully ✅';
        });
      } else {
        setState(() {
          _status = 'Failed to send notification: ${response.statusCode}';
        });
      }
    } catch (error) {
      setState(() {
        _status = 'Error sending notification: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendOrderStatusUpdate(String status) async {
    setState(() {
      _isLoading = true;
      _status = 'Sending order status update...';
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications/order-status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': _userIdController.text,
          'orderId': _orderIdController.text,
          'status': status,
          'orderDetails': {
            'items': ['Nashville Hot Chicken', 'Fries', 'Drink'],
            'total': 15.99,
          },
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _status = 'Order status update sent: $status ✅';
        });
      } else {
        setState(() {
          _status = 'Failed to send order update: ${response.statusCode}';
        });
      }
    } catch (error) {
      setState(() {
        _status = 'Error sending order update: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔔 Notification Test'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          _notificationService.isWebSocketConnected
                              ? Icons.wifi
                              : Icons.wifi_off,
                          color: _notificationService.isWebSocketConnected
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _notificationService.isWebSocketConnected
                              ? 'WebSocket Connected'
                              : 'WebSocket Disconnected',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Controls',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _userIdController,
                      decoration: const InputDecoration(
                        labelText: 'User ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    TextField(
                      controller: _orderIdController,
                      decoration: const InputDecoration(
                        labelText: 'Order ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _sendTestNotification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Send Test Notification'),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      'Order Status Updates:',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Wrap(
                      spacing: 8,
                      children: [
                        'confirmed',
                        'preparing',
                        'ready',
                        'completed',
                      ].map((status) => ElevatedButton(
                        onPressed: _isLoading ? null : () => _sendOrderStatusUpdate(status),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(status.toUpperCase()),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Received Notifications
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Received Notifications (${_receivedNotifications.length})',
                        style: AppTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Expanded(
                        child: _receivedNotifications.isEmpty
                            ? const Center(
                                child: Text('No notifications received yet'),
                              )
                            : ListView.builder(
                                itemCount: _receivedNotifications.length,
                                itemBuilder: (context, index) {
                                  final notification = _receivedNotifications[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: Icon(
                                        notification['type'] == 'order_update'
                                            ? Icons.restaurant
                                            : Icons.notifications,
                                        color: AppColors.primary,
                                      ),
                                      title: Text(
                                        notification['title'] ?? 'Notification',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(notification['body'] ?? ''),
                                          if (notification['orderId'] != null)
                                            Text(
                                              'Order: ${notification['orderId']}',
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          Text(
                                            'Received: ${notification['receivedAt']}',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      isThreeLine: true,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
