import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/menu_service.dart';
import '../widgets/sauce_selection_dialog.dart';

class CrewPackCustomizationScreen extends StatefulWidget {
  final MenuItem crewPack;

  const CrewPackCustomizationScreen({Key? key, required this.crewPack}) : super(key: key);

  @override
  State<CrewPackCustomizationScreen> createState() => _CrewPackCustomizationScreenState();
}

class _CrewPackCustomizationScreenState extends State<CrewPackCustomizationScreen> {
  final MenuService _menuService = MenuService();
  final Map<String, List<MenuItem>> _categoryItems = {};
  final Map<String, List<MenuItem>> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _loadCategoryItems();
    _initializeSelectedItems();
  }

  void _initializeSelectedItems() {
    if (widget.crewPack.customizationCounts != null) {
      for (var category in widget.crewPack.customizationCounts!.keys) {
        _selectedItems[category] = [];
      }
    }
  }

  Future<void> _loadCategoryItems() async {
    for (String category in widget.crewPack.customizationCategories ?? []) {
      _categoryItems[category] = await _menuService.getMenuItems(category);
    }
    setState(() {});
  }

  bool _canAddMore(String category) {
    final maxCount = widget.crewPack.customizationCounts?[category] ?? 0;
    final currentCount = _selectedItems[category]?.length ?? 0;
    return currentCount < maxCount;
  }

  void _addItem(String category, MenuItem item) {
    if (_canAddMore(category)) {
      setState(() {
        _selectedItems[category]?.add(item);
      });
    }
  }

  void _removeItem(String category, MenuItem item) {
    setState(() {
      _selectedItems[category]?.remove(item);
    });
  }

  Future<void> _handleSauceSelection() async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) => SauceSelectionDialog(
        maxSauces: widget.crewPack.includedSauceCount,
        initialSelections: widget.crewPack.selectedSauces,
      ),
    );

    if (result != null) {
      setState(() {
        widget.crewPack.selectedSauces = result;
      });
    }
  }

  bool _isValid() {
    if (widget.crewPack.customizationCounts == null) return false;
    
    // Check if all categories have the required number of selections
    for (var entry in widget.crewPack.customizationCounts!.entries) {
      if ((_selectedItems[entry.key]?.length ?? 0) != entry.value) {
        return false;
      }
    }

    // Check if sauces are selected
    if (widget.crewPack.allowsSauceSelection &&
        (widget.crewPack.selectedSauces == null ||
            widget.crewPack.selectedSauces!.length !=
                widget.crewPack.includedSauceCount)) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.crewPack.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.crewPack.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Text(
                'Please make your selections for each component of the pack below.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              // Add sauce selection button if applicable
              if (widget.crewPack.allowsSauceSelection) ...[
                ElevatedButton.icon(
                  onPressed: _handleSauceSelection,
                  icon: const Icon(Icons.local_dining),
                  label: Text(
                    widget.crewPack.selectedSauces?.isEmpty ?? true
                        ? 'Select ${widget.crewPack.includedSauceCount} Sauces'
                        : 'Selected Sauces: ${widget.crewPack.selectedSauces!.join(", ")}',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Existing category selections
              ...widget.crewPack.customizationCategories?.map((category) {
                    final selectedCount = _selectedItems[category]?.length ?? 0;
                    final maxCount = widget.crewPack.customizationCounts?[category] ?? 0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CHOOSE $maxCount ${category.toUpperCase()}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '($selectedCount/$maxCount selected)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        ..._categoryItems[category]?.map((item) {
                              final isSelected =
                                  _selectedItems[category]?.contains(item) ?? false;
                              final itemCount = _selectedItems[category]
                                      ?.where((selected) => selected.name == item.name)
                                      .length ??
                                  0;

                              return ListTile(
                                title: Text(item.name),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline),
                                      onPressed: isSelected
                                          ? () => _removeItem(category, item)
                                          : null,
                                    ),
                                    Text('$itemCount'),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: _canAddMore(category)
                                          ? () => _addItem(category, item)
                                          : null,
                                    ),
                                  ],
                                ),
                              );
                            }) ??
                            [],
                        const SizedBox(height: 16),
                      ],
                    );
                  }) ??
                  [],
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _isValid()
                    ? () {
                        // Return the selected items to the previous screen
                        Navigator.pop(context, _selectedItems);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Add to Cart (\$${widget.crewPack.price.toStringAsFixed(2)})',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
