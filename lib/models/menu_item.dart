class MenuItem {
  final String id;
  final String name;
  final String description;
  double price;
  final String imageUrl;
  final String category;
  final bool isSpecial;
  final bool available;

  // Sauce selection properties
  bool allowsSauceSelection;
  List<String>? selectedSauces;
  int? includedSauceCount;

  // Bun selection properties
  String? selectedBunType;

  // Heat level properties
  bool allowsHeatLevelSelection;
  String? selectedHeatLevel;

  // Size options
  Map<String, double>? sizes;

  // Crew pack customization properties
  Map<String, int>? customizationCounts;
  List<String>? customizationCategories;
  Map<String, dynamic>? customizations;

  // Nutrition information
  Map<String, dynamic>? nutritionInfo;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isSpecial = false,
    this.available = true,
    this.allowsSauceSelection = false,
    this.selectedSauces,
    this.includedSauceCount,
    this.selectedBunType,
    this.allowsHeatLevelSelection = false,
    this.selectedHeatLevel,
    this.sizes,
    this.customizationCounts,
    this.customizationCategories,
    this.customizations,
    this.nutritionInfo,
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
      available: available,
      allowsSauceSelection: allowsSauceSelection,
      selectedSauces: selectedSauces != null ? List.from(selectedSauces!) : null,
      includedSauceCount: includedSauceCount,
      selectedBunType: selectedBunType,
      allowsHeatLevelSelection: allowsHeatLevelSelection,
      selectedHeatLevel: selectedHeatLevel,
      sizes: sizes != null ? Map.from(sizes!) : null,
      customizationCounts: customizationCounts != null ? Map.from(customizationCounts!) : null,
      customizationCategories: customizationCategories != null ? List.from(customizationCategories!) : null,
      customizations: customizations != null ? Map.from(customizations!) : null,
      nutritionInfo: nutritionInfo != null ? Map.from(nutritionInfo!) : null,
    );
  }

  // Factory constructor for creating MenuItem from JSON
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      category: json['category'],
      isSpecial: json['isSpecial'] ?? false,
      available: json['available'] ?? true,
      allowsSauceSelection: json['allowsSauceSelection'] ?? false,
      selectedSauces: json['selectedSauces'] != null
          ? List<String>.from(json['selectedSauces'])
          : null,
      includedSauceCount: json['includedSauceCount'],
      selectedBunType: json['selectedBunType'],
      allowsHeatLevelSelection: json['allowsHeatLevelSelection'] ?? false,
      selectedHeatLevel: json['selectedHeatLevel'],
      sizes: json['sizes'] != null
          ? Map<String, double>.from(json['sizes'].map((k, v) => MapEntry(k, v.toDouble())))
          : null,
      customizationCounts: json['customizationCounts'] != null
          ? Map<String, int>.from(json['customizationCounts'])
          : null,
      customizationCategories: json['customizationCategories'] != null
          ? List<String>.from(json['customizationCategories'])
          : null,
      customizations: json['customizations'],
      nutritionInfo: json['nutritionInfo'],
    );
  }

  // Convert MenuItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isSpecial': isSpecial,
      'available': available,
      'allowsSauceSelection': allowsSauceSelection,
      'selectedSauces': selectedSauces,
      'includedSauceCount': includedSauceCount,
      'selectedBunType': selectedBunType,
      'allowsHeatLevelSelection': allowsHeatLevelSelection,
      'selectedHeatLevel': selectedHeatLevel,
      'sizes': sizes,
      'customizationCounts': customizationCounts,
      'customizationCategories': customizationCategories,
      'customizations': customizations,
      'nutritionInfo': nutritionInfo,
    };
  }
}
