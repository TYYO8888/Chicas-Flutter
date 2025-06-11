import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences.dart';
import '../models/cart.dart';

class UserPreferencesService {
  static const String baseUrl = 'http://localhost:3000/api';
  static const String _prefsKey = 'user_preferences';
  static const String _userIdKey = 'user_id';
  
  UserPreferences? _currentPreferences;
  String? _currentUserId;

  // Singleton pattern
  static final UserPreferencesService _instance = UserPreferencesService._internal();
  factory UserPreferencesService() => _instance;
  UserPreferencesService._internal();

  // Initialize user preferences
  Future<void> initialize({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get or generate user ID
    _currentUserId = userId ?? prefs.getString(_userIdKey) ?? _generateUserId();
    await prefs.setString(_userIdKey, _currentUserId!);

    // Load preferences from local storage first
    await _loadLocalPreferences();

    // Try to sync with server
    try {
      await syncWithServer();
    } catch (e) {
      debugPrint('Failed to sync with server: $e');
      // Continue with local preferences
    }
  }

  String _generateUserId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Load preferences from local storage
  Future<void> _loadLocalPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsJson = prefs.getString(_prefsKey);
    
    if (prefsJson != null) {
      try {
        final prefsMap = jsonDecode(prefsJson);
        _currentPreferences = UserPreferences.fromJson(prefsMap);
      } catch (e) {
        debugPrint('Error loading local preferences: $e');
        _currentPreferences = _createDefaultPreferences();
      }
    } else {
      _currentPreferences = _createDefaultPreferences();
    }
  }

  UserPreferences _createDefaultPreferences() {
    return UserPreferences(
      userId: _currentUserId!,
      lastUpdated: DateTime.now(),
    );
  }

  // Save preferences to local storage
  Future<void> _saveLocalPreferences() async {
    if (_currentPreferences == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final prefsJson = jsonEncode(_currentPreferences!.toJson());
    await prefs.setString(_prefsKey, prefsJson);
  }

  // Get current preferences
  UserPreferences? get currentPreferences => _currentPreferences;
  String? get currentUserId => _currentUserId;

  // API Methods

  // Get user preferences from server
  Future<UserPreferences> getUserPreferences(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/preferences'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserPreferences.fromJson(data);
    } else if (response.statusCode == 404) {
      // User preferences don't exist, create default
      return _createDefaultPreferences();
    } else {
      throw Exception('Failed to load user preferences: ${response.statusCode}');
    }
  }

