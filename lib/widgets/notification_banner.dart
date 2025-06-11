// 🔔 Notification Banner Widget
// Displays real-time notifications and order updates

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/notification_service.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';

class NotificationBanner extends StatefulWidget {
  const NotificationBanner({super.key});

  @override
  State<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<NotificationBanner>
    with TickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  Map<String, dynamic>? _currentNotification;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Listen for notifications
    _notificationService.notificationStream.listen(_handleNotification);
    _notificationService.orderUpdateStream.listen(_handleOrderUpdate);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleNotification(Map<String, dynamic> notification) {
    setState(() {
      _currentNotification = notification;
    });
    _showNotification();
  }

  void _handleOrderUpdate(Map<String, dynamic> orderUpdate) {
    final notification = {
      'title': orderUpdate['title'] ?? '🍗 Order Update',
      'body': orderUpdate['body'] ?? 'Your order status has been updated',
      'type': 'order_update',
      'orderId': orderUpdate['orderId'],
      'status': orderUpdate['status'],
      'timestamp': orderUpdate['timestamp'],
    };

    setState(() {
      _currentNotification = notification;
    });
    _showNotification();
  }

  void _showNotification() {
    _animationController.forward();
    
    // Auto-hide after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _hideNotification();
      }
    });
  }

  void _hideNotification() {
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _currentNotification = null;
        });
      }
    });
  }

  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'order_update':
        return AppColors.primary;
      case 'promotion':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'order_update':
        return Icons.restaurant;
      case 'promotion':
        return Icons.local_offer;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentNotification == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value * 100),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getNotificationColor(_currentNotification!['type']),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getNotificationColor(_currentNotification!['type'])
                            .withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getNotificationColor(_currentNotification!['type'])
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getNotificationIcon(_currentNotification!['type']),
                          color: _getNotificationColor(_currentNotification!['type']),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentNotification!['title'] ?? 'Notification',
                              style: AppTypography.headlineSmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentNotification!['body'] ?? '',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_currentNotification!['orderId'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Order #${_currentNotification!['orderId']}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: _getNotificationColor(_currentNotification!['type']),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _hideNotification,
                        icon: const Icon(Icons.close),
                        iconSize: 20,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ).animate()
      .shimmer(
        duration: const Duration(seconds: 2),
        color: _getNotificationColor(_currentNotification!['type']).withValues(alpha: 0.3),
      );
  }
}
