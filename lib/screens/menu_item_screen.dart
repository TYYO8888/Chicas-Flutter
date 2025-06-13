import 'package:flutter/material.dart';
import 'package:qsr_app/models/menu_item.dart';
import 'package:qsr_app/services/cart_service.dart';
import 'package:qsr_app/services/menu_service.dart';
import 'package:qsr_app/services/navigation_service.dart';
import 'package:qsr_app/services/user_preferences_service.dart';
import 'package:qsr_app/widgets/sauce_selection_dialog.dart';
import 'package:qsr_app/widgets/heat_level_selector.dart';
import 'package:qsr_app/widgets/custom_bottom_nav_bar.dart';
import 'package:qsr_app/screens/crew_pack_customization_screen.dart';
import 'package:qsr_app/models/crew_pack_selection.dart';
import 'package:qsr_app/screens/menu_item_extras_screen.dart';
import 'package:qsr_app/models/menu_extras.dart';
import 'package:qsr_app/models/combo_selection.dart';

class MenuItemScreen extends StatefulWidget {
  final String category;
  final CartService cartService;

  const MenuItemScreen({
    super.key, 
    required this.category,
    required this.cartService,
  });

  @override
  State<MenuItemScreen> createState() => _MenuItemScreenState();
}

class _MenuItemScreenState extends State<MenuItemScreen> {
  late Future<List<MenuItem>> _menuItemsFuture;
  final MenuService _menuService = MenuService();
  final UserPreferencesService _preferencesService = UserPreferencesService();
  final Map<String, String> _selectedSizes = {};
  final Set<String> _favoriteItems = {};

  @override
  void initState() {
    super.initState();
    _menuItemsFuture = _menuService.getMenuItems(widget.category);
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    await _preferencesService.initialize();
    final preferences = _preferencesService.currentPreferences;
    if (preferences != null) {
      setState(() {
        _favoriteItems.addAll(preferences.favoriteMenuItems);
      });
    }
  }

  Future<void> _toggleFavorite(MenuItem menuItem) async {
    final isFavorite = _favoriteItems.contains(menuItem.id);

    if (isFavorite) {
      await _preferencesService.removeFromFavorites(menuItem.id);
      setState(() {
        _favoriteItems.remove(menuItem.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${menuItem.name} removed from favorites'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.grey[600],
          ),
        );
      }
    } else {
      await _preferencesService.addToFavorites(menuItem.id);
      setState(() {
        _favoriteItems.add(menuItem.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${menuItem.name} added to favorites'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.pink,
          ),
        );
      }
    }
  }

