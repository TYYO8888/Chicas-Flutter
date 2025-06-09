import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/menu_item.dart';
import '../models/menu_category.dart';
import '../utils/logger.dart';

class SimpleOfflineStorage {
  static const String _menuItemsKey = 'cached_menu_items';
  static const String _categoriesKey = 'cached_categories';
  static const String _syncMetadataKey = 'sync_metadata';

  late SharedPreferences _prefs;
  bool _isInitialized = false;
  final Connectivity _connectivity = Connectivity();

  // Singleton pattern
  static final SimpleOfflineStorage _instance = SimpleOfflineStorage._internal();
  factory SimpleOfflineStorage() => _instance;
  SimpleOfflineStorage._internal();

  // Initialize storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      AppLogger.info('Simple offline storage initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize offline storage', e);
    }
  }

  // Check network connectivity
  Future<bool> isOnline() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Cache menu items
  Future<void> cacheMenuItems(List<MenuItem> menuItems) async {
    await _ensureInitialized();
    
    try {
      final itemsJson = menuItems.map((item) => {
        'id': item.id,
        'name': item.name,
        'description': item.description,
        'price': item.price,
        'imageUrl': item.imageUrl,
        'category': item.category,
        'isSpecial': item.isSpecial,
        'available': item.available,
        'allowsSauceSelection': item.allowsSauceSelection,
        'selectedSauces': item.selectedSauces,
        'includedSauceCount': item.includedSauceCount,
        'selectedBunType': item.selectedBunType,
        'allowsHeatLevelSelection': item.allowsHeatLevelSelection,
        'selectedHeatLevel': item.selectedHeatLevel,
        'sizes': item.sizes,
        'customizationCounts': item.customizationCounts,
        'customizationCategories': item.customizationCategories,
        'customizations': item.customizations,
        'nutritionInfo': item.nutritionInfo,
      }).toList();
      
      await _prefs.setString(_menuItemsKey, jsonEncode(itemsJson));
      await _updateSyncMetadata('menu_items', menuItems.length);
      
      AppLogger.info('Cached ${menuItems.length} menu items');
    } catch (e) {
      AppLogger.error('Failed to cache menu items', e);
    }
  }

  // Get cached menu items
  Future<List<MenuItem>> getCachedMenuItems({String? category}) async {
    await _ensureInitialized();
    
    try {
      final itemsJson = _prefs.getString(_menuItemsKey);
      if (itemsJson == null) return [];
      
      final itemsList = jsonDecode(itemsJson) as List;
      final menuItems = itemsList.map((json) => MenuItem(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        imageUrl: json['imageUrl'] ?? '',
        category: json['category'] ?? '',
        isSpecial: json['isSpecial'] ?? false,
        available: json['available'] ?? true,
        allowsSauceSelection: json['allowsSauceSelection'] ?? false,
        selectedSauces: json['selectedSauces']?.cast<String>(),
        includedSauceCount: json['includedSauceCount'],
        selectedBunType: json['selectedBunType'],
        allowsHeatLevelSelection: json['allowsHeatLevelSelection'] ?? false,
        selectedHeatLevel: json['selectedHeatLevel'],
        sizes: json['sizes']?.cast<String, double>(),
        customizationCounts: json['customizationCounts']?.cast<String, int>(),
        customizationCategories: json['customizationCategories']?.cast<String>(),
        customizations: json['customizations']?.cast<String, dynamic>(),
        nutritionInfo: json['nutritionInfo']?.cast<String, dynamic>(),
      )).toList();
      
      if (category != null) {
        return menuItems.where((item) => 
            item.category.toLowerCase() == category.toLowerCase()).toList();
      }
      
      return menuItems;
    } catch (e) {
      AppLogger.error('Failed to get cached menu items', e);
      return [];
    }
  }

  // Cache menu categories
  Future<void> cacheMenuCategories(List<MenuCategory> categories) async {
    await _ensureInitialized();
    
    try {
      final categoriesJson = categories.map((category) => {
        'id': category.id,
        'name': category.name,
        'displayOrder': category.displayOrder,
        'available': category.available,
      }).toList();
      
      await _prefs.setString(_categoriesKey, jsonEncode(categoriesJson));
      await _updateSyncMetadata('categories', categories.length);
      
      AppLogger.info('Cached ${categories.length} categories');
    } catch (e) {
      AppLogger.error('Failed to cache categories', e);
    }
  }

  // Get cached categories
  Future<List<MenuCategory>> getCachedCategories() async {
    await _ensureInitialized();
    
    try {
      final categoriesJson = _prefs.getString(_categoriesKey);
      if (categoriesJson == null) return [];
      
      final categoriesList = jsonDecode(categoriesJson) as List;
      final categories = categoriesList.map((json) => MenuCategory(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        displayOrder: json['displayOrder'] ?? 0,
        available: json['available'] ?? true,
      )).toList();
      
      categories.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      return categories;
    } catch (e) {
      AppLogger.error('Failed to get cached categories', e);
      return [];
    }
  }

  // Check if menu items are cached
  bool hasMenuItemsCache() {
    if (!_isInitialized) return false;
    return _prefs.getString(_menuItemsKey) != null;
  }

  // Get cache age for menu items
  DateTime? getMenuItemsCacheAge() {
    if (!_isInitialized) return null;
    
    final metadataJson = _prefs.getString(_syncMetadataKey);
    if (metadataJson == null) return null;
    
    try {
      final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;
      final menuItemsMetadata = metadata['menu_items'] as Map<String, dynamic>?;
      if (menuItemsMetadata != null && menuItemsMetadata['lastSync'] != null) {
        return DateTime.parse(menuItemsMetadata['lastSync']);
      }
    } catch (e) {
      AppLogger.error('Failed to get cache age', e);
    }
    
    return null;
  }

  // Update sync metadata
  Future<void> _updateSyncMetadata(String dataType, int recordCount) async {
    try {
      final existingMetadataJson = _prefs.getString(_syncMetadataKey);
      Map<String, dynamic> metadata = {};
      
      if (existingMetadataJson != null) {
        metadata = jsonDecode(existingMetadataJson) as Map<String, dynamic>;
      }
      
      metadata[dataType] = {
        'lastSync': DateTime.now().toIso8601String(),
        'recordCount': recordCount,
      };
      
      await _prefs.setString(_syncMetadataKey, jsonEncode(metadata));
    } catch (e) {
      AppLogger.error('Failed to update sync metadata', e);
    }
  }

  // Get sync status
  Map<String, dynamic> getSyncStatus() {
    if (!_isInitialized) {
      return {
        'menuItems': {'lastSync': null, 'recordCount': 0, 'hasCache': false},
        'categories': {'lastSync': null, 'recordCount': 0, 'hasCache': false},
        'isOnline': false,
      };
    }
    
    try {
      final metadataJson = _prefs.getString(_syncMetadataKey);
      Map<String, dynamic> metadata = {};
      
      if (metadataJson != null) {
        metadata = jsonDecode(metadataJson) as Map<String, dynamic>;
      }
      
      return {
        'menuItems': {
          'lastSync': metadata['menu_items']?['lastSync'],
          'recordCount': metadata['menu_items']?['recordCount'] ?? 0,
          'hasCache': hasMenuItemsCache(),
        },
        'categories': {
          'lastSync': metadata['categories']?['lastSync'],
          'recordCount': metadata['categories']?['recordCount'] ?? 0,
          'hasCache': _prefs.getString(_categoriesKey) != null,
        },
        'isOnline': false, // Will be updated by connectivity check
      };
    } catch (e) {
      AppLogger.error('Failed to get sync status', e);
      return {
        'menuItems': {'lastSync': null, 'recordCount': 0, 'hasCache': false},
        'categories': {'lastSync': null, 'recordCount': 0, 'hasCache': false},
        'isOnline': false,
      };
    }
  }

  // Clear all cached data
  Future<void> clearCache() async {
    await _ensureInitialized();
    
    try {
      await _prefs.remove(_menuItemsKey);
      await _prefs.remove(_categoriesKey);
      await _prefs.remove(_syncMetadataKey);
      
      AppLogger.info('All cached data cleared');
    } catch (e) {
      AppLogger.error('Failed to clear cache', e);
    }
  }

  // Utility methods
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }
}
