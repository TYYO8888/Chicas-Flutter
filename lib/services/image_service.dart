import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image/image.dart' as img;

/// 🖼️ Advanced Image Service for Chica's Chicken App
/// Handles image optimization, caching, and delivery
class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  // 📱 Custom Cache Manager for Menu Images
  static final CacheManager _menuImageCache = CacheManager(
    Config(
      'menu_images',
      stalePeriod: const Duration(days: 7), // Keep images for 7 days
      maxNrOfCacheObjects: 200, // Maximum 200 cached images
      repo: JsonCacheInfoRepository(databaseName: 'menu_images'),
      fileService: HttpFileService(),
    ),
  );

  // 🎨 Custom Cache Manager for User Images
  static final CacheManager _userImageCache = CacheManager(
    Config(
      'user_images',
      stalePeriod: const Duration(days: 3), // Keep user images for 3 days
      maxNrOfCacheObjects: 50,
      repo: JsonCacheInfoRepository(databaseName: 'user_images'),
      fileService: HttpFileService(),
    ),
  );

  // 🌐 CDN Configuration
  static const String _cdnBaseUrl = 'https://res.cloudinary.com/chicas-chicken';
  static const String _fallbackCdnUrl = 'https://images.unsplash.com';

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
      child: CachedNetworkImage(
        imageUrl: optimizedUrl,
        cacheManager: _menuImageCache,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _buildPlaceholder(width, height, placeholder),
        errorWidget: (context, url, error) => _buildErrorWidget(width, height),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 100),
        memCacheWidth: (width * MediaQuery.of(context).devicePixelRatio).toInt(),
        memCacheHeight: (height * MediaQuery.of(context).devicePixelRatio).toInt(),
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
      child: CachedNetworkImage(
        imageUrl: optimizedUrl,
        cacheManager: _userImageCache,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildAvatarFallback(size, fallbackText, backgroundColor),
        errorWidget: (context, url, error) => _buildAvatarFallback(size, fallbackText, backgroundColor),
        fadeInDuration: const Duration(milliseconds: 200),
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

    Widget imageWidget = CachedNetworkImage(
      imageUrl: optimizedUrl,
      cacheManager: _menuImageCache,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _buildHeroPlaceholder(width, height),
      errorWidget: (context, url, error) => _buildHeroPlaceholder(width, height),
      fadeInDuration: const Duration(milliseconds: 500),
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

  /// 🧹 Clear image cache
  Future<void> clearCache() async {
    try {
      await _menuImageCache.emptyCache();
      await _userImageCache.emptyCache();
      AppLogger.info('Image cache cleared successfully');
    } catch (e) {
      AppLogger.error('Failed to clear image cache', e);
    }
  }

  /// 📊 Get cache info
  Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final menuCacheInfo = await _menuImageCache.getFileFromCache('cache_info');
      final userCacheInfo = await _userImageCache.getFileFromCache('cache_info');
      
      return {
        'menuCache': {
          'size': await _getCacheSize(_menuImageCache),
          'fileCount': await _getCacheFileCount(_menuImageCache),
        },
        'userCache': {
          'size': await _getCacheSize(_userImageCache),
          'fileCount': await _getCacheFileCount(_userImageCache),
        },
      };
    } catch (e) {
      AppLogger.error('Failed to get cache info', e);
      return {};
    }
  }

  /// 📏 Get cache size
  Future<int> _getCacheSize(CacheManager cacheManager) async {
    // Implementation would depend on cache manager internals
    return 0; // Placeholder
  }

  /// 📁 Get cache file count
  Future<int> _getCacheFileCount(CacheManager cacheManager) async {
    // Implementation would depend on cache manager internals
    return 0; // Placeholder
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
