import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/user_preferences.dart';
import '../models/menu_item.dart';
import '../services/user_preferences_service.dart';
import '../services/menu_service.dart';
import '../services/cart_service.dart';
import '../constants/typography.dart';
import '../constants/colors.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with TickerProviderStateMixin {
  final UserPreferencesService _preferencesService = UserPreferencesService();
  final MenuService _menuService = MenuService();
  final CartService _cartService = CartService();
  
  late TabController _tabController;
  List<MenuItem> _favoriteMenuItems = [];
  List<FavoriteOrder> _favoriteOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    
    try {
      // Load favorite menu items
      final favoriteItemIds = _preferencesService.getFavoriteMenuItems();
      final allMenuItems = await _menuService.getAllMenuItems();
      
      _favoriteMenuItems = allMenuItems
          .where((item) => favoriteItemIds.contains(item.id))
          .toList();

      // Load favorite orders
      _favoriteOrders = _preferencesService.getFavoriteOrders();
      
    } catch (e) {
      print('Error loading favorites: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FAVORITES',
          style: AppTypography.displaySmall.copyWith(color: AppColors.textPrimary),
        ).animate()
          .fadeIn(duration: const Duration(milliseconds: 600))
          .slideX(begin: -0.2, end: 0),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'MENU ITEMS'),
            Tab(text: 'SAVED ORDERS'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFavoriteMenuItems(),
                _buildFavoriteOrders(),
              ],
            ),
    );
  }

  Widget _buildFavoriteMenuItems() {
    if (_favoriteMenuItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: AppColors.textSecondary,
            ).animate().scale(delay: const Duration(milliseconds: 200)),
            const SizedBox(height: 16),
            Text(
              'NO FAVORITE ITEMS YET',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
            const SizedBox(height: 8),
            Text(
              'Add items to favorites by tapping the heart icon',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: const Duration(milliseconds: 600)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favoriteMenuItems.length,
      itemBuilder: (context, index) {
        final item = _favoriteMenuItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.restaurant,
                color: AppColors.primary,
              ),
            ),
            title: Text(
              item.name.toUpperCase(),
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: AppTypography.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _removeFromFavorites(item.id),
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  tooltip: 'Remove from favorites',
                ),
                IconButton(
                  onPressed: () => _addToCart(item),
                  icon: Icon(Icons.add_shopping_cart, color: AppColors.primary),
                  tooltip: 'Add to cart',
                ),
              ],
            ),
          ),
        ).animate()
          .fadeIn(delay: Duration(milliseconds: 100 * index))
          .slideX(begin: 0.2, end: 0);
      },
    );
  }

  Widget _buildFavoriteOrders() {
    if (_favoriteOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: AppColors.textSecondary,
            ).animate().scale(delay: const Duration(milliseconds: 200)),
            const SizedBox(height: 16),
            Text(
              'NO SAVED ORDERS YET',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
            const SizedBox(height: 8),
            Text(
              'Save your favorite orders for quick reordering',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: const Duration(milliseconds: 600)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favoriteOrders.length,
      itemBuilder: (context, index) {
        final order = _favoriteOrders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.bookmark,
                color: AppColors.primary,
              ),
            ),
            title: Text(
              order.name.toUpperCase(),
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${order.items.length} items • \$${order.totalPrice.toStringAsFixed(2)}',
                  style: AppTypography.bodySmall,
                ),
                Text(
                  'Ordered ${order.orderCount} time${order.orderCount == 1 ? '' : 's'}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _reorderFavorite(order),
                  icon: Icon(Icons.add_shopping_cart, color: AppColors.primary),
                  tooltip: 'Add to cart',
                ),
                IconButton(
                  onPressed: () => _removeFavoriteOrder(order.id),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Remove order',
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORDER DETAILS:',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Text('${item.quantity}x '),
                          Expanded(
                            child: Text(
                              item.menuItemName,
                              style: AppTypography.bodySmall,
                            ),
                          ),
                          Text(
                            '\$${(item.itemPrice * item.quantity).toStringAsFixed(2)}',
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ],
          ),
        ).animate()
          .fadeIn(delay: Duration(milliseconds: 100 * index))
          .slideX(begin: 0.2, end: 0);
      },
    );
  }

  Future<void> _removeFromFavorites(String menuItemId) async {
    await _preferencesService.removeFromFavorites(menuItemId);
    await _loadFavorites();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('REMOVED FROM FAVORITES'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addToCart(MenuItem item) async {
    // Add item to cart with default settings
    _cartService.addToCart(item);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name.toUpperCase()} ADDED TO CART'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _reorderFavorite(FavoriteOrder order) async {
    try {
      // Get all menu items to match with favorite order items
      final allMenuItems = await _menuService.getAllMenuItems();

      for (final favoriteItem in order.items) {
        // Find the corresponding menu item
        final menuItem = allMenuItems.firstWhere(
          (item) => item.id == favoriteItem.menuItemId,
          orElse: () => throw Exception('Menu item not found: ${favoriteItem.menuItemId}'),
        );

        // Create a copy with the saved customizations
        final customizedItem = menuItem.clone();
        customizedItem.selectedSauces = favoriteItem.selectedSauces;

        // Add to cart with saved settings
        for (int i = 0; i < favoriteItem.quantity; i++) {
          _cartService.addToCart(
            customizedItem,
            selectedSize: favoriteItem.selectedSize,
            customizations: favoriteItem.customizations.isNotEmpty
                ? {favoriteItem.menuItemId: [customizedItem]}
                : null,
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${order.name.toUpperCase()} ADDED TO CART'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ERROR ADDING ORDER TO CART'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeFavoriteOrder(String orderId) async {
    await _preferencesService.removeFavoriteOrder(orderId);
    await _loadFavorites();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SAVED ORDER REMOVED'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
