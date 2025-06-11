import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/menu_item.dart';
import '../models/menu_extras.dart';
import '../screens/menu_item_extras_screen.dart';
import '../services/cart_service.dart';

/// 🍗 Extras Demo Screen
/// 
/// Demonstration screen showcasing the comprehensive extras system:
/// - Sample menu items with extras support
/// - Live testing of extras selection
/// - Cart integration demonstration
/// - Real-time price calculations
class ExtrasDemoScreen extends StatefulWidget {
  const ExtrasDemoScreen({super.key});

  @override
  State<ExtrasDemoScreen> createState() => _ExtrasDemoScreenState();
}

class _ExtrasDemoScreenState extends State<ExtrasDemoScreen> {
  final CartService _cartService = CartService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        '🍗 EXTRAS SYSTEM DEMO',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
      backgroundColor: const Color(0xFFFF6B35),
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Demo info
          _buildDemoInfo(),
          const SizedBox(height: 24),
          
          // Sample menu items
          _buildSampleMenuItems(),
          
          // Cart summary
          const SizedBox(height: 24),
          _buildCartSummary(),
        ],
      ),
    );
  }

  Widget _buildDemoInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF8A50)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 EXTRAS SYSTEM FEATURES',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem('✅ Make it a Combo! upgrades'),
          _buildFeatureItem('✅ 20+ extra add-ons per item'),
          _buildFeatureItem('✅ Real-time price calculation'),
          _buildFeatureItem('✅ Special instructions support'),
          _buildFeatureItem('✅ Category-specific extras'),
          _buildFeatureItem('✅ Quantity controls'),
          _buildFeatureItem('✅ Popular item indicators'),
          _buildFeatureItem('✅ Cart integration'),
        ],
      ),
    ).animate()
      .fadeIn()
      .slideY(begin: -0.2, end: 0);
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildSampleMenuItems() {
    final sampleItems = _getSampleMenuItems();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🍗 SAMPLE MENU ITEMS',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        ...sampleItems.map((item) => _buildMenuItemCard(item)),
      ],
    );
  }

  Widget _buildMenuItemCard(MenuItem menuItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with image placeholder
          Container(
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF8A50)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
                _getIconForCategory(menuItem.category),
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        menuItem.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (menuItem.allowsExtras)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'EXTRAS',
                          style: TextStyle(
                            color: Color(0xFFFF6B35),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  menuItem.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${menuItem.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _showExtrasForItem(menuItem),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'CUSTOMIZE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: Duration(milliseconds: 200 * _getSampleMenuItems().indexOf(menuItem)))
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildCartSummary() {
    final cartItems = _cartService.getCartItems();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_cart, color: Color(0xFFFF6B35)),
              const SizedBox(width: 8),
              const Text(
                'CART SUMMARY',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${cartItems.length} items',
                  style: const TextStyle(
                    color: Color(0xFFFF6B35),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (cartItems.isEmpty) ...[
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cart is empty',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add items with extras to see them here',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ...cartItems.map((cartItem) => _buildCartItemSummary(cartItem)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${_cartService.getTotalPrice().toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B35),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate()
      .fadeIn(delay: const Duration(milliseconds: 600))
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildCartItemSummary(dynamic cartItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  cartItem.menuItem.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '\$${cartItem.itemPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B35),
                ),
              ),
            ],
          ),
          if (cartItem.extras != null && cartItem.extras!.totalExtrasCount > 0) ...[
            const SizedBox(height: 8),
            Text(
              '+ ${cartItem.extras!.totalExtrasCount} extras (+\$${cartItem.extras!.totalExtrasPrice.toStringAsFixed(2)})',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<MenuItem> _getSampleMenuItems() {
    return [
      MenuItem(
        id: 'og_sando_demo',
        name: 'The OG Sando',
        description: 'Nashville-spiced chicken breast with pickles and mayo',
        price: 13.00,
        imageUrl: 'assets/sandwiches.png',
        category: 'sandwiches',
        allowsExtras: true,
        allowsHeatLevelSelection: true,
      ),
      MenuItem(
        id: 'crew_pack_demo',
        name: 'Crew Pack (4 Sandwiches)',
        description: 'Perfect for sharing with the crew',
        price: 45.00,
        imageUrl: 'assets/crew_packs.png',
        category: 'crew packs',
        allowsExtras: true,
      ),
      MenuItem(
        id: 'whole_wings_demo',
        name: 'Whole Wings (8 pieces)',
        description: 'Crispy Nashville-style whole wings',
        price: 18.00,
        imageUrl: 'assets/whole_wings.png',
        category: 'whole wings',
        allowsExtras: true,
      ),
      MenuItem(
        id: 'chicken_pieces_demo',
        name: 'Chicken Pieces (6 pieces)',
        description: 'Tender chicken pieces with signature spice',
        price: 16.00,
        imageUrl: 'assets/chicken_pieces.png',
        category: 'chicken pieces',
        allowsExtras: true,
      ),
    ];
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'sandwiches':
        return Icons.lunch_dining;
      case 'crew packs':
        return Icons.group;
      case 'whole wings':
        return Icons.restaurant;
      case 'chicken pieces':
        return Icons.fastfood;
      default:
        return Icons.restaurant_menu;
    }
  }

  Future<void> _showExtrasForItem(MenuItem menuItem) async {
    final result = await Navigator.of(context).push<MenuItemExtras>(
      MaterialPageRoute(
        builder: (context) => MenuItemExtrasScreen(menuItem: menuItem),
      ),
    );

    if (result != null && mounted) {
      _cartService.addToCart(menuItem, extras: result);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${menuItem.name} added to cart with extras!'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFFF6B35),
          duration: const Duration(seconds: 2),
        ),
      );
      
      setState(() {}); // Refresh cart summary
    }
  }
}
