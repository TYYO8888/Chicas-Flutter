import 'package:flutter/material.dart';
import 'dart:async';

/// 🛒 Real-time Order Tracking Widget
/// Shows live updates of order status with beautiful animations
class RealTimeOrderTracker extends StatefulWidget {
  final String orderId;
  final VoidCallback? onOrderComplete;

  const RealTimeOrderTracker({
    Key? key,
    required this.orderId,
    this.onOrderComplete,
  }) : super(key: key);

  @override
  State<RealTimeOrderTracker> createState() => _RealTimeOrderTrackerState();
}

class _RealTimeOrderTrackerState extends State<RealTimeOrderTracker>
    with TickerProviderStateMixin {
  
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  
  Timer? _statusUpdateTimer;
  int _currentStep = 0;
  String _currentStatus = 'Order Received';
  String _estimatedTime = '15-20 minutes';
  // bool _isComplete = false;

  final List<OrderStep> _orderSteps = [
    OrderStep(
      title: 'Order Received',
      description: 'We\'ve received your order and are preparing it',
      icon: Icons.receipt_long,
      color: Colors.blue,
    ),
    OrderStep(
      title: 'Preparing',
      description: 'Our chefs are cooking your delicious meal',
      icon: Icons.restaurant,
      color: Colors.orange,
    ),
    OrderStep(
      title: 'Almost Ready',
      description: 'Final touches being added to your order',
      icon: Icons.timer,
      color: Colors.amber,
    ),
    OrderStep(
      title: 'Ready for Pickup',
      description: 'Your order is ready! Please come collect it',
      icon: Icons.check_circle,
      color: Colors.green,
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticOut,
    ));
    
    _startOrderTracking();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _statusUpdateTimer?.cancel();
    super.dispose();
  }

  /// 🔄 Start simulated order tracking
  void _startOrderTracking() {
    _progressController.forward();
    
    // Simulate real-time updates
    _statusUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentStep < _orderSteps.length - 1) {
        setState(() {
          _currentStep++;
          _currentStatus = _orderSteps[_currentStep].title;
          _updateEstimatedTime();
        });
        
        _pulseController.forward().then((_) {
          _pulseController.reverse();
        });
        
        _progressController.reset();
        _progressController.forward();
      } else {
        _completeOrder();
        timer.cancel();
      }
    });
  }

  /// ✅ Complete the order
  void _completeOrder() {
    setState(() {
      // _isComplete = true;
      _currentStatus = 'Order Complete!';
      _estimatedTime = 'Ready now';
    });
    
    _pulseController.repeat(reverse: true);
    widget.onOrderComplete?.call();
  }

  /// ⏰ Update estimated time
  void _updateEstimatedTime() {
    switch (_currentStep) {
      case 0:
        _estimatedTime = '15-20 minutes';
        break;
      case 1:
        _estimatedTime = '10-15 minutes';
        break;
      case 2:
        _estimatedTime = '5-10 minutes';
        break;
      case 3:
        _estimatedTime = 'Ready now!';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          
          const SizedBox(height: 32),
          
          // Progress Steps
          _buildProgressSteps(),
          
          const SizedBox(height: 32),
          
          // Current Status Card
          _buildCurrentStatusCard(),
          
          const SizedBox(height: 24),
          
          // Estimated Time
          _buildEstimatedTime(),
        ],
      ),
    );
  }

  /// 📋 Build header
  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Order #${widget.orderId}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Real-time tracking',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 📊 Build progress steps
  Widget _buildProgressSteps() {
    return Column(
      children: List.generate(_orderSteps.length, (index) {
        final step = _orderSteps[index];
        final isActive = index <= _currentStep;
        final isCurrent = index == _currentStep;
        
        return _buildStepItem(step, index, isActive, isCurrent);
      }),
    );
  }

  /// 📍 Build individual step item
  Widget _buildStepItem(OrderStep step, int index, bool isActive, bool isCurrent) {
    return Row(
      children: [
        // Step indicator
        AnimatedBuilder(
          animation: isCurrent ? _pulseAnimation : 
                     const AlwaysStoppedAnimation(1.0),
          builder: (context, child) {
            return Transform.scale(
              scale: isCurrent ? _pulseAnimation.value : 1.0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive ? step.color : Colors.grey[300],
                  shape: BoxShape.circle,
                  boxShadow: isActive ? [
                    BoxShadow(
                      color: step.color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ] : null,
                ),
                child: Icon(
                  step.icon,
                  color: isActive ? Colors.white : Colors.grey[600],
                  size: 20,
                ),
              ),
            );
          },
        ),
        
        const SizedBox(width: 16),
        
        // Step content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? step.color : Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                step.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        
        // Progress line
        if (index < _orderSteps.length - 1)
          Container(
            width: 2,
            height: 40,
            margin: const EdgeInsets.only(left: 19, top: 40),
            decoration: BoxDecoration(
              color: index < _currentStep ? step.color : Colors.grey[300],
              borderRadius: BorderRadius.circular(1),
            ),
          ),
      ],
    );
  }

  /// 📱 Build current status card
  Widget _buildCurrentStatusCard() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _orderSteps[_currentStep].color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _orderSteps[_currentStep].color.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                _orderSteps[_currentStep].icon,
                size: 32,
                color: _orderSteps[_currentStep].color,
              ),
              const SizedBox(height: 12),
              Text(
                _currentStatus,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _orderSteps[_currentStep].color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _orderSteps[_currentStep].description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation(_orderSteps[_currentStep].color),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ⏰ Build estimated time
  Widget _buildEstimatedTime() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.access_time,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Estimated time: $_estimatedTime',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// 📍 Order Step Model
class OrderStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OrderStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
