import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/offline_data.dart';
import '../models/menu_item.dart';
import '../models/menu_category.dart';
import '../utils/logger.dart';

class OfflineStorageService {
  static const String _menuItemsBox = 'menu_items';
  static const String _ordersBox = 'orders';
  static const String _categoriesBox = 'categories';
  static const String _syncMetadataBox = 'sync_metadata';
  static const String _orderHistoryTable = 'order_history';

  late Box<OfflineMenuItem> _menuItemsBox_;
  late Box<OfflineOrder> _ordersBox_;
  late Box<OfflineMenuCategory> _categoriesBox_;
  late Box<SyncMetadata> _syncMetadataBox_;
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
      // Initialize Hive
      await Hive.initFlutter();
      
      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(OfflineMenuItemAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(OfflineOrderAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(OfflineOrderItemAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(OfflineMenuCategoryAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(SyncMetadataAdapter());
      }

      // Open boxes
      _menuItemsBox_ = await Hive.openBox<OfflineMenuItem>(_menuItemsBox);
      _ordersBox_ = await Hive.openBox<OfflineOrder>(_ordersBox);
      _categoriesBox_ = await Hive.openBox<OfflineMenuCategory>(_categoriesBox);
      _syncMetadataBox_ = await Hive.openBox<SyncMetadata>(_syncMetadataBox);

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
      final offlineItems = menuItems.map((item) => 
          OfflineMenuItem.fromMenuItem(item)).toList();
      
      // Clear existing items
      await _menuItemsBox_.clear();
      
      // Add new items
      for (final item in offlineItems) {
        await _menuItemsBox_.put(item.id, item);
      }

      // Update sync metadata
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
      final offlineItems = _menuItemsBox_.values.toList();
      
      List<OfflineMenuItem> filteredItems = offlineItems;
      if (category != null) {
        filteredItems = offlineItems.where((item) => 
            item.category.toLowerCase() == category.toLowerCase()).toList();
      }
      
      return filteredItems.map((item) => item.toMenuItem()).toList();
    } catch (e) {
      AppLogger.error('Failed to get cached menu items', e);
      return [];
    }
  }

  // Check if menu items are cached
  bool hasMenuItemsCache() {
    return _isInitialized && _menuItemsBox_.isNotEmpty;
  }

  // Get cache age for menu items
  DateTime? getMenuItemsCacheAge() {
    final metadata = _syncMetadataBox_.get('menu_items');
    return metadata?.lastSyncTime;
  }

  // Categories Storage

  // Cache menu categories
  Future<void> cacheMenuCategories(List<MenuCategory> categories) async {
    await _ensureInitialized();
    
    try {
      // Clear existing categories
      await _categoriesBox_.clear();
      
      // Add new categories
      for (final category in categories) {
        final offlineCategory = OfflineMenuCategory(
          id: category.id,
          name: category.name,
          displayOrder: category.displayOrder,
          lastUpdated: DateTime.now(),
        );
        await _categoriesBox_.put(category.id, offlineCategory);
      }

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
      final offlineCategories = _categoriesBox_.values.toList();
      offlineCategories.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      
      return offlineCategories.map((category) => MenuCategory(
        id: category.id,
        name: category.name,
        displayOrder: category.displayOrder,
      )).toList();
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
      final offlineOrder = OfflineOrder(
        id: orderData['id'],
        customerId: orderData['customerId'] ?? 'guest',
        items: (orderData['items'] as List).map((item) => OfflineOrderItem(
          menuItemId: item['menuItemId'],
          menuItemName: item['menuItemName'],
          quantity: item['quantity'],
          unitPrice: item['unitPrice'].toDouble(),
          totalPrice: item['totalPrice'].toDouble(),
          selectedSize: item['selectedSize'],
          selectedSauces: item['selectedSauces']?.cast<String>(),
          customizations: item['customizations'],
        )).toList(),
        subtotal: orderData['subtotal'].toDouble(),
        tax: orderData['tax'].toDouble(),
        total: orderData['total'].toDouble(),
        status: 'pending',
        createdAt: DateTime.parse(orderData['createdAt'] ?? DateTime.now().toIso8601String()),
        synced: false,
        metadata: orderData['metadata'],
      );
      
      await _ordersBox_.put(orderData['id'], offlineOrder);
      
      AppLogger.info('Pending order saved: ${orderData['id']}');
    } catch (e) {
      AppLogger.error('Failed to save pending order', e);
    }
  }

  // Get pending orders
  Future<List<OfflineOrder>> getPendingOrders() async {
    await _ensureInitialized();
    
    return _ordersBox_.values.where((order) => !order.synced).toList();
  }

  // Mark order as synced
  Future<void> markOrderAsSynced(String orderId) async {
    await _ensureInitialized();
    
    try {
      final order = _ordersBox_.get(orderId);
      if (order != null) {
        await _ordersBox_.delete(orderId);
        
        // Also update in SQLite
        await _database.update(
          _orderHistoryTable,
          {'synced': 1},
          where: 'id = ?',
          whereArgs: [orderId],
        );
      }
    } catch (e) {
      AppLogger.error('Failed to mark order as synced', e);
    }
  }

  // Sync Management

  // Update sync metadata
  Future<void> _updateSyncMetadata(String dataType, int recordCount) async {
    final metadata = SyncMetadata(
      dataType: dataType,
      lastSyncTime: DateTime.now(),
      recordCount: recordCount,
      syncInProgress: false,
    );
    
    await _syncMetadataBox_.put(dataType, metadata);
  }

  // Get sync status
  Map<String, dynamic> getSyncStatus() {
    final menuItemsMetadata = _syncMetadataBox_.get('menu_items');
    final categoriesMetadata = _syncMetadataBox_.get('categories');
    
    return {
      'menuItems': {
        'lastSync': menuItemsMetadata?.lastSyncTime?.toIso8601String(),
        'recordCount': menuItemsMetadata?.recordCount ?? 0,
        'hasCache': hasMenuItemsCache(),
      },
      'categories': {
        'lastSync': categoriesMetadata?.lastSyncTime?.toIso8601String(),
        'recordCount': categoriesMetadata?.recordCount ?? 0,
        'hasCache': _categoriesBox_.isNotEmpty,
      },
      'pendingOrders': _ordersBox_.length,
      'isOnline': false, // Will be updated by connectivity check
    };
  }

  // Clear all cached data
  Future<void> clearCache() async {
    await _ensureInitialized();
    
    try {
      await _menuItemsBox_.clear();
      await _categoriesBox_.clear();
      await _syncMetadataBox_.clear();
      
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
      await _menuItemsBox_.close();
      await _ordersBox_.close();
      await _categoriesBox_.close();
      await _syncMetadataBox_.close();
      await _database.close();
      _isInitialized = false;
    }
  }
}
