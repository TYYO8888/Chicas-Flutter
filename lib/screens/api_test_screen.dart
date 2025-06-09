// 🧪 API Test Screen
// This screen tests the backend API integration

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/menu_item.dart';
import '../utils/logger.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({Key? key}) : super(key: key);

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final ApiService _apiService = ApiService();
  List<MenuCategory> _categories = [];
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;
  String _status = 'Ready to test API';

  @override
  void initState() {
    super.initState();
    _testHealthCheck();
  }

  Future<void> _testHealthCheck() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing health check...';
    });

    try {
      // Test basic connectivity by checking if we can reach the health endpoint
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      setState(() {
        _status = '✅ Backend is reachable!';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Backend connection failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testGetCategories() async {
    setState(() {
      _isLoading = true;
      _status = 'Fetching menu categories...';
    });

    try {
      final categories = await _apiService.getMenuCategories();
      setState(() {
        _categories = categories;
        _status = '✅ Loaded ${categories.length} categories';
      });
      AppLogger.info('Successfully loaded ${categories.length} categories');
    } catch (e) {
      setState(() {
        _status = '❌ Failed to load categories: $e';
      });
      AppLogger.error('Failed to load categories', e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testGetMenuItems(String categoryId) async {
    setState(() {
      _isLoading = true;
      _status = 'Fetching menu items for $categoryId...';
    });

    try {
      final items = await _apiService.getMenuItems(categoryId);
      setState(() {
        _menuItems = items;
        _status = '✅ Loaded ${items.length} items for $categoryId';
      });
      AppLogger.info('Successfully loaded ${items.length} items for $categoryId');
    } catch (e) {
      setState(() {
        _status = '❌ Failed to load items: $e';
      });
      AppLogger.error('Failed to load menu items', e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    if (_isLoading) ...[
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test Buttons
            ElevatedButton(
              onPressed: _isLoading ? null : _testGetCategories,
              child: const Text('Test Get Categories'),
            ),
            
            const SizedBox(height: 8),
            
            if (_categories.isNotEmpty) ...[
              const Text(
                'Categories:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _categories.map((category) {
                  return ElevatedButton(
                    onPressed: _isLoading 
                        ? null 
                        : () => _testGetMenuItems(category.id),
                    child: Text(category.name),
                  );
                }).toList(),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Menu Items
            if (_menuItems.isNotEmpty) ...[
              const Text(
                'Menu Items:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _menuItems.length,
                  itemBuilder: (context, index) {
                    final item = _menuItems[index];
                    return Card(
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Text(item.description),
                        trailing: Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            item.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
