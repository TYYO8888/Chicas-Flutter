class MenuItem {
  final String id;
  final String name;
  final String description;
  double price;
  final String imageUrl;
  final String category;
  String? heatLevel;
  String? selectedBunType; // Add this line
  Map<String, double>? sizes;
  Map<String, int>? customizationCounts; // How many items of each type can be selected
  List<String>? customizationCategories; // Which categories can be selected from
  bool allowsSauceSelection;
  int includedSauceCount;
  List<String>? selectedSauces;

  MenuItem({
    String? id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl = '',
    required this.category,
    this.heatLevel,
    this.sizes,
    this.customizationCounts,
    this.customizationCategories,
    this.allowsSauceSelection = false,
    this.includedSauceCount = 0,
    this.selectedSauces,
  }) : id = id ?? name.toLowerCase().replaceAll(' ', '_');
}
