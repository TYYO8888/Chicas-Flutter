import 'package:hive/hive.dart';
import 'menu_item.dart';

part 'offline_data.g.dart';

@HiveType(typeId: 0)
class OfflineMenuItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final String imageUrl;

  @HiveField(5)
  final String category;

  @HiveField(6)
  final bool isSpecial;

  @HiveField(7)
  final bool available;

  @HiveField(8)
  final bool allowsSauceSelection;

  @HiveField(9)
  final List<String>? selectedSauces;

  @HiveField(10)
  final int? includedSauceCount;

  @HiveField(11)
  final String? selectedBunType;

  @HiveField(12)
  final bool allowsHeatLevelSelection;

  @HiveField(13)
  final String? selectedHeatLevel;

  @HiveField(14)
  final Map<String, double>? sizes;

  @HiveField(15)
  final Map<String, int>? customizationCounts;

  @HiveField(16)
  final List<String>? customizationCategories;

  @HiveField(17)
  final Map<String, dynamic>? customizations;

  @HiveField(18)
  final Map<String, dynamic>? nutritionInfo;

  @HiveField(19)
  final DateTime lastUpdated;

  OfflineMenuItem({
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
    required this.lastUpdated,
  });

  // Convert from MenuItem
  factory OfflineMenuItem.fromMenuItem(MenuItem menuItem) {
    return OfflineMenuItem(
      id: menuItem.id,
      name: menuItem.name,
      description: menuItem.description,
      price: menuItem.price,
      imageUrl: menuItem.imageUrl,
      category: menuItem.category,
      isSpecial: menuItem.isSpecial,
      available: menuItem.available,
      allowsSauceSelection: menuItem.allowsSauceSelection,
      selectedSauces: menuItem.selectedSauces,
      includedSauceCount: menuItem.includedSauceCount,
      selectedBunType: menuItem.selectedBunType,
      allowsHeatLevelSelection: menuItem.allowsHeatLevelSelection,
      selectedHeatLevel: menuItem.selectedHeatLevel,
      sizes: menuItem.sizes,
      customizationCounts: menuItem.customizationCounts,
      customizationCategories: menuItem.customizationCategories,
      customizations: menuItem.customizations,
      nutritionInfo: menuItem.nutritionInfo,
      lastUpdated: DateTime.now(),
    );
  }

  // Convert to MenuItem
  MenuItem toMenuItem() {
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
      selectedSauces: selectedSauces,
      includedSauceCount: includedSauceCount,
      selectedBunType: selectedBunType,
      allowsHeatLevelSelection: allowsHeatLevelSelection,
      selectedHeatLevel: selectedHeatLevel,
      sizes: sizes,
      customizationCounts: customizationCounts,
      customizationCategories: customizationCategories,
      customizations: customizations,
      nutritionInfo: nutritionInfo,
    );
  }
}

@HiveType(typeId: 1)
class OfflineOrder extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String customerId;

  @HiveField(2)
  final List<OfflineOrderItem> items;

  @HiveField(3)
  final double subtotal;

  @HiveField(4)
  final double tax;

  @HiveField(5)
  final double total;

  @HiveField(6)
  final String status;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime? completedAt;

  @HiveField(9)
  final bool synced;

  @HiveField(10)
  final Map<String, dynamic>? metadata;

  OfflineOrder({
    required this.id,
    required this.customerId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.synced = false,
    this.metadata,
  });
}

@HiveType(typeId: 2)
class OfflineOrderItem extends HiveObject {
  @HiveField(0)
  final String menuItemId;

  @HiveField(1)
  final String menuItemName;

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final double unitPrice;

  @HiveField(4)
  final double totalPrice;

  @HiveField(5)
  final String? selectedSize;

  @HiveField(6)
  final List<String>? selectedSauces;

  @HiveField(7)
  final Map<String, dynamic>? customizations;

  OfflineOrderItem({
    required this.menuItemId,
    required this.menuItemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.selectedSize,
    this.selectedSauces,
    this.customizations,
  });
}

@HiveType(typeId: 3)
class OfflineMenuCategory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int displayOrder;

  @HiveField(3)
  final bool available;

  @HiveField(4)
  final DateTime lastUpdated;

  OfflineMenuCategory({
    required this.id,
    required this.name,
    required this.displayOrder,
    this.available = true,
    required this.lastUpdated,
  });
}

@HiveType(typeId: 4)
class SyncMetadata extends HiveObject {
  @HiveField(0)
  final String dataType;

  @HiveField(1)
  final DateTime lastSyncTime;

  @HiveField(2)
  final int recordCount;

  @HiveField(3)
  final String? lastSyncError;

  @HiveField(4)
  final bool syncInProgress;

  SyncMetadata({
    required this.dataType,
    required this.lastSyncTime,
    required this.recordCount,
    this.lastSyncError,
    this.syncInProgress = false,
  });
}
