import 'package:flutter/material.dart';
import '../constants/heat_levels.dart';

class HeatLevelSelector extends StatefulWidget {
  final String? selectedHeatLevel;
  final Function(String?) onHeatLevelChanged;

  const HeatLevelSelector({
    Key? key,
    this.selectedHeatLevel,
    required this.onHeatLevelChanged,
  }) : super(key: key);

  @override
  State<HeatLevelSelector> createState() => _HeatLevelSelectorState();
}

class _HeatLevelSelectorState extends State<HeatLevelSelector> {
  String? _selectedLevel;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.selectedHeatLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
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
              Text(
                'Heat Level',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...HeatLevels.all.map((heatLevel) => _buildHeatLevelOption(heatLevel)),
        ],
      ),
    );
  }

  Widget _buildHeatLevelOption(HeatLevel heatLevel) {
    final isSelected = _selectedLevel == heatLevel.name;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedLevel = heatLevel.name;
          });
          widget.onHeatLevelChanged(heatLevel.name);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? heatLevel.color.withOpacity(0.1) : Colors.white,
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
                size: 24,
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? heatLevel.color : Colors.grey[800],
                      ),
                    ),
                    Text(
                      heatLevel.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Star rating
              Row(
                children: HeatLevels.buildStarRating(heatLevel.stars, size: 18),
              ),
              
              // Selection indicator
              const SizedBox(width: 12),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? heatLevel.color : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? heatLevel.color : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
