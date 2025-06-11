import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/user_preferences_service.dart';
import '../constants/colors.dart';

class FavoriteButton extends StatefulWidget {
  final String menuItemId;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final VoidCallback? onToggle;

  const FavoriteButton({
    super.key,
    required this.menuItemId,
    this.size = 24.0,
    this.activeColor,
    this.inactiveColor,
    this.onToggle,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  final UserPreferencesService _preferencesService = UserPreferencesService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _loadFavoriteStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadFavoriteStatus() {
    setState(() {
      _isFavorite = _preferencesService.isFavorite(widget.menuItemId);
    });
  }

  Future<void> _toggleFavorite() async {
    // Animate the button
    await _animationController.forward();
    await _animationController.reverse();

    // Toggle favorite status
    if (_isFavorite) {
      await _preferencesService.removeFromFavorites(widget.menuItemId);
    } else {
      await _preferencesService.addToFavorites(widget.menuItemId);
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });

    // Call the callback if provided
    widget.onToggle?.call();

    // Show feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite 
                ? 'ADDED TO FAVORITES' 
                : 'REMOVED FROM FAVORITES',
          ),
          backgroundColor: _isFavorite 
              ? AppColors.primary 
              : Colors.red,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              size: widget.size,
              color: _isFavorite 
                  ? (widget.activeColor ?? Colors.red)
                  : (widget.inactiveColor ?? Colors.grey),
            ),
            tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
          ),
        );
      },
    );
  }
}

class SaveOrderDialog extends StatefulWidget {
  final VoidCallback onSave;

  const SaveOrderDialog({
    super.key,
    required this.onSave,
  });

  @override
  State<SaveOrderDialog> createState() => _SaveOrderDialogState();
}

class _SaveOrderDialogState extends State<SaveOrderDialog> {
  final TextEditingController _nameController = TextEditingController();
  // final UserPreferencesService _preferencesService = UserPreferencesService();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('SAVE ORDER'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Give your order a name for easy reordering:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Order Name',
              hintText: 'e.g., "My Usual Order"',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
              Navigator.of(context).pop(_nameController.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('SAVE'),
        ),
      ],
    );
  }
}

class SaveOrderButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;

  const SaveOrderButton({
    super.key,
    this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: isEnabled ? onPressed : null,
      icon: Icon(
        Icons.bookmark_add,
        color: isEnabled ? AppColors.primary : Colors.grey,
      ),
      tooltip: 'Save current order',
    ).animate()
      .fadeIn(duration: const Duration(milliseconds: 300))
      .scale(delay: const Duration(milliseconds: 100));
  }
}

// Extension to add favorite functionality to existing widgets
extension FavoriteExtension on Widget {
  Widget withFavoriteButton(String menuItemId, {
    Alignment alignment = Alignment.topRight,
    double size = 24.0,
  }) {
    return Stack(
      children: [
        this,
        Positioned.fill(
          child: Align(
            alignment: alignment,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FavoriteButton(
                menuItemId: menuItemId,
                size: size,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
