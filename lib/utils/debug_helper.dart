import 'package:flutter/material.dart';
import '../screens/extras_test_screen.dart';
import '../screens/extras_demo_screen.dart';
import '../screens/menu_item_extras_screen.dart';
import '../screens/simple_extras_test.dart';
import '../models/menu_item.dart';
import '../models/menu_extras.dart';

/// 🔧 Debug Helper for Extras System
/// 
/// Provides easy access to testing and debugging tools
class DebugHelper {
  
  /// Show debug menu with all testing options
  static void showDebugMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔧 DEBUG MENU',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            ListTile(
              leading: const Icon(Icons.bug_report, color: Colors.green),
              title: const Text('Extras Test Screen'),
              subtitle: const Text('Basic testing and validation'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExtrasTestScreen(),
                  ),
                );
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.play_circle_outline, color: Colors.orange),
              title: const Text('Simple Extras Test'),
              subtitle: const Text('Basic test without complex dependencies'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SimpleExtrasTest(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.blue),
              title: const Text('Extras Demo Screen'),
              subtitle: const Text('Full demo with sample items'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExtrasDemoScreen(),
                  ),
                );
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.restaurant_menu, color: Colors.blue),
              title: const Text('Test Sandwich Extras'),
              subtitle: const Text('Direct extras screen test'),
              onTap: () {
                Navigator.pop(context);
                _testSandwichExtras(context);
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.info, color: Colors.grey),
              title: const Text('System Info'),
              subtitle: const Text('View implementation details'),
              onTap: () {
                Navigator.pop(context);
                _showSystemInfo(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Test sandwich extras directly
  static void _testSandwichExtras(BuildContext context) {
    final testItem = MenuItem(
      id: 'debug_sandwich',
      name: 'Debug Test Sandwich',
      description: 'Test sandwich for debugging extras system',
      price: 13.0,
      imageUrl: 'assets/sandwiches.png',
      category: 'sandwiches',
      allowsExtras: true,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuItemExtrasScreen(menuItem: testItem),
      ),
    );
  }

  /// Show system information
  static void _showSystemInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔧 System Info'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'EXTRAS SYSTEM IMPLEMENTATION',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              
              Text('📁 Core Files:'),
              Text('• lib/models/menu_extras.dart'),
              Text('• lib/screens/menu_item_extras_screen.dart'),
              Text('• lib/screens/extras_demo_screen.dart'),
              Text('• lib/screens/extras_test_screen.dart'),
              SizedBox(height: 12),
              
              Text('🎯 Features:'),
              Text('• Make it a Combo! upgrades'),
              Text('• 20+ extras per item'),
              Text('• Real-time price calculation'),
              Text('• Special instructions'),
              Text('• Cart integration'),
              Text('• Category-specific extras'),
              SizedBox(height: 12),
              
              Text('🧪 Testing:'),
              Text('• Use Extras Test Screen for basic validation'),
              Text('• Use Demo Screen for full experience'),
              Text('• Check cart integration'),
              Text('• Verify price calculations'),
              SizedBox(height: 12),
              
              Text('🐛 Common Issues:'),
              Text('• Ensure allowsExtras = true on menu items'),
              Text('• Check category matching in MenuExtrasData'),
              Text('• Verify cart service integration'),
              Text('• Test navigation flow'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  /// Quick test of core functionality
  static String quickSystemTest() {
    final results = <String>[];
    
    try {
      // Test 1: Menu extras data
      final sandwichExtras = MenuExtrasData.getExtrasForCategory('sandwiches');
      results.add('✅ Sandwich extras: ${sandwichExtras.length} sections');
      
      final crewPackExtras = MenuExtrasData.getExtrasForCategory('crew packs');
      results.add('✅ Crew pack extras: ${crewPackExtras.length} sections');
      
      // Test 2: Sample menu item
      final testItem = MenuItem(
        id: 'test',
        name: 'Test',
        description: 'Test',
        price: 10.0,
        imageUrl: 'test.png',
        category: 'sandwiches',
        allowsExtras: true,
      );
      results.add('✅ Menu item creation: ${testItem.allowsExtras}');
      
      // Test 3: Extras creation
      final extras = MenuItemExtras(sections: sandwichExtras);
      results.add('✅ Extras creation: ${extras.sections.length} sections');
      
      return results.join('\n');
      
    } catch (e) {
      return '❌ Error: $e';
    }
  }

  /// Add debug floating action button to any screen
  static Widget debugFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => showDebugMenu(context),
      backgroundColor: Colors.red,
      child: const Icon(Icons.bug_report, color: Colors.white),
    );
  }
}

/// Extension to add debug capabilities to any screen
extension DebugExtension on Widget {
  Widget withDebug(BuildContext context) {
    return Stack(
      children: [
        this,
        Positioned(
          top: 100,
          right: 16,
          child: FloatingActionButton.small(
            onPressed: () => DebugHelper.showDebugMenu(context),
            backgroundColor: Colors.red.withValues(alpha: 0.8),
            child: const Icon(Icons.bug_report, color: Colors.white, size: 16),
          ),
        ),
      ],
    );
  }
}
