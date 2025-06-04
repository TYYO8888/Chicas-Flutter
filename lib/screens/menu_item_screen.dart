import 'package:flutter/material.dart';
import 'package:qsr_app/models/menu_item.dart';
import 'package:qsr_app/services/cart_service.dart';
import 'package:qsr_app/services/menu_service.dart';
import 'package:qsr_app/widgets/sauce_selection_dialog.dart';
import 'package:qsr_app/screens/crew_pack_customization_screen.dart';

final CartService cartService = CartService();

class MenuItemScreen extends StatefulWidget {
  final String category;

  const MenuItemScreen({super.key, required this.category});

  @override
  _MenuItemScreenState createState() => _MenuItemScreenState();
}

class _MenuItemScreenState extends State<MenuItemScreen> {
  late Future<List<MenuItem>> _menuItemsFuture;
  final MenuService _menuService = MenuService();
  String? _selectedHeatLevel;
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
      // Add the crew pack with its selected items to the cart
      cartService.addToCart(crewPack, customizations: result);
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
    if (menuItem.allowsSauceSelection &&
        (menuItem.selectedSauces == null ||
            menuItem.selectedSauces!.length != menuItem.includedSauceCount)) {
      // Show sauce selection dialog if sauces haven't been selected
      _handleSauceSelection(menuItem).then((_) {
        if (menuItem.selectedSauces?.length == menuItem.includedSauceCount) {
          cartService.addToCart(menuItem);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${menuItem.name} added to cart'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    } else {
      cartService.addToCart(menuItem);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
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
