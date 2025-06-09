import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'offline_storage_service.dart';
import 'menu_service.dart';
import '../models/offline_data.dart';
import '../utils/logger.dart';

class DataSyncService {
  static const String baseUrl = 'http://localhost:3000/api';
  static const Duration syncInterval = Duration(minutes: 15);
  static const Duration cacheValidityDuration = Duration(hours: 2);

  final OfflineStorageService _offlineStorage = OfflineStorageService();
  final MenuService _menuService = MenuService();
  final Connectivity _connectivity = Connectivity();
  
  Timer? _syncTimer;
  bool _syncInProgress = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // Singleton pattern
  static final DataSyncService _instance = DataSyncService._internal();
  factory DataSyncService() => _instance;
  DataSyncService._internal();

  // Initialize sync service
  Future<void> initialize() async {
    await _offlineStorage.initialize();
    
    // Start listening to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );

    // Start periodic sync
    _startPeriodicSync();

    // Perform initial sync if online
    if (await _isOnline()) {
      _performSync();
    }

    AppLogger.info('Data sync service initialized');
  }

  // Handle connectivity changes
  void _onConnectivityChanged(ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      AppLogger.info('Connection restored, starting sync');
      _performSync();
    } else {
      AppLogger.info('Connection lost, switching to offline mode');
    }
  }

  // Start periodic synchronization
  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(syncInterval, (timer) {
      if (!_syncInProgress) {
        _performSync();
      }
    });
  }

  // Check if device is online
  Future<bool> _isOnline() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Perform full data synchronization
  Future<SyncResult> _performSync() async {
    if (_syncInProgress) {
      return SyncResult(success: false, message: 'Sync already in progress');
    }

    _syncInProgress = true;
    final syncResult = SyncResult();

    try {
      if (!await _isOnline()) {
        return SyncResult(success: false, message: 'Device is offline');
      }

      AppLogger.info('Starting data synchronization');

      // Sync menu data
      final menuSyncResult = await _syncMenuData();
      syncResult.menuItemsUpdated = menuSyncResult.menuItemsUpdated;
      syncResult.categoriesUpdated = menuSyncResult.categoriesUpdated;

      // Sync pending orders
      final orderSyncResult = await _syncPendingOrders();
      syncResult.ordersSynced = orderSyncResult.ordersSynced;

      syncResult.success = true;
      syncResult.message = 'Sync completed successfully';
      
      AppLogger.info('Data synchronization completed successfully');
    } catch (e) {
      syncResult.success = false;
      syncResult.message = 'Sync failed: $e';
      AppLogger.error('Data synchronization failed', e);
    } finally {
      _syncInProgress = false;
    }

    return syncResult;
  }

  // Sync menu data (categories and items)
  Future<SyncResult> _syncMenuData() async {
    final syncResult = SyncResult();

    try {
      // Check if cache is still valid
      final cacheAge = _offlineStorage.getMenuItemsCacheAge();
      if (cacheAge != null && 
          DateTime.now().difference(cacheAge) < cacheValidityDuration) {
        AppLogger.info('Menu cache is still valid, skipping sync');
        return syncResult;
      }

      // Sync categories
      final categories = await _menuService.getMenuCategories();
      await _offlineStorage.cacheMenuCategories(categories);
      syncResult.categoriesUpdated = categories.length;

      // Sync menu items for each category
      int totalItemsUpdated = 0;
      for (final category in categories) {
        final items = await _menuService.getMenuItems(category.name);
        await _offlineStorage.cacheMenuItems(items);
        totalItemsUpdated += items.length;
      }
      
      syncResult.menuItemsUpdated = totalItemsUpdated;
      AppLogger.info('Menu data synced: $totalItemsUpdated items, ${categories.length} categories');
    } catch (e) {
      AppLogger.error('Failed to sync menu data', e);
      throw e;
    }

    return syncResult;
  }

  // Sync pending orders to server
  Future<SyncResult> _syncPendingOrders() async {
    final syncResult = SyncResult();

    try {
      final pendingOrders = await _offlineStorage.getPendingOrders();
      
      if (pendingOrders.isEmpty) {
        AppLogger.info('No pending orders to sync');
        return syncResult;
      }

      int syncedCount = 0;
      for (final order in pendingOrders) {
        try {
          final success = await _uploadOrder(order);
          if (success) {
            await _offlineStorage.markOrderAsSynced(order.id);
            syncedCount++;
          }
        } catch (e) {
          AppLogger.error('Failed to sync order ${order.id}', e);
          // Continue with other orders
        }
      }

      syncResult.ordersSynced = syncedCount;
      AppLogger.info('Synced $syncedCount pending orders');
    } catch (e) {
      AppLogger.error('Failed to sync pending orders', e);
      throw e;
    }

    return syncResult;
  }

  // Upload order to server
  Future<bool> _uploadOrder(OfflineOrder order) async {
    try {
      final orderData = {
        'id': order.id,
        'customerId': order.customerId,
        'items': order.items.map((item) => {
          'menuItemId': item.menuItemId,
          'menuItemName': item.menuItemName,
          'quantity': item.quantity,
          'unitPrice': item.unitPrice,
          'totalPrice': item.totalPrice,
          'selectedSize': item.selectedSize,
          'selectedSauces': item.selectedSauces,
          'customizations': item.customizations,
        }).toList(),
        'subtotal': order.subtotal,
        'tax': order.tax,
        'total': order.total,
        'status': order.status,
        'createdAt': order.createdAt.toIso8601String(),
        'completedAt': order.completedAt?.toIso8601String(),
        'metadata': order.metadata,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.info('Order ${order.id} uploaded successfully');
        return true;
      } else {
        AppLogger.error('Failed to upload order ${order.id}: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      AppLogger.error('Error uploading order ${order.id}', e);
      return false;
    }
  }

  // Public API methods

  // Force sync now
  Future<SyncResult> syncNow() async {
    return await _performSync();
  }

  // Get sync status
  Map<String, dynamic> getSyncStatus() {
    final status = _offlineStorage.getSyncStatus();
    status['syncInProgress'] = _syncInProgress;
    status['lastSyncAttempt'] = DateTime.now().toIso8601String();
    return status;
  }

  // Check if data is available offline
  Future<bool> isDataAvailableOffline() async {
    return _offlineStorage.hasMenuItemsCache();
  }

  // Get menu items (online or offline)
  Future<List<MenuItem>> getMenuItems(String category) async {
    if (await _isOnline()) {
      try {
        // Try to get fresh data
        final items = await _menuService.getMenuItems(category);
        // Cache the fresh data
        await _offlineStorage.cacheMenuItems(items);
        return items;
      } catch (e) {
        AppLogger.error('Failed to fetch online data, falling back to cache', e);
      }
    }

    // Fallback to cached data
    return await _offlineStorage.getCachedMenuItems(category: category);
  }

  // Get menu categories (online or offline)
  Future<List<MenuCategory>> getMenuCategories() async {
    if (await _isOnline()) {
      try {
        // Try to get fresh data
        final categories = await _menuService.getMenuCategories();
        // Cache the fresh data
        await _offlineStorage.cacheMenuCategories(categories);
        return categories;
      } catch (e) {
        AppLogger.error('Failed to fetch online categories, falling back to cache', e);
      }
    }

    // Fallback to cached data
    return await _offlineStorage.getCachedCategories();
  }

  // Save order (online or offline)
  Future<bool> saveOrder(Map<String, dynamic> orderData) async {
    // Always save to local storage first
    await _offlineStorage.saveOrderToHistory(orderData);

    if (await _isOnline()) {
      try {
        // Try to upload immediately
        final response = await http.post(
          Uri.parse('$baseUrl/orders'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(orderData),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          AppLogger.info('Order uploaded immediately: ${orderData['id']}');
          return true;
        }
      } catch (e) {
        AppLogger.error('Failed to upload order immediately', e);
      }
    }

    // Save as pending order for later sync
    await _offlineStorage.savePendingOrder(orderData);
    AppLogger.info('Order saved for later sync: ${orderData['id']}');
    return true;
  }

  // Clear all cached data
  Future<void> clearCache() async {
    await _offlineStorage.clearCache();
  }

  // Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    _offlineStorage.dispose();
  }
}

// Sync result class
class SyncResult {
  bool success;
  String message;
  int menuItemsUpdated;
  int categoriesUpdated;
  int ordersSynced;

  SyncResult({
    this.success = false,
    this.message = '',
    this.menuItemsUpdated = 0,
    this.categoriesUpdated = 0,
    this.ordersSynced = 0,
  });

  @override
  String toString() {
    return 'SyncResult(success: $success, message: $message, '
           'menuItems: $menuItemsUpdated, categories: $categoriesUpdated, '
           'orders: $ordersSynced)';
  }
}
