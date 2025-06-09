import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qsr_app/screens/menu_item_screen.dart';
import '../constants/typography.dart';
import '../constants/colors.dart';
import '../services/cart_service.dart';

class MenuScreen extends StatelessWidget {
  final CartService cartService;

  const MenuScreen({super.key, required this.cartService});

  final List<String> menuCategories = const [
    'Sandwiches',
    'Whole Wings',
    'Chicken Pieces',
    'Chicken Bites',
    'Crew Packs',
    'Sides',
    'Fixin\'s',
    'Sauces',
    'Beverages',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(      appBar: AppBar(
        title: Text(
          'Menu',
          style: AppTypography.displaySmall.copyWith(color: AppColors.textPrimary),
        ).animate()
          .fadeIn(duration: const Duration(milliseconds: 600))
          .slideX(begin: -0.2, end: 0),
        backgroundColor: Colors.white,
        elevation: 0,
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

          return GridView.builder(
            padding: EdgeInsets.all(constraints.maxWidth < 600 ? 12.0 : 16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: constraints.maxWidth < 600 ? 12.0 : 16.0,
              mainAxisSpacing: constraints.maxWidth < 600 ? 12.0 : 16.0,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: menuCategories.length,
            itemBuilder: (context, index) {
              final category = menuCategories[index];
              return MenuCategoryCard(
                category: category,
                index: index,
                cartService: cartService,
                isMobile: constraints.maxWidth < 600,
              );
            },
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
