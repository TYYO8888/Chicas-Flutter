import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../models/menu_extras.dart';
import '../models/combo_selection.dart';
import '../services/cart_service.dart';
import '../screens/combo_selection_screen.dart';

class CartItemEditDialog extends StatefulWidget {
  final CartItem cartItem;
  final int itemIndex;
  final CartService cartService;
  final VoidCallback onUpdated;

  const CartItemEditDialog({
    super.key,
    required this.cartItem,
    required this.itemIndex,
    required this.cartService,
    required this.onUpdated,
  });

  @override
  State<CartItemEditDialog> createState() => _CartItemEditDialogState();
}

class _CartItemEditDialogState extends State<CartItemEditDialog> {
  late int _quantity;
  String? _selectedSize;
  List<String> _selectedSauces = [];
  MenuItemExtras? _extras;
  ComboMeal? _comboMeal;

  // Available sauces (same as in SauceSelectionDialog)
  final List<String> _availableSauces = [
    "Chica's Sauce (Buttermilk Ranch)",
    'Sweet Heat',
    'Buffalo',
    'Hot Honey',
    'Chipotle Aioli',
    'BBQ',
  ];

  @override
  void initState() {
    super.initState();
    _quantity = widget.cartItem.quantity;

    // Initialize selected size - check combo meal first, then regular cart item
    if (widget.cartItem.comboMeal != null) {
      // For combo meals, get bun selection from combo's main item
      _selectedSize = widget.cartItem.comboMeal!.mainItem.selectedBunType;
    } else {
      // For regular items, use cart item's selected size
      _selectedSize = widget.cartItem.selectedSize;
    }

    _selectedSauces = List.from(widget.cartItem.menuItem.selectedSauces ?? []);
    _extras = widget.cartItem.extras?.clone();
    _comboMeal = widget.cartItem.comboMeal;
  }

  String _getBunDisplayText(String bunKey, double bunPrice) {
    // Convert bun key to proper display text
    String bunName;
    switch (bunKey.toLowerCase()) {
      case 'texas':
      case 'texas toast':
        bunName = 'Texas Toast';
        break;
      case 'brioche':
      case 'brioche bun':
        bunName = 'Brioche Bun';
        break;
      default:
        bunName = bunKey;
        break;
    }

    // Calculate cost based on the lowest price option (Texas Toast is the base)
    final sizes = widget.cartItem.menuItem.sizes!;
    final lowestPrice = sizes.values.reduce((a, b) => a < b ? a : b);
    final extraCost = bunPrice - lowestPrice;

    // Add cost information
    if (extraCost > 0) {
      return '$bunName (+\$${extraCost.toStringAsFixed(2)})';
    } else {
      return '$bunName (Free)';
    }
  }

