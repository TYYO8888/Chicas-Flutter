import '../models/menu_item.dart';

class RecommendationService {
  // In a real app, this would call an AI service or backend API
  Future<List<MenuItem>> getPersonalizedRecommendations() async {
    // Simulated delay to mimic API call
    await Future.delayed(const Duration(milliseconds: 800));
    
    // For now, return mock recommendations
    return [
      MenuItem(
        id: 'cajun_pepper_wings',
        name: 'Cajun Pepper Wings',
        description: 'Crispy wings tossed in our signature Cajun pepper sauce',
        price: 15.99,
        imageUrl: 'assets/cajun_wings.jpg',
        category: 'Wings',
      ),
      MenuItem(
        id: 'og_sandwich',
        name: 'The OG Sando',
        description: 'Our classic chicken sandwich with premium pickles',
        price: 11.99,
        imageUrl: 'assets/og_sandwich.jpg',
        category: 'Sandwiches',
      ),
      MenuItem(
        id: 'tenders_combo',
        name: 'Tenders Combo',
        description: 'Hand-breaded tenders with fries and sauce',
        price: 14.99,
        imageUrl: 'assets/tenders.jpg',
        category: 'Combos',
      ),
    ];
  }

  Future<List<MenuItem>> getHotDeals() async {
    // Simulated delay to mimic API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return mock deals
    return [
      MenuItem(
        id: 'thirsty_thursday',
        name: 'Thirsty Thursday',
        description: 'Get a free large drink with any combo purchase',
        price: 0.00,
        imageUrl: 'assets/drink_deal.jpg',
        category: 'Deals',
        isSpecial: true,
      ),
      // Add more deals as needed
    ];
  }
}
