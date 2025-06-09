import 'package:flutter/material.dart';

class HeatLevel {
  final String name;
  final String description;
  final int stars;
  final Color color;
  final IconData icon;

  const HeatLevel({
    required this.name,
    required this.description,
    required this.stars,
    required this.color,
    required this.icon,
  });
}

class HeatLevels {
  static const mild = HeatLevel(
    name: 'MILD',
    description: 'NO HEAT',
    stars: 1,
    color: Colors.green,
    icon: Icons.local_fire_department_outlined,
  );

  static const medium = HeatLevel(
    name: 'MEDIUM',
    description: 'HOT',
    stars: 2,
    color: Colors.orange,
    icon: Icons.local_fire_department,
  );

  static const mediumHot = HeatLevel(
    name: 'MEDIUM / HOT',
    description: 'VERY HOT',
    stars: 3,
    color: Colors.deepOrange,
    icon: Icons.local_fire_department,
  );

  static const hot = HeatLevel(
    name: 'HOT',
    description: 'EXTREMELY HOT',
    stars: 4,
    color: Colors.red,
    icon: Icons.whatshot,
  );

  static const List<HeatLevel> all = [
    mild,
    medium,
    mediumHot,
    hot,
  ];

  static HeatLevel? getByName(String name) {
    try {
      return all.firstWhere((level) => level.name == name);
    } catch (e) {
      return null;
    }
  }

  static List<Widget> buildStarRating(int stars, {double size = 16}) {
    return List.generate(4, (index) {
      return Icon(
        index < stars ? Icons.star : Icons.star_border,
        color: index < stars ? Colors.amber : Colors.grey,
        size: size,
      );
    });
  }
}
