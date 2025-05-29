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
          ),
          MenuItem(
            name: 'Waffle Fries',
            description: '',
            price: 5.00,
            imageUrl: 'assets/sides.png', // Replace with actual image URL
            category: 'Sides',
          ),
          MenuItem(
            name: 'Cajun Waffle Fries',
            description: '',
            price: 5.00,
            imageUrl: 'assets/sides.png', // Replace with actual image URL
            category: 'Sides',
          ),
          MenuItem(
            name: 'Sour Cream + Onion Waffle Fries',
            description: '+\$0.75',
            price: 5.75,
            imageUrl: 'assets/sides.png', // Replace with actual image URL
            category: 'Sides',
          ),
          MenuItem(
            name: 'Deep Fried Pickles',
            description: '+\$3',
            price: 8.00,
            imageUrl: 'assets/sides.png', // Replace with actual image URL
            category: 'Sides',
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
          MenuItem(
            name: 'Pickled Jalapenos 8 oz',
            description: '',
            price: 2.50,
            imageUrl: 'assets/fixins.png', // Replace with actual image URL
            category: 'Fixin\'s',
          ),
          MenuItem(
            name: 'Brioche Bun',
            description: '',
            price: 1.00,
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
          MenuItem(
            name: 'Sweet Heat Sauce',
            description: '',
            price: 1.25,
            imageUrl: 'assets/sauces.png', // Replace with actual image URL
            category: 'Sauces',
          ),
          MenuItem(
            name: 'Buffalo Sauce',
            description: '',
            price: 1.25,
            imageUrl: 'assets/sauces.png', // Replace with actual image URL
            category: 'Sauces',
          ),
          MenuItem(
            name: 'Chipotle Aioli',
            description: '',
            price: 1.25,
            imageUrl: 'assets/sauces.png', // Replace with actual image URL
            category: 'Sauces',
          ),
          MenuItem(
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
            name: 'Crew Pack 1',
            description: '(\$45 serves 2-3): 2x Sandwiches, 1x Chicken Bites, 2x Sides [R], 2x Sauces, 2x Drinks',
            price: 45.00,
            imageUrl: 'assets/crew_combos.png', // Replace with actual image URL
            category: 'CREW Combos',
          ),
          MenuItem(
            name: 'Crew Pack 2',
            description: '(\$65 serves 3-4): 1x Chicken Bites, 1x Whole Wings, 4x Chicken Pieces [Bone-In], 2x Sides [L], 1x 8 oz Pickles/Pickled Jalapenos, 4x Sauces, 4x Drinks',
            price: 65.00,
            imageUrl: 'assets/crew_combos.png', // Replace with actual image URL
            category: 'CREW Combos',
          ),
          MenuItem(
            name: 'Crew Pack 3',
            description: '(\$85 serves 4-5): 2x Sandwiches, 2x Chicken Bites, 1x Whole Wings, 3x Sides [L], 1x 8 oz Pickles/Pickled Jalapenos, 5x Sauces, 5x Drinks',
            price: 85.00,
            imageUrl: 'assets/crew_combos.png', // Replace with actual image URL
            category: 'CREW Combos',
          ),
        ];
      default:
        return []; // Return an empty list if the category is not found
    }
  }
}
