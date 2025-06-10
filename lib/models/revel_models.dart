import 'package:json_annotation/json_annotation.dart';

part 'revel_models.g.dart';

/// 🔐 Revel Authentication Response
@JsonSerializable()
class RevelAuthResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  
  @JsonKey(name: 'token_type')
  final String tokenType;
  
  @JsonKey(name: 'expires_in')
  final int expiresIn;
  
  final String scope;

  RevelAuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.scope,
  });

  factory RevelAuthResponse.fromJson(Map<String, dynamic> json) =>
      _$RevelAuthResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$RevelAuthResponseToJson(this);
}

/// 🛒 Revel Order Model
@JsonSerializable()
class RevelOrder {
  final int? id;
  
  @JsonKey(name: 'order_number')
  final String orderNumber;
  
  @JsonKey(name: 'establishment_id')
  final String establishmentId;
  
  @JsonKey(name: 'customer_id')
  final int? customerId;
  
  @JsonKey(name: 'order_type')
  final String orderType; // 'PICKUP', 'DELIVERY', 'DINE_IN'
  
  final String status; // 'PENDING', 'CONFIRMED', 'PREPARING', 'READY', 'COMPLETED'
  
  @JsonKey(name: 'order_items')
  final List<RevelOrderItem> orderItems;
  
  @JsonKey(name: 'subtotal')
  final double subtotal;
  
  @JsonKey(name: 'tax_amount')
  final double taxAmount;
  
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  
  @JsonKey(name: 'discount_amount')
  final double? discountAmount;
  
  @JsonKey(name: 'tip_amount')
  final double? tipAmount;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  
  @JsonKey(name: 'special_instructions')
  final String? specialInstructions;

  RevelOrder({
    this.id,
    required this.orderNumber,
    required this.establishmentId,
    this.customerId,
    required this.orderType,
    required this.status,
    required this.orderItems,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    this.discountAmount,
    this.tipAmount,
    required this.createdAt,
    this.updatedAt,
    this.specialInstructions,
  });

  factory RevelOrder.fromJson(Map<String, dynamic> json) =>
      _$RevelOrderFromJson(json);
  
  Map<String, dynamic> toJson() => _$RevelOrderToJson(this);
}

/// 🍗 Revel Order Item Model
@JsonSerializable()
class RevelOrderItem {
  final int? id;
  
  @JsonKey(name: 'product_id')
  final int productId;
  
  @JsonKey(name: 'product_name')
  final String productName;
  
  final int quantity;
  
  @JsonKey(name: 'unit_price')
  final double unitPrice;
  
  @JsonKey(name: 'total_price')
  final double totalPrice;
  
  @JsonKey(name: 'modifiers')
  final List<RevelOrderModifier>? modifiers;
  
  @JsonKey(name: 'special_instructions')
  final String? specialInstructions;

  RevelOrderItem({
    this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.modifiers,
    this.specialInstructions,
  });

  factory RevelOrderItem.fromJson(Map<String, dynamic> json) =>
      _$RevelOrderItemFromJson(json);
  
  Map<String, dynamic> toJson() => _$RevelOrderItemToJson(this);
}

/// 🔧 Revel Order Modifier Model
@JsonSerializable()
class RevelOrderModifier {
  @JsonKey(name: 'modifier_id')
  final int modifierId;
  
  @JsonKey(name: 'modifier_name')
  final String modifierName;
  
  @JsonKey(name: 'modifier_price')
  final double modifierPrice;
  
  final int quantity;

  RevelOrderModifier({
    required this.modifierId,
    required this.modifierName,
    required this.modifierPrice,
    required this.quantity,
  });

  factory RevelOrderModifier.fromJson(Map<String, dynamic> json) =>
      _$RevelOrderModifierFromJson(json);
  
  Map<String, dynamic> toJson() => _$RevelOrderModifierToJson(this);
}

/// 💳 Revel Payment Model
@JsonSerializable()
class RevelPayment {
  final int? id;
  
  @JsonKey(name: 'order_id')
  final int orderId;
  
  @JsonKey(name: 'payment_type')
  final String paymentType; // 'CASH', 'CREDIT_CARD', 'MOBILE_PAYMENT', etc.
  
  @JsonKey(name: 'payment_method')
  final String? paymentMethod; // 'VISA', 'MASTERCARD', 'APPLE_PAY', etc.
  
  final double amount;
  
  final String status; // 'PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'REFUNDED'
  
