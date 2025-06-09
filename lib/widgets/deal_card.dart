import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/menu_item.dart';
import '../constants/typography.dart';
import '../constants/colors.dart';

class DealCard extends StatefulWidget {
  final MenuItem deal;
  final VoidCallback onTap;
  final int index;

  const DealCard({
    Key? key,
    required this.deal,
    required this.onTap,
    this.index = 0,
  }) : super(key: key);

  @override
  State<DealCard> createState() => _DealCardState();
}

class _DealCardState extends State<DealCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _elevationAnimation;
  late final Animation<double> _buttonOffsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    final scaleCurve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(scaleCurve);

    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(scaleCurve);

    _buttonOffsetAnimation = Tween<double>(
      begin: 0.0,
      end: -2.0,
    ).animate(scaleCurve);
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
            child: Card(
              elevation: _elevationAnimation.value,
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      children: [                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  widget.deal.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Theme.of(context).cardColor,
                                      child: Icon(
                                        Icons.fastfood,
                                        size: 48,
                                        color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.5),
                                      ),
                                    );
                                  },
                                ),
                                AnimatedBuilder(
                                  animation: _controller,
                                  builder: (context, child) => Opacity(
                                    opacity: _controller.value * 0.15,
                                    child: Container(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (widget.deal.isSpecial)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),                              decoration: BoxDecoration(
                                color: AppColors.spiceRed,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'SPECIAL',
                                style: AppTypography.button.copyWith(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ).animate(onPlay: (controller) => controller.repeat())
                              .shimmer(
                                duration: const Duration(seconds: 2),
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.deal.name,
                            style: AppTypography.headlineSmall.copyWith(
                              color: Theme.of(context).textTheme.headlineSmall?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.deal.description,
                            style: AppTypography.bodyMedium.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          if (widget.deal.price > 0)
                            Text(
                              '\$${widget.deal.price.toStringAsFixed(2)}',                              style: AppTypography.headlineSmall.copyWith(
                                color: AppColors.chicaOrange,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _buttonOffsetAnimation.value),
                            child: ElevatedButton(
                              onPressed: widget.onTap,                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.chicaOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                elevation: _isHovered ? 6 : 2,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),                                    style: AppTypography.button.copyWith(
                                      fontSize: _isHovered ? 16 : 14,
                                      color: Colors.white,
                                    ),
                                    child: const Text('ORDER NOW'),
                                  ),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    transitionBuilder: (Widget child, Animation<double> animation) {
                                      return ScaleTransition(
                                        scale: animation,
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: _isHovered
                                        ? const Padding(
                                            padding: EdgeInsets.only(left: 8),
                                            child: Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
