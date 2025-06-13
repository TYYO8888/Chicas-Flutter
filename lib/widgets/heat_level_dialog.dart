import 'package:flutter/material.dart';
import 'package:qsr_app/constants/heat_levels.dart';

/// ✅ Reusable Heat Level Selection Dialog for Cart Editing
class HeatLevelDialog extends StatefulWidget {
  final String? currentHeatLevel;
  final Function(String) onHeatLevelSelected;
  final String itemName;

  const HeatLevelDialog({
    super.key,
    required this.currentHeatLevel,
    required this.onHeatLevelSelected,
    required this.itemName,
  });

  @override
  State<HeatLevelDialog> createState() => _HeatLevelDialogState();
}

class _HeatLevelDialogState extends State<HeatLevelDialog> {
  String? _selectedHeatLevel;

  @override
  void initState() {
    super.initState();
    _selectedHeatLevel = widget.currentHeatLevel;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.whatshot,
                color: Colors.red[600],
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'CHANGE HEAT LEVEL',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.itemName,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...HeatLevels.all.map((heatLevel) => _buildHeatLevelOption(heatLevel)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'CANCEL',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: _selectedHeatLevel != null
              ? () {
                  widget.onHeatLevelSelected(_selectedHeatLevel!);
                  Navigator.of(context).pop();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
          ),
          child: const Text('UPDATE HEAT LEVEL'),
        ),
      ],
    );
  }

  Widget _buildHeatLevelOption(HeatLevel heatLevel) {
    final isSelected = _selectedHeatLevel == heatLevel.name;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedHeatLevel = heatLevel.name;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? heatLevel.color.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? heatLevel.color : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Heat level icon
              Icon(
                heatLevel.icon,
                color: heatLevel.color,
                size: 20,
              ),
              const SizedBox(width: 12),
              
              // Heat level info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      heatLevel.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? heatLevel.color : Colors.grey[800],
                      ),
                    ),
                    Text(
                      heatLevel.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Flame rating
              Row(
                children: HeatLevels.buildFlameRating(heatLevel.stars, size: 14),
              ),
              
              // Selection indicator
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.check_circle,
                    color: heatLevel.color,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Static method to show heat level dialog
  static Future<void> show({
    required BuildContext context,
    required String? currentHeatLevel,
    required Function(String) onHeatLevelSelected,
    required String itemName,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return HeatLevelDialog(
          currentHeatLevel: currentHeatLevel,
          onHeatLevelSelected: onHeatLevelSelected,
          itemName: itemName,
        );
      },
    );
  }
}
