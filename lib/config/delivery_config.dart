/// 🚚 Delivery Services Configuration
/// Configuration for 3rd party delivery service integrations

import 'package:flutter/material.dart';

enum DeliveryProvider {
  ubereats,
  skipTheDishes,
  doordash,
  grubhub,
  foodora,
  justEat,
}

enum OrderType {
  pickup,
  delivery,
}

class DeliveryConfig {
  /// 🏪 Restaurant Information for Delivery Services
  static const String restaurantName = "Chica's Chicken";
  static const String restaurantId = "chicas-chicken-main";
  static const String restaurantSlug = "chicas-chicken";
  
  /// 📍 Restaurant Location
  static const String address = "123 Main Street, Toronto, ON M5V 3A8";
  static const double latitude = 43.6532;
  static const double longitude = -79.3832;
  
  /// 🚚 Delivery Service URLs and Configuration
  static const Map<DeliveryProvider, Map<String, dynamic>> deliveryServices = {
    DeliveryProvider.ubereats: {
      'name': 'Uber Eats',
      'baseUrl': 'https://www.ubereats.com/ca/store/',
      'restaurantUrl': 'https://www.ubereats.com/ca/store/chicas-chicken/restaurant-id',
      'deepLink': 'ubereats://stores/restaurant-id',
      'color': Color(0xFF000000),
      'icon': 'assets/icons/ubereats.png',
      'isAvailable': true,
      'estimatedDeliveryTime': '25-40 min',
      'deliveryFee': 2.99,
      'minimumOrder': 15.00,
    },
    DeliveryProvider.skipTheDishes: {
      'name': 'Skip The Dishes',
      'baseUrl': 'https://www.skipthedishes.com/restaurant/',
      'restaurantUrl': 'https://www.skipthedishes.com/restaurant/chicas-chicken',
      'deepLink': 'skipthedishes://restaurant/chicas-chicken',
      'color': Color(0xFFE31837),
      'icon': 'assets/icons/skip.png',
      'isAvailable': true,
      'estimatedDeliveryTime': '30-45 min',
      'deliveryFee': 3.49,
      'minimumOrder': 20.00,
    },
    DeliveryProvider.doordash: {
      'name': 'DoorDash',
      'baseUrl': 'https://www.doordash.com/store/',
      'restaurantUrl': 'https://www.doordash.com/store/chicas-chicken-restaurant-id',
      'deepLink': 'doordash://restaurant/restaurant-id',
      'color': Color(0xFFFF3008),
      'icon': 'assets/icons/doordash.png',
      'isAvailable': true,
      'estimatedDeliveryTime': '20-35 min',
      'deliveryFee': 2.49,
      'minimumOrder': 12.00,
    },
    DeliveryProvider.grubhub: {
      'name': 'Grubhub',
      'baseUrl': 'https://www.grubhub.com/restaurant/',
      'restaurantUrl': 'https://www.grubhub.com/restaurant/chicas-chicken-restaurant-id',
      'deepLink': 'grubhub://restaurant/restaurant-id',
      'color': Color(0xFFFF8000),
      'icon': 'assets/icons/grubhub.png',
      'isAvailable': false, // Not available in Canada
      'estimatedDeliveryTime': '25-40 min',
      'deliveryFee': 2.99,
      'minimumOrder': 15.00,
    },
    DeliveryProvider.foodora: {
      'name': 'Foodora',
      'baseUrl': 'https://www.foodora.ca/restaurant/',
      'restaurantUrl': 'https://www.foodora.ca/restaurant/chicas-chicken',
      'deepLink': 'foodora://restaurant/chicas-chicken',
      'color': Color(0xFFE91E63),
      'icon': 'assets/icons/foodora.png',
      'isAvailable': true,
      'estimatedDeliveryTime': '30-50 min',
      'deliveryFee': 3.99,
      'minimumOrder': 18.00,
    },
    DeliveryProvider.justEat: {
      'name': 'Just Eat',
      'baseUrl': 'https://www.justeat.ca/restaurants-',
      'restaurantUrl': 'https://www.justeat.ca/restaurants-chicas-chicken',
      'deepLink': 'justeat://restaurant/chicas-chicken',
      'color': Color(0xFFFF6900),
      'icon': 'assets/icons/justeat.png',
      'isAvailable': true,
      'estimatedDeliveryTime': '35-50 min',
      'deliveryFee': 4.49,
      'minimumOrder': 22.00,
    },
  };

