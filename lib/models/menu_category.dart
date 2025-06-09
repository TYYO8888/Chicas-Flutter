class MenuCategory {
  final String id;
  final String name;
  final int displayOrder;
  final bool available;

  MenuCategory({
    required this.id,
    required this.name,
    required this.displayOrder,
    this.available = true,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'] ?? json['name']?.toLowerCase().replaceAll(' ', '_') ?? '',
      name: json['name'] ?? '',
      displayOrder: json['displayOrder'] ?? 0,
      available: json['available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayOrder': displayOrder,
      'available': available,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuCategory &&
        other.id == id &&
        other.name == name &&
        other.displayOrder == displayOrder &&
        other.available == available;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        displayOrder.hashCode ^
        available.hashCode;
  }

  @override
  String toString() {
    return 'MenuCategory(id: $id, name: $name, displayOrder: $displayOrder, available: $available)';
  }
}
