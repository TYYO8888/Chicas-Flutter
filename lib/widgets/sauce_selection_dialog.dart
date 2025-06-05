import 'package:flutter/material.dart';

class SauceSelectionDialog extends StatefulWidget {
  final int? maxSauces;
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
    if (widget.maxSauces == null) return true;
    return _selectedSauces.length < widget.maxSauces!;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.maxSauces != null
          ? 'Select Sauces (${_selectedSauces.length}/${widget.maxSauces})'
          : 'Select Sauces (${_selectedSauces.length})'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _availableSauces.map((sauce) {
            final isSelected = _selectedSauces.contains(sauce);
            return ListTile(
              title: Text(sauce),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: Colors.green[700])
                  : null,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedSauces.remove(sauce);
                  } else if (_canAddMore()) {
                    _selectedSauces.add(sauce);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedSauces),
          child: const Text('CONFIRM'),
        ),
      ],
    );
  }
}
