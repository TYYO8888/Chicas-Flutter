import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../models/menu_extras.dart';
import '../screens/menu_item_extras_screen.dart';
import '../screens/extras_demo_screen.dart';
import '../services/cart_service.dart';

/// 🧪 Simple Extras Test Screen
/// 
/// Minimal test interface to debug and validate the extras system
class ExtrasTestScreen extends StatefulWidget {
  const ExtrasTestScreen({super.key});

  @override
  State<ExtrasTestScreen> createState() => _ExtrasTestScreenState();
}

class _ExtrasTestScreenState extends State<ExtrasTestScreen> {
  final CartService _cartService = CartService();
  String _lastResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 EXTRAS TEST'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔍 SYSTEM STATUS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusItem('Menu Extras Model', _testMenuExtrasModel()),
                  _buildStatusItem('Cart Service', _testCartService()),
                  _buildStatusItem('Sample Data', _testSampleData()),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Test Buttons
            const Text(
              '🧪 TEST ACTIONS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: _testBasicExtras,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Test Basic Extras'),
                ),
                ElevatedButton(
                  onPressed: _testSandwichExtras,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Test Sandwich'),
                ),
                ElevatedButton(
                  onPressed: _testCartIntegration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Test Cart'),
                ),
                ElevatedButton(
                  onPressed: _openDemoScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Open Demo'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Results
            if (_lastResult.isNotEmpty) ...[
              const Text(
                '📋 LAST RESULT',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _lastResult,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            
            const Spacer(),
            
            // Cart Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🛒 CART STATUS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Items: ${_cartService.getCartItems().length}'),
                  Text('Total: \$${_cartService.getTotalPrice().toStringAsFixed(2)}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.error,
            color: status ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  bool _testMenuExtrasModel() {
    try {
      final extras = MenuExtrasData.getExtrasForCategory('sandwiches');
      return extras.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  bool _testCartService() {
    try {
      _cartService.getCartItems();
      _cartService.getTotalPrice();
      return true;
    } catch (e) {
      return false;
    }
  }

  bool _testSampleData() {
    try {
      final sampleItem = MenuItem(
        id: 'test',
        name: 'Test Item',
        description: 'Test Description',
        price: 10.0,
        imageUrl: 'test.png',
        category: 'sandwiches',
        allowsExtras: true,
      );
      return sampleItem.allowsExtras;
    } catch (e) {
      return false;
    }
  }

  void _testBasicExtras() {
    try {
      final extras = MenuExtrasData.getExtrasForCategory('sandwiches');
      setState(() {
        _lastResult = 'SUCCESS: Found ${extras.length} extra sections\n'
            'Sections: ${extras.map((e) => e.title).join(', ')}\n'
            'Total extras: ${extras.fold(0, (sum, section) => sum + section.extras.length)}';
      });
    } catch (e) {
      setState(() {
        _lastResult = 'ERROR: $e';
      });
    }
  }

  void _testSandwichExtras() async {
    try {
      final sampleItem = MenuItem(
        id: 'test_sandwich',
        name: 'Test Sandwich',
        description: 'Test sandwich for extras',
        price: 13.0,
        imageUrl: 'test.png',
        category: 'sandwiches',
        allowsExtras: true,
      );

      final result = await Navigator.of(context).push<MenuItemExtras>(
        MaterialPageRoute(
          builder: (context) => MenuItemExtrasScreen(menuItem: sampleItem),
        ),
      );

      if (result != null) {
        setState(() {
          _lastResult = 'SUCCESS: Extras selected\n'
              'Total extras: ${result.totalExtrasCount}\n'
              'Total price: \$${result.totalExtrasPrice.toStringAsFixed(2)}\n'
              'Instructions: ${result.specialInstructions ?? 'None'}';
        });
      } else {
        setState(() {
          _lastResult = 'CANCELLED: User cancelled extras selection';
        });
      }
    } catch (e) {
      setState(() {
        _lastResult = 'ERROR: $e';
      });
    }
  }

  void _testCartIntegration() {
    try {
      final sampleItem = MenuItem(
        id: 'test_cart',
        name: 'Test Cart Item',
        description: 'Test item for cart',
        price: 15.0,
        imageUrl: 'test.png',
        category: 'sandwiches',
        allowsExtras: true,
      );

      // Create sample extras
      final sections = MenuExtrasData.getExtrasForCategory('sandwiches');
      final extras = MenuItemExtras(sections: sections);
      
      // Add a sample extra
      if (sections.isNotEmpty && sections.first.extras.isNotEmpty) {
        extras.addExtra(sections.first.id, sections.first.extras.first);
      }

      _cartService.addToCart(sampleItem, extras: extras);

      setState(() {
        _lastResult = 'SUCCESS: Added item to cart with extras\n'
            'Cart items: ${_cartService.getCartItems().length}\n'
            'Cart total: \$${_cartService.getTotalPrice().toStringAsFixed(2)}';
      });
    } catch (e) {
      setState(() {
        _lastResult = 'ERROR: $e';
      });
    }
  }

  void _openDemoScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ExtrasDemoScreen(),
      ),
    );
  }
}
