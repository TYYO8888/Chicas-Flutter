class UserPreferences {
  final String userId;
  final List<String> favoriteMenuItems;
  final Map<String, dynamic> defaultCustomizations;
  final bool darkModeEnabled;
  final bool notificationsEnabled;
  final String preferredLanguage;
  final Map<String, dynamic> dietaryRestrictions;
  final List<FavoriteOrder> favoriteOrders;
  final DateTime lastUpdated;

  UserPreferences({
    required this.userId,
    this.favoriteMenuItems = const [],
    this.defaultCustomizations = const {},
    this.darkModeEnabled = false,
    this.notificationsEnabled = true,
    this.preferredLanguage = 'en',
    this.dietaryRestrictions = const {},
    this.favoriteOrders = const [],
    required this.lastUpdated,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: json['userId'],
      favoriteMenuItems: List<String>.from(json['favoriteMenuItems'] ?? []),
      defaultCustomizations: Map<String, dynamic>.from(json['defaultCustomizations'] ?? {}),
      darkModeEnabled: json['darkModeEnabled'] ?? false,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      preferredLanguage: json['preferredLanguage'] ?? 'en',
      dietaryRestrictions: Map<String, dynamic>.from(json['dietaryRestrictions'] ?? {}),
      favoriteOrders: (json['favoriteOrders'] as List<dynamic>?)
          ?.map((order) => FavoriteOrder.fromJson(order))
          .toList() ?? [],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'favoriteMenuItems': favoriteMenuItems,
      'defaultCustomizations': defaultCustomizations,
      'darkModeEnabled': darkModeEnabled,
      'notificationsEnabled': notificationsEnabled,
      'preferredLanguage': preferredLanguage,
      'dietaryRestrictions': dietaryRestrictions,
      'favoriteOrders': favoriteOrders.map((order) => order.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  UserPreferences copyWith({
    List<String>? favoriteMenuItems,
    Map<String, dynamic>? defaultCustomizations,
    bool? darkModeEnabled,
    bool? notificationsEnabled,
    String? preferredLanguage,
    Map<String, dynamic>? dietaryRestrictions,
    List<FavoriteOrder>? favoriteOrders,
  }) {
    return UserPreferences(
      userId: userId,
      favoriteMenuItems: favoriteMenuItems ?? this.favoriteMenuItems,
      defaultCustomizations: defaultCustomizations ?? this.defaultCustomizations,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      favoriteOrders: favoriteOrders ?? this.favoriteOrders,
      lastUpdated: DateTime.now(),
    );
  }
}

class FavoriteOrder {
  final String id;
  final String name;
  final List<FavoriteOrderItem> items;
  final double totalPrice;
  final DateTime createdAt;
  final int orderCount; // How many times this order has been placed

  FavoriteOrder({
    required this.id,
    required this.name,
    required this.items,
    required this.totalPrice,
    required this.createdAt,
    this.orderCount = 1,
  });

  factory FavoriteOrder.fromJson(Map<String, dynamic> json) {
    return FavoriteOrder(
      id: json['id'],
      name: json['name'],
      items: (json['items'] as List<dynamic>)
          .map((item) => FavoriteOrderItem.fromJson(item))
          .toList(),
      totalPrice: json['totalPrice'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      orderCount: json['orderCount'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'createdAt': createdAt.toIso8601String(),
      'orderCount': orderCount,
    };
  }
}

class FavoriteOrderItem {
  final String menuItemId;
  final String menuItemName;
  final int quantity;
  final String? selectedSize;
  final List<String> selectedSauces;
  final Map<String, dynamic> customizations;
  final double itemPrice;

  FavoriteOrderItem({
    required this.menuItemId,
    required this.menuItemName,
    required this.quantity,
    this.selectedSize,
    this.selectedSauces = const [],
    this.customizations = const {},
    required this.itemPrice,
  });

  factory FavoriteOrderItem.fromJson(Map<String, dynamic> json) {
    return FavoriteOrderItem(
      menuItemId: json['menuItemId'],
      menuItemName: json['menuItemName'],
      quantity: json['quantity'],
      selectedSize: json['selectedSize'],
      selectedSauces: List<String>.from(json['selectedSauces'] ?? []),
      customizations: Map<String, dynamic>.from(json['customizations'] ?? {}),
      itemPrice: json['itemPrice'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuItemId': menuItemId,
      'menuItemName': menuItemName,
      'quantity': quantity,
      'selectedSize': selectedSize,
      'selectedSauces': selectedSauces,
      'customizations': customizations,
      'itemPrice': itemPrice,
    };
  }
}

class DietaryRestriction {
  final String id;
  final String name;
  final String description;
  final List<String> excludedIngredients;

  DietaryRestriction({
    required this.id,
    required this.name,
    required this.description,
    required this.excludedIngredients,
  });

  factory DietaryRestriction.fromJson(Map<String, dynamic> json) {
    return DietaryRestriction(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      excludedIngredients: List<String>.from(json['excludedIngredients'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'excludedIngredients': excludedIngredients,
    };
  }
}
