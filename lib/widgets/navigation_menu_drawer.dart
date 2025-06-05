import 'package:flutter/material.dart';
import '../screens/coming_soon_screen.dart';

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
        child: ListView(
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
                  ),
                ],
              ),
            ),
            const Divider(),

            // Chica's Rewards Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _navigateToComingSoon(context, 'Login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Log In'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _navigateToComingSoon(context, 'Sign Up'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.deepOrange),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
            const Divider(),

            // Language Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                trailing: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => _navigateToComingSoon(context, 'Language Settings'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
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

            // Menu Items
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('My Account'),
              onTap: () => _navigateToComingSoon(context, 'My Account'),
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
              leading: const Icon(Icons.help_outline),
              title: const Text('Support'),
              onTap: () => _navigateToComingSoon(context, 'Support'),
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: const Text('Gift Card'),
              onTap: () => _navigateToComingSoon(context, 'Gift Card'),
            ),
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Find a Restaurant'),
              onTap: () => _navigateToComingSoon(context, 'Restaurant Locator'),
            ),

            const SizedBox(height: 24),

            // Legal Terms & Policies Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  ListTile(
                    title: const Text('Terms of Use'),
                    dense: true,
                    visualDensity: const VisualDensity(vertical: -4),
                    contentPadding: EdgeInsets.zero,
                    onTap: () => _navigateToComingSoon(context, 'Terms of Use'),
                  ),
                  ListTile(
                    title: const Text('Privacy Policy'),
                    dense: true,
                    visualDensity: const VisualDensity(vertical: -4),
                    contentPadding: EdgeInsets.zero,
                    onTap: () => _navigateToComingSoon(context, 'Privacy Policy'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
