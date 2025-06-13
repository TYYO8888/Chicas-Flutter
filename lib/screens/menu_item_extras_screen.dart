import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/menu_item.dart';
import '../models/menu_extras.dart';
import '../models/combo_selection.dart';
import '../screens/combo_selection_screen.dart';

/// 🍗 Menu Item Extras Selection Screen
/// 
/// Comprehensive extras selection interface matching the reference design:
/// - Make it a Combo! section
/// - Extra add-ons section (up to 20 items)
/// - Special Instructions
/// - Real-time price calculation
/// - Quantity controls for each extra
class MenuItemExtrasScreen extends StatefulWidget {
  final MenuItem menuItem;
  final MenuItemExtras? initialExtras;
  final String? initialSelectedSize;

  const MenuItemExtrasScreen({
    super.key,
    required this.menuItem,
    this.initialExtras,
    this.initialSelectedSize,
  });

  @override
  State<MenuItemExtrasScreen> createState() => _MenuItemExtrasScreenState();
}

class _MenuItemExtrasScreenState extends State<MenuItemExtrasScreen> {
  late MenuItemExtras _extras;
  ComboMeal? _selectedCombo;
  String? _selectedSize;
  final TextEditingController _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize selected size from initial parameter
    _selectedSize = widget.initialSelectedSize;

    // Initialize extras based on menu item category
    final sections = MenuExtrasData.getExtrasForCategory(widget.menuItem.category);

    if (widget.initialExtras != null) {
      _extras = widget.initialExtras!.clone();
    } else {
      _extras = MenuItemExtras(sections: sections);
    }

    _instructionsController.text = _extras.specialInstructions ?? '';
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.menuItem.name.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Menu item info
          _buildMenuItemInfo(),
          const SizedBox(height: 24),
          
          // Extras sections
          ..._extras.sections.map((section) => _buildExtraSection(section)),
          
          // Special instructions
          _buildSpecialInstructions(),
          
          // Bottom padding for floating button
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildMenuItemInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.menuItem.name.toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.menuItem.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Base Price',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '\$${widget.menuItem.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B35),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn()
      .slideY(begin: -0.2, end: 0);
  }

  Widget _buildExtraSection(MenuExtraSection section) {
    final selectedExtras = _extras.getSelectedExtrasForSection(section.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      section.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedExtras.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${selectedExtras.length}/${section.maxSelection}',
                    style: const TextStyle(
                      color: Color(0xFFFF6B35),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          
          if (section.isRequired) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'REQUIRED',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Extras list
          ...section.extras.map((extra) => _buildExtraItem(section, extra)),
        ],
      ),
    ).animate()
      .fadeIn(delay: Duration(milliseconds: 200 * _extras.sections.indexOf(section)))
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildExtraItem(MenuExtraSection section, MenuExtra extra) {
    final selectedExtras = _extras.getSelectedExtrasForSection(section.id);
    final selectedExtra = selectedExtras.firstWhere(
      (selected) => selected.extra.id == extra.id,
      orElse: () => SelectedExtra(extra: extra, quantity: 0),
    );
    final isSelected = selectedExtra.quantity > 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected 
            ? const Color(0xFFFF6B35).withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? const Color(0xFFFF6B35).withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Extra info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        extra.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (extra.isPopular)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'POPULAR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                if (extra.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    extra.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '+\$${extra.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B35),
                  ),
                ),
              ],
            ),
          ),
          
          // Quantity controls
          if (isSelected) ...[
            const SizedBox(width: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _updateExtraQuantity(section, extra, selectedExtra.quantity - 1),
                  icon: const Icon(Icons.remove_circle_outline),
                  color: const Color(0xFFFF6B35),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${selectedExtra.quantity}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: selectedExtra.quantity < extra.maxQuantity && 
                             _extras.canAddExtra(section.id, extra)
                      ? () => _updateExtraQuantity(section, extra, selectedExtra.quantity + 1)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                  color: const Color(0xFFFF6B35),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(width: 16),
            IconButton(
              onPressed: _extras.canAddExtra(section.id, extra)
                  ? () => _updateExtraQuantity(section, extra, 1)
                  : null,
              icon: const Icon(Icons.add_circle),
              color: const Color(0xFFFF6B35),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecialInstructions() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Special Instructions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _instructionsController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add a note...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFFF6B35)),
              ),
              filled: true,
              fillColor: Colors.grey.withValues(alpha: 0.05),
            ),
            onChanged: (value) {
              _extras.specialInstructions = value.isEmpty ? null : value;
            },
          ),
          const SizedBox(height: 12),
          Text(
            'You may be charged for extras.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: Duration(milliseconds: 200 * (_extras.sections.length + 1)))
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildBottomBar() {
    final totalPrice = widget.menuItem.price + _extras.totalExtrasPrice;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _extras.isValidSelection() ? _confirmExtras : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Add 1 to order',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '• \$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateExtraQuantity(MenuExtraSection section, MenuExtra extra, int quantity) {
    // Check if this is a combo extra
    if (extra.id == 'combo_upgrade' && quantity > 0) {
      _handleComboSelection();
      return;
    }

    setState(() {
      if (quantity <= 0) {
        _extras.removeExtra(section.id, extra.id);
      } else {
        _extras.updateExtraQuantity(section.id, extra.id, quantity);
        if (!_extras.getSelectedExtrasForSection(section.id).any((selected) => selected.extra.id == extra.id)) {
          _extras.addExtra(section.id, extra, quantity: quantity);
        }
      }
    });
  }

  /// Handle combo selection by navigating to combo selection screen
  Future<void> _handleComboSelection() async {
    // Create a combo with the current menu item and selected size
    final combo = ComboConfiguration.createCombo(widget.menuItem, selectedSize: _selectedSize);

    final result = await Navigator.of(context).push<ComboMeal>(
      MaterialPageRoute(
        builder: (context) => ComboSelectionScreen(combo: combo),
      ),
    );

    if (result != null && mounted) {
      // Store the combo selection and continue with extras
      setState(() {
        _selectedCombo = result;
        // Remove the combo extra from selection since it's now configured
        _extras.removeExtra('combo', 'combo_upgrade');
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Combo configured! Add more extras or tap "Add to Cart"'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirmExtras() {
    // If combo is selected, return the combo instead of extras
    if (_selectedCombo != null) {
      Navigator.of(context).pop(_selectedCombo);
    } else {
      // Create a map to return both extras and selected size
      final result = {
        'extras': _extras,
        'selectedSize': _selectedSize,
      };
      Navigator.of(context).pop(result);
    }
  }
}
