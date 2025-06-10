import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qsr_app/screens/menu_item_screen.dart';
import '../constants/typography.dart';
import '../constants/colors.dart';
import '../services/cart_service.dart';
import '../config/delivery_config.dart';

class MenuScreen extends StatelessWidget {
  final CartService cartService;
  final OrderType orderType;

  const MenuScreen({
    super.key,
    required this.cartService,
    this.orderType = OrderType.pickup,
  });

  final List<String> menuCategories = const [
    'Crew Packs',
    'Sandwiches',
    'Whole Wings',
    'Chicken Pieces',
    'Chicken Bites',
    'Sides',
    'Fixin\'s',
    'Sauces',
    'Beverages',
  ];

  @override
  Widget build(BuildContext context) {
    final orderTypeText = orderType == OrderType.pickup ? 'PICKUP' : 'DELIVERY';
    final orderTypeIcon = orderType == OrderType.pickup ? Icons.store : Icons.delivery_dining;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MENU',
              style: AppTypography.displaySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ).animate()
              .fadeIn(duration: const Duration(milliseconds: 600))
              .slideX(begin: -0.2, end: 0),
            Row(
              children: [
                Icon(
                  orderTypeIcon,
                  size: 16,
                  color: orderType == OrderType.pickup ? Colors.green : Colors.blue,
                ),
                const SizedBox(width: 4),
                Text(
                  orderTypeText,
                  style: TextStyle(
                    fontSize: 12,
                    color: orderType == OrderType.pickup ? Colors.green : Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        toolbarHeight: 80, // Increased height for better spacing
        titleSpacing: 20, // Better horizontal spacing
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive grid based on screen width
          int crossAxisCount;
          double childAspectRatio;

          if (constraints.maxWidth < 600) {
            // Mobile: 2 columns, taller cards for bigger images
            crossAxisCount = 2;
            childAspectRatio = 0.7; // Even taller for bigger images
          } else if (constraints.maxWidth < 900) {
            // Tablet: 3 columns
            crossAxisCount = 3;
            childAspectRatio = 0.75;
          } else {
            // Desktop: 4 columns
            crossAxisCount = 4;
            childAspectRatio = 0.8;
          }

          return CustomScrollView(
            slivers: [
              // Smart Ordering Tips Section
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CHEAT DAYTIPS:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF6B35),
                          letterSpacing: 0.5,
                        ),
                      ).animate()
                        .fadeIn()
                        .slideX(
                          begin: -0.2,
                          end: 0,
                          duration: const Duration(milliseconds: 600),
                        ),
                      const SizedBox(height: 12),
                      const Column(
                        children: [
                          SmartOrderingTip(index: 0, text: 'Pair 2-3 chicken pieces with pickled vegetables'),
                          SmartOrderingTip(index: 1, text: 'Extra Jalapeños & Pickles (cuz they\'re delish veggies!)'),
                          SmartOrderingTip(index: 2, text: 'Skip the bun and make it a protein-focused meal'),
                          SmartOrderingTip(index: 3, text: 'Choose "Whole Wings" — it\'s all protein!'),
                          SmartOrderingTip(index: 4, text: 'Grab hot sauce instead of creamy sauces to minimize calories'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Disclaimer
                      Text(
                        'While this menu isn\'t traditionally "diet-friendly," the high-quality protein source and customizable portions make it workable for flexible eating approaches when consumed mindfully.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                        .fadeIn(delay: const Duration(milliseconds: 800))
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          delay: const Duration(milliseconds: 800),
                          duration: const Duration(milliseconds: 600),
                        ),
                    ],
                  ),
                ),
              ),

              // Menu Categories Grid
              SliverPadding(
                padding: EdgeInsets.all(constraints.maxWidth < 600 ? 12.0 : 16.0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: constraints.maxWidth < 600 ? 12.0 : 16.0,
                    mainAxisSpacing: constraints.maxWidth < 600 ? 12.0 : 16.0,
                    childAspectRatio: childAspectRatio,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = menuCategories[index];
                      return MenuCategoryCard(
                        category: category,
                        index: index,
                        cartService: cartService,
                        isMobile: constraints.maxWidth < 600,
                      );
                    },
                    childCount: menuCategories.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MenuCategoryCard extends StatefulWidget {
  final String category;
  final int index;
  final CartService cartService;
  final bool isMobile;

  const MenuCategoryCard({
    Key? key,
    required this.category,
    required this.index,
    required this.cartService,
    this.isMobile = false,
  }) : super(key: key);

  @override
  State<MenuCategoryCard> createState() => _MenuCategoryCardState();
}

class _MenuCategoryCardState extends State<MenuCategoryCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(curve);

    _elevationAnimation = Tween<double>(
      begin: 3,
      end: 8,
    ).animate(curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHoverChanged(bool isHovered) {
    if (!mounted) return;
    setState(() {
      _isHovered = isHovered;
      if (isHovered) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'sandwiches':
        return Icons.lunch_dining;
      case 'whole wings':
        return Icons.local_fire_department;
      case 'chicken pieces':
        return Icons.restaurant;
      case 'chicken bites':
        return Icons.fastfood;
      case 'crew packs':
        return Icons.group;
      case 'sides':
        return Icons.rice_bowl;
      case 'fixin\'s':
        return Icons.add_circle;
      case 'sauces':
        return Icons.water_drop;
      case 'beverages':
        return Icons.local_drink;
      default:
        return Icons.restaurant_menu;
    }
  }

  String _getCategorySubtitle(String category) {
    switch (category.toLowerCase()) {
      case 'sandwiches':
        return 'Hearty & delicious';
      case 'whole wings':
        return 'Crispy & flavorful';
      case 'chicken pieces':
        return 'Classic favorites';
      case 'chicken bites':
        return 'Bite-sized goodness';
      case 'crew packs':
        return 'Perfect for sharing';
      case 'sides':
        return 'Perfect pairings';
      case 'fixin\'s':
        return 'Extra touches';
      case 'sauces':
        return 'Flavor enhancers';
      case 'beverages':
        return 'Thirst quenchers';
      default:
        return 'Delicious options';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _handleHoverChanged(true),
      onPointerUp: (_) => _handleHoverChanged(false),
      onPointerCancel: (_) => _handleHoverChanged(false),
      child: MouseRegion(
        onEnter: (_) => _handleHoverChanged(true),
        onExit: (_) => _handleHoverChanged(false),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MenuItemScreen(
                      category: widget.category,
                      cartService: widget.cartService,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      spreadRadius: 0,
                      blurRadius: _elevationAnimation.value + 4,
                      offset: Offset(0, _elevationAnimation.value / 2),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // Background gradient
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            AppColors.surfaceLight,
                          ],
                        ),
                      ),
                    ),

                    // Content
                    Column(
                      children: <Widget>[
                        // Full-width Image container at top (bigger)
                        Container(
                          width: double.infinity,
                          height: widget.isMobile ? 140 : 160,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary.withValues(alpha: 0.8),
                                AppColors.primary.withValues(alpha: 0.6),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  size: widget.isMobile ? 32 : 40,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                                SizedBox(height: widget.isMobile ? 4 : 8),
                                Text(
                                  widget.isMobile ? 'IMAGE' : 'IMAGE COMING SOON',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: widget.isMobile ? 10 : 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Text content below image (compact)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(widget.isMobile ? 6.0 : 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Category name
                                Flexible(
                                  child: Text(
                                    widget.category.toUpperCase(),
                                    style: AppTypography.headlineSmall.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: widget.isMobile ? 12 : 14,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: widget.isMobile ? 1.0 : 2.0),

                                // Subtitle
                                Flexible(
                                  child: Text(
                                    _getCategorySubtitle(widget.category).toUpperCase(),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: widget.isMobile ? 9 : 11,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) => Opacity(
                        opacity: _controller.value * 0.15,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate(
      delay: Duration(milliseconds: 100 * widget.index),
    ).fadeIn(
      duration: const Duration(milliseconds: 600),
    ).slideY(
      begin: 0.2,
      end: 0,
      curve: Curves.easeOutBack,
      duration: const Duration(milliseconds: 800),
    );
  }
}

class SmartOrderingTip extends StatelessWidget {
  final String text;
  final int index;

  const SmartOrderingTip({
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
          Container(
            margin: const EdgeInsets.only(top: 6, right: 12),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: Duration(milliseconds: 200 + (index * 100)))
      .slideX(
        begin: 0.2,
        end: 0,
        delay: Duration(milliseconds: 200 + (index * 100)),
        duration: const Duration(milliseconds: 600),
      );
  }
}
