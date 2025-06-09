import 'package:flutter/material.dart';
import 'package:qsr_app/models/menu_item.dart';
import 'package:qsr_app/services/cart_service.dart';
import 'package:qsr_app/services/menu_service.dart';
import 'package:qsr_app/services/navigation_service.dart';
import 'package:qsr_app/widgets/sauce_selection_dialog.dart';
import 'package:qsr_app/widgets/heat_level_selector.dart';
import 'package:qsr_app/widgets/custom_bottom_nav_bar.dart';
import 'package:qsr_app/screens/crew_pack_customization_screen.dart';
import 'package:qsr_app/models/crew_pack_selection.dart';

class MenuItemScreen extends StatefulWidget {
  final String category;
  final CartService cartService;

  const MenuItemScreen({
    super.key, 
    required this.category,
    required this.cartService,
  });

  @override
  _MenuItemScreenState createState() => _MenuItemScreenState();
}

class _MenuItemScreenState extends State<MenuItemScreen> {  late Future<List<MenuItem>> _menuItemsFuture;
  final MenuService _menuService = MenuService();
  final Map<String, String> _selectedSizes = {};

  @override
  void initState() {
    super.initState();
    _menuItemsFuture = _menuService.getMenuItems(widget.category);
  }

 Future<void> _handleCrewPackSelection(MenuItem crewPack) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrewPackCustomizationScreen(crewPack: crewPack),
      ),
    );

    if (result != null) {
      // Extract the crew pack customization data
      final crewPackCustomization = result['sandwiches'] as CrewPackCustomization?;
      final customizations = result['customizations'] as Map<String, List<MenuItem>>?;
      final selectedSauces = result['sauces'] as List<String>?;

      // Update the crew pack with selected sauces
      if (selectedSauces != null) {
        crewPack.selectedSauces = selectedSauces;
      }

      // Add the crew pack with its customizations to the cart
      widget.cartService.addToCart(
        crewPack,
        customizations: customizations,
        crewPackCustomization: crewPackCustomization,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${crewPack.name} added to cart'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleSauceSelection(MenuItem menuItem) async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) => SauceSelectionDialog(
        maxSauces: menuItem.includedSauceCount,
        initialSelections: menuItem.selectedSauces,
      ),
    );

    if (result != null) {
      setState(() {
        menuItem.selectedSauces = result;
      });
    }
  }

  Future<void> _handleHeatLevelSelection(MenuItem menuItem) async {
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Select Heat Level'),
        content: SizedBox(
          width: double.maxFinite,
          child: HeatLevelSelector(
            selectedHeatLevel: menuItem.selectedHeatLevel,
            onHeatLevelChanged: (heatLevel) {
              Navigator.pop(context, heatLevel);
            },
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        menuItem.selectedHeatLevel = result;
      });
    }
  }

  void _addToCart(MenuItem menuItem) {
    String? selectedSize = _selectedSizes[menuItem.name];

    // Check if sauce selection is required
    if (menuItem.allowsSauceSelection &&
        (menuItem.selectedSauces == null ||
            menuItem.selectedSauces!.length != menuItem.includedSauceCount)) {
      // Show sauce selection dialog if sauces haven't been selected
      _handleSauceSelection(menuItem).then((_) {
        if (menuItem.selectedSauces?.length == menuItem.includedSauceCount) {
          _checkHeatLevelAndAddToCart(menuItem, selectedSize);
        }
      });
    } else {
      _checkHeatLevelAndAddToCart(menuItem, selectedSize);
    }
  }

  void _checkHeatLevelAndAddToCart(MenuItem menuItem, String? selectedSize) {
    // Check if heat level selection is required
    if (menuItem.allowsHeatLevelSelection && menuItem.selectedHeatLevel == null) {
      // Show heat level selection dialog if heat level hasn't been selected
      _handleHeatLevelSelection(menuItem).then((_) {
        if (menuItem.selectedHeatLevel != null) {
          _finalizeAddToCart(menuItem, selectedSize);
        }
      });
    } else {
      _finalizeAddToCart(menuItem, selectedSize);
    }
  }

  void _finalizeAddToCart(MenuItem menuItem, String? selectedSize) {
    widget.cartService.addToCart(menuItem, selectedSize: selectedSize);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${menuItem.name} added to cart'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.toUpperCase()),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to main menu page
            NavigationService.navigateToMenu();
          },
        ),
      ),
      body: FutureBuilder<List<MenuItem>>(
        future: _menuItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final menuItems = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final menuItem = menuItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Section
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFFFF5C22).withOpacity(0.8),
                                const Color(0xFF9B1C24).withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Placeholder for actual image
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.restaurant,
                                      size: 60,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Image Coming Soon',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Price badge
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '\$${menuItem.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF9B1C24),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Content Section
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                menuItem.name.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Description
                              Text(
                                menuItem.description.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 16),
                              // Size Selection (if available)
                              if (menuItem.sizes != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'CHOOSE BUN:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: menuItem.sizes!.keys.map((size) {
                                          final isSelected = _selectedSizes[menuItem.name] == size;
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedSizes[menuItem.name] = size;
                                                menuItem.price = menuItem.sizes![size]!;
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? const Color(0xFFFF5C22)
                                                    : Colors.white,
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? const Color(0xFFFF5C22)
                                                      : Colors.grey[300]!,
                                                ),
                                              ),
                                              child: Text(
                                                size == 'Brioche Bun' ? '${size.toUpperCase()} (+\$1)' : size.toUpperCase(),
                                                style: TextStyle(
                                                  color: isSelected ? Colors.white : Colors.black87,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Heat Level Selection (if available)
                              if (menuItem.allowsHeatLevelSelection) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red[200]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.whatshot,
                                            color: Colors.red[600],
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'HEAT LEVEL:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: () => _handleHeatLevelSelection(menuItem),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: menuItem.selectedHeatLevel != null ? Colors.red[100] : Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: Colors.red[300]!),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                menuItem.selectedHeatLevel != null
                                                    ? Icons.local_fire_department
                                                    : Icons.add,
                                                color: Colors.red[600],
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                menuItem.selectedHeatLevel != null
                                                    ? '${menuItem.selectedHeatLevel!} (TAP TO CHANGE)'
                                                    : 'SELECT HEAT LEVEL',
                                                style: TextStyle(
                                                  color: Colors.red[600],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Action Button
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: widget.category == 'Crew Packs'
                                      ? () => _handleCrewPackSelection(menuItem)
                                      : () => _addToCart(menuItem),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF5C22),
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shadowColor: const Color(0xFFFF5C22).withOpacity(0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        widget.category == 'Crew Packs'
                                            ? Icons.tune
                                            : Icons.add_shopping_cart,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        widget.category == 'Crew Packs'
                                            ? 'CUSTOMIZE PACK'
                                            : 'ADD TO CART',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 2, // Menu is selected (now at index 2)
        onItemSelected: (index) {
          // Navigate to the correct page using navigation service
          switch (index) {
            case 0:
              NavigationService.navigateToHome();
              break;
            case 1:
              NavigationService.navigateToScan();
              break;
            case 2:
              NavigationService.navigateToMenu();
              break;
            case 3:
              NavigationService.navigateToCart();
              break;
            case 4:
              NavigationService.navigateToMore();
              break;
          }
        },
      ),
    );
  }
}
