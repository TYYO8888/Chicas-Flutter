import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../services/cart_service.dart';

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
    _selectedSize = widget.cartItem.selectedSize;
    _selectedSauces = List.from(widget.cartItem.menuItem.selectedSauces ?? []);
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
                final extraCost = entry.value - widget.cartItem.menuItem.price;
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
    
    // Update size if changed
    if (_selectedSize != widget.cartItem.selectedSize) {
      widget.cartService.updateCartItem(widget.itemIndex, selectedSize: _selectedSize);
    }
    
    widget.onUpdated();
    Navigator.of(context).pop();
  }
}
