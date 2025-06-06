import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../utils/animation_utils.dart';
import '../models/menu_item.dart';

class AnimatedMenuItemCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final bool isFavorite;
  final ValueChanged<bool> onFavoriteChanged;
  final int index;

  const AnimatedMenuItemCard({
    Key? key,
    required this.item,
    required this.onTap,
    required this.onAddToCart,
    required this.isFavorite,
    required this.onFavoriteChanged,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('menu-item-${item.id}'),
      onVisibilityChanged: (info) {
        // Trigger animation when item becomes visible
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(
                      item.imageUrl,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () => onFavoriteChanged(!isFavorite),
                    ).animate(target: isFavorite ? 1 : 0)
                      .scale(
                        duration: AnimationDurations.fast,
                        curve: GSAPCurves.backOut,
                      )
                      .rotate(
                        begin: 0,
                        end: 0.15,
                        duration: AnimationDurations.fast,
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
                      item.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: onAddToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Add to Cart'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate()
        .fadeIn(
          delay: Duration(milliseconds: (index * 100)),
          duration: AnimationDurations.normal,
        )
        .slideX(
          begin: 0.25,
          end: 0,
          delay: Duration(milliseconds: (index * 100)),
          duration: AnimationDurations.normal,
          curve: GSAPCurves.backOut,
        ),
    );
  }
}
