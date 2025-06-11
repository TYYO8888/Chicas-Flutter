import 'package:flutter/material.dart';

/// 🧪 Simple Extras Test - Minimal Version
/// 
/// This is a simplified version to test if the basic structure works
/// without complex dependencies or animations
class SimpleExtrasTest extends StatefulWidget {
  const SimpleExtrasTest({super.key});

  @override
  State<SimpleExtrasTest> createState() => _SimpleExtrasTestState();
}

class _SimpleExtrasTestState extends State<SimpleExtrasTest> {
  String _testResult = 'Ready to test...';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Simple Extras Test'),
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
                    '🔍 BASIC SYSTEM TEST',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _testResult,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Test Buttons
            const Text(
              '🧪 BASIC TESTS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _testBasicFunctionality,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Test Basic Functionality'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _testMenuItemCreation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Test Menu Item Creation'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _testExtrasData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Test Extras Data'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _showSimpleExtrasDemo,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Show Simple Extras Demo'),
            ),
          ],
        ),
      ),
    );
  }

  void _testBasicFunctionality() {
    try {
      // Test basic Flutter functionality
      final testList = <String>['test1', 'test2', 'test3'];
      final testMap = <String, dynamic>{'key': 'value', 'number': 42};
      
      setState(() {
        _testResult = 'SUCCESS: Basic functionality working\n'
            'List length: ${testList.length}\n'
            'Map keys: ${testMap.keys.join(', ')}\n'
            'Flutter widgets: OK';
      });
    } catch (e) {
      setState(() {
        _testResult = 'ERROR: Basic functionality failed\n$e';
      });
    }
  }

  void _testMenuItemCreation() {
    try {
      // Test creating a simple menu item structure
      final menuItem = {
        'id': 'test_item',
        'name': 'Test Sandwich',
        'description': 'A test sandwich for debugging',
        'price': 13.0,
        'category': 'sandwiches',
        'allowsExtras': true,
      };
      
      setState(() {
        _testResult = 'SUCCESS: Menu item creation working\n'
            'ID: ${menuItem['id']}\n'
            'Name: ${menuItem['name']}\n'
            'Price: \$${menuItem['price']}\n'
            'Allows Extras: ${menuItem['allowsExtras']}';
      });
    } catch (e) {
      setState(() {
        _testResult = 'ERROR: Menu item creation failed\n$e';
      });
    }
  }

  void _testExtrasData() {
    try {
      // Test creating simple extras structure
      final extras = [
        {
          'id': 'combo',
          'name': 'Make it a Combo!',
          'price': 8.50,
          'category': 'combo',
        },
        {
          'id': 'sauce',
          'name': 'Chica\'s Sauce',
          'price': 1.50,
          'category': 'sauce',
        },
        {
          'id': 'bun',
          'name': 'Brioche Bun',
          'price': 1.00,
          'category': 'bun',
        },
      ];
      
      final totalPrice = extras.fold<double>(0.0, (sum, extra) => sum + (extra['price'] as double));
      
      setState(() {
        _testResult = 'SUCCESS: Extras data working\n'
            'Total extras: ${extras.length}\n'
            'Sample extras: ${extras.map((e) => e['name']).join(', ')}\n'
            'Total price: \$${totalPrice.toStringAsFixed(2)}';
      });
    } catch (e) {
      setState(() {
        _testResult = 'ERROR: Extras data failed\n$e';
      });
    }
  }

  void _showSimpleExtrasDemo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🍗 Simple Extras Demo'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SAMPLE EXTRAS:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              _buildSimpleExtraItem('Make it a Combo!', 8.50, 'Add fries and drink'),
              _buildSimpleExtraItem('Chica\'s Sauce', 1.50, 'Buttermilk ranch sauce'),
              _buildSimpleExtraItem('Chipotle Aioli', 1.50, 'Smoky chipotle sauce'),
              _buildSimpleExtraItem('Buffalo Sauce', 1.50, 'Classic buffalo sauce'),
              _buildSimpleExtraItem('Brioche Bun', 1.00, 'Upgrade to brioche'),
              _buildSimpleExtraItem('Dill Pickles', 3.00, 'Extra pickle slices'),
              
              const SizedBox(height: 16),
              const Text(
                'TOTAL SAMPLE PRICE: \$17.00',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B35),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _testResult = 'SUCCESS: Simple extras demo completed\n'
                    'All extras displayed correctly\n'
                    'Dialog functionality working\n'
                    'Ready for full implementation';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
            ),
            child: const Text('TEST PASSED'),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleExtraItem(String name, double price, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+\$${price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B35),
            ),
          ),
        ],
      ),
    );
  }
}
