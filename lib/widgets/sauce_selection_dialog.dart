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
                  : null,              onTap: () {
                setState(() {
                  if (isSelected) {
                    // If already selected, just remove it
                    _selectedSauces.remove(sauce);
                  } else {
                    // If we have a max sauce limit of 1, replace the current selection
                    if (widget.maxSauces == 1) {
                      _selectedSauces.clear();
                      _selectedSauces.add(sauce);
                    } else if (widget.maxSauces == null || _selectedSauces.length < widget.maxSauces!) {
                      // If we have no limit or haven't reached the limit, add the sauce
                      _selectedSauces.add(sauce);
                    } else {
                      // If we've reached the limit, remove the first sauce and add the new one
                      _selectedSauces.removeAt(0);
                      _selectedSauces.add(sauce);
                    }
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
