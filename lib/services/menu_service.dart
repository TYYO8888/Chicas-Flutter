import 'package:qsr_app/models/menu_item.dart';
import 'package:qsr_app/services/api_service.dart';
import 'package:qsr_app/utils/logger.dart';

class MenuService {
  final ApiService _apiService = ApiService();

  // 📋 Get menu categories
  Future<List<MenuCategory>> getMenuCategories() async {
    try {
      AppLogger.info('Fetching menu categories');
      return await _apiService.getMenuCategories();
    } catch (e) {
      AppLogger.error('Failed to fetch menu categories', e);
      // Return fallback categories if API fails
      return _getFallbackCategories();
    }
  }

  // 🍗 Get menu items by category
  Future<List<MenuItem>> getMenuItems(String category) async {
    try {
      AppLogger.info('Fetching menu items for category: $category');

      // Convert display name to API category ID
      final categoryId = _getCategoryId(category);
      return await _apiService.getMenuItems(categoryId);
    } catch (e) {
      AppLogger.error('Failed to fetch menu items for $category', e);
      // Return fallback data if API fails
      return _getFallbackMenuItems(category);
    }
  }

  // 🔍 Search menu items
  Future<List<MenuItem>> searchMenuItems(String query, {String? category}) async {
    try {
      AppLogger.info('Searching menu items: $query');
      return await _apiService.searchMenuItems(query, category: category);
    } catch (e) {
      AppLogger.error('Failed to search menu items', e);
      return [];
    }
  }

  // 🎯 Get specific menu item
  Future<MenuItem?> getMenuItem(String itemId) async {
    try {
      AppLogger.info('Fetching menu item: $itemId');
      return await _apiService.getMenuItem(itemId);
    } catch (e) {
      AppLogger.error('Failed to fetch menu item $itemId', e);
      return null;
    }
  }

  // 📋 Get all menu items across all categories
  Future<List<MenuItem>> getAllMenuItems() async {
    try {
      AppLogger.info('Fetching all menu items');
      final categories = await getMenuCategories();
      final List<MenuItem> allItems = [];

      for (final category in categories) {
        final items = await getMenuItems(category.name);
        allItems.addAll(items);
      }

      return allItems;
    } catch (e) {
      AppLogger.error('Failed to fetch all menu items', e);
      // Return fallback data from all categories
      final List<MenuItem> fallbackItems = [];
      final categories = ['Sandwiches', 'Whole Wings', 'Chicken Pieces', 'Chicken Bites', 'Sides', 'Fixin\'s', 'Sauces', 'Crew Packs', 'Beverages'];

      for (final category in categories) {
        final items = await _getFallbackMenuItems(category);
        fallbackItems.addAll(items);
      }

      return fallbackItems;
    }
  }



  // �🔄 Convert display category name to API category ID
  String _getCategoryId(String displayName) {
    switch (displayName) {
      case 'Sandwiches':
        return 'sandwiches';
      case 'Whole Wings':
        return 'whole-wings';
      case 'Chicken Pieces':
        return 'chicken-pieces';
      case 'Chicken Bites':
        return 'chicken-bites';
      case 'Sides':
        return 'sides';
      case "Fixin's":
        return 'fixins';
      case 'Sauces':
        return 'sauces';
      case 'Crew Packs':
        return 'crew-packs';
      case 'Beverages':
        return 'beverages';
      default:
        return displayName.toLowerCase().replaceAll(' ', '-');
    }
  }

  // 📋 Fallback categories if API fails
  List<MenuCategory> _getFallbackCategories() {
    return [
      MenuCategory(id: 'sandwiches', name: 'Sandwiches', displayOrder: 1),
      MenuCategory(id: 'whole-wings', name: 'Whole Wings', displayOrder: 2),
      MenuCategory(id: 'chicken-pieces', name: 'Chicken Pieces', displayOrder: 3),
      MenuCategory(id: 'chicken-bites', name: 'Chicken Bites', displayOrder: 4),
      MenuCategory(id: 'sides', name: 'Sides', displayOrder: 5),
      MenuCategory(id: 'fixins', name: "Fixin's", displayOrder: 6),
      MenuCategory(id: 'sauces', name: 'Sauces', displayOrder: 7),
      MenuCategory(id: 'crew-packs', name: 'Crew Packs', displayOrder: 5),
      MenuCategory(id: 'beverages', name: 'Beverages', displayOrder: 9),
    ];
  }

