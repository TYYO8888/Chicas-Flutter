import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.local_offer),
                activeIcon: Icon(Icons.local_offer, size: 28),
                label: 'HOME',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                activeIcon: Icon(Icons.shopping_cart, size: 28),
                label: 'CART',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_menu),
                activeIcon: Icon(Icons.restaurant_menu, size: 28),
                label: 'MENU',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.qr_code_scanner),
                activeIcon: Icon(Icons.qr_code_scanner, size: 28),
                label: 'SCAN',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz),
                activeIcon: Icon(Icons.more_horiz, size: 28),
                label: 'MORE',
              ),
            ],
            currentIndex: selectedIndex,
            selectedItemColor: Colors.red[700],
            unselectedItemColor: Colors.grey[600],
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            elevation: 0,
            backgroundColor: Colors.white,
            onTap: onItemSelected,
          ),
        ),
      ),
    );
  }
}
