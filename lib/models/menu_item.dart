class MenuItem {
  final String name;
  final String description;
  double price;
  final String imageUrl;
  final String category;
  String? heatLevel;
  Map<String, double>? sizes;

  MenuItem({
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl = '',
    required this.category,
    this.heatLevel,
    this.sizes,
  });
}
