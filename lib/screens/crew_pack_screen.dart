import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/menu_service.dart';
import '../services/cart_service.dart';
import '../screens/crew_pack_customization_screen.dart';

class CrewPackScreen extends StatefulWidget {
  final MenuItem crewPack;

  const CrewPackScreen({Key? key, required this.crewPack}) : super(key: key);

  @override
  State<CrewPackScreen> createState() => _CrewPackScreenState();
}

class _CrewPackScreenState extends State<CrewPackScreen> {
  final MenuService _menuService = MenuService();
  final CartService _cartService = CartService();
  Map<String, List<MenuItem>> _categoryItems = {};

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
    });
  }

  Future<void> _startCustomization() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrewPackCustomizationScreen(crewPack: widget.crewPack),
      ),
    );

    if (result != null && mounted) {
      _cartService.addToCart(
        widget.crewPack,
        crewPackCustomization: result['sandwiches'],
      );
      Navigator.pop(context); // Return to the menu screen
    }
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
              // Display crew pack image if available
              if (widget.crewPack.imageUrl.isNotEmpty)
                Center(
                  child: Image.network(
                    widget.crewPack.imageUrl,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16),
              
              // Crew pack description
              Text(
                widget.crewPack.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),

              // Price
              Text(
                'Price: \$${widget.crewPack.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Customization instructions
              Text(
                'This Crew Pack includes:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),

              // List included items
              ...widget.crewPack.customizationCounts?.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '• ${entry.value} ${entry.key}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }) ?? [],

              if (widget.crewPack.allowsSauceSelection)
                Text(
                  '• ${widget.crewPack.includedSauceCount} Sauces',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

              const SizedBox(height: 32),

              // Start customization button
              Center(
                child: ElevatedButton(
                  onPressed: _startCustomization,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Start Customization'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