  // 🍗 Fallback menu items if API fails (keeping your original mock data)
  Future<List<MenuItem>> _getFallbackMenuItems(String category) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    AppLogger.warning('Using fallback data for category: $category');
    // For now, we'll return a hardcoded list of menu items
    switch (category) {
      case 'Sandwiches':
        return [
          MenuItem(
            id: 'og_sando',
            name: 'The OG Sando',
            description: 'Choose your heat level! Nashville-spiced',
            price: 13.00,
            imageUrl: 'assets/sandwiches.png',
            category: 'Sandwiches',
            sizes: {'Texas Toast': 13.00, 'Brioche Bun': 14.00},
            allowsHeatLevelSelection: true,
            allowsExtras: true,
          ),
          MenuItem(
            id: 'sweet_heat_sando',
            name: 'Sweet Heat Sando',
            description: 'Sweet heat sauce topped with pickled jalapeños',
            price: 13.00,
            imageUrl: 'assets/sandwiches.png',
            category: 'Sandwiches',
            sizes: {'Texas Toast': 13.00, 'Brioche Bun': 14.00},
            allowsExtras: true,
          ),
          MenuItem(
            id: 'buffalo_sando',
            name: 'Crispy Buffalo Sando',
            description: 'Buffalo sauce topped with slaw and Chica\'s sauce',
            price: 13.00,
            imageUrl: 'assets/sandwiches.png',
            category: 'Sandwiches',
            sizes: {'Texas Toast': 13.00, 'Brioche Bun': 14.00},
          ),
          MenuItem(
            id: 'jalapeno_sando',
            name: 'Jalapeno Popper Sando',
            description: 'Topped with chipotle aioli, pickled jalapeños',
            price: 13.00,
            imageUrl: 'assets/sandwiches.png',
            category: 'Sandwiches',
            sizes: {'Texas Toast': 13.00, 'Brioche Bun': 14.00},
          ),
          MenuItem(
            id: 'hot_honey_sando',
            name: 'Hot Honey Sando',
            description: 'Hot honey sauce topped with pickled jalapeños',
            price: 13.00,
            imageUrl: 'assets/sandwiches.png',
            category: 'Sandwiches',
            sizes: {'Texas Toast': 13.00, 'Brioche Bun': 14.00},
          ),
        ];
      case 'Whole Wings':
        return [
          MenuItem(
            id: 'og_wings',
            name: 'OG Whole Wings',
            description: 'Choose your heat level! Nashville-spiced served on white bread, topped with pickles',
            price: 16.00,
            imageUrl: 'assets/whole_wings.png',
            category: 'Whole Wings',
            allowsSauceSelection: true,
            includedSauceCount: 1,
            allowsHeatLevelSelection: true,
          ),
          MenuItem(
            id: 'lemon_pepper_wings',
            name: 'Lemon Pepper Wings',
            description: 'Lemon pepper seasoning',
            price: 16.00,
            imageUrl: 'assets/whole_wings.png',
            category: 'Whole Wings',
            allowsSauceSelection: true,
            includedSauceCount: 1,
          ),
        ];
      case 'Chicken Pieces':
        return [
          MenuItem(
            id: '2pc_chicken',
            name: '2 Pieces',
            description: 'Served on white bread, topped with pickles, includes one Chica\'s sauce',
            price: 13.00,
            imageUrl: 'assets/chicken_pieces.png',
            category: 'Chicken Pieces',
            allowsSauceSelection: true,
            includedSauceCount: 1,
            allowsHeatLevelSelection: true,
          ),
          MenuItem(
            id: '3pc_chicken',
            name: '3 Pieces',
            description: 'Served on white bread, topped with pickles, includes one Chica\'s sauce',
            price: 18.00,
            imageUrl: 'assets/chicken_pieces.png',
            category: 'Chicken Pieces',
            allowsSauceSelection: true,
            includedSauceCount: 1,
            allowsHeatLevelSelection: true,
          ),
          MenuItem(
            id: '4pc_chicken',
            name: '4 Pieces',
            description: 'Served on white bread, topped with pickles, includes two Chica\'s sauces',
            price: 22.00,
            imageUrl: 'assets/chicken_pieces.png',
            category: 'Chicken Pieces',
            allowsSauceSelection: true,
            includedSauceCount: 2,
            allowsHeatLevelSelection: true,
          ),
        ];
      case 'Chicken Bites':
        return [
          MenuItem(
            id: 'og_bites',
            name: 'OG Bites',
            description: 'Choose your heat level! Nashville-spiced',
            price: 12.50,
            imageUrl: 'assets/chicken_bites.png',
            category: 'Chicken Bites',
            allowsSauceSelection: true,
            includedSauceCount: 1,
            allowsHeatLevelSelection: true,
          ),
          MenuItem(
            id: 'sweet_heat_bites',
            name: 'Sweet Heat Bites',
            description: 'Sweet heat sauce topped with pickled jalapeños',
            price: 12.50,
            imageUrl: 'assets/chicken_bites.png',
            category: 'Chicken Bites',
            allowsSauceSelection: true,
            includedSauceCount: 1,
          ),
          MenuItem(
            id: 'buffalo_bites',
            name: 'Buffalo Bites',
            description: 'Buffalo sauce',
            price: 12.50,
            imageUrl: 'assets/chicken_bites.png',
            category: 'Chicken Bites',
            allowsSauceSelection: true,
            includedSauceCount: 1,
          ),
          MenuItem(
            id: 'lemon_pepper_bites',
            name: 'Lemon Pepper Bites',
            description: 'Lemon pepper seasoning',
            price: 12.50,
            imageUrl: 'assets/chicken_bites.png',
            category: 'Chicken Bites',
            allowsSauceSelection: true,
            includedSauceCount: 1,
          ),
          MenuItem(
            id: 'hot_honey_bites',
            name: 'Hot Honey Bites',
            description: 'Hot honey sauce topped with pickled jalapeños',
            price: 12.50,
            imageUrl: 'assets/chicken_bites.png',
            category: 'Chicken Bites',
            allowsSauceSelection: true,
            includedSauceCount: 1,
          ),
        ];
      case 'Sides':
        return [
          MenuItem(
            id: 'waffle_fries',
            name: 'Waffle Fries',
            description: 'Golden waffle-cut fries with perfect seasoning',
            price: 5.50,
            imageUrl: 'assets/sides.png',
            category: 'Sides',
            sizes: {'Regular': 5.50, 'Large': 8.00},
          ),
          MenuItem(
            id: 'cajun_waffle_fries',
            name: 'Cajun Waffle Fries',
            description: 'Waffle fries seasoned with Cajun spices',
            price: 6.00,
            imageUrl: 'assets/sides.png',
            category: 'Sides',
            sizes: {'Regular': 6.00, 'Large': 8.50},
          ),
          MenuItem(
            id: 'sour_cream_onion_waffle_fries',
            name: 'Sour Cream + Onion Waffle Fries',
            description: 'Waffle fries with sour cream and onion seasoning',
            price: 6.00,
            imageUrl: 'assets/sides.png',
            category: 'Sides',
            sizes: {'Regular': 6.00, 'Large': 8.50},
          ),
          MenuItem(
            id: 'deep_fried_pickles',
            name: 'DEEP Fried Pickles',
            description: 'Crispy deep-fried pickle spears',
            price: 6.50,
            imageUrl: 'assets/sides.png',
            category: 'Sides',
          ),
        ];
      case 'Fixin\'s':
        return [
          MenuItem(
            id: 'dill_pickles_8oz',
            name: 'Dill Pickles 8 oz',
            description: '',
            price: 2.50,
            imageUrl: 'assets/fixins.png', // Replace with actual image URL
            category: 'Fixin\'s',
          ),
          MenuItem(
            id: 'pickled_jalapenos_8oz',
            name: 'Pickled Jalapenos 8 oz',
            description: '',
            price: 2.50,
            imageUrl: 'assets/fixins.png', // Replace with actual image URL
            category: 'Fixin\'s',
          ),
          MenuItem(
            id: 'brioche_bun',
            name: 'Brioche Bun',
            description: '',
            price: 2.00,
            imageUrl: 'assets/fixins.png', // Replace with actual image URL
            category: 'Fixin\'s',
          ),
        ];
      case 'Sauces':
        return [
          MenuItem(
            id: 'chicas_sauce',
            name: 'Chica\'s Sauce (Buttermilk Ranch)',
            description: '',
            price: 1.25,
            imageUrl: 'assets/sauces.png', // Replace with actual image URL
            category: 'Sauces',
          ),
          MenuItem(
            id: 'sweet_heat_sauce',
            name: 'Sweet Heat Sauce',
            description: '',
            price: 1.25,
            imageUrl: 'assets/sauces.png', // Replace with actual image URL
            category: 'Sauces',
          ),
          MenuItem(
            id: 'buffalo_sauce',
            name: 'Buffalo Sauce',
            description: '',
            price: 1.25,
            imageUrl: 'assets/sauces.png', // Replace with actual image URL
            category: 'Sauces',
          ),
          MenuItem(
            id: 'chipotle_aioli',
            name: 'Chipotle Aioli',
            description: '',
            price: 1.25,
            imageUrl: 'assets/sauces.png', // Replace with actual image URL
            category: 'Sauces',
          ),
          MenuItem(
            id: 'hot_honey_sauce',
            name: 'Hot Honey Sauce',
            description: '',
            price: 1.25,
            imageUrl: 'assets/sauces.png', // Replace with actual image URL
            category: 'Sauces',
          ),
        ];
      case 'Crew Packs':
        return [
          MenuItem(
            id: 'crew_pack_1',
            name: 'Crew Pack 1',
            description: '(\$45 serves 2-3): 2x Sandwiches, 1x Chicken Bites, 2x Sides [R], 2x Sauces, 2x Drinks',
            price: 45.00,
            imageUrl: 'assets/crew_packs.png',
            category: 'Crew Packs',
            customizationCounts: {
              'Sandwiches': 2,
              'Chicken Bites': 1,
              'Sides': 2,
              'Sauces': 2,
              'Beverages': 2,
            },
            customizationCategories: ['Sandwiches', 'Chicken Bites', 'Sides', 'Sauces', 'Beverages'],
          ),
          MenuItem(
            id: 'crew_pack_2',
            name: 'Crew Pack 2',
            description: '(\$65 serves 4-5): 3x Sandwiches, 2x Chicken Bites, 3x Sides [R], 3x Sauces, 3x Drinks',
            price: 65.00,
            imageUrl: 'assets/crew_packs.png',
            category: 'Crew Packs',
            customizationCounts: {
              'Sandwiches': 3,
              'Chicken Bites': 2,
              'Sides': 3,
              'Sauces': 3,
              'Beverages': 3,
            },
            customizationCategories: ['Sandwiches', 'Chicken Bites', 'Sides', 'Sauces', 'Beverages'],
          ),
          MenuItem(
            id: 'crew_pack_3',
            name: 'Crew Pack 3',
            description: '(\$85 serves 6-7): 4x Sandwiches, 3x Chicken Bites, 4x Sides [R], 4x Sauces, 4x Drinks',
            price: 85.00,
            imageUrl: 'assets/crew_packs.png',
            category: 'Crew Packs',
            customizationCounts: {
              'Sandwiches': 4,
              'Chicken Bites': 3,
              'Sides': 4,
              'Sauces': 4,
              'Beverages': 4,
            },
            customizationCategories: ['Sandwiches', 'Chicken Bites', 'Sides', 'Sauces', 'Beverages'],
          ),
        ];
      case 'Beverages':
        return [
          MenuItem(
            id: 'pepsi',
            name: 'Pepsi',
            description: 'Classic Pepsi cola.',
            price: 2.50,
            imageUrl: 'assets/beverages.png', // Replace with actual image URL
            category: 'Beverages',
          ),
          MenuItem(
            id: 'diet_pepsi',
            name: 'Diet Pepsi',
            description: 'Zero calorie Diet Pepsi.',
            price: 2.50,
            imageUrl: 'assets/beverages.png', // Replace with actual image URL
            category: 'Beverages',
          ),
          MenuItem(
            id: 'mug_root_beer',
            name: 'Mug Root Beer',
            description: 'Classic creamy root beer.',
            price: 2.50,
            imageUrl: 'assets/beverages.png', // Replace with actual image URL
            category: 'Beverages',
          ),
          MenuItem(
            id: 'orange_crush',
            name: 'Orange Crush',
            description: 'Refreshing orange flavored soda.',
            price: 2.50,
            imageUrl: 'assets/beverages.png', // Replace with actual image URL
            category: 'Beverages',
          ),
          MenuItem(
            id: 'mountain_dew',
            name: 'Mountain Dew',
            description: 'Citrus flavored soda.',
            price: 2.50,
            imageUrl: 'assets/beverages.png', // Replace with actual image URL
            category: 'Beverages',
          ),
          MenuItem(
            id: 'bottled_water',
            name: 'Bottled Water',
            description: 'Chilled bottled spring water.',
            price: 2.50,
            imageUrl: 'assets/beverages.png', // Replace with actual image URL
            category: 'Beverages',
          ),
        ];
      default:
        return []; // Return an empty list if the category is not found
    }
  }
}
