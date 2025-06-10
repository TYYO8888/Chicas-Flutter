import 'package:flutter/material.dart';
import '../screens/menu_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/home_screen.dart';
import '../screens/loyalty_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/navigation_menu_drawer.dart';
import '../widgets/notification_banner.dart';
import '../services/cart_service.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart' as theme_service;
import '../widgets/theme_mode_selector.dart';

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

    // Initialize notification service
    _notificationService.initialize();

    _pages = [
      HomeScreen(cartService: _cartService), // Home/Offers page
      const Scaffold(body: Center(child: Text('SCAN COMING SOON'))), // Scan page placeholder
      MenuScreen(cartService: _cartService), // Menu page
      CartScreen(cartService: _cartService), // Cart page
      const LoyaltyScreen(), // Loyalty page
    ];
  }

  void _onItemTapped(int index) {
    // All tabs now navigate to their respective screens
    setState(() {
      _selectedIndex = index;
    });
    // Jump to the selected page
    _pageController.jumpToPage(index);
  }



  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Test button (for development)
        FloatingActionButton(
          heroTag: "test",
          onPressed: () {
            Navigator.pushNamed(context, '/test');
          },
          backgroundColor: Colors.purple,
          tooltip: 'Test Advanced Features',
          child: const Icon(Icons.science, color: Colors.white),
        ),
        const SizedBox(height: 12),
        // Settings button (moved to top)
        FloatingActionButton(
          heroTag: "settings",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
          backgroundColor: Colors.green,
          tooltip: 'Settings',
          child: const Icon(Icons.settings, color: Colors.white),
        ),
        const SizedBox(height: 12),
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
          PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: _pages,
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
