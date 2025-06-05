class MenuItem {
  final String id;
  final String name;
  final String description;
  double price;
  final String imageUrl;
  final String category;
  final bool isSpecial;
  
  // Sauce selection properties
  bool allowsSauceSelection;
  List<String>? selectedSauces;
  int? includedSauceCount;

  // Bun selection properties
  String? selectedBunType;

  // Size options
  Map<String, double>? sizes;

  // Crew pack customization properties
  Map<String, int>? customizationCounts;
  List<String>? customizationCategories;
  Map<String, dynamic>? customizations;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isSpecial = false,
    this.allowsSauceSelection = false,
    this.selectedSauces,
    this.includedSauceCount,
    this.selectedBunType,
    this.sizes,
    this.customizationCounts,
    this.customizationCategories,
    this.customizations,
  });

  // Clone method for creating copies of menu items
  MenuItem clone() {
    return MenuItem(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      category: category,
      isSpecial: isSpecial,
      allowsSauceSelection: allowsSauceSelection,
      selectedSauces: selectedSauces != null ? List.from(selectedSauces!) : null,
      includedSauceCount: includedSauceCount,
      selectedBunType: selectedBunType,
      sizes: sizes != null ? Map.from(sizes!) : null,
      customizationCounts: customizationCounts != null ? Map.from(customizationCounts!) : null,
      customizationCategories: customizationCategories != null ? List.from(customizationCategories!) : null,
      customizations: customizations != null ? Map.from(customizations!) : null,
    );
  }
}
