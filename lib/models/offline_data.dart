import 'menu_item.dart';

// Note: For now, we'll use simple classes without Hive annotations
// In production, you would generate adapters with: flutter packages pub run build_runner build

// Simplified version without Hive annotations for testing
class OfflineMenuItem {
  final String id;

  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isSpecial;
  final bool available;
  final bool allowsSauceSelection;
  final List<String>? selectedSauces;
  final int? includedSauceCount;
  final String? selectedBunType;
  final bool allowsHeatLevelSelection;
  final String? selectedHeatLevel;
  final Map<String, double>? sizes;
  final Map<String, int>? customizationCounts;
  final List<String>? customizationCategories;
  final Map<String, dynamic>? customizations;
  final Map<String, dynamic>? nutritionInfo;
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

class OfflineOrder {
  final String id;
  final String customerId;
  final List<OfflineOrderItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool synced;
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

class OfflineOrderItem {
  final String menuItemId;
  final String menuItemName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? selectedSize;
  final List<String>? selectedSauces;
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

class OfflineMenuCategory {
  final String id;
  final String name;
  final int displayOrder;
  final bool available;
  final DateTime lastUpdated;

  OfflineMenuCategory({
    required this.id,
    required this.name,
    required this.displayOrder,
    this.available = true,
    required this.lastUpdated,
  });
}

class SyncMetadata {
  final String dataType;
  final DateTime lastSyncTime;
  final int recordCount;
  final String? lastSyncError;
  final bool syncInProgress;

  SyncMetadata({
    required this.dataType,
    required this.lastSyncTime,
    required this.recordCount,
    this.lastSyncError,
    this.syncInProgress = false,
  });
}