  /// 🏙️ City-Based Delivery Configuration
  static const Map<String, Map<String, dynamic>> cityDeliveryConfig = {
    'Toronto': {
      'name': 'TORONTO',
      'isAvailable': true,
      'primaryService': DeliveryProvider.ubereats,
      'deliveryUrl': 'https://www.ubereats.com/ca/store/chicas-chicken/k0aCJ48XQXKxYWK0sYkv-A?srsltid=AfmBOoqss9cI8pCA-8pkG59VCUSO1lk2OA2M-qy1Zof3LEehuLbRDuX_',
      'estimatedTime': '25-40 min',
      'description': 'Order through Uber Eats',
      'cityImage': 'assets/images/cities/toronto.jpg',
      'skylineColor': Color(0xFF0066CC),
      'population': '2.9M',
    },
    'Winnipeg': {
      'name': 'WINNIPEG',
      'isAvailable': true,
      'primaryService': DeliveryProvider.skipTheDishes,
      'deliveryUrl': 'https://www.skipthedishes.com/chicas-chicken-main-street?embedded=0',
      'estimatedTime': '30-45 min',
      'description': 'Order through Skip The Dishes',
      'cityImage': 'assets/images/cities/winnipeg.jpg',
      'skylineColor': Color(0xFF8B4A9C),
      'population': '750K',
    },
    'Whitby': {
      'name': 'WHITBY',
      'isAvailable': true,
      'primaryService': DeliveryProvider.ubereats,
      'deliveryUrl': 'https://www.ubereats.com/ca/store/chicas-chicken/iSeDxmPZWpeKoHRY9hQHUw?diningMode=DELIVERY&pl=JTdCJTIyYWRkcmVzcyUyMiUzQSUyMkNoaWNhJ3MlMjBDaGlja2VuJTIyJTJDJTIycmVmZXJlbmNlJTIyJTNBJTIyNTFjNGZkYmUtNmY2ZC00ZGM5LWJmZTEtY2QxOTc0MzkzZmVmJTIyJTJDJTIycmVmZXJlbmNlVHlwZSUyMiUzQSUyMnViZXJfcGxhY2VzJTIyJTJDJTIybGF0aXR1ZGUlMjIlM0E0My42NjUzMjkyJTJDJTIybG9uZ2l0dWRlJTIyJTNBLTc5LjQ2NDI2NjUlN0Q%3D',
      'estimatedTime': '20-35 min',
      'description': 'Order through Uber Eats',
      'cityImage': 'assets/images/cities/whitby.jpg',
      'skylineColor': Color(0xFF00A693),
      'population': '140K',
    },
    'Edmonton': {
      'name': 'EDMONTON',
      'isAvailable': false,
      'primaryService': null,
      'deliveryUrl': null,
      'estimatedTime': 'Coming Soon',
      'description': 'Coming Soon!',
      'cityImage': 'assets/images/cities/edmonton.jpg',
      'skylineColor': Color(0xFF8B4513),
      'population': '1.0M',
    },
  };

  /// 🇨🇦 Canadian Market Focus - Available Services
  static List<DeliveryProvider> get availableInCanada => [
    DeliveryProvider.ubereats,
    DeliveryProvider.skipTheDishes,
    DeliveryProvider.doordash,
    DeliveryProvider.foodora,
    DeliveryProvider.justEat,
  ];

