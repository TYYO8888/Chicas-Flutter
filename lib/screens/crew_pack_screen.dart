import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/menu_service.dart';

class CrewPackScreen extends StatefulWidget {
  final MenuItem crewPack;

  const CrewPackScreen({Key? key, required this.crewPack}) : super(key: key);

  @override
  State<CrewPackScreen> createState() => _CrewPackScreenState();
}

class _CrewPackScreenState extends State<CrewPackScreen> {
  final MenuService _menuService = MenuService();
  Map<String, List<MenuItem>> _categoryItems = {};
  Map<String, List<MenuItem>> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _loadCategoryItems();
  }

  Future<void> _loadCategoryItems() async {
    Map<String, List<MenuItem>> items = {};
    for (String category in widget.crewPack.customizationCategories ?? []) {
      items[category] = await _menuService.getMenuItems(category);
    }
    setState(() {
      _categoryItems = items;
      // Initialize selected items map      for (var entry in (widget.crewPack.customizationCounts as Map<String, int>?)?.entries ?? []) {
        _selectedItems[entry.key] = [];
      }
    });
  }

  bool _canAddMore(String category) {
    int maxCount = widget.crewPack.customizationCounts?[category] ?? 0;
    int currentCount = _selectedItems[category]?.length ?? 0;
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

  bool _isValid() {    for (var entry in (widget.crewPack.customizationCounts as Map<String, int>?)?.entries ?? []) {
      if ((_selectedItems[entry.key]?.length ?? 0) != entry.value) {
        return false;
      }
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
              ...widget.crewPack.customizationCategories?.map((category) {
                    int selectedCount = _selectedItems[category]?.length ?? 0;
                    int maxCount = widget.crewPack.customizationCounts?[category] ?? 0;

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
                              bool isSelected =
                                  _selectedItems[category]?.contains(item) ?? false;
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
                                    Text('${_selectedItems[category]?.where((selected) => selected.name == item.name).length ?? 0}'),
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
