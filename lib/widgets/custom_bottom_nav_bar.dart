import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final CartService? cartService;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.cartService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: BottomNavigationBar(            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(
              fontFamily: 'MontserratBlack',
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'MontserratBlack',
              fontSize: 12,
            ),
            selectedItemColor: const Color(0xFFFF5C22), // Chica Orange
            unselectedItemColor: Colors.black54,
            elevation: 0,
            backgroundColor: Colors.white,
            items: <BottomNavigationBarItem>[
              const BottomNavigationBarItem(
                icon: Icon(Icons.local_offer),
                activeIcon: Icon(Icons.local_offer, size: 28),
                label: 'HOME',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.sports_esports),
                activeIcon: Icon(Icons.sports_esports, size: 28),
                label: 'GAMES',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_menu),
                activeIcon: Icon(Icons.restaurant_menu, size: 28),
                label: 'MENU',
              ),
              BottomNavigationBarItem(
                icon: _buildCartIcon(false),
                activeIcon: _buildCartIcon(true),
                label: 'CART',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.stars),
                activeIcon: Icon(Icons.stars, size: 28),
                label: 'LOYALTY',
              ),
            ],            currentIndex: selectedIndex,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            onTap: onItemSelected,
          ),
        ),
      ),
    );
  }

  Widget _buildCartIcon(bool isActive) {
    final itemCount = cartService?.itemCount ?? 0;

    return Stack(
      children: [
        Icon(
          Icons.shopping_cart,
          size: isActive ? 28 : 24,
        ),
        if (itemCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5C22),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                itemCount > 99 ? '99+' : itemCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
