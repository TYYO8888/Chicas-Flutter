import 'package:flutter/material.dart';
import '../models/payment_method.dart';
import '../services/revel_payment_service.dart';
import '../services/loyalty_service_mock.dart';
import '../models/loyalty_program.dart';
import '../config/environment.dart';
import '../screens/feedback_screen.dart';

/// 💳 Payment Screen with Multiple Payment Options
/// Supports Apple Pay, Google Pay, Cards, PayPal, and Cash
class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final String orderId;
  final Map<String, dynamic> orderDetails;

  const PaymentScreen({
    Key? key,
    required this.totalAmount,
    required this.orderId,
    required this.orderDetails,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final RevelPaymentService _paymentService = RevelPaymentService();
  final LoyaltyService _loyaltyService = LoyaltyService();
  
  List<PaymentMethodOption> _paymentMethods = [];
  PaymentMethodOption? _selectedPaymentMethod;
  bool _isLoading = false;
  bool _isProcessingPayment = false;
  
  // Loyalty program
  LoyaltyAccount? _loyaltyAccount;
  int _pointsToRedeem = 0;
  double _discountAmount = 0.0;
  
  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
    _loadLoyaltyAccount();
  }

  /// 💳 Load available payment methods
  Future<void> _loadPaymentMethods() async {
    setState(() => _isLoading = true);

    try {
      // Load payment methods from Revel service
      final methods = await _paymentService.getAvailablePaymentMethods();

      // Add environment indicator for development
      if (EnvironmentConfig.isDevelopment) {
        debugPrint('🏪 Loaded ${methods.length} payment methods from Revel service');
        debugPrint('🔧 Environment: ${EnvironmentConfig.environmentName}');
        debugPrint('🔧 Revel Integration: ${EnvironmentConfig.isFeatureEnabled('enableRevelIntegration')}');
      }

      setState(() {
        _paymentMethods = methods;
        if (_paymentMethods.isNotEmpty) {
          _selectedPaymentMethod = _paymentMethods.first;
        }
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load payment methods: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 🏆 Load loyalty account
  Future<void> _loadLoyaltyAccount() async {
    try {
      // Mock user ID for testing
      const userId = 'test_user_123';
      final account = await _loyaltyService.getLoyaltyAccount(userId);
      setState(() => _loyaltyAccount = account);
    } catch (e) {
      debugPrint('Failed to load loyalty account: $e');
      // Set a default account if loading fails
      setState(() {
        _loyaltyAccount = LoyaltyAccount(
          userId: 'test_user_123',
          currentPoints: 1250,
          lifetimePoints: 2500,
          tier: LoyaltyTier.gold,
          joinDate: DateTime.now().subtract(const Duration(days: 90)),
          lastActivity: DateTime.now(),
          totalOrders: 25,
          totalSpent: 625.50,
          referralCode: 'CHICA123',
        );
      });
    }
  }

  /// 💰 Calculate final amount after discounts
  double get _finalAmount {
    return (widget.totalAmount - _discountAmount).clamp(0.0, double.infinity);
  }

  /// 🎁 Apply loyalty points discount
  void _applyLoyaltyDiscount(int points) {
    if (_loyaltyAccount == null || points > _loyaltyAccount!.currentPoints) {
      return;
    }

    setState(() {
      _pointsToRedeem = points;
      _discountAmount = _loyaltyService.calculateDollarValue(points);
    });
  }



  /// 💳 Process payment
  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) {
      _showErrorSnackBar('Please select a payment method');
      return;
    }

    setState(() => _isProcessingPayment = true);

    try {
      // Process payment through Revel Systems
      final result = await _paymentService.processPayment(
        paymentMethod: _selectedPaymentMethod!,
        amount: _finalAmount,
        orderId: widget.orderId,
        orderDetails: widget.orderDetails,
      );

      if (result.success) {
        // Redeem loyalty points if any
        if (_pointsToRedeem > 0 && _loyaltyAccount != null) {
          await _loyaltyService.redeemPoints(
            userId: _loyaltyAccount!.userId,
            pointsToRedeem: _pointsToRedeem,
            orderId: widget.orderId,
          );
        }

        // Award points for purchase
        if (_loyaltyAccount != null) {
          await _loyaltyService.awardPointsForPurchase(
            userId: _loyaltyAccount!.userId,
            orderId: widget.orderId,
            orderAmount: _finalAmount,
          );
        }

        _showSuccessDialog(result);
      } else {
        _showErrorSnackBar(result.error ?? 'Payment failed');
      }
    } catch (e) {
      _showErrorSnackBar('Payment processing failed: $e');
    } finally {
      setState(() => _isProcessingPayment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💳 PAYMENT'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderSummary(),
                  const SizedBox(height: 24),
                  _buildLoyaltySection(),
                  const SizedBox(height: 24),
                  _buildPaymentMethods(),
                  const SizedBox(height: 24),
                  _buildPaymentButton(),
                ],
              ),
            ),
    );
  }

  /// 📋 Build order summary
  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📋 ORDER SUMMARY',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:'),
                Text('\$${widget.totalAmount.toStringAsFixed(2)}'),
              ],
            ),
            if (_discountAmount > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Loyalty Discount ($_pointsToRedeem pts):'),
                  Text(
                    '-\$${_discountAmount.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ],
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${_finalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🏆 Build loyalty section
  Widget _buildLoyaltySection() {
    if (_loyaltyAccount == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _loyaltyAccount!.tier.icon,
                  color: _loyaltyAccount!.tier.color,
                ),
                const SizedBox(width: 8),
                Text(
                  '🏆 LOYALTY REWARDS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _loyaltyAccount!.tier.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Available Points:'),
                Text(
                  '${_loyaltyAccount!.currentPoints} pts',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Point Value:'),
                Text(
                  '\$${_loyaltyAccount!.dollarValue.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loyaltyAccount!.canRedeemPoints) ...[
              const Text('Redeem Points:'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _pointsToRedeem.toDouble(),
                      min: 0,
                      max: _loyaltyAccount!.currentPoints.toDouble(),
                      divisions: (_loyaltyAccount!.currentPoints / 100).floor(),
                      label: '$_pointsToRedeem pts',
                      onChanged: (value) {
                        _applyLoyaltyDiscount(value.round());
                      },
                    ),
                  ),
                  Text('$_pointsToRedeem pts'),
                ],
              ),
            ] else ...[
              const Text(
                'Minimum 100 points required to redeem',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 💳 Build payment methods
  Widget _buildPaymentMethods() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💳 PAYMENT METHOD',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._paymentMethods.map((method) => _buildPaymentMethodTile(method)),
          ],
        ),
      ),
    );
  }

  /// 💳 Build payment method tile
  Widget _buildPaymentMethodTile(PaymentMethodOption method) {
    final isSelected = _selectedPaymentMethod?.id == method.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          method.icon,
          color: method.color ?? Theme.of(context).primaryColor,
        ),
        title: Text(
          method.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: method.description != null ? Text(method.description!) : null,
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              )
            : null,
        onTap: () {
          setState(() => _selectedPaymentMethod = method);
        },
      ),
    );
  }

  /// 💳 Build payment button
  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isProcessingPayment ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isProcessingPayment
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('PROCESSING...'),
                ],
              )
            : Text(
                'PAY \$${_finalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  /// ✅ Show success dialog
  void _showSuccessDialog(PaymentResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Payment Successful!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transaction ID: ${result.transactionId}'),
            Text('Amount: \$${result.amount?.toStringAsFixed(2)}'),
            Text('Method: ${result.paymentMethod}'),
            if (_pointsToRedeem > 0)
              Text('Points Redeemed: $_pointsToRedeem'),
            if (result.metadata?['instructions'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange),
                ),
                child: Text(
                  result.metadata!['instructions'],
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              '📝 Help us improve by sharing your feedback!',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to previous screen
              // Navigate to home without feedback
            },
            child: const Text('SKIP'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to previous screen
              // Navigate to feedback screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FeedbackScreen(
                    orderId: widget.orderId,
                    customerEmail: 'customer@example.com', // NOTE: Get from user profile
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('GIVE FEEDBACK'),
          ),
        ],
      ),
    );
  }

  /// ❌ Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}
