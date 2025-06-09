import 'package:flutter/material.dart';
import 'package:qsr_app/models/menu_item.dart';
import 'package:qsr_app/services/cart_service.dart';
import 'package:qsr_app/services/menu_service.dart';
import 'package:qsr_app/widgets/sauce_selection_dialog.dart';
import 'package:qsr_app/screens/crew_pack_customization_screen.dart';

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
      // Extract the selected items and bun types from the result
      final selectedItems = result['selectedItems'] as Map<String, List<MenuItem>>;
      final selectedBunTypes = result['selectedBunTypes'] as Map<String, String>;

      // Update the price of the crew pack based on the selected bun types
      double totalPrice = crewPack.price;
      for (var sandwich in selectedItems['Sandwiches'] ?? []) {
        sandwich.selectedBunType = selectedBunTypes[sandwich.name];
        if (sandwich.selectedBunType == 'Brioche Bun') {
          totalPrice += 1.0;
        }
      }

      // Add the crew pack with its selected items to the cart
      widget.cartService.addToCart(crewPack, customizations: selectedItems);

      // Update the crew pack price
      crewPack.price = totalPrice;

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

  void _addToCart(MenuItem menuItem) {
    String? selectedSize = _selectedSizes[menuItem.name];
    if (menuItem.allowsSauceSelection &&
        (menuItem.selectedSauces == null ||
            menuItem.selectedSauces!.length != menuItem.includedSauceCount)) {
      // Show sauce selection dialog if sauces haven't been selected
      _handleSauceSelection(menuItem).then((_) {
        if (menuItem.selectedSauces?.length == menuItem.includedSauceCount) {
          widget.cartService.addToCart(menuItem, selectedSize: selectedSize);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${menuItem.name} added to cart'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    } else {
      widget.cartService.addToCart(menuItem, selectedSize: selectedSize);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${menuItem.name} added to cart'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: FutureBuilder<List<MenuItem>>(
        future: _menuItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final menuItems = snapshot.data!;
            return ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final menuItem = menuItems[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          menuItem.name,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(menuItem.description),
                        const SizedBox(height: 4.0),
                        Text(
                          '\$${menuItem.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (menuItem.sizes != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Choose your size:'),
                              Wrap(
                                children: menuItem.sizes!.keys.map((size) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Radio<String>(
                                        value: size,
                                        groupValue: _selectedSizes[menuItem.name],
                                        onChanged: (String? value) {
                                          setState(() {
                                            _selectedSizes[menuItem.name] = value!;
                                            menuItem.price = menuItem.sizes![size]!;
                                          });
                                        },
                                      ),
                                      Text('$size (\$${menuItem.sizes![size]!.toStringAsFixed(2)})'),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        const SizedBox(height: 8.0),
                        if (widget.category == 'CREW Combos')
                          ElevatedButton(
                            onPressed: () => _handleCrewPackSelection(menuItem),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Customize Pack'),
                          )
                        else
                          ElevatedButton(
                            onPressed: () => _addToCart(menuItem),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Add to Cart'),
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
    );
  }
}
