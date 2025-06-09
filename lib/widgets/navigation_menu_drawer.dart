import 'package:flutter/material.dart';
import '../screens/coming_soon_screen.dart';
import '../screens/notification_test_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/offline_indicator.dart';


class NavigationMenuDrawer extends StatelessWidget {
  const NavigationMenuDrawer({Key? key}) : super(key: key);

  void _navigateToComingSoon(BuildContext context, String featureName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComingSoonScreen(featureName: featureName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                // Header with close button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'NAVIGATION MENU',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Chica's Rewards Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.deepOrange.shade400),
                          const SizedBox(width: 8),
                          const Text(
                            "Chica's Rewards",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Save your order history and information for a faster checkout.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth - 32,
                        ),
                        child: ElevatedButton(
                          onPressed: () => _navigateToComingSoon(context, 'Login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            minimumSize: const Size.fromHeight(45),
                          ),
                          child: const Text('Log In'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth - 32,
                        ),
                        child: OutlinedButton(
                          onPressed: () => _navigateToComingSoon(context, 'Sign Up'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.deepOrange),
                            minimumSize: const Size.fromHeight(45),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(color: Colors.deepOrange),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Language Selection
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
                    trailing: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 130),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _navigateToComingSoon(context, 'Language Settings'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Français'),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'English',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Menu Items - Using constrained height to prevent overflow
                ...ListTile.divideTiles(
                  context: context,
                  tiles: [                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('My Account'),
                      onTap: () => _navigateToComingSoon(context, 'My Account'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.favorite_outline),
                      title: const Text('Favorites'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FavoritesScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.local_fire_department),
                      title: const Text('Special Offers'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      onTap: () => _navigateToComingSoon(context, 'Special Offers'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: const Text('Find a Restaurant'),
                      onTap: () => _navigateToComingSoon(context, 'Restaurant Locator'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.card_giftcard),
                      title: const Text('Rewards Program'),
                      onTap: () => _navigateToComingSoon(context, 'Rewards Program'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.local_offer_outlined),
                      title: const Text('Catering'),
                      onTap: () => _navigateToComingSoon(context, 'Catering'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.card_giftcard),
                      title: const Text('Gift Cards'),
                      onTap: () => _navigateToComingSoon(context, 'Gift Cards'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: const Text('Support & FAQ'),
                      onTap: () => _navigateToComingSoon(context, 'Support'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: const Text('Settings'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.api),
                      title: const Text('API Test'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'DEV',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/api-test');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text('Notification Test'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationTestScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Legal Terms & Policies Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'LEGAL TERMS & POLICIES',
                        style: TextStyle(
                          color: Colors.brown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: () => _navigateToComingSoon(context, 'Terms of Use'),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('Terms of Use'),
                        ),
                      ),
                      InkWell(
                        onTap: () => _navigateToComingSoon(context, 'Privacy Policy'),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('Privacy Policy'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}
