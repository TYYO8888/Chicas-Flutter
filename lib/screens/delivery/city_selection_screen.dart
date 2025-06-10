import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/delivery_config.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../services/navigation_service.dart';
import '../../screens/menu_screen.dart';
import '../../services/cart_service.dart';

/// 🏙️ City Selection Screen for Delivery and Pickup
///
/// Beautiful city-based selection with skyline graphics
/// Supports both delivery (3rd party links) and pickup (menu navigation)
class CitySelectionScreen extends StatefulWidget {
  final bool isPickup;

  const CitySelectionScreen({super.key, this.isPickup = false});

  @override
  State<CitySelectionScreen> createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<CitySelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            widget.isPickup ? 'PICKUP LOCATIONS' : 'DELIVERY LOCATIONS',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F5F5),
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87,
          size: 24,
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black87,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        widget.isPickup ? Icons.store : Icons.location_city,
                        color: const Color(0xFFFF6B35),
                        size: 48,
                      ),
                    ).animate()
                      .fadeIn(delay: const Duration(milliseconds: 300))
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1.0, 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                      ),
                    const SizedBox(height: 24),
                    Text(
                      'SELECT YOUR CITY',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ).animate()
                      .fadeIn(delay: const Duration(milliseconds: 500))
                      .slideY(
                        begin: -0.3,
                        end: 0,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutBack,
                      ),
                    const SizedBox(height: 12),
                    Text(
                      widget.isPickup
                        ? 'Choose your location for pickup'
                        : 'Choose your location for delivery',
                      style: TextStyle(
                        color: isDark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                        fontSize: 16,
                      ),
                    ).animate()
                      .fadeIn(delay: const Duration(milliseconds: 700))
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                      ),
                  ],
                ),
              ),

              // Cities Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: DeliveryConfig.getAvailableCities().length,
                    itemBuilder: (context, index) {
                      final cityName = DeliveryConfig.getAvailableCities()[index];
                      return _buildCityCard(context, cityName).animate()
                        .fadeIn(delay: Duration(milliseconds: 900 + (index * 100)))
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          delay: Duration(milliseconds: 900 + (index * 100)),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutBack,
                        )
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.0, 1.0),
                          delay: Duration(milliseconds: 900 + (index * 100)),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.elasticOut,
                        );
                    },
                  ),
                ),
              ),

              // Footer Info
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'More cities coming soon!',
                      style: TextStyle(
                        color: isDark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ).animate()
                      .fadeIn(delay: const Duration(milliseconds: 1200))
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Powered by UberEats & Skip The Dishes',
                      style: TextStyle(
                        color: isDark
                          ? Colors.grey[600]
                          : Colors.grey[500],
                        fontSize: 12,
                      ),
                    ).animate()
                      .fadeIn(delay: const Duration(milliseconds: 1400))
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 2, // Menu section (since this is part of ordering flow)
        onItemSelected: (index) {
          switch (index) {
            case 0:
              NavigationService.navigateToHome();
              break;
            case 1:
              NavigationService.navigateToScan();
              break;
            case 2:
              NavigationService.navigateToMenu();
              break;
            case 3:
              NavigationService.navigateToCart();
              break;
            case 4:
              NavigationService.navigateToMore();
              break;
          }
        },
      ),
    );
  }

  /// 🏙️ Build City Card with Skyline Design
  Widget _buildCityCard(BuildContext context, String cityName) {
    final isAvailable = DeliveryConfig.isCityAvailable(cityName);
    final skylineColor = DeliveryConfig.getCitySkylineColor(cityName);
    final estimatedTime = DeliveryConfig.getCityEstimatedTime(cityName);
    final description = DeliveryConfig.getCityDescription(cityName);
    final population = DeliveryConfig.getCityPopulation(cityName);
    
    return GestureDetector(
      onTap: () => _handleCitySelection(context, cityName), // Always allow pickup access
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isAvailable
                ? [
                    skylineColor.withValues(alpha: 0.8),
                    skylineColor.withValues(alpha: 0.6),
                    Colors.black.withValues(alpha: 0.8),
                  ]
                : [
                    Colors.grey[800]!,
                    Colors.grey[900]!,
                    Colors.black,
                  ],
          ),
          border: Border.all(
            color: isAvailable ? skylineColor.withValues(alpha: 0.5) : Colors.grey[700]!,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Skyline Background Pattern
            Positioned.fill(
              child: _buildSkylinePattern(skylineColor, isAvailable),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // City Name
                  Text(
                    cityName.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.7),
                          offset: const Offset(1, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  
                  // Population
                  if (population.isNotEmpty)
                    Text(
                      population,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? Colors.green.withValues(alpha: 0.8)
                          : Colors.orange.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isAvailable ? 'AVAILABLE' : 'COMING SOON',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Delivery Info
                  Text(
                    estimatedTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Coming Soon Overlay
            if (!isAvailable)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.access_time,
                      color: Colors.orange,
                      size: 32,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 🏗️ Build Skyline Pattern Background
  Widget _buildSkylinePattern(Color color, bool isAvailable) {
    return CustomPaint(
      painter: SkylinePainter(
        color: isAvailable ? color.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.2),
      ),
    );
  }

  /// 🚀 Handle City Selection - Pickup goes to menu, Delivery launches URL
  void _handleCitySelection(BuildContext context, String cityName) {
    if (widget.isPickup) {
      // For pickup, navigate to menu screen
      _showLoadingSnackBar(context, 'Loading $cityName menu...');

      // Navigate to menu screen for pickup
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MenuScreen(
            cartService: CartService(),
            orderType: OrderType.pickup,
          ),
        ),
      );
      return;
    }

    // For delivery, handle async URL launching
    _handleDeliverySelection(context, cityName);
  }

  /// 🚚 Handle Delivery Selection and Launch URL
  Future<void> _handleDeliverySelection(BuildContext context, String cityName) async {

    // For delivery, launch external URL
    final deliveryUrl = DeliveryConfig.getCityDeliveryUrl(cityName);
    final isAvailable = DeliveryConfig.isCityAvailable(cityName);

    if (!isAvailable) {
      _showErrorSnackBar(context, '$cityName delivery coming soon!');
      return;
    }

    if (deliveryUrl == null) {
      _showErrorSnackBar(context, 'Delivery URL not available for $cityName');
      return;
    }

    // Show loading indicator
    _showLoadingSnackBar(context, 'Opening $cityName delivery...');

    try {
      final uri = Uri.parse(deliveryUrl);

      // Try to launch the URL
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // If external app launch fails, try in-app browser
        final inAppLaunched = await launchUrl(
          uri,
          mode: LaunchMode.inAppBrowserView,
        );

        if (!inAppLaunched) {
          _showErrorSnackBar(context, 'Could not open delivery service for $cityName');
        }
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Error opening delivery service: ${e.toString()}');
    }
  }

  /// 📱 Show Loading SnackBar
  void _showLoadingSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// ❌ Show Error SnackBar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

/// 🎨 Custom Painter for City Skyline
class SkylinePainter extends CustomPainter {
  final Color color;

  SkylinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Create a simple skyline silhouette
    path.moveTo(0, size.height * 0.7);
    path.lineTo(size.width * 0.1, size.height * 0.7);
    path.lineTo(size.width * 0.1, size.height * 0.4);
    path.lineTo(size.width * 0.2, size.height * 0.4);
    path.lineTo(size.width * 0.2, size.height * 0.6);
    path.lineTo(size.width * 0.3, size.height * 0.6);
    path.lineTo(size.width * 0.3, size.height * 0.3);
    path.lineTo(size.width * 0.4, size.height * 0.3);
    path.lineTo(size.width * 0.4, size.height * 0.5);
    path.lineTo(size.width * 0.5, size.height * 0.5);
    path.lineTo(size.width * 0.5, size.height * 0.2);
    path.lineTo(size.width * 0.6, size.height * 0.2);
    path.lineTo(size.width * 0.6, size.height * 0.6);
    path.lineTo(size.width * 0.7, size.height * 0.6);
    path.lineTo(size.width * 0.7, size.height * 0.4);
    path.lineTo(size.width * 0.8, size.height * 0.4);
    path.lineTo(size.width * 0.8, size.height * 0.7);
    path.lineTo(size.width, size.height * 0.7);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