  /// 🏆 Recommended Services (most popular in Canada)
  static List<DeliveryProvider> get recommendedServices => [
    DeliveryProvider.ubereats,
    DeliveryProvider.skipTheDishes,
    DeliveryProvider.doordash,
  ];

  /// 📱 Get service configuration
  static Map<String, dynamic> getServiceConfig(DeliveryProvider provider) {
    return deliveryServices[provider] ?? {};
  }

  /// 🌐 Get restaurant URL for specific service
  static String getRestaurantUrl(DeliveryProvider provider) {
    final config = getServiceConfig(provider);
    return config['restaurantUrl'] ?? '';
  }

  /// 📱 Get deep link for specific service
  static String getDeepLink(DeliveryProvider provider) {
    final config = getServiceConfig(provider);
    return config['deepLink'] ?? '';
  }

  /// ✅ Check if service is available
  static bool isServiceAvailable(DeliveryProvider provider) {
    final config = getServiceConfig(provider);
    return config['isAvailable'] ?? false;
  }

  /// 🎨 Get service brand color
  static Color getServiceColor(DeliveryProvider provider) {
    final config = getServiceConfig(provider);
    return config['color'] ?? Colors.grey;
  }

  /// 📦 Get service details
  static String getServiceName(DeliveryProvider provider) {
    final config = getServiceConfig(provider);
    return config['name'] ?? provider.name;
  }

  static String getEstimatedDeliveryTime(DeliveryProvider provider) {
    final config = getServiceConfig(provider);
    return config['estimatedDeliveryTime'] ?? 'N/A';
  }

  static double getDeliveryFee(DeliveryProvider provider) {
    final config = getServiceConfig(provider);
    return config['deliveryFee'] ?? 0.0;
  }

  static double getMinimumOrder(DeliveryProvider provider) {
    final config = getServiceConfig(provider);
    return config['minimumOrder'] ?? 0.0;
  }

  /// 🔗 Build complete URL with parameters
  static String buildDeliveryUrl(DeliveryProvider provider, {
    Map<String, String>? additionalParams,
  }) {
    final baseUrl = getRestaurantUrl(provider);
    
    if (additionalParams == null || additionalParams.isEmpty) {
      return baseUrl;
    }

    final uri = Uri.parse(baseUrl);
    final newParams = Map<String, String>.from(uri.queryParameters);
    newParams.addAll(additionalParams);
    
    return uri.replace(queryParameters: newParams).toString();
  }

  /// 📍 Build URL with location parameters
  static String buildDeliveryUrlWithLocation(
    DeliveryProvider provider, {
    String? userAddress,
    double? userLat,
    double? userLng,
  }) {
    final params = <String, String>{};
    
    if (userAddress != null) {
      params['address'] = userAddress;
    }
    if (userLat != null && userLng != null) {
      params['lat'] = userLat.toString();
      params['lng'] = userLng.toString();
    }
    
    return buildDeliveryUrl(provider, additionalParams: params);
  }

  /// 🏪 Pickup Configuration
  static const Map<String, dynamic> pickupConfig = {
    'isAvailable': true,
    'estimatedTime': '15-25 min',
    'instructions': 'Order will be ready for pickup at our restaurant location',
    'address': address,
    'phone': '+1 (416) 555-0123',
    'hours': {
      'monday': '10:00 AM - 10:00 PM',
      'tuesday': '10:00 AM - 10:00 PM',
      'wednesday': '10:00 AM - 10:00 PM',
      'thursday': '10:00 AM - 10:00 PM',
      'friday': '10:00 AM - 11:00 PM',
      'saturday': '10:00 AM - 11:00 PM',
      'sunday': '11:00 AM - 9:00 PM',
    },
  };

  /// ⏰ Operating Hours
  static bool get isPickupAvailable {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentDay = now.weekday;
    
    // Simplified check - restaurant is open 10 AM to 10 PM most days
    if (currentDay == 7) { // Sunday
      return currentHour >= 11 && currentHour < 21;
    } else if (currentDay == 5 || currentDay == 6) { // Friday/Saturday
      return currentHour >= 10 && currentHour < 23;
    } else { // Monday-Thursday
      return currentHour >= 10 && currentHour < 22;
    }
  }

