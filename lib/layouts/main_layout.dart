import 'package:flutter/material.dart';
import '../screens/cart_screen.dart';
import '../screens/home_screen.dart';
import '../screens/loyalty_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/games_hub_screen.dart';

import '../screens/order_type_selection_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/navigation_menu_drawer.dart';
import '../widgets/notification_banner.dart';
import '../services/cart_service.dart';
import '../services/notification_service.dart';


class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0; // Start with Home/Offers selected
  final CartService _cartService = CartService();
  final NotificationService _notificationService = NotificationService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final PageController _pageController;
  bool _hasProcessedArguments = false;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);

    // 🚀 Performance: Initialize notification service asynchronously
    _initializeServicesAsync();

    // 🚀 Performance: Lazy load pages to reduce initial memory usage
    _pages = [
      HomeScreen(cartService: _cartService), // Home/Offers page - load immediately
      const GamesHubScreen(), // Games hub - play and earn rewards
      OrderTypeSelectionScreen(cartService: _cartService), // Order type selection page
      CartScreen(cartService: _cartService), // Cart page
      const LoyaltyScreen(), // Loyalty page
    ];
  }

  // 🚀 Performance: Async service initialization
  void _initializeServicesAsync() {
    Future.microtask(() async {
      try {
        await _notificationService.initialize();
      } catch (e) {
        // Handle initialization errors gracefully
        debugPrint('Notification service initialization failed: $e');
      }
    });
  }

  void _onItemTapped(int index) {
    // All tabs now navigate to their respective screens
    setState(() {
      _selectedIndex = index;
    });
    // Jump to the selected page
    _pageController.jumpToPage(index);
  }

  // 🧹 Performance: Proper disposal to prevent memory leaks
  @override
  void dispose() {
    _pageController.dispose();
    _notificationService.dispose();
    super.dispose();
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🚀 Advanced analytics/test features removed for production
        // Favorites button (moved to bottom)
        FloatingActionButton(
          heroTag: "favorites",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FavoritesScreen(),
              ),
            );
          },
          backgroundColor: Colors.pink,
          tooltip: 'Favorites',
          child: const Icon(Icons.favorite, color: Colors.white),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check for route arguments to set initial page (only once)
    final args = ModalRoute.of(context)?.settings.arguments;
    if (!_hasProcessedArguments && args is Map<String, dynamic> && args['initialPage'] != null) {
      final targetPage = args['initialPage'] as int;
      if (targetPage >= 0 && targetPage < _pages.length) {
        _hasProcessedArguments = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _selectedIndex = targetPage;
          });
          _pageController.jumpToPage(targetPage);
        });
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          // 🚀 Performance: Optimized PageView with caching
          PageView.builder(
            physics: const NeverScrollableScrollPhysics(),
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _pages[index];
            },
          ),
          // Notification banner overlay
          const NotificationBanner(),
        ],
      ),
      endDrawer: const NavigationMenuDrawer(),
      floatingActionButton: _buildFloatingActionButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
