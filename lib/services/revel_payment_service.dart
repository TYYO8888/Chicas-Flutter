import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/payment_method.dart';
import '../models/revel_models.dart';
import '../services/revel_api_service.dart';
import '../config/revel_config.dart';

/// 💳 Revel Systems Payment Service
/// Handles payment processing through Revel Systems POS API
class RevelPaymentService {
  static final RevelPaymentService _instance = RevelPaymentService._internal();
  factory RevelPaymentService() => _instance;
  RevelPaymentService._internal();

  final RevelApiService _revelApi = RevelApiService();
  
  /// 🚀 Initialize payment service
  Future<void> initialize() async {
    await _revelApi.initialize();
  }

  /// 💳 Process payment through Revel Systems
  Future<PaymentResult> processPayment({
    required PaymentMethodOption paymentMethod,
    required double amount,
    required String orderId,
    required Map<String, dynamic> orderDetails,
    int? customerId,
  }) async {
    try {
      debugPrint('🏪 Processing payment through Revel Systems');
      debugPrint('Payment Method: ${paymentMethod.name}');
      debugPrint('Amount: \$${amount.toStringAsFixed(2)}');
      debugPrint('Order ID: $orderId');

      // Convert payment method to Revel payment type
      final revelPaymentType = _mapPaymentMethodToRevelType(paymentMethod.type);
      
      // Create payment in Revel system
      final revelPayment = await _createRevelPayment(
        orderId: orderId,
        paymentType: revelPaymentType,
        paymentMethod: paymentMethod.name,
        amount: amount,
        orderDetails: orderDetails,
      );

      // Process payment based on type
      PaymentResult result;
      switch (paymentMethod.type) {
        case PaymentType.card:
          result = await _processCardPayment(revelPayment, paymentMethod);
          break;
        case PaymentType.applePay:
          result = await _processApplePayPayment(revelPayment, paymentMethod);
          break;
        case PaymentType.googlePay:
          result = await _processGooglePayPayment(revelPayment, paymentMethod);
          break;
        case PaymentType.paypal:
          result = await _processPayPalPayment(revelPayment, paymentMethod);
          break;
        case PaymentType.cash:
          result = await _processCashPayment(revelPayment, paymentMethod);
          break;
      }

      // Update payment status in Revel if successful
      if (result.success && revelPayment.id != null) {
        await _updatePaymentStatus(revelPayment.id!, 'COMPLETED');
      }

      return result;

    } catch (e) {
      debugPrint('❌ Payment processing failed: $e');
      return PaymentResult(
        success: false,
        error: 'Payment processing failed: $e',
        transactionId: null,
      );
    }
  }

