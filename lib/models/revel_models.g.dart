// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revel_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RevelAuthResponse _$RevelAuthResponseFromJson(Map<String, dynamic> json) =>
    RevelAuthResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
      scope: json['scope'] as String,
    );

Map<String, dynamic> _$RevelAuthResponseToJson(RevelAuthResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'token_type': instance.tokenType,
      'expires_in': instance.expiresIn,
      'scope': instance.scope,
    };

RevelOrder _$RevelOrderFromJson(Map<String, dynamic> json) => RevelOrder(
      id: (json['id'] as num?)?.toInt(),
      orderNumber: json['order_number'] as String,
      establishmentId: json['establishment_id'] as String,
      customerId: (json['customer_id'] as num?)?.toInt(),
      orderType: json['order_type'] as String,
      status: json['status'] as String,
      orderItems: (json['order_items'] as List<dynamic>)
          .map((e) => RevelOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num?)?.toDouble(),
      tipAmount: (json['tip_amount'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      specialInstructions: json['special_instructions'] as String?,
    );

Map<String, dynamic> _$RevelOrderToJson(RevelOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_number': instance.orderNumber,
      'establishment_id': instance.establishmentId,
      'customer_id': instance.customerId,
      'order_type': instance.orderType,
      'status': instance.status,
      'order_items': instance.orderItems,
      'subtotal': instance.subtotal,
      'tax_amount': instance.taxAmount,
      'total_amount': instance.totalAmount,
      'discount_amount': instance.discountAmount,
      'tip_amount': instance.tipAmount,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'special_instructions': instance.specialInstructions,
    };

RevelOrderItem _$RevelOrderItemFromJson(Map<String, dynamic> json) =>
    RevelOrderItem(
      id: (json['id'] as num?)?.toInt(),
      productId: (json['product_id'] as num).toInt(),
      productName: json['product_name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      modifiers: (json['modifiers'] as List<dynamic>?)
          ?.map((e) => RevelOrderModifier.fromJson(e as Map<String, dynamic>))
          .toList(),
      specialInstructions: json['special_instructions'] as String?,
    );

Map<String, dynamic> _$RevelOrderItemToJson(RevelOrderItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'product_name': instance.productName,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'total_price': instance.totalPrice,
      'modifiers': instance.modifiers,
      'special_instructions': instance.specialInstructions,
    };

RevelOrderModifier _$RevelOrderModifierFromJson(Map<String, dynamic> json) =>
    RevelOrderModifier(
      modifierId: (json['modifier_id'] as num).toInt(),
      modifierName: json['modifier_name'] as String,
      modifierPrice: (json['modifier_price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$RevelOrderModifierToJson(RevelOrderModifier instance) =>
    <String, dynamic>{
      'modifier_id': instance.modifierId,
      'modifier_name': instance.modifierName,
      'modifier_price': instance.modifierPrice,
      'quantity': instance.quantity,
    };

RevelPayment _$RevelPaymentFromJson(Map<String, dynamic> json) => RevelPayment(
      id: (json['id'] as num?)?.toInt(),
      orderId: (json['order_id'] as num).toInt(),
      paymentType: json['payment_type'] as String,
      paymentMethod: json['payment_method'] as String?,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      transactionId: json['transaction_id'] as String?,
      referenceNumber: json['reference_number'] as String?,
      processorResponse: json['processor_response'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      processedAt: json['processed_at'] == null
          ? null
          : DateTime.parse(json['processed_at'] as String),
    );

Map<String, dynamic> _$RevelPaymentToJson(RevelPayment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'payment_type': instance.paymentType,
      'payment_method': instance.paymentMethod,
      'amount': instance.amount,
      'status': instance.status,
      'transaction_id': instance.transactionId,
      'reference_number': instance.referenceNumber,
      'processor_response': instance.processorResponse,
      'created_at': instance.createdAt.toIso8601String(),
      'processed_at': instance.processedAt?.toIso8601String(),
    };

RevelCustomer _$RevelCustomerFromJson(Map<String, dynamic> json) =>
    RevelCustomer(
      id: (json['id'] as num?)?.toInt(),
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      loyaltyNumber: json['loyalty_number'] as String?,
      loyaltyPoints: (json['loyalty_points'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$RevelCustomerToJson(RevelCustomer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'loyalty_number': instance.loyaltyNumber,
      'loyalty_points': instance.loyaltyPoints,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

RevelProduct _$RevelProductFromJson(Map<String, dynamic> json) => RevelProduct(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      categoryId: (json['category_id'] as num).toInt(),
      categoryName: json['category_name'] as String?,
      isActive: json['is_active'] as bool,
      imageUrl: json['image_url'] as String?,
      modifiers: (json['modifiers'] as List<dynamic>?)
          ?.map((e) => RevelModifier.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RevelProductToJson(RevelProduct instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'category_id': instance.categoryId,
      'category_name': instance.categoryName,
      'is_active': instance.isActive,
      'image_url': instance.imageUrl,
      'modifiers': instance.modifiers,
    };

RevelModifier _$RevelModifierFromJson(Map<String, dynamic> json) =>
    RevelModifier(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      isRequired: json['is_required'] as bool,
      maxSelections: (json['max_selections'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RevelModifierToJson(RevelModifier instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'is_required': instance.isRequired,
      'max_selections': instance.maxSelections,
    };

RevelApiResponse<T> _$RevelApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    RevelApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: _$nullableGenericFromJson(json['data'], fromJsonT),
      errors: json['errors'] as Map<String, dynamic>?,
      meta: json['meta'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$RevelApiResponseToJson<T>(
  RevelApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': _$nullableGenericToJson(instance.data, toJsonT),
      'errors': instance.errors,
      'meta': instance.meta,
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);

RevelApiError _$RevelApiErrorFromJson(Map<String, dynamic> json) =>
    RevelApiError(
      code: json['code'] as String,
      message: json['message'] as String,
      field: json['field'] as String?,
      details: json['details'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$RevelApiErrorToJson(RevelApiError instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'field': instance.field,
      'details': instance.details,
    };

RevelWebhookEvent _$RevelWebhookEventFromJson(Map<String, dynamic> json) =>
    RevelWebhookEvent(
      event: json['event'] as String,
      objectType: json['objectType'] as String?,
      objectId: (json['objectId'] as num?)?.toInt(),
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
      signature: json['signature'] as String,
    );

Map<String, dynamic> _$RevelWebhookEventToJson(RevelWebhookEvent instance) =>
    <String, dynamic>{
      'event': instance.event,
      'objectType': instance.objectType,
      'objectId': instance.objectId,
      'data': instance.data,
      'timestamp': instance.timestamp.toIso8601String(),
      'signature': instance.signature,
    };
