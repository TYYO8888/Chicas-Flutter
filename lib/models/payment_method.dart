import 'package:flutter/material.dart';

/// 💳 Payment Method Types
enum PaymentType {
  card,
  applePay,
  googlePay,
  paypal,
  cash,
}

/// 💳 Payment Method Option
class PaymentMethodOption {
  final String id;
  final String name;
  final IconData icon;
  final PaymentType type;
  final bool isAvailable;
  final String? description;
  final Color? color;

  PaymentMethodOption({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    required this.isAvailable,
    this.description,
    this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'isAvailable': isAvailable,
      'description': description,
    };
  }

  factory PaymentMethodOption.fromJson(Map<String, dynamic> json) {
    return PaymentMethodOption(
      id: json['id'],
      name: json['name'],
      icon: Icons.payment, // Default icon
      type: PaymentType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => PaymentType.card,
      ),
      isAvailable: json['isAvailable'] ?? false,
      description: json['description'],
    );
  }
}

/// 💳 Payment Method Data (for saved methods)
class PaymentMethodData {
  final String id;
  final String userId;
  final PaymentType type;
  final String displayName;
  final String? lastFour;
  final String? brand;
  final String? expiryMonth;
  final String? expiryYear;
  final bool isDefault;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  PaymentMethodData({
    required this.id,
    required this.userId,
    required this.type,
    required this.displayName,
    this.lastFour,
    this.brand,
    this.expiryMonth,
    this.expiryYear,
    required this.isDefault,
    required this.createdAt,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString(),
      'displayName': displayName,
      'lastFour': lastFour,
      'brand': brand,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory PaymentMethodData.fromJson(Map<String, dynamic> json) {
    return PaymentMethodData(
      id: json['id'],
      userId: json['userId'],
      type: PaymentType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => PaymentType.card,
      ),
      displayName: json['displayName'],
      lastFour: json['lastFour'],
      brand: json['brand'],
      expiryMonth: json['expiryMonth'],
      expiryYear: json['expiryYear'],
      isDefault: json['isDefault'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      metadata: json['metadata'],
    );
  }

  String get maskedNumber {
    if (lastFour != null) {
      return '**** **** **** $lastFour';
    }
    return displayName;
  }

  IconData get icon {
    switch (type) {
      case PaymentType.card:
        switch (brand?.toLowerCase()) {
          case 'visa':
            return Icons.credit_card;
          case 'mastercard':
            return Icons.credit_card;
          case 'amex':
            return Icons.credit_card;
          default:
            return Icons.credit_card;
        }
      case PaymentType.applePay:
        return Icons.apple;
      case PaymentType.googlePay:
        return Icons.payment;
      case PaymentType.paypal:
        return Icons.account_balance_wallet;
      case PaymentType.cash:
        return Icons.money;
    }
  }

  Color get brandColor {
    switch (brand?.toLowerCase()) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'amex':
        return const Color(0xFF006FCF);
      default:
        return Colors.grey;
    }
  }
}

/// 💰 Payment Result
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? paymentMethod;
  final double? amount;
  final String? error;
  final Map<String, dynamic>? metadata;

  PaymentResult({
    required this.success,
    this.transactionId,
    this.paymentMethod,
    this.amount,
    this.error,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'transactionId': transactionId,
      'paymentMethod': paymentMethod,
      'amount': amount,
      'error': error,
      'metadata': metadata,
    };
  }

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      success: json['success'],
      transactionId: json['transactionId'],
      paymentMethod: json['paymentMethod'],
      amount: json['amount']?.toDouble(),
      error: json['error'],
      metadata: json['metadata'],
    );
  }
}

/// 📊 Payment Transaction
class PaymentTransaction {
  final String id;
  final String userId;
  final String orderId;
  final double amount;
  final String currency;
  final PaymentType paymentMethod;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? description;
  final Map<String, dynamic>? metadata;

  PaymentTransaction({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.description,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'orderId': orderId,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod.toString(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'description': description,
      'metadata': metadata,
    };
  }

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'],
      userId: json['userId'],
      orderId: json['orderId'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      paymentMethod: PaymentType.values.firstWhere(
        (e) => e.toString() == json['paymentMethod'],
        orElse: () => PaymentType.card,
      ),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      description: json['description'],
      metadata: json['metadata'],
    );
  }

  bool get isCompleted => status == 'completed' || status == 'succeeded';
  bool get isPending => status == 'pending' || status == 'processing';
  bool get isFailed => status == 'failed' || status == 'cancelled';

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'succeeded':
        return Colors.green;
      case 'pending':
      case 'processing':
        return Colors.orange;
      case 'failed':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'succeeded':
        return Icons.check_circle;
      case 'pending':
      case 'processing':
        return Icons.access_time;
      case 'failed':
      case 'cancelled':
        return Icons.error;
      default:
        return Icons.help;
    }
  }
}

/// 💳 Card Information (for manual entry)
class CardInformation {
  final String number;
  final String expiryMonth;
  final String expiryYear;
  final String cvc;
  final String? holderName;
  final Map<String, dynamic>? billingAddress;

  CardInformation({
    required this.number,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvc,
    this.holderName,
    this.billingAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cvc': cvc,
      'holderName': holderName,
      'billingAddress': billingAddress,
    };
  }

  bool get isValid {
    return number.isNotEmpty &&
           expiryMonth.isNotEmpty &&
           expiryYear.isNotEmpty &&
           cvc.isNotEmpty &&
           _isValidCardNumber(number) &&
           _isValidExpiry(expiryMonth, expiryYear) &&
           _isValidCVC(cvc);
  }

  bool _isValidCardNumber(String number) {
    // Basic Luhn algorithm check
    final cleanNumber = number.replaceAll(RegExp(r'\D'), '');
    if (cleanNumber.length < 13 || cleanNumber.length > 19) return false;
    
    int sum = 0;
    bool alternate = false;
    
    for (int i = cleanNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cleanNumber[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return sum % 10 == 0;
  }

  bool _isValidExpiry(String month, String year) {
    final now = DateTime.now();
    final expiry = DateTime(
      int.parse('20$year'), // Assuming 2-digit year
      int.parse(month),
    );
    return expiry.isAfter(now);
  }

  bool _isValidCVC(String cvc) {
    return cvc.length >= 3 && cvc.length <= 4 && int.tryParse(cvc) != null;
  }

  String get brand {
    final cleanNumber = number.replaceAll(RegExp(r'\D'), '');
    
    if (cleanNumber.startsWith('4')) return 'Visa';
    if (cleanNumber.startsWith(RegExp(r'^5[1-5]'))) return 'Mastercard';
    if (cleanNumber.startsWith(RegExp(r'^3[47]'))) return 'American Express';
    if (cleanNumber.startsWith('6')) return 'Discover';
    
    return 'Unknown';
  }

  String get lastFour {
    final cleanNumber = number.replaceAll(RegExp(r'\D'), '');
    return cleanNumber.length >= 4 
        ? cleanNumber.substring(cleanNumber.length - 4)
        : cleanNumber;
  }
}