  /// 🏪 Create payment record in Revel system
  Future<RevelPayment> _createRevelPayment({
    required String orderId,
    required String paymentType,
    required String paymentMethod,
    required double amount,
    required Map<String, dynamic> orderDetails,
  }) async {
    try {
      // In a real implementation, you would first create/get the order in Revel
      // For now, we'll simulate this
      final revelOrderId = int.tryParse(orderId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 
                          DateTime.now().millisecondsSinceEpoch;

      return await _revelApi.createPayment(
        orderId: revelOrderId,
        paymentType: paymentType,
        amount: amount,
        paymentMethod: paymentMethod,
        paymentData: {
          'app_order_id': orderId,
          'order_details': orderDetails,
          'establishment_id': RevelConfig.establishmentId,
          'terminal_id': RevelConfig.terminalId,
        },
      );
    } catch (e) {
      debugPrint('❌ Failed to create Revel payment: $e');
      // Return mock payment for demo purposes
      return RevelPayment(
        id: DateTime.now().millisecondsSinceEpoch,
        orderId: int.tryParse(orderId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        paymentType: paymentType,
        paymentMethod: paymentMethod,
        amount: amount,
        status: 'PENDING',
        createdAt: DateTime.now(),
      );
    }
  }

  /// 💳 Process credit/debit card payment
  Future<PaymentResult> _processCardPayment(
    RevelPayment revelPayment,
    PaymentMethodOption paymentMethod,
  ) async {
    try {
      // Simulate card processing delay
      await Future.delayed(const Duration(seconds: 2));

      // In a real implementation, this would:
      // 1. Collect card details securely
      // 2. Process through Revel's payment processor
      // 3. Handle 3D Secure if required
      // 4. Return actual transaction result

      final transactionId = 'revel_card_${DateTime.now().millisecondsSinceEpoch}';
      
      return PaymentResult(
        success: true,
        transactionId: transactionId,
        paymentMethod: paymentMethod.name,
        amount: revelPayment.amount,
        metadata: {
          'revel_payment_id': revelPayment.id,
          'payment_type': revelPayment.paymentType,
          'processor': 'Revel Systems',
        },
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        error: 'Card payment failed: $e',
        transactionId: null,
      );
    }
  }

  /// 🍎 Process Apple Pay payment
  Future<PaymentResult> _processApplePayPayment(
    RevelPayment revelPayment,
    PaymentMethodOption paymentMethod,
  ) async {
    try {
      // Simulate Apple Pay processing
      await Future.delayed(const Duration(milliseconds: 800));

      // In a real implementation, this would:
      // 1. Initialize Apple Pay session
      // 2. Process payment token through Revel
      // 3. Handle Apple Pay specific responses

      final transactionId = 'revel_ap_${DateTime.now().millisecondsSinceEpoch}';
      
      return PaymentResult(
        success: true,
        transactionId: transactionId,
        paymentMethod: paymentMethod.name,
        amount: revelPayment.amount,
        metadata: {
          'revel_payment_id': revelPayment.id,
          'payment_type': revelPayment.paymentType,
          'processor': 'Apple Pay via Revel',
        },
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        error: 'Apple Pay failed: $e',
        transactionId: null,
      );
    }
  }

  /// 🤖 Process Google Pay payment
  Future<PaymentResult> _processGooglePayPayment(
    RevelPayment revelPayment,
    PaymentMethodOption paymentMethod,
  ) async {
    try {
      // Simulate Google Pay processing
      await Future.delayed(const Duration(milliseconds: 800));

      final transactionId = 'revel_gp_${DateTime.now().millisecondsSinceEpoch}';
      
      return PaymentResult(
        success: true,
        transactionId: transactionId,
        paymentMethod: paymentMethod.name,
        amount: revelPayment.amount,
        metadata: {
          'revel_payment_id': revelPayment.id,
          'payment_type': revelPayment.paymentType,
          'processor': 'Google Pay via Revel',
        },
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        error: 'Google Pay failed: $e',
        transactionId: null,
      );
    }
  }

  /// 💰 Process PayPal payment
  Future<PaymentResult> _processPayPalPayment(
    RevelPayment revelPayment,
    PaymentMethodOption paymentMethod,
  ) async {
    try {
      // Simulate PayPal processing
      await Future.delayed(const Duration(milliseconds: 1500));

      final transactionId = 'revel_pp_${DateTime.now().millisecondsSinceEpoch}';
      
      return PaymentResult(
        success: true,
        transactionId: transactionId,
        paymentMethod: paymentMethod.name,
        amount: revelPayment.amount,
        metadata: {
          'revel_payment_id': revelPayment.id,
          'payment_type': revelPayment.paymentType,
          'processor': 'PayPal via Revel',
        },
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        error: 'PayPal payment failed: $e',
        transactionId: null,
      );
    }
  }

  /// 💵 Process cash payment
  Future<PaymentResult> _processCashPayment(
    RevelPayment revelPayment,
    PaymentMethodOption paymentMethod,
  ) async {
    try {
      // Cash payments are instant in the system
      await Future.delayed(const Duration(milliseconds: 500));

      final transactionId = 'revel_cash_${DateTime.now().millisecondsSinceEpoch}';
      
      return PaymentResult(
        success: true,
        transactionId: transactionId,
        paymentMethod: paymentMethod.name,
        amount: revelPayment.amount,
        metadata: {
          'revel_payment_id': revelPayment.id,
          'payment_type': revelPayment.paymentType,
          'processor': 'Revel Systems',
          'instructions': 'Please pay cash when collecting your order at ${RevelConfig.storeName}',
        },
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        error: 'Cash payment registration failed: $e',
        transactionId: null,
      );
    }
  }

  /// 🔄 Update payment status in Revel
  Future<void> _updatePaymentStatus(int paymentId, String status) async {
    try {
      // In a real implementation, this would update the payment status in Revel
      debugPrint('🏪 Updating Revel payment $paymentId status to $status');
    } catch (e) {
      debugPrint('❌ Failed to update payment status: $e');
    }
  }

  /// 🔄 Refund payment through Revel
  Future<bool> refundPayment({
    required String transactionId,
    required double amount,
    String? reason,
  }) async {
    try {
      // Extract Revel payment ID from transaction ID or metadata
      final paymentId = _extractRevelPaymentId(transactionId);
      if (paymentId == null) {
        throw Exception('Invalid transaction ID for Revel refund');
      }

      await _revelApi.refundPayment(
        paymentId: paymentId,
        amount: amount,
        reason: reason ?? 'Customer request',
      );

      debugPrint('🏪 Revel refund processed: $transactionId');
      return true;
    } catch (e) {
      debugPrint('❌ Revel refund failed: $e');
      return false;
    }
  }

  /// 🔍 Get payment status from Revel
  Future<String?> getPaymentStatus(String transactionId) async {
    try {
      final paymentId = _extractRevelPaymentId(transactionId);
      if (paymentId == null) return null;

      // In a real implementation, this would query Revel for payment status
      return 'COMPLETED'; // Mock status
    } catch (e) {
      debugPrint('❌ Failed to get payment status: $e');
      return null;
    }
  }

  /// 🔧 Helper Methods

  /// Map Flutter payment type to Revel payment type
  String _mapPaymentMethodToRevelType(PaymentType type) {
    switch (type) {
      case PaymentType.card:
        return 'CREDIT_CARD';
      case PaymentType.applePay:
      case PaymentType.googlePay:
        return 'MOBILE_PAYMENT';
      case PaymentType.paypal:
        return 'DIGITAL_WALLET';
      case PaymentType.cash:
        return 'CASH';
    }
  }

  /// Extract Revel payment ID from transaction ID
  int? _extractRevelPaymentId(String transactionId) {
    // In a real implementation, you would store the mapping between
    // transaction IDs and Revel payment IDs
    return DateTime.now().millisecondsSinceEpoch; // Mock ID
  }

  /// 📊 Get available payment methods from Revel
  Future<List<PaymentMethodOption>> getAvailablePaymentMethods() async {
    try {
      // In a real implementation, this would query Revel for enabled payment methods
      return [
        PaymentMethodOption(
          id: 'revel_card',
          name: 'Credit/Debit Card',
          icon: Icons.credit_card,
          type: PaymentType.card,
          isAvailable: true,
          description: 'Processed by Revel Systems',
          color: Colors.blue,
        ),
        PaymentMethodOption(
          id: 'revel_apple_pay',
          name: 'Apple Pay',
          icon: Icons.apple,
          type: PaymentType.applePay,
          isAvailable: true,
          description: 'Touch ID or Face ID',
          color: Colors.black,
        ),
        PaymentMethodOption(
          id: 'revel_google_pay',
          name: 'Google Pay',
          icon: Icons.payment,
          type: PaymentType.googlePay,
          isAvailable: true,
          description: 'Quick and secure',
          color: Colors.green,
        ),
        PaymentMethodOption(
          id: 'revel_paypal',
          name: 'PayPal',
          icon: Icons.account_balance_wallet,
          type: PaymentType.paypal,
          isAvailable: true,
          description: 'Pay with PayPal',
          color: Colors.indigo,
        ),
        PaymentMethodOption(
          id: 'revel_cash',
          name: 'Cash on Pickup',
          icon: Icons.money,
          type: PaymentType.cash,
          isAvailable: true,
          description: 'Pay at ${RevelConfig.storeName}',
          color: Colors.orange,
        ),
      ];
    } catch (e) {
      debugPrint('❌ Failed to get payment methods: $e');
      return [];
    }
  }

  /// 🔐 Validate Revel configuration
  bool get isConfigured => RevelConfig.isConfigured;
  
  /// ⚠️ Get configuration warnings
  List<String> get configurationWarnings => RevelConfig.configurationWarnings;
}
