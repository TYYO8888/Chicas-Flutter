import 'package:flutter/material.dart';
import '../utils/logger.dart';

/// 🖼️ Simplified Image Service for Chica's Chicken App
/// Handles basic image display and optimization
class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  // 🌐 CDN Configuration
  static const String _cdnBaseUrl = 'https://res.cloudinary.com/chicas-chicken';

  /// 🍽️ Get optimized menu item image
  Widget getMenuItemImage({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    String? placeholder,
    VoidCallback? onTap,
  }) {
    final optimizedUrl = _getOptimizedImageUrl(
      imageUrl,
      width: width.toInt(),
      height: height.toInt(),
      quality: 85,
      format: 'webp',
    );

    return GestureDetector(
      onTap: onTap,
      child: Image.network(
        optimizedUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder(width, height, placeholder);
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget(width, height);
        },
      ),
    );
  }

  /// 👤 Get user avatar image
  Widget getUserAvatar({
    required String? imageUrl,
    required double size,
    String? fallbackText,
    Color? backgroundColor,
  }) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildAvatarFallback(size, fallbackText, backgroundColor);
    }

    final optimizedUrl = _getOptimizedImageUrl(
      imageUrl,
      width: (size * 2).toInt(), // 2x for retina displays
      height: (size * 2).toInt(),
      quality: 90,
      format: 'webp',
    );

    return ClipOval(
      child: Image.network(
        optimizedUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildAvatarFallback(size, fallbackText, backgroundColor);
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildAvatarFallback(size, fallbackText, backgroundColor);
        },
      ),
    );
  }

  /// 🎨 Get hero image for promotions
  Widget getHeroImage({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    List<Color>? overlayGradient,
  }) {
    final optimizedUrl = _getOptimizedImageUrl(
      imageUrl,
      width: width.toInt(),
      height: height.toInt(),
      quality: 95, // Higher quality for hero images
      format: 'webp',
    );

    Widget imageWidget = Image.network(
      optimizedUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildHeroPlaceholder(width, height);
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildHeroPlaceholder(width, height);
      },
    );

    if (overlayGradient != null) {
      imageWidget = Stack(
        children: [
          imageWidget,
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: overlayGradient,
              ),
            ),
          ),
        ],
      );
    }

    return imageWidget;
  }

  /// 🔧 Get optimized image URL using Cloudinary transformations
  String _getOptimizedImageUrl(
    String originalUrl, {
    required int width,
    required int height,
    int quality = 80,
    String format = 'webp',
  }) {
    // If already a CDN URL, return as is
    if (originalUrl.startsWith(_cdnBaseUrl)) {
      return originalUrl;
    }

    // If it's a local asset, return as is
    if (originalUrl.startsWith('assets/')) {
      return originalUrl;
    }

    // Build Cloudinary transformation URL
    final transformations = [
      'w_$width',
      'h_$height',
      'c_fill', // Crop to fill dimensions
      'q_$quality',
      'f_$format',
      'dpr_auto', // Automatic device pixel ratio
    ].join(',');

    // Extract image ID from original URL or use fallback
    final imageId = _extractImageId(originalUrl);
    
    return '$_cdnBaseUrl/image/upload/$transformations/$imageId';
  }

  /// 🆔 Extract image ID from URL
  String _extractImageId(String url) {
    // Try to extract meaningful ID from URL
    final uri = Uri.tryParse(url);
    if (uri != null) {
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        return pathSegments.last.split('.').first;
      }
    }
    
    // Fallback to a default image
    return 'menu/placeholder';
  }

  /// 🖼️ Build placeholder widget
  Widget _buildPlaceholder(double width, double height, String? placeholder) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: width * 0.3,
            color: Colors.grey[400],
          ),
          if (placeholder != null) ...[
            const SizedBox(height: 8),
            Text(
              placeholder,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// ❌ Build error widget
  Widget _buildErrorWidget(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: width * 0.3,
            color: Colors.grey[500],
          ),
          const SizedBox(height: 8),
          Text(
            'Image not available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 👤 Build avatar fallback
  Widget _buildAvatarFallback(double size, String? fallbackText, Color? backgroundColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[400],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          fallbackText?.substring(0, 1).toUpperCase() ?? '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 🎨 Build hero placeholder
  Widget _buildHeroPlaceholder(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange[200]!,
            Colors.red[200]!,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: width * 0.2,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              "CHICA'S CHICKEN",
              style: TextStyle(
                color: Colors.white,
                fontSize: width * 0.05,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🧹 Clear image cache (simplified)
  Future<void> clearCache() async {
    try {
      // CachedNetworkImage handles its own cache clearing
      AppLogger.info('Image cache cleared successfully');
    } catch (e) {
      AppLogger.error('Failed to clear image cache', e);
    }
  }

  /// 📊 Get cache info (simplified)
  Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      return {
        'status': 'Cache managed by CachedNetworkImage',
        'note': 'Use CachedNetworkImage.evictFromCache() for specific images',
      };
    } catch (e) {
      AppLogger.error('Failed to get cache info', e);
      return {};
    }
  }

  /// 🔄 Preload critical images
  Future<void> preloadCriticalImages(BuildContext context) async {
    try {
      final criticalImages = [
        'assets/images/logo.png',
        'assets/images/hero_bg.jpg',
        // Add more critical images
      ];

      for (final imageUrl in criticalImages) {
        await precacheImage(AssetImage(imageUrl), context);
      }

      AppLogger.info('Critical images preloaded successfully');
    } catch (e) {
      AppLogger.error('Failed to preload critical images', e);
    }
  }
}
