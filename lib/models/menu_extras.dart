/// 🍗 Menu Extras Model
/// 
/// Comprehensive model for handling menu item extras including:
/// - Combo upgrades
/// - Additional sauces and toppings
/// - Bun upgrades
/// - Special instructions
/// - Pricing calculations

class MenuExtra {
  final String id;
  final String name;
  final String description;
  final double price;
  final MenuExtraCategory category;
  final bool isPopular;
  final bool isAvailable;
  final int maxQuantity;
  final String? imageUrl;

  MenuExtra({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.isPopular = false,
    this.isAvailable = true,
    this.maxQuantity = 10,
    this.imageUrl,
  });

  factory MenuExtra.fromJson(Map<String, dynamic> json) {
    return MenuExtra(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      category: MenuExtraCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => MenuExtraCategory.sauce,
      ),
      isPopular: json['isPopular'] ?? false,
      isAvailable: json['isAvailable'] ?? true,
      maxQuantity: json['maxQuantity'] ?? 10,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category.toString().split('.').last,
      'isPopular': isPopular,
      'isAvailable': isAvailable,
      'maxQuantity': maxQuantity,
      'imageUrl': imageUrl,
    };
  }
}

enum MenuExtraCategory {
  combo,
  sauce,
  bun,
  pickle,
  vegetable,
  cheese,
  protein,
  side,
  drink,
  other,
}

class MenuExtraSection {
  final String id;
  final String title;
  final String description;
  final int minSelection;
  final int maxSelection;
  final List<MenuExtra> extras;
  final bool isRequired;

  MenuExtraSection({
    required this.id,
    required this.title,
    required this.description,
    this.minSelection = 0,
    this.maxSelection = 1,
    required this.extras,
    this.isRequired = false,
  });

  factory MenuExtraSection.fromJson(Map<String, dynamic> json) {
    return MenuExtraSection(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      minSelection: json['minSelection'] ?? 0,
      maxSelection: json['maxSelection'] ?? 1,
      extras: (json['extras'] as List<dynamic>?)
          ?.map((e) => MenuExtra.fromJson(e))
          .toList() ?? [],
      isRequired: json['isRequired'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'minSelection': minSelection,
      'maxSelection': maxSelection,
      'extras': extras.map((e) => e.toJson()).toList(),
      'isRequired': isRequired,
    };
  }
}

class SelectedExtra {
  final MenuExtra extra;
  int quantity;

  SelectedExtra({
    required this.extra,
    this.quantity = 1,
  });

  double get totalPrice => extra.price * quantity;

  factory SelectedExtra.fromJson(Map<String, dynamic> json) {
    return SelectedExtra(
      extra: MenuExtra.fromJson(json['extra']),
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'extra': extra.toJson(),
      'quantity': quantity,
    };
  }
}

class MenuItemExtras {
  final List<MenuExtraSection> sections;
  final Map<String, List<SelectedExtra>> selectedExtras;
  String? specialInstructions;

  MenuItemExtras({
    required this.sections,
    Map<String, List<SelectedExtra>>? selectedExtras,
    this.specialInstructions,
  }) : selectedExtras = selectedExtras ?? {};

  double get totalExtrasPrice {
    double total = 0.0;
    for (final sectionExtras in selectedExtras.values) {
      for (final selectedExtra in sectionExtras) {
        total += selectedExtra.totalPrice;
      }
    }
    return total;
  }

  int get totalExtrasCount {
    int count = 0;
    for (final sectionExtras in selectedExtras.values) {
      for (final selectedExtra in sectionExtras) {
        count += selectedExtra.quantity;
      }
    }
    return count;
  }

  List<SelectedExtra> getSelectedExtrasForSection(String sectionId) {
    return selectedExtras[sectionId] ?? [];
  }

