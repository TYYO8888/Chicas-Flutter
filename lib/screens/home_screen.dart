import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/animation_utils.dart';
import '../widgets/custom_carousel.dart';
import '../widgets/navigation_menu_drawer.dart';
import '../widgets/hot_deals_section.dart';
import '../widgets/personalized_recommendations_section.dart';
import '../screens/menu_item_screen.dart';
import '../services/cart_service.dart';


class HomeScreen extends StatefulWidget {
  final CartService cartService;

  const HomeScreen({Key? key, required this.cartService}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Placeholder carousel items
  final List<Map<String, String>> carouselItems = [
    {
      'title': 'Nashville Hot Chicken',
      'subtitle': 'Feel the heat!',
      'color': '#FF5722',
      'category': 'Chicken Pieces',
    },
    {
      'title': 'Crew Pack Special',
      'subtitle': 'Perfect for sharing',
      'color': '#F4511E',
      'category': 'CREW Combos',
    },
    {
      'title': 'Fresh Sides',
      'subtitle': 'Complete your meal',
      'color': '#E64A19',
      'category': 'Sides',
    },
  ];
  Widget _buildCarouselItem(Map<String, String> item) {
    return Container(
      decoration: BoxDecoration(
        color: Color(int.parse(item['color']!.replaceAll('#', '0xFF'))),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(int.parse(item['color']!.replaceAll('#', '0xFF'))),
            Color(int.parse(item['color']!.replaceAll('#', '0xFF'))).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(int.parse(item['color']!.replaceAll('#', '0xFF'))).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/CC-Penta-3.png',
              color: Colors.white.withOpacity(0.1),
              colorBlendMode: BlendMode.srcOver,
              fit: BoxFit.contain,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [                Text(
                  item['title']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ).animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: const Duration(seconds: 2)),
                const SizedBox(height: 8),
                Text(
                  item['subtitle']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ).animate()
                  .fadeIn(delay: const Duration(milliseconds: 300))
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    curve: GSAPCurves.backOut,
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenuItemScreen(
                          category: item['category']!,
                          cartService: widget.cartService,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(int.parse(item['color']!.replaceAll('#', '0xFF'))),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Order Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh logic
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top bar with menu and loyalty points
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Loyalty points widget
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber, Colors.orange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '1,250 pts',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Menu button
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                        tooltip: 'Open menu',
                      ),
                    ),
                  ],
                ),
              ),

              // Carousel Header
              CustomCarousel(
                height: 300,
                items: carouselItems.map((item) => _buildCarouselItem(item)).toList(),
              ).animate()
                .fadeIn(duration: AnimationDurations.normal)
                .slideX(
                  begin: -0.25,
                  end: 0,
                  duration: AnimationDurations.normal,
                  curve: GSAPCurves.power2InOut,
                ),

                // Smart Ordering Tips
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Smart Ordering Tips',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headlineSmall?.color,
                      ),
                    ).animate()
                      .fadeIn()
                      .slideX(
                        begin: -0.2,
                        end: 0,
                        duration: AnimationDurations.normal,
                        curve: GSAPCurves.power2InOut,
                      ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BulletPoint(index: 0, text: 'Use the online menu and place your order'),
                          BulletPoint(index: 1, text: 'Select a pickup store for faster service'),
                          BulletPoint(index: 2, text: 'Place an order without downloading an app'),
                          BulletPoint(index: 3, text: 'Skip the queue and collect at your preferred time'),
                          BulletPoint(index: 4, text: 'Save favorite combinations of items'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Hot Deals Section
              HotDealsSection(cartService: widget.cartService),

              // Personalized Recommendations Section
              PersonalizedRecommendationsSection(cartService: widget.cartService),

              // Bottom padding
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      endDrawer: const NavigationMenuDrawer(),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;
  final int index;

  const BulletPoint({
    Key? key,
    required this.text,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],      ),
    ).animate()
      .fadeIn(delay: Duration(milliseconds: index * 200))
      .slideX(
        begin: 0.2,
        end: 0,
        delay: Duration(milliseconds: index * 200),
        duration: AnimationDurations.normal,
        curve: GSAPCurves.backOut,
      );
  }
}