  List<Widget> _buildExtrasSection() {
    if (_extras == null) return [];

    List<Widget> widgets = [];

    for (final section in _extras!.sections) {
      final selectedExtras = _extras!.getSelectedExtrasForSection(section.id);

      if (section.extras.isNotEmpty) {
        widgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...section.extras.map((extra) {
                  final selectedExtra = selectedExtras.firstWhere(
                    (selected) => selected.extra.id == extra.id,
                    orElse: () => SelectedExtra(extra: extra, quantity: 0),
                  );
                  final isSelected = selectedExtra.quantity > 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                extra.name,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '+\$${extra.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.deepOrange,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: isSelected
                                  ? () => _updateExtraQuantity(section, extra, selectedExtra.quantity - 1)
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                              iconSize: 20,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${selectedExtra.quantity}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _updateExtraQuantity(section, extra, selectedExtra.quantity + 1),
                              icon: const Icon(Icons.add_circle_outline),
                              iconSize: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      }
    }

    return widgets;
  }

  void _updateExtraQuantity(MenuExtraSection section, MenuExtra extra, int quantity) {
    if (_extras == null) return;

    // Check if this is a combo extra
    if (extra.id == 'combo_upgrade' && quantity > 0) {
      _handleComboSelection();
      return;
    }

    setState(() {
      if (quantity <= 0) {
        _extras!.removeExtra(section.id, extra.id);
      } else {
        _extras!.updateExtraQuantity(section.id, extra.id, quantity);
        if (!_extras!.getSelectedExtrasForSection(section.id).any((selected) => selected.extra.id == extra.id)) {
          _extras!.addExtra(section.id, extra, quantity: quantity);
        }
      }
    });
  }

  /// Handle combo selection by navigating to combo selection screen
  Future<void> _handleComboSelection() async {
    // Create a combo with the current menu item and selected size
    final combo = ComboConfiguration.createCombo(widget.cartItem.menuItem, selectedSize: _selectedSize);

    final result = await Navigator.of(context).push<ComboMeal>(
      MaterialPageRoute(
        builder: (context) => ComboSelectionScreen(combo: combo),
      ),
    );

    if (result != null && mounted) {
      // Store the combo selection
      setState(() {
        _comboMeal = result;
        // Remove the combo extra from selection since it's now configured
        _extras?.removeExtra('combo', 'combo_upgrade');
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Combo configured! You can now update the item.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildComboSection() {
    if (_comboMeal == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.orange.withValues(alpha: 0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Main: ${_comboMeal!.mainItem.name}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          // Show bun selection for sandwiches
          if (_comboMeal!.mainItem.category.toLowerCase().contains('sandwich') &&
              _comboMeal!.mainItem.selectedBunType != null) ...[
            const SizedBox(height: 4),
            Text(
              'Bun: ${_comboMeal!.mainItem.selectedBunType}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
          if (_comboMeal!.selectedDrink != null) ...[
            const SizedBox(height: 4),
            Text(
              'Drink: ${_comboMeal!.selectedDrink!.name}${_comboMeal!.selectedDrinkSize != null ? ' (${_comboMeal!.selectedDrinkSize})' : ''}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
          if (_comboMeal!.selectedSide != null) ...[
            const SizedBox(height: 4),
            Text(
              'Side: ${_comboMeal!.selectedSide!.name}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Total: \$${_comboMeal!.totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editCombo() async {
    if (_comboMeal == null) return;

    final result = await Navigator.of(context).push<ComboMeal>(
      MaterialPageRoute(
        builder: (context) => ComboSelectionScreen(combo: _comboMeal!),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _comboMeal = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'EDIT ${widget.cartItem.menuItem.name.toUpperCase()}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quantity selector
            const Text(
              'QUANTITY',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 32,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _quantity.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _quantity++),
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 32,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Size selector (if applicable)
            if (widget.cartItem.menuItem.sizes != null && widget.cartItem.menuItem.sizes!.isNotEmpty) ...[
              Text(
                widget.cartItem.menuItem.category.toLowerCase() == 'sandwiches' 
                  ? 'CHOOSE BUN' 
                  : 'CHOOSE SIZE',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ...widget.cartItem.menuItem.sizes!.entries.map((entry) {
                final isSelected = _selectedSize == entry.key;
                // Calculate extra cost properly for sandwiches (bun upgrades)
                double extraCost;
                if (widget.cartItem.menuItem.category.toLowerCase().contains('sandwich')) {
                  // For sandwiches, calculate bun upgrade cost
                  final lowestPrice = widget.cartItem.menuItem.sizes!.values.reduce((a, b) => a < b ? a : b);
                  extraCost = entry.value - lowestPrice;
                } else {
                  // For other items, use size price vs base price
                  extraCost = entry.value - widget.cartItem.menuItem.price;
                }
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedSize = entry.key),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.deepOrange : Colors.grey,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: isSelected ? Colors.deepOrange.withValues(alpha: 0.1) : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.cartItem.menuItem.category.toLowerCase() == 'sandwiches'
                                ? _getBunDisplayText(entry.key, entry.value)
                                : '${entry.key.toUpperCase()} ${extraCost > 0 ? '(+\$${extraCost.toStringAsFixed(2)})' : '(FREE)'}',
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.deepOrange : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
            ],

            // Sauce selector (if applicable)
            if (widget.cartItem.menuItem.allowsSauceSelection) ...[
              const Text(
                'SAUCES',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ..._availableSauces.map((sauce) {
                final isSelected = _selectedSauces.contains(sauce);
                return CheckboxListTile(
                  title: Text(sauce.toUpperCase()),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        // Check if we have a sauce limit
                        if (widget.cartItem.menuItem.includedSauceCount != null) {
                          if (_selectedSauces.length < widget.cartItem.menuItem.includedSauceCount!) {
                            _selectedSauces.add(sauce);
                          } else {
                            // Replace the first sauce if at limit
                            _selectedSauces.removeAt(0);
                            _selectedSauces.add(sauce);
                          }
                        } else {
                          _selectedSauces.add(sauce);
                        }
                      } else {
                        _selectedSauces.remove(sauce);
                      }
                    });
                  },
                  activeColor: Colors.deepOrange,
                );
              }).toList(),
            ],

            // Combo section (if applicable)
            if (_comboMeal != null) ...[
              const SizedBox(height: 16),
              const Text(
                'COMBO DETAILS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              _buildComboSection(),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _editCombo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('EDIT COMBO SELECTIONS'),
              ),
            ],

            // Extras section (if applicable)
            if (_extras != null && _extras!.sections.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'EXTRAS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ..._buildExtrasSection(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: _updateCartItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
          ),
          child: const Text('UPDATE'),
        ),
      ],
    );
  }

  void _updateCartItem() {
    // Update the menu item's selected sauces
    widget.cartItem.menuItem.selectedSauces = _selectedSauces.isNotEmpty ? _selectedSauces : null;

    // Update quantity
    widget.cartService.updateCartItemQuantity(widget.itemIndex, _quantity);

    // Update size/bun selection
    if (widget.cartItem.comboMeal != null) {
      // For combo meals, update the bun selection in both the combo's main item AND the cart item's menu item
      final currentBunType = widget.cartItem.comboMeal!.mainItem.selectedBunType;
      if (_selectedSize != currentBunType) {
        widget.cartItem.comboMeal!.mainItem.selectedBunType = _selectedSize;
        // Also update the cart item's menu item for consistent display
        widget.cartItem.menuItem.selectedBunType = _selectedSize;
        // Update the combo meal reference to trigger price recalculation
        widget.cartItem.comboMeal = widget.cartItem.comboMeal;
      }
    } else {
      // For regular items, update the cart item's selected size
      if (_selectedSize != widget.cartItem.selectedSize) {
        widget.cartService.updateCartItem(widget.itemIndex, selectedSize: _selectedSize);
      }
    }

    // Update extras if changed
    if (_extras != null) {
      widget.cartItem.extras = _extras;
    }

    // Update combo if changed
    if (_comboMeal != null) {
      widget.cartItem.comboMeal = _comboMeal;
    }

    widget.onUpdated();
    Navigator.of(context).pop();
  }
}
