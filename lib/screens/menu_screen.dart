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
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.0,
        ),
        itemCount: menuCategories.length,
        itemBuilder: (context, index) {
          final category = menuCategories[index];
          return MenuCategoryCard(
            category: category,
            index: index,
            cartService: cartService,
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

  const MenuCategoryCard({
    Key? key,
    required this.category,
    required this.index,
    required this.cartService,
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
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: _elevationAnimation.value + 4,
                      offset: Offset(0, _elevationAnimation.value / 2),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // Icon/Image container
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                _getCategoryIcon(widget.category),
                                size: 40,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12.0),

                          // Category name
                          Text(
                            widget.category,
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4.0),

                          // Subtitle
                          Text(
                            _getCategorySubtitle(widget.category),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
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
