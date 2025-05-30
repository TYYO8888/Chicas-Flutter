import 'package:qsr_app/models/menu_item.dart';

class MenuService {
  // This method will eventually fetch menu items from the Revel API
  Future<List<MenuItem>> getMenuItems(String category) async {
    // For now, we'll return a hardcoded list of menu items
    switch (category) {
      case 'Sandwiches':
        return [
          MenuItem(
            name: 'The OG',
            description: 'Choose your heat level! Nashville-spiced served on Texas toast (sub Texas toast for brioche bun +\$1)',
            price: 13.00,
            imageUrl: 'assets/sandwiches.png', // Replace with actual image URL
            category: 'Sandwiches',
          ),
          MenuItem(
            name: 'Sweet Heat Sando',
            description: 'Sweet heat sauce topped with pickled jalapeños, served on a toasted brioche bun',
            price: 13.00,
            imageUrl: 'assets/sandwiches.png', // Replace with actual image URL
            category: 'Sandwiches',
          ),
          MenuItem(
            name: 'Crispy Buffalo Sando',
            description: 'Buffalo sauce topped with slaw and Chica\'s sauce, served on a toasted brioche bun',
            price: 13.00,
            imageUrl: 'assets/sandwiches.png', // Replace with actual image URL
            category: 'Sandwiches',
          ),
          MenuItem(
            name: 'Jalapeno Popper Sando',
            description: 'Topped with chipotle aioli, pickled jalapeños, served on a toasted brioche bun',
            price: 13.00,
            imageUrl: 'assets/sandwiches.png', // Replace with actual image URL
            category: 'Sandwiches',
          ),
          MenuItem(
            name: 'Hot Honey Sando',
            description: 'Hot honey sauce topped with pickled jalapeños, served on a toasted brioche bun',
            price: 13.00,
            imageUrl: 'assets/sandwiches.png', // Replace with actual image URL
            category: 'Sandwiches',
          ),
        ];
      case 'Whole Wings':
        return [
          MenuItem(
            name: 'OG Whole Wings',
            description: 'Choose your heat level! Nashville-spiced served on white bread, topped with pickles',
            price: 16.00,
            imageUrl: 'assets/whole_wings.png', // Replace with actual image URL
            category: 'Whole Wings',
          ),
          MenuItem(
            name: 'Lemon Pepper Wings',
            description: 'Lemon pepper seasoning',
            price: 16.00,
            imageUrl: 'assets/whole_wings.png', // Replace with actual image URL
            category: 'Whole Wings',
          ),
        ];
      case 'Chicken Pieces':
        return [
          MenuItem(
            name: '2 Pieces',
            description: 'Served on white bread, topped with pickles, includes one Chica\'s sauce',
            price: 13.00,
            imageUrl: 'assets/chicken_pieces.png', // Replace with actual image URL
            category: 'Chicken Pieces',
          ),
          MenuItem(
            name: '3 Pieces',
            description: 'Served on white bread, topped with pickles, includes one Chica\'s sauce',
            price: 18.00,
            imageUrl: 'assets/chicken_pieces.png', // Replace with actual image URL
            category: 'Chicken Pieces',
          ),
          MenuItem(
            name: '4 Pieces',
            description: 'Served on white bread, topped with pickles, includes two Chica\'s sauces',
            price: 22.00,
            imageUrl: 'assets/chicken_pieces.png', // Replace with actual image URL
            category: 'Chicken Pieces',
          ),
        ];
      case 'Chicken Bites':
        return [
          MenuItem(
            name: 'OG Bites',
            description: 'Choose your heat level! Nashville-spiced',
            price: 12.50,
            imageUrl: 'assets/chicken_bites.png', // Replace with actual image URL
            category: 'Chicken Bites',
          ),
          MenuItem(
            name: 'Sweet Heat Bites',
            description: 'Sweet heat sauce topped with pickled jalapeños',
            price: 12.50,
            imageUrl: 'assets/chicken_bites.png', // Replace with actual image URL
            category: 'Chicken Bites',
          ),
          MenuItem(
            name: 'Buffalo Bites',
            description: 'Buffalo sauce',
            price: 12.50,
            imageUrl: 'assets/chicken_bites.png', // Replace with actual image URL
            category: 'Chicken Bites',
          ),
          MenuItem(
            name: 'Lemon Pepper Bites',
            description: 'Lemon pepper seasoning',
            price: 12.50,
            imageUrl: 'assets/chicken_bites.png', // Replace with actual image URL
            category: 'Chicken Bites',
          ),
          MenuItem(
            name: 'Hot Honey Bites',
            description: 'Hot honey sauce topped with pickled jalapeños',
            price: 12.50,
            imageUrl: 'assets/chicken_bites.png', // Replace with actual image URL
            category: 'Chicken Bites',
          ),
        ];
      case 'Sides':
        return [
          MenuItem(
            name: 'Slaw',
            description: '',
            price: 5.00,
            imageUrl: 'assets/sides.png', // Replace with actual image URL
            category: 'Sides',
            sizes: {'Regular': 5.00, 'Large': 7.50},
          ),
          MenuItem(
            name: 'Waffle Fries',
            description: '',
            price: 5.00,
            imageUrl: 'assets/sides.png', // Replace with actual image URL
            category: 'Sides',
            sizes: {'Regular': 5.00, 'Large': 7.50},
          ),
          MenuItem(
            name: 'Cajun Waffle Fries',
            description: '',
            price: 5.75,
            imageUrl: 'assets/sides.png', // Replace with actual image URL
            category: 'Sides',
            sizes: {'Regular': 5.75, 'Large': 8.25},
          ),
          MenuItem(
            name: 'Sour Cream + Onion Waffle Fries',
            description: '',
            price: 5.75,
            imageUrl: 'assets/sides.png', // Replace with actual image URL
            category: 'Sides',
            sizes: {'Regular': 5.75, 'Large': 8.25},
          ),
          MenuItem(
            name: 'Deep Fried Pickles',
            description: '',
            price: 8.00,
            imageUrl: 'assets/sides.png', // Replace with actual image URL
            category: 'Sides',
            sizes: {'Regular': 8.00, 'Large': 11.00},
          ),
        ];
      case 'Fixin\'s':
        return [
          MenuItem(
            name: 'Dill Pickles 8 oz',
            description: '',
            price: 2.50,
            imageUrl: 'assets/fixins.png', // Replace with actual image URL
            category: 'Fixin\'s',
          ),
        ];
      case 'Sauces':
        return [
          MenuItem(
            name: 'Chica\'s Sauce (Buttermilk Ranch)',
            description: '',
            price: 1.25,
            imageUrl: 'assets/sauces.png', // Replace with actual image URL
            category: 'Sauces',
          ),
        ];
      case 'CREW Combos':
        return [
          MenuItem(
            name: 'Crew Pack 1',
            description: '(\$45 serves 2-3): 2x Sandwiches, 1x Chicken Bites, 2x Sides [R], 2x Sauces, 2x Drinks',
            price: 45.00,
            imageUrl: 'assets/crew_combos.png', // Replace with actual image URL
            category: 'CREW Combos',
          ),
        ];
      default:
        return []; // Return an empty list if the category is not found
    }
  }
}
