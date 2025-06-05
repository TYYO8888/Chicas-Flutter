import 'package:qsr_app/models/menu_item.dart';

class MenuService {
  // This method will eventually fetch menu items from the Revel API
  Future<List<MenuItem>> getMenuItems(String category) async {
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
          ),
          MenuItem(
            id: 'sweet_heat_sando',
            name: 'Sweet Heat Sando',
            description: 'Sweet heat sauce topped with pickled jalapeños',
            price: 13.00,
            imageUrl: 'assets/sandwiches.png',
            category: 'Sandwiches',
            sizes: {'Texas Toast': 13.00, 'Brioche Bun': 14.00},
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
            id: 'ilb_plus_wings',
            name: 'ILB+',
            description: 'Includes one side of Chica\'s sauce',
            price: 18.00,
            imageUrl: 'assets/whole_wings.png',
            category: 'Whole Wings',
            allowsSauceSelection: true,
            includedSauceCount: 1,
          ),
          MenuItem(
            id: 'og_wings',
            name: 'OG Whole Wings',
            description: 'Choose your heat level! Nashville-spiced served on white bread, topped with pickles',
            price: 16.00,
            imageUrl: 'assets/whole_wings.png',
            category: 'Whole Wings',
            allowsSauceSelection: true,
            includedSauceCount: 1,
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
            id: 'crinkle_fries',
            name: 'Crinkle Cut Fries',
            description: 'Crispy crinkle cut fries',
            price: 5.00,
            imageUrl: 'assets/sides.png',
            category: 'Sides',
            sizes: {'Regular': 5.00, 'Large': 7.50},
          ),
          MenuItem(
            id: 'mac_cheese',
            name: 'Mac & Cheese',
            description: 'Creamy three-cheese blend',
            price: 5.00,
            imageUrl: 'assets/sides.png',
            category: 'Sides',
            sizes: {'Regular': 5.00, 'Large': 7.50},
          ),
          MenuItem(
            id: 'coleslaw',
            name: 'Coleslaw',
            description: 'Fresh, creamy house-made slaw',
            price: 5.75,
            imageUrl: 'assets/sides.png',
            category: 'Sides',
            sizes: {'Regular': 5.75, 'Large': 8.25},
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
      case 'CREW Combos':
        return [
          MenuItem(
            id: 'crew_pack_1',
            name: 'Crew Pack 1',
            description: '(\$45 serves 2-3): 2x Sandwiches, 1x Chicken Bites, 2x Sides [R], 2x Sauces, 2x Drinks',
            price: 45.00,
            imageUrl: 'assets/crew_combos.png',
            category: 'CREW Combos',
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
            imageUrl: 'assets/crew_combos.png',
            category: 'CREW Combos',
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
            imageUrl: 'assets/crew_combos.png',
            category: 'CREW Combos',
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
