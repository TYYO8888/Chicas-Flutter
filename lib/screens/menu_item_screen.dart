import 'package:flutter/material.dart';
import 'package:qsr_app/models/menu_item.dart';
import 'package:qsr_app/services/cart_service.dart';
import 'package:qsr_app/services/menu_service.dart';

final CartService cartService = CartService();

class MenuItemScreen extends StatefulWidget {
  final String category;

  MenuItemScreen({required this.category});

  @override
  _MenuItemScreenState createState() => _MenuItemScreenState();
}

class _MenuItemScreenState extends State<MenuItemScreen> {
  late Future<List<MenuItem>> _menuItemsFuture;
  final MenuService _menuService = MenuService();
  String? _selectedHeatLevel;
  Map<String, String> _selectedSizes = {};

  @override
  void initState() {
    super.initState();
    _menuItemsFuture = _menuService.getMenuItems(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
                  margin: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          menuItem.name,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(menuItem.description),
                        SizedBox(height: 4.0),
                        Text(
                          '\$${menuItem.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (menuItem.sizes != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Choose your size:'),
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
                        if (menuItem.name == 'The OG' ||
                            menuItem.name == 'OG Whole Wings' ||
                            menuItem.name == 'OG Bites' ||
                            widget.category == 'Chicken Pieces')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Choose your heat level:'),
                              Row(
                                children: [
                                  Radio<String>(
                                    value: 'Plain',
                                    groupValue: _selectedHeatLevel,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _selectedHeatLevel = value;
                                        menuItem.heatLevel = value;
                                      });
                                    },
                                  ),
                                  Text('Plain'),
                                  Radio<String>(
                                    value: 'Mild (No Heat)',
                                    groupValue: _selectedHeatLevel,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _selectedHeatLevel = value;
                                        menuItem.heatLevel = value;
                                      });
                                    },
                                  ),
                                  Text('Mild (No Heat)'),
                                ],
                              ),
                              Row(
                                children: [
                                  Radio<String>(
                                    value: 'Medium (Hot)',
                                    groupValue: _selectedHeatLevel,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _selectedHeatLevel = value;
                                        menuItem.heatLevel = value;
                                      });
                                    },
                                  ),
                                  Text('Medium (Hot)'),
                                  Radio<String>(
                                    value: 'Medium/Hot (Very Hot)',
                                    groupValue: _selectedHeatLevel,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _selectedHeatLevel = value;
                                        menuItem.heatLevel = value;
                                      });
                                    },
                                  ),
                                  Text('Medium/Hot (Very Hot)'),
                                ],
                              ),
                              Row(
                                children: [
                                  Radio<String>(
                                    value: 'Hot AF (Extremely Hot)',
                                    groupValue: _selectedHeatLevel,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _selectedHeatLevel = value;
                                        menuItem.heatLevel = value;
                                      });
                                    },
                                  ),
                                  Text('Hot AF (Extremely Hot)'),
                                ],
                              ),
                            ],
                          ),
                        ElevatedButton(
                          onPressed: () {
                            // Add the item to the cart
                            cartService.addItem(menuItem);
                            print('${menuItem.name} added to cart with heat level: ${menuItem.heatLevel}');
                          },
                          child: Text('Add to Cart'),
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
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
