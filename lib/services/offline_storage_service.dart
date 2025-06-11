import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/menu_item.dart';
import '../models/menu_category.dart';
import '../utils/logger.dart';

class OfflineStorageService {
  static const String _menuItemsKey = 'cached_menu_items';
  static const String _categoriesKey = 'cached_categories';
  static const String _pendingOrdersKey = 'pending_orders';
  static const String _syncMetadataKey = 'sync_metadata';
  static const String _orderHistoryTable = 'order_history';

  late SharedPreferences _prefs;
  late Database _database;

  bool _isInitialized = false;
  final Connectivity _connectivity = Connectivity();

  // Singleton pattern
  static final OfflineStorageService _instance = OfflineStorageService._internal();
  factory OfflineStorageService() => _instance;
  OfflineStorageService._internal();

  // Initialize offline storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();

      // Initialize SQLite for order history
      await _initializeDatabase();

      _isInitialized = true;
      AppLogger.info('Offline storage initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize offline storage', e);
      throw Exception('Offline storage initialization failed: $e');
    }
  }

  Future<void> _initializeDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'chicas_chicken.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_orderHistoryTable (
            id TEXT PRIMARY KEY,
            customer_id TEXT NOT NULL,
            items TEXT NOT NULL,
            subtotal REAL NOT NULL,
            tax REAL NOT NULL,
            total REAL NOT NULL,
            status TEXT NOT NULL,
            created_at TEXT NOT NULL,
            completed_at TEXT,
            synced INTEGER NOT NULL DEFAULT 0,
            metadata TEXT
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_customer_id ON $_orderHistoryTable(customer_id)
        ''');

        await db.execute('''
          CREATE INDEX idx_created_at ON $_orderHistoryTable(created_at)
        ''');
      },
    );
  }

  // Check network connectivity
  Future<bool> isOnline() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Menu Items Storage

  // Cache menu items locally
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

      AppLogger.info('Cached ${menuItems.length} menu items offline');
    } catch (e) {
      AppLogger.error('Failed to cache menu items', e);
    }
  }

  // Get cached menu items
  Future<List<MenuItem>> getCachedMenuItems({String? category}) async {
    await _ensureInitialized();

    try {
      final cachedData = _prefs.getString(_menuItemsKey);
      if (cachedData == null) return [];

      final itemsJson = jsonDecode(cachedData) as List;
      List<MenuItem> items = itemsJson.map((json) => MenuItem(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        price: json['price'].toDouble(),
        imageUrl: json['imageUrl'],
        category: json['category'],
        isSpecial: json['isSpecial'] ?? false,
        available: json['available'] ?? true,
        allowsSauceSelection: json['allowsSauceSelection'] ?? false,
        selectedSauces: json['selectedSauces']?.cast<String>() ?? [],
        includedSauceCount: json['includedSauceCount'] ?? 0,
        selectedBunType: json['selectedBunType'],
        allowsHeatLevelSelection: json['allowsHeatLevelSelection'] ?? false,
        selectedHeatLevel: json['selectedHeatLevel'],
        sizes: json['sizes']?.cast<String>() ?? [],
        customizationCounts: json['customizationCounts']?.cast<String, int>() ?? {},
        customizationCategories: json['customizationCategories']?.cast<String>() ?? [],
        customizations: json['customizations']?.cast<String, dynamic>() ?? {},
        nutritionInfo: json['nutritionInfo']?.cast<String, dynamic>() ?? {},
      )).toList();

      if (category != null) {
        items = items.where((item) =>
            item.category.toLowerCase() == category.toLowerCase()).toList();
      }

      return items;
    } catch (e) {
      AppLogger.error('Failed to get cached menu items', e);
      return [];
    }
  }

  // Check if menu items are cached
  bool hasMenuItemsCache() {
    return _isInitialized && _prefs.containsKey(_menuItemsKey);
  }

  // Get cache age for menu items
  DateTime? getMenuItemsCacheAge() {
    final metadataJson = _prefs.getString('${_syncMetadataKey}_menu_items');
    if (metadataJson == null) return null;

    try {
      final metadata = jsonDecode(metadataJson);
      return DateTime.parse(metadata['lastSyncTime']);
    } catch (e) {
      return null;
    }
  }

  // Categories Storage

  // Cache menu categories
  Future<void> cacheMenuCategories(List<MenuCategory> categories) async {
    await _ensureInitialized();

    try {
      final categoriesJson = categories.map((category) => {
        'id': category.id,
        'name': category.name,
        'displayOrder': category.displayOrder,
        'lastUpdated': DateTime.now().toIso8601String(),
      }).toList();

      await _prefs.setString(_categoriesKey, jsonEncode(categoriesJson));
      await _updateSyncMetadata('categories', categories.length);

      AppLogger.info('Cached ${categories.length} categories offline');
    } catch (e) {
      AppLogger.error('Failed to cache categories', e);
    }
  }

  // Get cached categories
  Future<List<MenuCategory>> getCachedCategories() async {
    await _ensureInitialized();

    try {
      final cachedData = _prefs.getString(_categoriesKey);
      if (cachedData == null) return [];

      final categoriesJson = jsonDecode(cachedData) as List;
      List<MenuCategory> categories = categoriesJson.map((json) => MenuCategory(
        id: json['id'],
        name: json['name'],
        displayOrder: json['displayOrder'],
      )).toList();

      categories.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      return categories;
    } catch (e) {
      AppLogger.error('Failed to get cached categories', e);
      return [];
    }
  }

  // Order History Storage (SQLite)

  // Save order to local history
  Future<void> saveOrderToHistory(Map<String, dynamic> orderData) async {
    await _ensureInitialized();
    
    try {
      await _database.insert(
        _orderHistoryTable,
        {
          'id': orderData['id'],
          'customer_id': orderData['customerId'] ?? 'guest',
          'items': jsonEncode(orderData['items']),
          'subtotal': orderData['subtotal'],
          'tax': orderData['tax'],
          'total': orderData['total'],
          'status': orderData['status'] ?? 'completed',
          'created_at': orderData['createdAt'] ?? DateTime.now().toIso8601String(),
          'completed_at': orderData['completedAt'],
          'synced': 0,
          'metadata': orderData['metadata'] != null ? jsonEncode(orderData['metadata']) : null,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      AppLogger.info('Order saved to local history: ${orderData['id']}');
    } catch (e) {
      AppLogger.error('Failed to save order to history', e);
    }
  }

  // Get order history
  Future<List<Map<String, dynamic>>> getOrderHistory({
    String? customerId,
    int limit = 50,
    int offset = 0,
  }) async {
    await _ensureInitialized();
    
    try {
      String whereClause = '';
      List<dynamic> whereArgs = [];
      
      if (customerId != null) {
        whereClause = 'WHERE customer_id = ?';
        whereArgs.add(customerId);
      }
      
      final List<Map<String, dynamic>> orders = await _database.query(
        _orderHistoryTable,
        where: whereClause.isNotEmpty ? whereClause.substring(6) : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'created_at DESC',
        limit: limit,
        offset: offset,
      );
      
      // Parse JSON fields
      return orders.map((order) {
        final parsedOrder = Map<String, dynamic>.from(order);
        parsedOrder['items'] = jsonDecode(order['items']);
        if (order['metadata'] != null) {
          parsedOrder['metadata'] = jsonDecode(order['metadata']);
        }
        parsedOrder['synced'] = order['synced'] == 1;
        return parsedOrder;
      }).toList();
    } catch (e) {
      AppLogger.error('Failed to get order history', e);
      return [];
    }
  }

  // Pending Orders Storage (Hive)

  // Save pending order (for when offline)
  Future<void> savePendingOrder(Map<String, dynamic> orderData) async {
    await _ensureInitialized();

    try {
      // Get existing pending orders
      final existingOrders = await getPendingOrders();

      // Add new order
      final orderToSave = {
        'id': orderData['id'],
        'customerId': orderData['customerId'] ?? 'guest',
        'items': orderData['items'],
        'subtotal': orderData['subtotal'],
        'tax': orderData['tax'],
        'total': orderData['total'],
        'status': 'pending',
        'createdAt': orderData['createdAt'] ?? DateTime.now().toIso8601String(),
        'synced': false,
        'metadata': orderData['metadata'],
      };

      existingOrders.add(orderToSave);

      // Save back to SharedPreferences
      await _prefs.setString(_pendingOrdersKey, jsonEncode(existingOrders));

      AppLogger.info('Pending order saved: ${orderData['id']}');
    } catch (e) {
      AppLogger.error('Failed to save pending order', e);
    }
  }

  // Get pending orders
  Future<List<Map<String, dynamic>>> getPendingOrders() async {
    await _ensureInitialized();

    try {
      final cachedData = _prefs.getString(_pendingOrdersKey);
      if (cachedData == null) return [];

      final ordersJson = jsonDecode(cachedData) as List;
      return ordersJson.cast<Map<String, dynamic>>();
    } catch (e) {
      AppLogger.error('Failed to get pending orders', e);
      return [];
    }
  }

  // Mark order as synced
  Future<void> markOrderAsSynced(String orderId) async {
    await _ensureInitialized();

    try {
      // Get pending orders and remove the synced one
      final pendingOrders = await getPendingOrders();
      final updatedOrders = pendingOrders.where((order) => order['id'] != orderId).toList();

      // Save updated list
      await _prefs.setString(_pendingOrdersKey, jsonEncode(updatedOrders));

      // Also update in SQLite
      await _database.update(
        _orderHistoryTable,
        {'synced': 1},
        where: 'id = ?',
        whereArgs: [orderId],
      );

      AppLogger.info('Order marked as synced: $orderId');
    } catch (e) {
      AppLogger.error('Failed to mark order as synced', e);
    }
  }

  // Sync Management

  // Update sync metadata
  Future<void> _updateSyncMetadata(String dataType, int recordCount) async {
    final metadata = {
      'dataType': dataType,
      'lastSyncTime': DateTime.now().toIso8601String(),
      'recordCount': recordCount,
      'syncInProgress': false,
    };

    await _prefs.setString('${_syncMetadataKey}_$dataType', jsonEncode(metadata));
  }

  // Get sync status
  Map<String, dynamic> getSyncStatus() {
    // Get menu items metadata
    final menuItemsMetadataJson = _prefs.getString('${_syncMetadataKey}_menu_items');
    Map<String, dynamic>? menuItemsMetadata;
    if (menuItemsMetadataJson != null) {
      try {
        menuItemsMetadata = jsonDecode(menuItemsMetadataJson);
      } catch (e) {
        menuItemsMetadata = null;
      }
    }

    // Get categories metadata
    final categoriesMetadataJson = _prefs.getString('${_syncMetadataKey}_categories');
    Map<String, dynamic>? categoriesMetadata;
    if (categoriesMetadataJson != null) {
      try {
        categoriesMetadata = jsonDecode(categoriesMetadataJson);
      } catch (e) {
        categoriesMetadata = null;
      }
    }

    return {
      'menuItems': {
        'lastSync': menuItemsMetadata?['lastSyncTime'],
        'recordCount': menuItemsMetadata?['recordCount'] ?? 0,
        'hasCache': hasMenuItemsCache(),
      },
      'categories': {
        'lastSync': categoriesMetadata?['lastSyncTime'],
        'recordCount': categoriesMetadata?['recordCount'] ?? 0,
        'hasCache': _prefs.containsKey(_categoriesKey),
      },
      'pendingOrders': _prefs.getString(_pendingOrdersKey) != null ?
          (jsonDecode(_prefs.getString(_pendingOrdersKey)!) as List).length : 0,
      'isOnline': false, // Will be updated by connectivity check
    };
  }

  // Clear all cached data
  Future<void> clearCache() async {
    await _ensureInitialized();

    try {
      await _prefs.remove(_menuItemsKey);
      await _prefs.remove(_categoriesKey);
      await _prefs.remove(_pendingOrdersKey);

      // Clear sync metadata
      final keys = _prefs.getKeys().where((key) => key.startsWith(_syncMetadataKey));
      for (final key in keys) {
        await _prefs.remove(key);
      }

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

  // Close all resources
  Future<void> dispose() async {
    if (_isInitialized) {
      await _database.close();
      _isInitialized = false;
    }
  }
}
