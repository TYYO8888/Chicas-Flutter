import 'package:flutter/material.dart';
import '../screens/menu_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/home_screen.dart';
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

    // Initialize notification service
    _notificationService.initialize();

    _pages = [
      HomeScreen(cartService: _cartService), // Home/Offers page
      const Scaffold(body: Center(child: Text('SCAN COMING SOON'))), // Scan page placeholder
      MenuScreen(cartService: _cartService), // Menu page
      CartScreen(cartService: _cartService), // Cart page
      const Scaffold(body: Center(child: Text('MORE OPTIONS'))), // More page placeholder
    ];
  }

  void _onItemTapped(int index) {
    if (index == 4) { // More button
      _scaffoldKey.currentState?.openEndDrawer();
    } else {
      setState(() {
        _selectedIndex = index;
      });
      // Jump to the selected page
      _pageController.jumpToPage(index);
    }
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
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
