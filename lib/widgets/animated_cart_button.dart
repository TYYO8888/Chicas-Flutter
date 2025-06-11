import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/animation_utils.dart';

class AnimatedCartButton extends StatelessWidget {
  final int itemCount;
  final VoidCallback onPressed;
  final bool isHighlighted;

  const AnimatedCartButton({
    Key? key,
    required this.itemCount,
    required this.onPressed,
    this.isHighlighted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: 28,
            ).animate(target: isHighlighted ? 1 : 0)
              .shake(duration: AnimationDurations.fast)
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.2, 1.2),
                duration: AnimationDurations.fast,
                curve: GSAPCurves.backOut,
              ),
            if (itemCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '$itemCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    duration: AnimationDurations.fast,
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    curve: GSAPCurves.backOut,
                  ),
              ),
          ],
        ),
      ),
    );
  }
}
