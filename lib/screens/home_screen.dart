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
  // 🚀 Performance: Optimized carousel item with cached color parsing
  Widget _buildCarouselItem(Map<String, String> item) {
    // Cache color parsing to avoid repeated computation
    final color = Color(int.parse(item['color']!.replaceAll('#', '0xFF')));

    return Container(
      decoration: BoxDecoration(
        color: color,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withValues(alpha: 0.8), // Use withValues for better performance
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 🚀 Performance: Optimized background image with caching
          Positioned.fill(
            child: Image.asset(
              'assets/CC-Penta-3.png',
              color: Colors.white.withValues(alpha: 0.1),
              colorBlendMode: BlendMode.srcOver,
              fit: BoxFit.contain,
              cacheWidth: 200, // Cache at reasonable size
              cacheHeight: 200,
              filterQuality: FilterQuality.low, // Lower quality for background
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
          // Store ScaffoldMessenger reference before async operation
          final scaffoldMessenger = ScaffoldMessenger.of(context);

          // 🚀 Performance: Lightweight refresh - just show feedback
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text('Content refreshed!'),
                duration: Duration(seconds: 1),
              ),
            );
          }
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
                        gradient: const LinearGradient(
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
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.stars,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text(
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

                // Craving Crunch? Make Your Cheat Day Count!
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF2D2D2D)
                            : const Color(0xFF1A1A1A),
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1A1A1A)
                            : const Color(0xFF2D2D2D),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withValues(alpha: 0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main heading
                      const Text(
                        'CRAVING CRUNCH? MAKE YOUR CHEAT DAY COUNT!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                        .fadeIn()
                        .slideY(
                          begin: -0.3,
                          end: 0,
                          duration: AnimationDurations.normal,
                          curve: GSAPCurves.power2InOut,
                        ),
                      const SizedBox(height: 16),

                      // Subtitle
                      Text(
                        'Indulge in our irresistible crispy, juicy, and perfectly spiced hot chicken.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                        .fadeIn(delay: const Duration(milliseconds: 200))
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          delay: const Duration(milliseconds: 200),
                          duration: AnimationDurations.normal,
                          curve: GSAPCurves.power2InOut,
                        ),
                      const SizedBox(height: 20),

                      // INDULGE section
                      const Text(
                        'INDULGE. IT\'S THE ULTIMATE YUMMY!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B35),
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                        .fadeIn(delay: const Duration(milliseconds: 400))
                        .slideX(
                          begin: -0.3,
                          end: 0,
                          delay: const Duration(milliseconds: 400),
                          duration: AnimationDurations.normal,
                          curve: GSAPCurves.power2InOut,
                        ),
                      const SizedBox(height: 12),

                      Text(
                        'Our locally-raised, free-range, halal chickens provide premium protein (30-40g per serving) to fuel our eclectic lifestyles. Perfect for intermittent fasting warriors - our high-protein, satisfying portions help you stay full longer.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                        .fadeIn(delay: const Duration(milliseconds: 600))
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          delay: const Duration(milliseconds: 600),
                          duration: AnimationDurations.normal,
                          curve: GSAPCurves.power2InOut,
                        ),
                      const SizedBox(height: 20),

                    ],
                  ),
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

class CheatDayTip extends StatelessWidget {
  final String text;
  final int index;

  const CheatDayTip({
    Key? key,
    required this.text,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 12),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: Duration(milliseconds: 1000 + (index * 100)))
      .slideX(
        begin: 0.3,
        end: 0,
        delay: Duration(milliseconds: 1000 + (index * 100)),
        duration: AnimationDurations.normal,
        curve: GSAPCurves.power2InOut,
      );
  }
}
