/// Centralized menu item image management
/// 
/// This file contains all menu item images for easy management and updates.
/// To update any menu item image:
/// 1. Add the new image to the assets/images/ folder
/// 2. Update the corresponding path in this file
/// 3. Run 'flutter pub get' to refresh assets
class MenuImages {
  // Base path for menu item images
  static const String _basePath = 'assets/images/menu/';
  
  // Placeholder/fallback images
  static const String placeholder = 'assets/images/placeholder_food.png';
  static const String logoPlaceholder = 'assets/images/chicas_logo.png';
  
  // SANDWICHES
  static const String ogSandwich = '${_basePath}og_sandwich.jpg';
  static const String spicySandwich = '${_basePath}spicy_sandwich.jpg';
  static const String bbqSandwich = '${_basePath}bbq_sandwich.jpg';
  static const String buffaloSandwich = '${_basePath}buffalo_sandwich.jpg';
  
  // WINGS
  static const String cajunWings = '${_basePath}cajun_wings.jpg';
  static const String buffaloWings = '${_basePath}buffalo_wings.jpg';
  static const String bbqWings = '${_basePath}bbq_wings.jpg';
  static const String honeyGarlicWings = '${_basePath}honey_garlic_wings.jpg';
  
  // TENDERS
  static const String classicTenders = '${_basePath}classic_tenders.jpg';
  static const String spicyTenders = '${_basePath}spicy_tenders.jpg';
  static const String tendersCombo = '${_basePath}tenders_combo.jpg';
  
  // SIDES
  static const String crinkleFries = '${_basePath}crinkle_fries.jpg';
  static const String deepFriedPickles = '${_basePath}deep_fried_pickles.jpg';
  static const String macAndCheese = '${_basePath}mac_and_cheese.jpg';
  static const String coleslaw = '${_basePath}coleslaw.jpg';
  
  // DRINKS
  static const String softDrinks = '${_basePath}soft_drinks.jpg';
  static const String lemonade = '${_basePath}lemonade.jpg';
  static const String icedTea = '${_basePath}iced_tea.jpg';
  
  // COMBOS
  static const String familyPack = '${_basePath}family_pack.jpg';
  static const String dateNightCombo = '${_basePath}date_night_combo.jpg';
  static const String gameNightCombo = '${_basePath}game_night_combo.jpg';
  
  // DEALS & SPECIALS
  static const String thirstyThursday = '${_basePath}drink_deal.jpg';
  static const String weekendSpecial = '${_basePath}weekend_special.jpg';
  static const String happyHour = '${_basePath}happy_hour.jpg';
  
  // DESSERTS
  static const String applePie = '${_basePath}apple_pie.jpg';
  static const String iceCream = '${_basePath}ice_cream.jpg';
  static const String cookies = '${_basePath}cookies.jpg';
  
  /// Get image path by menu item ID
  /// This allows for dynamic image assignment based on item IDs
  static String getImageByItemId(String itemId) {
    switch (itemId.toLowerCase()) {
      // Sandwiches
      case 'og_sandwich':
      case 'og_sando':
        return ogSandwich;
      case 'spicy_sandwich':
      case 'spicy_sando':
        return spicySandwich;
      case 'bbq_sandwich':
      case 'bbq_sando':
        return bbqSandwich;
      case 'buffalo_sandwich':
      case 'buffalo_sando':
        return buffaloSandwich;
        
      // Wings
      case 'cajun_pepper_wings':
      case 'cajun_wings':
        return cajunWings;
      case 'buffalo_wings':
        return buffaloWings;
      case 'bbq_wings':
        return bbqWings;
      case 'honey_garlic_wings':
        return honeyGarlicWings;
        
      // Tenders
      case 'classic_tenders':
        return classicTenders;
      case 'spicy_tenders':
        return spicyTenders;
      case 'tenders_combo':
        return tendersCombo;
        
      // Sides
      case 'crinkle_fries':
        return crinkleFries;
      case 'deep_fried_pickles':
      case 'beer_fried_pickles':
        return deepFriedPickles;
      case 'mac_and_cheese':
        return macAndCheese;
      case 'coleslaw':
        return coleslaw;
        
      // Drinks
      case 'soft_drinks':
      case 'soda':
        return softDrinks;
      case 'lemonade':
        return lemonade;
      case 'iced_tea':
        return icedTea;
        
      // Combos
      case 'family_pack':
        return familyPack;
      case 'date_night_combo':
        return dateNightCombo;
      case 'game_night_combo':
        return gameNightCombo;
        
      // Deals
      case 'thirsty_thursday':
        return thirstyThursday;
      case 'weekend_special':
        return weekendSpecial;
      case 'happy_hour':
        return happyHour;
        
      // Desserts
      case 'apple_pie':
        return applePie;
      case 'ice_cream':
        return iceCream;
      case 'cookies':
        return cookies;
        
      // Default fallback
      default:
        return placeholder;
    }
  }
  
  /// Get all available images for a category
  static List<String> getImagesByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'sandwiches':
        return [ogSandwich, spicySandwich, bbqSandwich, buffaloSandwich];
      case 'wings':
        return [cajunWings, buffaloWings, bbqWings, honeyGarlicWings];
      case 'tenders':
        return [classicTenders, spicyTenders, tendersCombo];
      case 'sides':
        return [crinkleFries, deepFriedPickles, macAndCheese, coleslaw];
      case 'drinks':
        return [softDrinks, lemonade, icedTea];
      case 'combos':
        return [familyPack, dateNightCombo, gameNightCombo];
      case 'deals':
        return [thirstyThursday, weekendSpecial, happyHour];
      case 'desserts':
        return [applePie, iceCream, cookies];
      default:
        return [placeholder];
    }
  }
}
