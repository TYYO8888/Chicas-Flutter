import 'package:flutter/material.dart';
import '../config/delivery_config.dart';
import '../screens/delivery/city_selection_screen.dart';
import '../services/cart_service.dart';

/// 🍽️ Order Type Selection Screen
/// First screen users see - choose between pickup or delivery
class OrderTypeSelectionScreen extends StatefulWidget {
  final CartService? cartService;

  const OrderTypeSelectionScreen({super.key, this.cartService});

  @override
  State<OrderTypeSelectionScreen> createState() => _OrderTypeSelectionScreenState();
}

class _OrderTypeSelectionScreenState extends State<OrderTypeSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Hover states for cards
  bool _isPickupHovered = false;
  bool _isPickupPressed = false;
  bool _isDeliveryHovered = false;
  bool _isDeliveryPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 🏪 Handle pickup selection - now goes to city selection like delivery
  void _selectPickup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CitySelectionScreen(isPickup: true),
      ),
    );
  }

  /// 🚚 Handle delivery selection
  void _selectDelivery() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CitySelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
              ? [
                  const Color(0xFF1A1A1A), // Dark background
                  const Color(0xFF2D2D2D), // Slightly lighter dark
                  const Color(0xFF1A1A1A), // Back to dark
                ]
              : [
                  const Color(0xFFF5F5F5), // Light background
                  const Color(0xFFE0E0E0), // Slightly darker light
                  const Color(0xFFF5F5F5), // Back to light
                ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                               MediaQuery.of(context).padding.top -
                               MediaQuery.of(context).padding.bottom - 40,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildOrderTypeOptions(),
                      const SizedBox(height: 30),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🎯 Build header section
  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        const SizedBox(height: 20),
        // Beautiful logo with gradient and glow effect
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF6B35), // Orange
                Color(0xFFFF8E53), // Lighter orange
                Color(0xFFFFB74D), // Golden
              ],
            ),
            borderRadius: BorderRadius.circular(70),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B35).withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 15),
                spreadRadius: 5,
              ),
              BoxShadow(
                color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.restaurant_menu,
            size: 70,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 32),
        // App title with gradient text effect
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFFFF6B35),
              Color(0xFFFFB74D),
              Color(0xFFFF6B35),
            ],
          ).createShader(bounds),
          child: Text(
            "CHICA'S CHICKEN",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: 3,
              shadows: [
                Shadow(
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                  color: isDark ? Colors.black26 : Colors.grey.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isDark
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            'HOW WOULD YOU LIKE TO ORDER?',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  /// 🍽️ Build order type options with consistent card sizes and animations
  Widget _buildOrderTypeOptions() {
    return Column(
      children: [
        // Animated pickup card
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          )),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              height: 180, // Reduced height to prevent overflow
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildPickupOption(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Animated delivery card with delay
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
          )),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              height: 180, // Same reduced height for consistency
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildDeliveryOption(),
            ),
          ),
        ),
      ],
    );
  }

  /// 🏪 Build pickup option - always accessible
  Widget _buildPickupOption() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAvailable = DeliveryConfig.isPickupAvailable;

    return MouseRegion(
      onEnter: (_) => setState(() => _isPickupHovered = true),
      onExit: (_) => setState(() => _isPickupHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPickupPressed = true),
        onTapUp: (_) => setState(() => _isPickupPressed = false),
        onTapCancel: () => setState(() => _isPickupPressed = false),
        onTap: _selectPickup, // Always accessible for menu browsing
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(_isPickupPressed ? 0.95 : (_isPickupHovered ? 1.02 : 1.0)),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4CAF50), // Always green - always accessible
                Color(0xFF66BB6A), // Lighter green
                Color(0xFF4CAF50), // Back to green
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                blurRadius: _isPickupHovered ? 25 : 20,
                offset: Offset(0, _isPickupHovered ? 15 : 10),
                spreadRadius: _isPickupHovered ? 4 : 2,
              ),
              if (!isDark)
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: _isPickupHovered ? 20 : 15,
                  offset: Offset(0, _isPickupHovered ? 8 : 5),
                ),
            ],
          ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with glow effect
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.store_outlined,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Title
            const Text(
              'PICKUP',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    offset: Offset(0, 2),
                    blurRadius: 4,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Status - always shows "Browse Menu"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isAvailable ? 'READY IN 15-25 MIN' : 'BROWSE MENU ANYTIME',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              'SELECT YOUR PICKUP LOCATION',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  /// 🚚 Build delivery option
  Widget _buildDeliveryOption() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final availableCities = DeliveryConfig.getAvailableCitiesOnly();

    return MouseRegion(
      onEnter: (_) => setState(() => _isDeliveryHovered = true),
      onExit: (_) => setState(() => _isDeliveryHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isDeliveryPressed = true),
        onTapUp: (_) => setState(() => _isDeliveryPressed = false),
        onTapCancel: () => setState(() => _isDeliveryPressed = false),
        onTap: _selectDelivery,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(_isDeliveryPressed ? 0.95 : (_isDeliveryHovered ? 1.02 : 1.0)),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2196F3), // Blue
                Color(0xFF42A5F5), // Lighter blue
                Color(0xFF1976D2), // Darker blue
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2196F3).withValues(alpha: 0.4),
                blurRadius: _isDeliveryHovered ? 25 : 20,
                offset: Offset(0, _isDeliveryHovered ? 15 : 10),
                spreadRadius: _isDeliveryHovered ? 4 : 2,
              ),
              if (!isDark)
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: _isDeliveryHovered ? 20 : 15,
                  offset: Offset(0, _isDeliveryHovered ? 8 : 5),
                ),
            ],
          ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with glow effect
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.delivery_dining_outlined,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Title
            const Text(
              'DELIVERY',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    offset: Offset(0, 2),
                    blurRadius: 4,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Cities count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${availableCities.length} CITIES AVAILABLE',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              'SELECT YOUR CITY FOR DELIVERY',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  /// 📍 Build footer
  Widget _buildFooter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isDark
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.black.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        'Choose your preferred ordering method to continue',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: isDark
            ? Colors.white.withValues(alpha: 0.9)
            : Colors.black.withValues(alpha: 0.8),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
