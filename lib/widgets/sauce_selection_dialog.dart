import 'package:flutter/material.dart';

class SauceSelectionDialog extends StatefulWidget {
  final int maxSauces;
  final List<String>? initialSelections;

  const SauceSelectionDialog({
    Key? key,
    required this.maxSauces,
    this.initialSelections,
  }) : super(key: key);

  @override
  State<SauceSelectionDialog> createState() => _SauceSelectionDialogState();
}

class _SauceSelectionDialogState extends State<SauceSelectionDialog> {
  final List<String> _selectedSauces = [];
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
    if (widget.initialSelections != null) {
      _selectedSauces.addAll(widget.initialSelections!);
    }
  }

  bool _canAddMore() {
    return _selectedSauces.length < widget.maxSauces;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Sauces (${_selectedSauces.length}/${widget.maxSauces})'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _availableSauces.map((sauce) {
            final isSelected = _selectedSauces.contains(sauce);
            return ListTile(
              title: Text(sauce),
              trailing: isSelected
                  ? IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        setState(() {
                          _selectedSauces.remove(sauce);
                        });
                      },
                    )
                  : IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _canAddMore()
                          ? () {
                              setState(() {
                                _selectedSauces.add(sauce);
                              });
                            }
                          : null,
                    ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedSauces.length == widget.maxSauces
              ? () {
                  Navigator.of(context).pop(_selectedSauces);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