  void addExtra(String sectionId, MenuExtra extra, {int quantity = 1}) {
    selectedExtras[sectionId] ??= [];
    
    // Check if extra already exists
    final existingIndex = selectedExtras[sectionId]!
        .indexWhere((selected) => selected.extra.id == extra.id);
    
    if (existingIndex != -1) {
      // Update quantity
      selectedExtras[sectionId]![existingIndex].quantity += quantity;
      if (selectedExtras[sectionId]![existingIndex].quantity > extra.maxQuantity) {
        selectedExtras[sectionId]![existingIndex].quantity = extra.maxQuantity;
      }
    } else {
      // Add new extra
      selectedExtras[sectionId]!.add(SelectedExtra(
        extra: extra,
        quantity: quantity,
      ));
    }
  }

  void removeExtra(String sectionId, String extraId) {
    selectedExtras[sectionId]?.removeWhere((selected) => selected.extra.id == extraId);
    if (selectedExtras[sectionId]?.isEmpty ?? false) {
      selectedExtras.remove(sectionId);
    }
  }

  void updateExtraQuantity(String sectionId, String extraId, int quantity) {
    final sectionExtras = selectedExtras[sectionId];
    if (sectionExtras != null) {
      final extraIndex = sectionExtras.indexWhere((selected) => selected.extra.id == extraId);
      if (extraIndex != -1) {
        if (quantity <= 0) {
          sectionExtras.removeAt(extraIndex);
        } else {
          sectionExtras[extraIndex].quantity = quantity;
        }
      }
    }
  }

  bool canAddExtra(String sectionId, MenuExtra extra) {
    final section = sections.firstWhere((s) => s.id == sectionId);
    final currentCount = getSelectedExtrasForSection(sectionId).length;
    return currentCount < section.maxSelection;
  }

  bool isValidSelection() {
    for (final section in sections) {
      final selectedCount = getSelectedExtrasForSection(section.id).length;
      if (section.isRequired && selectedCount < section.minSelection) {
        return false;
      }
      if (selectedCount > section.maxSelection) {
        return false;
      }
    }
    return true;
  }

  MenuItemExtras clone() {
    final clonedSelectedExtras = <String, List<SelectedExtra>>{};
    selectedExtras.forEach((key, value) {
      clonedSelectedExtras[key] = value.map((selected) => SelectedExtra(
        extra: selected.extra,
        quantity: selected.quantity,
      )).toList();
    });

    return MenuItemExtras(
      sections: sections,
      selectedExtras: clonedSelectedExtras,
      specialInstructions: specialInstructions,
    );
  }

  factory MenuItemExtras.fromJson(Map<String, dynamic> json) {
    final selectedExtrasMap = <String, List<SelectedExtra>>{};
    if (json['selectedExtras'] != null) {
      (json['selectedExtras'] as Map<String, dynamic>).forEach((key, value) {
        selectedExtrasMap[key] = (value as List<dynamic>)
            .map((e) => SelectedExtra.fromJson(e))
            .toList();
      });
    }

    return MenuItemExtras(
      sections: (json['sections'] as List<dynamic>?)
          ?.map((e) => MenuExtraSection.fromJson(e))
          .toList() ?? [],
      selectedExtras: selectedExtrasMap,
      specialInstructions: json['specialInstructions'],
    );
  }

