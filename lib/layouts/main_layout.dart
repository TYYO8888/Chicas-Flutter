import 'package:flutter/material.dart';
import '../screens/menu_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/home_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/navigation_menu_drawer.dart';
import '../services/cart_service.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0; // Start with Home/Offers selected
  final CartService _cartService = CartService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(), // Home/Offers page
      CartScreen(cartService: _cartService), // Cart page
      const MenuScreen(), // Menu page
      const Scaffold(body: Center(child: Text('Scan Coming Soon'))), // Scan page placeholder
      const Scaffold(body: Center(child: Text('More Options'))), // More page placeholder
    ];
  }

  void _onItemTapped(int index) {
    if (index == 4) { // More button
      _scaffoldKey.currentState?.openEndDrawer();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      endDrawer: const NavigationMenuDrawer(),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
