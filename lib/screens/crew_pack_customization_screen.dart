import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/menu_service.dart';
import '../widgets/sauce_selection_dialog.dart';
import '../models/crew_pack_selection.dart';

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
  final Map<String, CrewPackCustomization> _crewPackSelections = {};
  final List<String> _availableBuns = ['Regular Bun', 'Brioche Bun'];

  @override
  void initState() {
    super.initState();
    _loadCategoryItems();
    _initializeSelections();
  }

  void _initializeSelections() {
    if (widget.crewPack.customizationCounts != null) {
      for (var entry in widget.crewPack.customizationCounts!.entries) {
        _selectedItems[entry.key] = [];
        if (entry.key == 'Sandwiches') {
          _crewPackSelections[entry.key] = CrewPackCustomization(
            maxSelections: entry.value
          );
        }
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
    if (category == 'Sandwiches') {
      return _crewPackSelections[category]?.canAddMore() ?? false;
    }
    final maxCount = widget.crewPack.customizationCounts?[category] ?? 0;
    final currentCount = _selectedItems[category]?.length ?? 0;
    return currentCount < maxCount;
  }

  Future<void> _selectBunType(String category, MenuItem sandwich) async {
    final selectedBun = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Select Bun Type for ${sandwich.name}'),
          children: _availableBuns.map((bun) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, bun);
              },
              child: Text(bun),
            );
          }).toList(),
        );
      },
    );

    if (selectedBun != null) {
      setState(() {
        double bunPrice = selectedBun == 'Brioche Bun' ? 1.0 : 0.0;
        _crewPackSelections[category]?.addSelection(
          CrewPackSelection(
            sandwichId: sandwich.id,
            bunType: selectedBun,
            price: sandwich.price + bunPrice,
          ),
        );
      });
    }
  }

  void _addItem(String category, MenuItem item) {
    if (category == 'Sandwiches') {
      _selectBunType(category, item);
    } else if (_canAddMore(category)) {
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

  void _removeSelection(String category, int index) {
    setState(() {
      _crewPackSelections[category]?.removeSelection(index);
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

    for (var entry in widget.crewPack.customizationCounts!.entries) {
      if (entry.key == 'Sandwiches') {
        final selections = _crewPackSelections[entry.key]?.selections.length ?? 0;
        if (selections != entry.value) {
          return false;
        }
      } else {
        if ((_selectedItems[entry.key]?.length ?? 0) != entry.value) {
          return false;
        }
      }
    }

    if (widget.crewPack.allowsSauceSelection &&
        (widget.crewPack.selectedSauces == null ||
            widget.crewPack.selectedSauces!.length !=
                widget.crewPack.includedSauceCount)) {
      return false;
    }

    return true;
  }

  Widget _buildCategorySection(String category) {
    final selectedCount = category == 'Sandwiches'
        ? _crewPackSelections[category]?.selections.length ?? 0
        : _selectedItems[category]?.length ?? 0;
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
        if (category == 'Sandwiches') ...[
          // Show selected sandwiches
          ..._crewPackSelections[category]?.selections.asMap().entries.map((entry) {
            final index = entry.key;
            final selection = entry.value;
            final sandwich = _categoryItems[category]?.firstWhere(
              (item) => item.id == selection.sandwichId,
              orElse: () => MenuItem(name: '', description: '', price: 0, category: ''),
            );            return ListTile(
              title: Text(sandwich?.name ?? 'Unknown Sandwich'),
              subtitle: Text('Bun: ${selection.bunType}'),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => _removeSelection(category, index),
              ),
            );
          }) ?? [],

          // Show available sandwiches
          if (_canAddMore(category))
            ..._categoryItems[category]?.map((sandwich) {
              final itemCount = _crewPackSelections[category]?.selections
                  .where((s) => s.sandwichId == sandwich.id)
                  .length ?? 0;
              
              return ListTile(
                title: Text(sandwich.name),
                subtitle: Text('Selected: $itemCount'),
                trailing: ElevatedButton(
                  onPressed: _canAddMore(category)
                      ? () => _selectBunType(category, sandwich)
                      : null,
                  child: const Text('Add'),
                ),
              );
            }) ?? [],
        ] else ...[
          // Other categories (sides, drinks, etc.)
          ..._categoryItems[category]?.map((item) {
            final itemCount = _selectedItems[category]
                    ?.where((selected) => selected.id == item.id)
                    .length ??
                0;

            return ListTile(
              title: Text(item.name),
              subtitle: Text('Selected: $itemCount'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: itemCount > 0
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
          }) ?? [],
        ],
        const Divider(height: 32),
      ],
    );
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
              ...widget.crewPack.customizationCategories?.map(_buildCategorySection) ?? [],

              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _isValid()
                      ? () {
                          final customizations = Map<String, List<MenuItem>>.from(_selectedItems);
                          Navigator.pop(context, {
                            'sandwiches': _crewPackSelections['Sandwiches'],
                            'customizations': customizations,
                            'sauces': widget.crewPack.selectedSauces,
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Add to Cart'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
