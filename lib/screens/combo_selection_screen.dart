// 🍗🍟🥤 Combo Selection Screen
// Allows users to select drink and side for combo meals

import 'package:flutter/material.dart';
import 'package:qsr_app/models/combo_selection.dart';
import 'package:qsr_app/models/menu_item.dart';
import 'package:qsr_app/services/menu_service.dart';
import 'package:qsr_app/widgets/custom_bottom_nav_bar.dart';

class ComboSelectionScreen extends StatefulWidget {
  final ComboMeal combo;

  const ComboSelectionScreen({
    Key? key,
    required this.combo,
  }) : super(key: key);

  @override
  State<ComboSelectionScreen> createState() => _ComboSelectionScreenState();
}

class _ComboSelectionScreenState extends State<ComboSelectionScreen> {
  final MenuService _menuService = MenuService();
  late ComboMeal _currentCombo;
  List<MenuItem> _drinks = [];
  List<MenuItem> _sides = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentCombo = widget.combo;
    _loadComboOptions();
  }

  Future<void> _loadComboOptions() async {
    try {
      final drinks = await _menuService.getMenuItems('Beverages');
      final sides = await _menuService.getMenuItems('Sides');
      
      setState(() {
        _drinks = drinks;
        _sides = sides;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load combo options: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _selectDrink(MenuItem drink, String? size) {
    setState(() {
      _currentCombo = _currentCombo.copyWith(
        selectedDrink: drink,
        selectedDrinkSize: size ?? 'Regular',
      );
    });
  }

  void _selectSide(MenuItem side, String? size) {
    setState(() {
      _currentCombo = _currentCombo.copyWith(
        selectedSide: side,
        selectedSideSize: size ?? 'Regular',
      );
    });
  }

  void _addComboToCart() {
    if (_currentCombo.isComplete) {
      // Return the combo to the extras screen for further customization
      Navigator.of(context).pop(_currentCombo);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both a drink and a side'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'MAKE IT A COMBO!',
          style: TextStyle(
            fontFamily: 'SofiaRoughBlackThree',
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).primaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Item Summary
                  _buildMainItemSummary(),
                  const SizedBox(height: 24),
                  
                  // Drink Selection
                  _buildDrinkSelection(),
                  const SizedBox(height: 24),
                  
                  // Side Selection
                  _buildSideSelection(),
                  const SizedBox(height: 24),
                  
                  // Combo Summary
                  _buildComboSummary(),
                  const SizedBox(height: 120), // Space for bottom nav and floating button
                ],
              ),
            ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 2, // Menu tab
        onItemSelected: (index) {
          // Handle navigation if needed
        },
        cartService: null, // No cart service available in this context
      ),
      floatingActionButton: _currentCombo.isComplete
          ? FloatingActionButton.extended(
              onPressed: _addComboToCart,
              backgroundColor: Theme.of(context).primaryColor,
              label: Text(
                'ADD TO CART - \$${_currentCombo.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildMainItemSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              _currentCombo.mainItem.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.fastfood, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentCombo.mainItem.name.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'COMBO UPGRADE: +\$${_currentCombo.basePrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_currentCombo.savings > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'YOU SAVE: \$${_currentCombo.savings.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrinkSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_drink, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text(
              'CHOOSE YOUR DRINK',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _drinks.length,
            itemBuilder: (context, index) {
              final drink = _drinks[index];
              final isSelected = _currentCombo.selectedDrink?.id == drink.id;
              
              return _buildSelectionCard(
                item: drink,
                isSelected: isSelected,
                onTap: () => _selectDrink(drink, 'Regular'),
                selectedSize: _currentCombo.selectedDrinkSize,
                onSizeChanged: (size) => _selectDrink(drink, size),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSideSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.restaurant, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text(
              'CHOOSE YOUR SIDE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140, // Increased height to accommodate dropdown
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _sides.length,
            itemBuilder: (context, index) {
              final side = _sides[index];
              final isSelected = _currentCombo.selectedSide?.id == side.id;

              return _buildSelectionCard(
                item: side,
                isSelected: isSelected,
                onTap: () => _selectSide(side, 'Regular'),
                selectedSize: _currentCombo.selectedSideSize,
                onSizeChanged: (size) => _selectSide(side, size),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionCard({
    required MenuItem item,
    required bool isSelected,
    required VoidCallback onTap,
    String? selectedSize,
    required Function(String) onSizeChanged,
  }) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                : Theme.of(context).cardColor,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  item.imageUrl,
                  width: double.infinity,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 50,
                      color: Colors.grey[300],
                      child: const Icon(Icons.fastfood, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  item.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (item.sizes != null && item.sizes!.length > 1 && isSelected) ...[
                const SizedBox(height: 4),
                SizedBox(
                  height: 30, // Fixed height for dropdown
                  child: DropdownButton<String>(
                    value: selectedSize ?? 'Regular',
                    isExpanded: true,
                    style: const TextStyle(fontSize: 9),
                    underline: Container(
                      height: 1,
                      color: Theme.of(context).primaryColor,
                    ),
                    items: item.sizes!.keys.map((size) {
                      return DropdownMenuItem(
                        value: size,
                        child: Text(
                          size,
                          style: const TextStyle(fontSize: 9),
                        ),
                      );
                    }).toList(),
                    onChanged: (size) {
                      if (size != null) onSizeChanged(size);
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComboSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COMBO SUMMARY',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Main Item', _currentCombo.mainItem.name),
          _buildSummaryRow(
            'Drink', 
            _currentCombo.selectedDrink?.name ?? 'Not selected',
          ),
          _buildSummaryRow(
            'Side', 
            _currentCombo.selectedSide?.name ?? 'Not selected',
          ),
          const Divider(),
          _buildSummaryRow(
            'TOTAL', 
            '\$${_currentCombo.totalPrice.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value.toUpperCase(),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Theme.of(context).primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }
}