  // Save user preferences to server
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/${preferences.userId}/preferences'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(preferences.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save user preferences: ${response.statusCode}');
    }
  }

  // Sync with server
  Future<void> syncWithServer() async {
    if (_currentUserId == null) return;

    try {
      final serverPrefs = await getUserPreferences(_currentUserId!);
      
      // Compare timestamps and use the most recent
      if (_currentPreferences == null || 
          serverPrefs.lastUpdated.isAfter(_currentPreferences!.lastUpdated)) {
        _currentPreferences = serverPrefs;
        await _saveLocalPreferences();
      } else if (_currentPreferences!.lastUpdated.isAfter(serverPrefs.lastUpdated)) {
        await saveUserPreferences(_currentPreferences!);
      }
    } catch (e) {
      debugPrint('Sync failed: $e');
      // Continue with local preferences
    }
  }

  // Favorite Menu Items

  // Add item to favorites
  Future<void> addToFavorites(String menuItemId) async {
    if (_currentPreferences == null) return;

    final updatedFavorites = List<String>.from(_currentPreferences!.favoriteMenuItems);
    if (!updatedFavorites.contains(menuItemId)) {
      updatedFavorites.add(menuItemId);
      
      _currentPreferences = _currentPreferences!.copyWith(
        favoriteMenuItems: updatedFavorites,
      );
      
      await _saveLocalPreferences();
      await _trySyncWithServer();
    }
  }

  // Remove item from favorites
  Future<void> removeFromFavorites(String menuItemId) async {
    if (_currentPreferences == null) return;

    final updatedFavorites = List<String>.from(_currentPreferences!.favoriteMenuItems);
    updatedFavorites.remove(menuItemId);
    
    _currentPreferences = _currentPreferences!.copyWith(
      favoriteMenuItems: updatedFavorites,
    );
    
    await _saveLocalPreferences();
    await _trySyncWithServer();
  }

  // Check if item is favorite
  bool isFavorite(String menuItemId) {
    return _currentPreferences?.favoriteMenuItems.contains(menuItemId) ?? false;
  }

  // Get favorite menu items
  List<String> getFavoriteMenuItems() {
    return _currentPreferences?.favoriteMenuItems ?? [];
  }

  // Favorite Orders

  // Save current cart as favorite order
  Future<void> saveFavoriteOrder(Cart cart, String orderName) async {
    if (_currentPreferences == null || cart.items.isEmpty) return;

    final favoriteOrder = FavoriteOrder(
      id: 'fav_${DateTime.now().millisecondsSinceEpoch}',
      name: orderName,
      items: cart.items.map((cartItem) => FavoriteOrderItem(
        menuItemId: cartItem.menuItem.id,
        menuItemName: cartItem.menuItem.name,
        quantity: cartItem.quantity,
        selectedSize: cartItem.selectedSize,
        selectedSauces: cartItem.menuItem.selectedSauces ?? [],
        customizations: const <String, dynamic>{}, // Simplified for compilation
        itemPrice: cartItem.itemPrice,
      )).toList(),
      totalPrice: cart.totalPrice,
      createdAt: DateTime.now(),
    );

    final updatedFavoriteOrders = List<FavoriteOrder>.from(_currentPreferences!.favoriteOrders);
    updatedFavoriteOrders.add(favoriteOrder);
    
    _currentPreferences = _currentPreferences!.copyWith(
      favoriteOrders: updatedFavoriteOrders,
    );
    
    await _saveLocalPreferences();
    await _trySyncWithServer();
  }

  // Get favorite orders
  List<FavoriteOrder> getFavoriteOrders() {
    return _currentPreferences?.favoriteOrders ?? [];
  }

  // Remove favorite order
  Future<void> removeFavoriteOrder(String orderId) async {
    if (_currentPreferences == null) return;

    final updatedFavoriteOrders = _currentPreferences!.favoriteOrders
        .where((order) => order.id != orderId)
        .toList();
    
    _currentPreferences = _currentPreferences!.copyWith(
      favoriteOrders: updatedFavoriteOrders,
    );
    
    await _saveLocalPreferences();
    await _trySyncWithServer();
  }

  // Settings

  // Update dark mode preference
  Future<void> setDarkMode(bool enabled) async {
    if (_currentPreferences == null) return;

    _currentPreferences = _currentPreferences!.copyWith(
      darkModeEnabled: enabled,
    );
    
    await _saveLocalPreferences();
    await _trySyncWithServer();
  }

  // Update notifications preference
  Future<void> setNotifications(bool enabled) async {
    if (_currentPreferences == null) return;

    _currentPreferences = _currentPreferences!.copyWith(
      notificationsEnabled: enabled,
    );
    
    await _saveLocalPreferences();
    await _trySyncWithServer();
  }

  // Update dietary restrictions
  Future<void> setDietaryRestrictions(Map<String, dynamic> restrictions) async {
    if (_currentPreferences == null) return;

    _currentPreferences = _currentPreferences!.copyWith(
      dietaryRestrictions: restrictions,
    );
    
    await _saveLocalPreferences();
    await _trySyncWithServer();
  }

  // Helper method to try syncing with server (non-blocking)
  Future<void> _trySyncWithServer() async {
    try {
      if (_currentPreferences != null) {
        await saveUserPreferences(_currentPreferences!);
      }
    } catch (e) {
      // Background sync failed, will retry later
      // Don't throw error, just log it
    }
  }

  // Clear all preferences (for logout)
  Future<void> clearPreferences() async {
    _currentPreferences = null;
    _currentUserId = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    await prefs.remove(_userIdKey);
  }
}