  Map<String, dynamic> toJson() {
    final selectedExtrasJson = <String, dynamic>{};
    selectedExtras.forEach((key, value) {
      selectedExtrasJson[key] = value.map((e) => e.toJson()).toList();
    });

    return {
      'sections': sections.map((e) => e.toJson()).toList(),
      'selectedExtras': selectedExtrasJson,
      'specialInstructions': specialInstructions,
    };
  }
}

/// Predefined extras for different menu categories
class MenuExtrasData {
  static List<MenuExtraSection> getExtrasForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'sandwiches':
        return _getSandwichExtras();
      case 'crew packs':
        return _getCrewPackExtras();
      case 'whole wings':
        return _getWingsExtras();
      case 'chicken pieces':
        return _getChickenPiecesExtras();
      case 'chicken bites':
      case 'chicken-bites':
        return _getChickenBitesExtras();
      default:
        return _getDefaultExtras();
    }
  }

  static List<MenuExtraSection> _getSandwichExtras() {
    return [
      MenuExtraSection(
        id: 'combo',
        title: 'Make it a Combo!',
        description: 'Choose up to 1',
        maxSelection: 1,
        extras: [
          MenuExtra(
            id: 'combo_upgrade',
            name: 'Make it a Combo!',
            description: 'Choose your drink and side (+\$8.50)',
            price: 8.50,
            category: MenuExtraCategory.combo,
            isPopular: true,
          ),
        ],
      ),
      MenuExtraSection(
        id: 'extras',
        title: 'Extra',
        description: 'Choose up to 20',
        maxSelection: 20,
        extras: [
          MenuExtra(
            id: 'chicas_sauce',
            name: 'Chica\'s Sauce (Buttermilk Ranch)',
            description: 'Our signature buttermilk ranch sauce',
            price: 1.50,
            category: MenuExtraCategory.sauce,
            isPopular: true,
          ),
          MenuExtra(
            id: 'chipotle_aioli',
            name: 'Chipotle Aioli',
            description: 'Smoky chipotle aioli sauce',
            price: 1.50,
            category: MenuExtraCategory.sauce,
          ),
          MenuExtra(
            id: 'buffalo_sauce',
            name: 'Buffalo Sauce',
            description: 'Classic buffalo wing sauce',
            price: 1.50,
            category: MenuExtraCategory.sauce,
          ),
          MenuExtra(
            id: 'sweet_heat_sauce',
            name: 'Sweet Heat Sauce',
            description: 'Sweet and spicy sauce blend',
            price: 1.50,
            category: MenuExtraCategory.sauce,
          ),
          MenuExtra(
            id: 'hot_honey_sauce',
            name: 'Hot Honey Sauce',
            description: 'Honey with a spicy kick',
            price: 1.50,
            category: MenuExtraCategory.sauce,
          ),
          MenuExtra(
            id: 'brioche_bun',
            name: 'Brioche Bun',
            description: 'Upgrade to brioche bun',
            price: 1.00,
            category: MenuExtraCategory.bun,
          ),
          MenuExtra(
            id: 'dill_pickles',
            name: 'Dill Pickles',
            description: 'Extra dill pickle slices',
            price: 3.00,
            category: MenuExtraCategory.pickle,
          ),
          MenuExtra(
            id: 'pickled_jalapenos',
            name: 'Pickled Jalapeños',
            description: 'Spicy pickled jalapeño slices',
            price: 3.00,
            category: MenuExtraCategory.pickle,
          ),
        ],
      ),
    ];
  }

  static List<MenuExtraSection> _getCrewPackExtras() {
    return [
      MenuExtraSection(
        id: 'combo',
        title: 'Make it a Combo!',
        description: 'Choose up to 1',
        maxSelection: 1,
        extras: [
          MenuExtra(
            id: 'crew_combo_upgrade',
            name: 'Make it a Combo!',
            description: 'Add large fries and drinks for the crew',
            price: 15.00,
            category: MenuExtraCategory.combo,
            isPopular: true,
          ),
        ],
      ),
      MenuExtraSection(
        id: 'extras',
        title: 'Extra',
        description: 'Choose up to 20',
        maxSelection: 20,
        extras: _getCommonExtras(),
      ),
    ];
  }

  static List<MenuExtraSection> _getWingsExtras() {
    return [
      MenuExtraSection(
        id: 'combo',
        title: 'Make it a Combo!',
        description: 'Choose up to 1',
        maxSelection: 1,
        extras: [
          MenuExtra(
            id: 'combo_upgrade',
            name: 'Make it a Combo!',
            description: 'Choose your drink and side (+\$8.50)',
            price: 8.50,
            category: MenuExtraCategory.combo,
            isPopular: true,
          ),
        ],
      ),
      MenuExtraSection(
        id: 'extras',
        title: 'Extra',
        description: 'Choose up to 20',
        maxSelection: 20,
        extras: _getCommonExtras(),
      ),
    ];
  }

  static List<MenuExtraSection> _getChickenPiecesExtras() {
    return [
      MenuExtraSection(
        id: 'combo',
        title: 'Make it a Combo!',
        description: 'Choose up to 1',
        maxSelection: 1,
        extras: [
          MenuExtra(
            id: 'combo_upgrade',
            name: 'Make it a Combo!',
            description: 'Choose your drink and side (+\$8.50)',
            price: 8.50,
            category: MenuExtraCategory.combo,
            isPopular: true,
          ),
        ],
      ),
      MenuExtraSection(
        id: 'extras',
        title: 'Extra',
        description: 'Choose up to 20',
        maxSelection: 20,
        extras: _getCommonExtras(),
      ),
    ];
  }

  static List<MenuExtraSection> _getDefaultExtras() {
    return [
      MenuExtraSection(
        id: 'extras',
        title: 'Extra',
        description: 'Choose up to 10',
        maxSelection: 10,
        extras: _getCommonExtras(),
      ),
    ];
  }

  static List<MenuExtra> _getCommonExtras() {
    return [
      MenuExtra(
        id: 'chicas_sauce',
        name: 'Chica\'s Sauce (Buttermilk Ranch)',
        description: 'Our signature buttermilk ranch sauce',
        price: 1.50,
        category: MenuExtraCategory.sauce,
        isPopular: true,
      ),
      MenuExtra(
        id: 'chipotle_aioli',
        name: 'Chipotle Aioli',
        description: 'Smoky chipotle aioli sauce',
        price: 1.50,
        category: MenuExtraCategory.sauce,
      ),
      MenuExtra(
        id: 'buffalo_sauce',
        name: 'Buffalo Sauce',
        description: 'Classic buffalo wing sauce',
        price: 1.50,
        category: MenuExtraCategory.sauce,
      ),
      MenuExtra(
        id: 'sweet_heat_sauce',
        name: 'Sweet Heat Sauce',
        description: 'Sweet and spicy sauce blend',
        price: 1.50,
        category: MenuExtraCategory.sauce,
      ),
      MenuExtra(
        id: 'hot_honey_sauce',
        name: 'Hot Honey Sauce',
        description: 'Honey with a spicy kick',
        price: 1.50,
        category: MenuExtraCategory.sauce,
      ),
      MenuExtra(
        id: 'brioche_bun',
        name: 'Brioche Bun',
        description: 'Upgrade to brioche bun',
        price: 1.00,
        category: MenuExtraCategory.bun,
      ),
      MenuExtra(
        id: 'dill_pickles',
        name: 'Dill Pickles',
        description: 'Extra dill pickle slices',
        price: 3.00,
        category: MenuExtraCategory.pickle,
      ),
      MenuExtra(
        id: 'pickled_jalapenos',
        name: 'Pickled Jalapeños',
        description: 'Spicy pickled jalapeño slices',
        price: 3.00,
        category: MenuExtraCategory.pickle,
      ),
    ];
  }

  static List<MenuExtraSection> _getChickenBitesExtras() {
    return [
      MenuExtraSection(
        id: 'combo',
        title: 'Make it a Combo!',
        description: 'Choose up to 1',
        maxSelection: 1,
        extras: [
          MenuExtra(
            id: 'combo_upgrade',
            name: 'Make it a Combo!',
            description: 'Choose your drink and side (+\$8.50)',
            price: 8.50,
            category: MenuExtraCategory.combo,
            isPopular: true,
          ),
        ],
      ),
      MenuExtraSection(
        id: 'sauces',
        title: 'Dipping Sauces',
        description: 'Choose up to 3',
        maxSelection: 3,
        extras: [
          MenuExtra(
            id: 'ranch',
            name: 'Ranch',
            description: 'Creamy ranch dipping sauce',
            price: 0.75,
            category: MenuExtraCategory.sauce,
          ),
          MenuExtra(
            id: 'honey_mustard',
            name: 'Honey Mustard',
            description: 'Sweet and tangy honey mustard',
            price: 0.75,
            category: MenuExtraCategory.sauce,
          ),
          MenuExtra(
            id: 'bbq_sauce',
            name: 'BBQ Sauce',
            description: 'Smoky barbecue sauce',
            price: 0.75,
            category: MenuExtraCategory.sauce,
          ),
          MenuExtra(
            id: 'buffalo_sauce',
            name: 'Buffalo Sauce',
            description: 'Spicy buffalo wing sauce',
            price: 0.75,
            category: MenuExtraCategory.sauce,
          ),
        ],
      ),
    ];
  }
}