  @JsonKey(name: 'transaction_id')
  final String? transactionId;
  
  @JsonKey(name: 'reference_number')
  final String? referenceNumber;
  
  @JsonKey(name: 'processor_response')
  final Map<String, dynamic>? processorResponse;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'processed_at')
  final DateTime? processedAt;

  RevelPayment({
    this.id,
    required this.orderId,
    required this.paymentType,
    this.paymentMethod,
    required this.amount,
    required this.status,
    this.transactionId,
    this.referenceNumber,
    this.processorResponse,
    required this.createdAt,
    this.processedAt,
  });

  factory RevelPayment.fromJson(Map<String, dynamic> json) =>
      _$RevelPaymentFromJson(json);
  
  Map<String, dynamic> toJson() => _$RevelPaymentToJson(this);
}

/// 👤 Revel Customer Model
@JsonSerializable()
class RevelCustomer {
  final int? id;
  
  @JsonKey(name: 'first_name')
  final String firstName;
  
  @JsonKey(name: 'last_name')
  final String lastName;
  
  final String email;
  
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  
  @JsonKey(name: 'loyalty_number')
  final String? loyaltyNumber;
  
  @JsonKey(name: 'loyalty_points')
  final int? loyaltyPoints;
  
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  RevelCustomer({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.loyaltyNumber,
    this.loyaltyPoints,
    this.createdAt,
    this.updatedAt,
  });

  factory RevelCustomer.fromJson(Map<String, dynamic> json) =>
      _$RevelCustomerFromJson(json);
  
  Map<String, dynamic> toJson() => _$RevelCustomerToJson(this);
}

/// 🍽️ Revel Product Model
@JsonSerializable()
class RevelProduct {
  final int id;
  
  final String name;
  
  final String? description;
  
  final double price;
  
  @JsonKey(name: 'category_id')
  final int categoryId;
  
  @JsonKey(name: 'category_name')
  final String? categoryName;
  
  @JsonKey(name: 'is_active')
  final bool isActive;
  
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  
  @JsonKey(name: 'modifiers')
  final List<RevelModifier>? modifiers;

  RevelProduct({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.categoryId,
    this.categoryName,
    required this.isActive,
    this.imageUrl,
    this.modifiers,
  });

  factory RevelProduct.fromJson(Map<String, dynamic> json) =>
      _$RevelProductFromJson(json);
  
  Map<String, dynamic> toJson() => _$RevelProductToJson(this);
}

/// 🔧 Revel Modifier Model
@JsonSerializable()
class RevelModifier {
  final int id;
  
  final String name;
  
  final double price;
  
  @JsonKey(name: 'is_required')
  final bool isRequired;
  
  @JsonKey(name: 'max_selections')
  final int? maxSelections;

  RevelModifier({
    required this.id,
    required this.name,
    required this.price,
    required this.isRequired,
    this.maxSelections,
  });

  factory RevelModifier.fromJson(Map<String, dynamic> json) =>
      _$RevelModifierFromJson(json);
  
  Map<String, dynamic> toJson() => _$RevelModifierToJson(this);
}

/// 📊 Revel API Response Wrapper
@JsonSerializable(genericArgumentFactories: true)
class RevelApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;
  final Map<String, dynamic>? meta;

  RevelApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.meta,
  });

  factory RevelApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$RevelApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$RevelApiResponseToJson(this, toJsonT);
}

/// ❌ Revel API Error Model
@JsonSerializable()
class RevelApiError {
  final String code;
  final String message;
  final String? field;
  final Map<String, dynamic>? details;

  RevelApiError({
    required this.code,
    required this.message,
    this.field,
    this.details,
  });

  factory RevelApiError.fromJson(Map<String, dynamic> json) =>
      _$RevelApiErrorFromJson(json);
  
  Map<String, dynamic> toJson() => _$RevelApiErrorToJson(this);
}

/// 🔄 Revel Webhook Event Model
@JsonSerializable()
class RevelWebhookEvent {
  final String event;
  final String? objectType;
  final int? objectId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String signature;

  RevelWebhookEvent({
    required this.event,
    this.objectType,
    this.objectId,
    required this.data,
    required this.timestamp,
    required this.signature,
  });

  factory RevelWebhookEvent.fromJson(Map<String, dynamic> json) =>
      _$RevelWebhookEventFromJson(json);
  
  Map<String, dynamic> toJson() => _$RevelWebhookEventToJson(this);
}
