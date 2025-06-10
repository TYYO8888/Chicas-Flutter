import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/delivery_config.dart';

/// 🚚 Delivery Service Integration
/// Handles launching 3rd party delivery apps and tracking
class DeliveryService {
  static final DeliveryService _instance = DeliveryService._internal();
  factory DeliveryService() => _instance;
  DeliveryService._internal();

  /// 🌐 Launch delivery service with tracking
  Future<bool> launchDeliveryService({
    required DeliveryProvider provider,
    String? userAddress,
    double? userLat,
    double? userLng,
    Map<String, String>? additionalParams,
  }) async {
    try {
      debugPrint('🚚 Launching ${DeliveryConfig.getServiceName(provider)}');
      
      // Build URL with location and parameters
      final url = DeliveryConfig.buildDeliveryUrlWithLocation(
        provider,
        userAddress: userAddress,
        userLat: userLat,
        userLng: userLng,
      );
      
      debugPrint('🔗 URL: $url');
      
      // Try deep link first, then web URL
      final success = await _tryLaunchWithFallback(provider, url);
      
      if (success) {
        // Track the launch for analytics
        await _trackDeliveryLaunch(provider, userAddress);
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ Error launching delivery service: $e');
      return false;
    }
  }

  /// 🔗 Try deep link first, fallback to web URL
  Future<bool> _tryLaunchWithFallback(DeliveryProvider provider, String webUrl) async {
    // Try deep link first
    final deepLink = DeliveryConfig.getDeepLink(provider);
    if (deepLink.isNotEmpty) {
      try {
        final deepLinkUri = Uri.parse(deepLink);
        if (await canLaunchUrl(deepLinkUri)) {
          await launchUrl(
            deepLinkUri,
            mode: LaunchMode.externalApplication,
          );
          debugPrint('✅ Launched via deep link: $deepLink');
          return true;
        }
      } catch (e) {
        debugPrint('⚠️ Deep link failed, trying web URL: $e');
      }
    }

    // Fallback to web URL
    try {
      final webUri = Uri.parse(webUrl);
      if (await canLaunchUrl(webUri)) {
        await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
        debugPrint('✅ Launched via web URL: $webUrl');
        return true;
      }
    } catch (e) {
      debugPrint('❌ Web URL launch failed: $e');
    }

    return false;
  }

  /// 📊 Track delivery service launch for analytics
  Future<void> _trackDeliveryLaunch(DeliveryProvider provider, String? userAddress) async {
    try {
      // In a real app, you would send this to your analytics service
      final event = {
        'event': 'delivery_service_launched',
        'provider': provider.name,
        'service_name': DeliveryConfig.getServiceName(provider),
        'timestamp': DateTime.now().toIso8601String(),
        'user_address': userAddress,
        'delivery_fee': DeliveryConfig.getDeliveryFee(provider),
        'minimum_order': DeliveryConfig.getMinimumOrder(provider),
      };
      
      debugPrint('📊 Analytics: $event');
      
      // TODO: Send to analytics service (Firebase, Mixpanel, etc.)
      // await analyticsService.track(event);
    } catch (e) {
      debugPrint('❌ Failed to track delivery launch: $e');
    }
  }

  /// 📍 Get user's delivery area status
  Future<Map<String, dynamic>> getDeliveryAreaStatus({
    double? lat,
    double? lng,
    String? address,
  }) async {
    try {
      final isInDeliveryArea = DeliveryConfig.isDeliveryAvailableInArea(lat, lng);
      final availableServices = DeliveryConfig.getAllAvailableServices();
      
      return {
        'isInDeliveryArea': isInDeliveryArea,
        'availableServices': availableServices.length,
        'services': availableServices,
        'recommendedService': DeliveryConfig.getRecommendedService(
          userLat: lat,
          userLng: lng,
        ),
      };
    } catch (e) {
      debugPrint('❌ Error getting delivery area status: $e');
      return {
        'isInDeliveryArea': false,
        'availableServices': 0,
        'services': [],
        'error': e.toString(),
      };
    }
  }

  /// 🎯 Get recommended service based on user preferences
  DeliveryProvider getRecommendedServiceForUser({
    double? orderValue,
    String? preferredService,
    double? userLat,
    double? userLng,
  }) {
    // If user has a preferred service, use it
    if (preferredService != null) {
      for (final provider in DeliveryProvider.values) {
        if (DeliveryConfig.getServiceName(provider).toLowerCase() == 
            preferredService.toLowerCase()) {
          return provider;
        }
      }
    }

    // Otherwise use config recommendation
    return DeliveryConfig.getRecommendedService(
      userLat: userLat,
      userLng: userLng,
      orderValue: orderValue,
    );
  }

  /// 💰 Calculate delivery costs for all services
  List<Map<String, dynamic>> getDeliveryCostComparison(double orderValue) {
    final services = DeliveryConfig.getAllAvailableServices();
    
    return services.map((service) {
      final provider = service['provider'] as DeliveryProvider;
      final deliveryFee = service['deliveryFee'] as double;
      final minimumOrder = service['minimumOrder'] as double;
      
      final meetsMinimum = orderValue >= minimumOrder;
      final totalCost = meetsMinimum ? orderValue + deliveryFee : minimumOrder + deliveryFee;
      
      return {
        'provider': provider,
        'name': service['name'],
        'deliveryFee': deliveryFee,
        'minimumOrder': minimumOrder,
        'meetsMinimum': meetsMinimum,
        'totalCost': totalCost,
        'estimatedTime': service['deliveryTime'],
        'color': service['color'],
      };
    }).toList()
      ..sort((a, b) => a['totalCost'].compareTo(b['totalCost'])); // Sort by total cost
  }

  /// 🔄 Check service availability
  Future<Map<DeliveryProvider, bool>> checkServiceAvailability() async {
    final availability = <DeliveryProvider, bool>{};
    
    for (final provider in DeliveryProvider.values) {
      try {
        // In a real app, you might ping the service APIs to check availability
        // For now, use the static configuration
        availability[provider] = DeliveryConfig.isServiceAvailable(provider);
      } catch (e) {
        availability[provider] = false;
      }
    }
    
    return availability;
  }

  /// 📱 Generate shareable delivery link
  String generateShareableLink(DeliveryProvider provider, {
    String? userAddress,
    String? restaurantMessage,
  }) {
    final baseUrl = DeliveryConfig.getRestaurantUrl(provider);
    final serviceName = DeliveryConfig.getServiceName(provider);
    
    final message = restaurantMessage ?? 
        "Check out ${DeliveryConfig.restaurantName} on $serviceName! 🍗";
    
    // In a real app, you might use a URL shortener service
    return "$message\n\n$baseUrl";
  }

  /// 🎁 Get promotional information for services
  Map<DeliveryProvider, Map<String, dynamic>> getPromotionalInfo() {
    // In a real app, this would fetch current promotions from your backend
    return {
      DeliveryProvider.ubereats: {
        'hasPromo': true,
        'promoText': 'Free delivery on orders over \$25',
        'promoCode': 'CHICAS25',
        'validUntil': DateTime.now().add(const Duration(days: 7)),
      },
      DeliveryProvider.skipTheDishes: {
        'hasPromo': true,
        'promoText': '20% off first order',
        'promoCode': 'NEWCHICA',
        'validUntil': DateTime.now().add(const Duration(days: 14)),
      },
      DeliveryProvider.doordash: {
        'hasPromo': false,
        'promoText': null,
        'promoCode': null,
        'validUntil': null,
      },
    };
  }

  /// 📈 Get service performance metrics
  Map<String, dynamic> getServiceMetrics() {
    // In a real app, this would come from your analytics
    return {
      'mostPopular': DeliveryProvider.ubereats,
      'fastest': DeliveryProvider.doordash,
      'cheapest': DeliveryProvider.doordash,
      'userPreference': DeliveryProvider.skipTheDishes,
      'lastUsed': DeliveryProvider.ubereats,
      'usageStats': {
        DeliveryProvider.ubereats: 45,
        DeliveryProvider.skipTheDishes: 30,
        DeliveryProvider.doordash: 20,
        DeliveryProvider.foodora: 5,
      },
    };
  }
}
