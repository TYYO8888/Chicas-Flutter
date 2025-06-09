import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qsr_app/screens/checkout_screen.dart';
import 'package:qsr_app/services/cart_service.dart';
import '../constants/typography.dart';
import '../constants/colors.dart';

class CartScreen extends StatefulWidget {
  final CartService cartService;

  const CartScreen({super.key, required this.cartService});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final total = widget.cartService.cart.items.fold<double>(
      0,
      (sum, item) => sum + (item.menuItem.price * item.quantity),
    );

    return Scaffold(
      appBar: AppBar(        title: Text(
          'Cart',
          style: AppTypography.displaySmall.copyWith(color: AppColors.textPrimary),
        ).animate()
          .fadeIn(duration: const Duration(milliseconds: 600))
          .slideX(begin: -0.2, end: 0),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              ).animate().fadeIn().scale(delay: const Duration(milliseconds: 200))
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.cartService.cart.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart_outlined, size: 64)
                            .animate()
                            .scale(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOutBack,
                            ),
                        const SizedBox(height: 16),
                        const Text(                          'Your cart is empty',
                          style: TextStyle(
                            fontFamily: 'MontserratBlack',
                            fontSize: 28,
                            height: 1.28,
                            color: AppColors.textSecondary,
                          ),
                        ).animate().fadeIn().slideY(begin: 0.2),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.cartService.cart.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = widget.cartService.cart.items[index];
                      return CartItemCard(
                        cartItem: cartItem,
                        index: index,
                        onDismissed: (direction) {
                          setState(() {
                            widget.cartService.removeItem(
                              cartItem.menuItem,
                              customizations: cartItem.customizations,
                            );
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${cartItem.menuItem.name} removed from cart'),
                              action: SnackBarAction(
                                label: 'UNDO',
                                onPressed: () {
                                  setState(() {
                                    widget.cartService.addToCart(
                                      cartItem.menuItem,
                                      customizations: cartItem.customizations,
                                    );
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          if (widget.cartService.cart.items.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ).animate().slideY(begin: 0.2).fadeIn(),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(
                          cart: widget.cartService.cart,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(                          'CHECKOUT',                          style: TextStyle(
                            fontFamily: 'MontserratBlack',
                            fontSize: 18,
                            height: 1.42,
                            letterSpacing: 0.1,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white),
                      ],
                    ),
                  ).animate().scale().fadeIn(delay: const Duration(milliseconds: 200)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class CartItemCard extends StatefulWidget {
  final dynamic cartItem;
  final int index;
  final Function(DismissDirection) onDismissed;

  const CartItemCard({
    Key? key,
    required this.cartItem,
    required this.index,
    required this.onDismissed,
  }) : super(key: key);

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard>
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
      end: 1.02,
    ).animate(curve);

    _elevationAnimation = Tween<double>(
      begin: 1,
      end: 6,
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

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.cartItem.menuItem.name + widget.index.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: widget.onDismissed,
      child: Listener(
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
              child: Card(
                margin: const EdgeInsets.all(8.0),
                elevation: _elevationAnimation.value,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.cartItem.menuItem.name,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (widget.cartItem.menuItem.selectedSauces?.isNotEmpty ?? false)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      'Sauces: ${widget.cartItem.menuItem.selectedSauces!.join(", ")}',
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${widget.cartItem.menuItem.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
    ).slideX(
      begin: 0.2,
      end: 0,
      curve: Curves.easeOutBack,
      duration: const Duration(milliseconds: 800),
    );
  }
}