 Future<void> _handleCrewPackSelection(MenuItem crewPack) async {
    // Store ScaffoldMessenger reference before async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrewPackCustomizationScreen(crewPack: crewPack),
      ),
    );

    if (result != null && mounted) {
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

      scaffoldMessenger.showSnackBar(
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

    // Check if item allows extras and should show extras screen
    if (menuItem.allowsExtras || _shouldShowExtrasForCategory(menuItem.category)) {
      _showExtrasScreen(menuItem, selectedSize);
      return;
    }

    // ✅ NEW: Enhanced validation for items requiring heat level
    if (menuItem.allowsHeatLevelSelection) {
      _validateHeatLevelItemRequirements(menuItem, selectedSize);
      return;
    }

    // ✅ NEW: Enhanced validation for items requiring sauce selection (chicken bites, whole wings)
    if (_requiresSauceSelection(menuItem)) {
      _validateSauceRequiredItemRequirements(menuItem, selectedSize);
      return;
    }

    // Check if sauce selection is required (for other items)
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

  /// ✅ Check if item requires sauce selection (chicken bites, whole wings)
  /// Note: Items with heat level selection are handled by heat level validation instead
  bool _requiresSauceSelection(MenuItem menuItem) {
    // If item has heat level selection, it's handled by heat level validation
    if (menuItem.allowsHeatLevelSelection) {
      return false;
    }

    final category = menuItem.category.toLowerCase();
    return (category.contains('chicken bites') ||
            category.contains('whole wings') ||
            category == 'chicken bites' ||
            category == 'whole wings') &&
           menuItem.allowsSauceSelection;
  }

  /// ✅ NEW: Enhanced validation for items requiring sauce selection (chicken bites, whole wings)
  void _validateSauceRequiredItemRequirements(MenuItem menuItem, String? selectedSize) {
    final bool needsSauce = menuItem.selectedSauces == null ||
        menuItem.selectedSauces!.length != menuItem.includedSauceCount;

    if (needsSauce) {
      _showRequirementDialog(
        title: 'Sauce Selection Required',
        message: 'Please select ${menuItem.includedSauceCount} sauce${menuItem.includedSauceCount! > 1 ? 's' : ''} for ${menuItem.name}.',
        onConfirm: () => _handleSauceSelection(menuItem).then((_) {
          if (menuItem.selectedSauces?.length == menuItem.includedSauceCount) {
            _finalizeAddToCart(menuItem, selectedSize);
          }
        }),
      );
    } else {
      // Sauce is selected, proceed to cart
      _finalizeAddToCart(menuItem, selectedSize);
    }
  }

  /// ✅ NEW: Enhanced validation for heat level items requiring BOTH sauce AND heat level
  void _validateHeatLevelItemRequirements(MenuItem menuItem, String? selectedSize) {
    final bool needsSauce = menuItem.allowsSauceSelection &&
        (menuItem.selectedSauces == null || menuItem.selectedSauces!.length != menuItem.includedSauceCount);
    final bool needsHeatLevel = menuItem.selectedHeatLevel == null;

    if (needsSauce && needsHeatLevel) {
      // Both sauce and heat level are missing
      _showRequirementDialog(
        title: 'Selection Required',
        message: 'Please select both sauce and heat level for ${menuItem.name}.',
        onConfirm: () => _handleSauceSelectionFirst(menuItem, selectedSize),
      );
    } else if (needsSauce) {
      // Only sauce is missing
      _showRequirementDialog(
        title: 'Sauce Selection Required',
        message: 'Please select a sauce for ${menuItem.name}.',
        onConfirm: () => _handleSauceSelection(menuItem).then((_) {
          if (menuItem.selectedSauces?.length == menuItem.includedSauceCount) {
            _finalizeAddToCart(menuItem, selectedSize);
          }
        }),
      );
    } else if (needsHeatLevel) {
      // Only heat level is missing
      _showRequirementDialog(
        title: 'Heat Level Selection Required',
        message: 'Please select a heat level for ${menuItem.name}.',
        onConfirm: () => _handleHeatLevelSelection(menuItem).then((_) {
          if (menuItem.selectedHeatLevel != null) {
            _finalizeAddToCart(menuItem, selectedSize);
          }
        }),
      );
    } else {
      // Both are selected, proceed to cart
      _finalizeAddToCart(menuItem, selectedSize);
    }
  }

  /// Handle sauce selection first, then heat level for items requiring both
  Future<void> _handleSauceSelectionFirst(MenuItem menuItem, String? selectedSize) async {
    await _handleSauceSelection(menuItem);

    if (menuItem.selectedSauces?.length == menuItem.includedSauceCount) {
      // Sauce selected, now check heat level
      if (menuItem.selectedHeatLevel == null) {
        await _handleHeatLevelSelection(menuItem);
      }

      // Check if both are now selected
      if (menuItem.selectedSauces?.length == menuItem.includedSauceCount &&
          menuItem.selectedHeatLevel != null) {
        _finalizeAddToCart(menuItem, selectedSize);
      }
    }
  }

  /// Show requirement dialog with custom message
  void _showRequirementDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
            child: const Text('SELECT'),
          ),
        ],
      ),
    );
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

  bool _shouldShowExtrasForCategory(String category) {
    // Categories that should show extras screen
    const extrasCategories = [
      'sandwiches',
      'crew packs',
      'whole wings',
      'chicken pieces',
      'chicken bites',
    ];
    return extrasCategories.contains(category.toLowerCase());
  }

  Future<void> _showExtrasScreen(MenuItem menuItem, String? selectedSize) async {
    // Store ScaffoldMessenger reference before async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (context) => MenuItemExtrasScreen(
          menuItem: menuItem,
          initialSelectedSize: selectedSize,
        ),
      ),
    );

    if (result != null && mounted) {
      if (result is ComboMeal) {
        // Add combo meal to cart
        widget.cartService.addComboToCart(result);

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('${result.name} added to cart'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (result is MenuItemExtras) {
        // ✅ Validate heat level items before adding to cart
        if (menuItem.allowsHeatLevelSelection) {
          _validateHeatLevelItemBeforeAddingToCart(
            menuItem,
            selectedSize,
            result,
            scaffoldMessenger,
          );
        } else if (_requiresSauceSelection(menuItem)) {
          // ✅ Validate sauce-required items before adding to cart
          _validateSauceRequiredItemBeforeAddingToCart(
            menuItem,
            selectedSize,
            result,
            scaffoldMessenger,
          );
        } else {
          // Add item with extras to cart (non-heat level, non-sauce-required items)
          widget.cartService.addToCart(
            menuItem,
            selectedSize: selectedSize,
            extras: result,
          );

          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('${menuItem.name} added to cart'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else if (result is Map<String, dynamic>) {
        // Handle new format with extras and selected size
        final extras = result['extras'] as MenuItemExtras?;
        final resultSelectedSize = result['selectedSize'] as String?;

        // ✅ Validate heat level items before adding to cart
        if (menuItem.allowsHeatLevelSelection) {
          _validateHeatLevelItemBeforeAddingToCart(
            menuItem,
            resultSelectedSize ?? selectedSize,
            extras,
            scaffoldMessenger,
          );
        } else if (_requiresSauceSelection(menuItem)) {
          // ✅ Validate sauce-required items before adding to cart
          _validateSauceRequiredItemBeforeAddingToCart(
            menuItem,
            resultSelectedSize ?? selectedSize,
            extras,
            scaffoldMessenger,
          );
        } else {
          widget.cartService.addToCart(
            menuItem,
            selectedSize: resultSelectedSize ?? selectedSize,
            extras: extras,
          );

          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('${menuItem.name} added to cart'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  /// ✅ Validate heat level items from extras screen before adding to cart
  void _validateHeatLevelItemBeforeAddingToCart(
    MenuItem menuItem,
    String? selectedSize,
    MenuItemExtras? extras,
    ScaffoldMessengerState scaffoldMessenger,
  ) {
    final bool needsSauce = menuItem.allowsSauceSelection &&
        (menuItem.selectedSauces == null || menuItem.selectedSauces!.length != menuItem.includedSauceCount);
    final bool needsHeatLevel = menuItem.selectedHeatLevel == null;

    if (needsSauce && needsHeatLevel) {
      // Both sauce and heat level are missing
      _showRequirementDialog(
        title: 'Selection Required',
        message: 'Please select both sauce and heat level for ${menuItem.name}.',
        onConfirm: () => _handleSauceAndHeatForExtras(menuItem, selectedSize, extras, scaffoldMessenger),
      );
    } else if (needsSauce) {
      // Only sauce is missing
      _showRequirementDialog(
        title: 'Sauce Selection Required',
        message: 'Please select a sauce for ${menuItem.name}.',
        onConfirm: () => _handleSauceSelection(menuItem).then((_) {
          if (menuItem.selectedSauces?.length == menuItem.includedSauceCount) {
            _addToCartWithExtras(menuItem, selectedSize, extras, scaffoldMessenger);
          }
        }),
      );
    } else if (needsHeatLevel) {
      // Only heat level is missing
      _showRequirementDialog(
        title: 'Heat Level Selection Required',
        message: 'Please select a heat level for ${menuItem.name}.',
        onConfirm: () => _handleHeatLevelSelection(menuItem).then((_) {
          if (menuItem.selectedHeatLevel != null) {
            _addToCartWithExtras(menuItem, selectedSize, extras, scaffoldMessenger);
          }
        }),
      );
    } else {
      // Both are selected, proceed to cart
      _addToCartWithExtras(menuItem, selectedSize, extras, scaffoldMessenger);
    }
  }

  /// Handle sauce and heat level selection for extras items
  Future<void> _handleSauceAndHeatForExtras(
    MenuItem menuItem,
    String? selectedSize,
    MenuItemExtras? extras,
    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    await _handleSauceSelection(menuItem);

    if (menuItem.selectedSauces?.length == menuItem.includedSauceCount) {
      // Sauce selected, now check heat level
      if (menuItem.selectedHeatLevel == null) {
        await _handleHeatLevelSelection(menuItem);
      }

      // Check if both are now selected
      if (menuItem.selectedSauces?.length == menuItem.includedSauceCount &&
          menuItem.selectedHeatLevel != null) {
        _addToCartWithExtras(menuItem, selectedSize, extras, scaffoldMessenger);
      }
    }
  }

  /// ✅ Validate sauce-required items from extras screen before adding to cart
  void _validateSauceRequiredItemBeforeAddingToCart(
    MenuItem menuItem,
    String? selectedSize,
    MenuItemExtras? extras,
    ScaffoldMessengerState scaffoldMessenger,
  ) {
    final bool needsSauce = menuItem.selectedSauces == null ||
        menuItem.selectedSauces!.length != menuItem.includedSauceCount;

    if (needsSauce) {
      _showRequirementDialog(
        title: 'Sauce Selection Required',
        message: 'Please select ${menuItem.includedSauceCount} sauce${menuItem.includedSauceCount! > 1 ? 's' : ''} for ${menuItem.name}.',
        onConfirm: () => _handleSauceSelection(menuItem).then((_) {
          if (menuItem.selectedSauces?.length == menuItem.includedSauceCount) {
            _addToCartWithExtras(menuItem, selectedSize, extras, scaffoldMessenger);
          }
        }),
      );
    } else {
      // Sauce is selected, proceed to cart
      _addToCartWithExtras(menuItem, selectedSize, extras, scaffoldMessenger);
    }
  }

  /// Add item with extras to cart after validation
  void _addToCartWithExtras(
    MenuItem menuItem,
    String? selectedSize,
    MenuItemExtras? extras,
    ScaffoldMessengerState scaffoldMessenger,
  ) {
    widget.cartService.addToCart(
      menuItem,
      selectedSize: selectedSize,
      extras: extras,
    );

    scaffoldMessenger.showSnackBar(
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
            // Navigate back to previous screen (main menu)
            Navigator.of(context).pop();
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
                        color: Colors.black.withValues(alpha: 0.1),
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
                                const Color(0xFFFF5C22).withValues(alpha: 0.8),
                                const Color(0xFF9B1C24).withValues(alpha: 0.8),
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
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Image Coming Soon',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Favorite button
                              Positioned(
                                top: 12,
                                left: 12,
                                child: GestureDetector(
                                  onTap: () => _toggleFavorite(menuItem),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _favoriteItems.contains(menuItem.id)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: _favoriteItems.contains(menuItem.id)
                                          ? Colors.pink
                                          : Colors.grey[600],
                                      size: 20,
                                    ),
                                  ),
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
                                        color: Colors.black.withValues(alpha: 0.2),
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
                                          const Spacer(),
                                          // ✅ Required indicator
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'REQUIRED',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
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

                              // ✅ Sauce Selection (for heat level items)
                              if (menuItem.allowsHeatLevelSelection && menuItem.allowsSauceSelection) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.orange[200]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.water_drop,
                                            color: Colors.orange[600],
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'SAUCE:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const Spacer(),
                                          // ✅ Required indicator
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.orange,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'REQUIRED',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: () => _handleSauceSelection(menuItem),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: menuItem.selectedSauces?.isNotEmpty == true ? Colors.orange[100] : Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: Colors.orange[300]!),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                menuItem.selectedSauces?.isNotEmpty == true
                                                    ? Icons.check_circle
                                                    : Icons.add,
                                                color: Colors.orange[600],
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                menuItem.selectedSauces?.isNotEmpty == true
                                                    ? '${menuItem.selectedSauces!.join(", ")} (TAP TO CHANGE)'
                                                    : 'SELECT SAUCE',
                                                style: TextStyle(
                                                  color: Colors.orange[600],
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

                              // ✅ Sauce Selection (for sauce-required items: chicken bites, whole wings)
                              if (_requiresSauceSelection(menuItem)) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.orange[200]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.water_drop,
                                            color: Colors.orange[600],
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'SAUCE (${menuItem.includedSauceCount}):',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const Spacer(),
                                          // ✅ Required indicator
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.orange,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'REQUIRED',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: () => _handleSauceSelection(menuItem),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: menuItem.selectedSauces?.isNotEmpty == true ? Colors.orange[100] : Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: Colors.orange[300]!),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                menuItem.selectedSauces?.isNotEmpty == true
                                                    ? Icons.check_circle
                                                    : Icons.add,
                                                color: Colors.orange[600],
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  menuItem.selectedSauces?.isNotEmpty == true
                                                      ? '${menuItem.selectedSauces!.join(", ")} (TAP TO CHANGE)'
                                                      : 'SELECT ${menuItem.includedSauceCount} SAUCE${menuItem.includedSauceCount! > 1 ? 'S' : ''}',
                                                  style: TextStyle(
                                                    color: Colors.orange[600],
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
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
                                    shadowColor: const Color(0xFFFF5C22).withValues(alpha: 0.3),
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
        cartService: widget.cartService,
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