  /// 🚚 Check if delivery is available in area
  static bool isDeliveryAvailableInArea(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    
    // Simple radius check (in real app, use proper geofencing)
    const deliveryRadius = 0.1; // ~10km radius
    final distance = _calculateDistance(latitude, longitude, lat, lng);
    
    return distance <= deliveryRadius;
  }

  /// 📏 Calculate distance between two points (simplified)
  static double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    // Simplified distance calculation for demo
    // In production, use proper haversine formula or Google Distance Matrix API
    final deltaLat = (lat1 - lat2).abs();
    final deltaLng = (lng1 - lng2).abs();
    return deltaLat + deltaLng;
  }

  /// 🎯 Get recommended delivery service based on user preferences
  static DeliveryProvider getRecommendedService({
    double? userLat,
    double? userLng,
    double? orderValue,
  }) {
    final available = availableInCanada.where(isServiceAvailable).toList();
    
    if (available.isEmpty) return DeliveryProvider.ubereats;
    
    // Simple recommendation logic
    if (orderValue != null) {
      // Find service with lowest minimum order that user meets
      for (final service in available) {
        if (orderValue >= getMinimumOrder(service)) {
          return service;
        }
      }
    }
    
    // Default to most popular
    return DeliveryProvider.ubereats;
  }

  /// 📊 Get all available services with details
  static List<Map<String, dynamic>> getAllAvailableServices() {
    return availableInCanada
        .where(isServiceAvailable)
        .map((provider) => {
              'provider': provider,
              'name': getServiceName(provider),
              'color': getServiceColor(provider),
              'deliveryTime': getEstimatedDeliveryTime(provider),
              'deliveryFee': getDeliveryFee(provider),
              'minimumOrder': getMinimumOrder(provider),
              'url': getRestaurantUrl(provider),
              'deepLink': getDeepLink(provider),
            })
        .toList();
  }

  /// 🏙️ City-Based Delivery Methods

  /// Get all available cities
  static List<String> getAvailableCities() {
    return cityDeliveryConfig.keys.toList();
  }

  /// Get city configuration
  static Map<String, dynamic>? getCityConfig(String cityName) {
    return cityDeliveryConfig[cityName];
  }

  /// Check if city has delivery available
  static bool isCityAvailable(String cityName) {
    final config = getCityConfig(cityName);
    return config?['isAvailable'] ?? false;
  }

  /// Get city delivery URL
  static String? getCityDeliveryUrl(String cityName) {
    final config = getCityConfig(cityName);
    return config?['deliveryUrl'];
  }

  /// Get city primary service
  static DeliveryProvider? getCityPrimaryService(String cityName) {
    final config = getCityConfig(cityName);
    return config?['primaryService'];
  }

  /// Get city skyline color
  static Color getCitySkylineColor(String cityName) {
    final config = getCityConfig(cityName);
    return config?['skylineColor'] ?? Colors.grey;
  }

  /// Get city estimated delivery time
  static String getCityEstimatedTime(String cityName) {
    final config = getCityConfig(cityName);
    return config?['estimatedTime'] ?? 'N/A';
  }

  /// Get city description
  static String getCityDescription(String cityName) {
    final config = getCityConfig(cityName);
    return config?['description'] ?? 'Delivery available';
  }

  /// Get city population
  static String getCityPopulation(String cityName) {
    final config = getCityConfig(cityName);
    return config?['population'] ?? '';
  }

  /// Get available cities only
  static List<String> getAvailableCitiesOnly() {
    return cityDeliveryConfig.entries
        .where((entry) => entry.value['isAvailable'] == true)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get coming soon cities
  static List<String> getComingSoonCities() {
    return cityDeliveryConfig.entries
        .where((entry) => entry.value['isAvailable'] == false)
        .map((entry) => entry.key)
        .toList();
  }
}
