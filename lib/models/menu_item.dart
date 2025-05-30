class MenuItem {
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  String? heatLevel;

  MenuItem({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.heatLevel,
  });
}
