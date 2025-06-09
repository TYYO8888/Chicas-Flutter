import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../constants/typography.dart';

// Accessible button with enhanced semantics
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final bool isEnabled;
  final ButtonStyle? style;
  final bool isElevated;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.isEnabled = true,
    this.style,
    this.isElevated = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget button;
    
    if (isElevated) {
      button = ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: style,
        child: child,
      );
    } else {
      button = TextButton(
        onPressed: isEnabled ? onPressed : null,
        style: style,
        child: child,
      );
    }

    return Semantics(
      label: semanticLabel,
      hint: tooltip,
      button: true,
      enabled: isEnabled,
      child: Tooltip(
        message: tooltip ?? '',
        child: button,
      ),
    );
  }
}

// Accessible card with enhanced semantics
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final String? semanticHint;
  final bool isButton;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.semanticHint,
    this.isButton = false,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: isButton,
      onTap: onTap,
      child: Card(
        margin: margin,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

// Accessible text with enhanced readability
class AccessibleText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final String? semanticLabel;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final bool isHeading;
  final bool isImportant;

  const AccessibleText(
    this.text, {
    super.key,
    this.style,
    this.semanticLabel,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.isHeading = false,
    this.isImportant = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? text,
      header: isHeading,
      liveRegion: isImportant,
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      ),
    );
  }
}

// Accessible menu item with enhanced semantics
class AccessibleMenuItem extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final VoidCallback? onTap;
  final Widget? leading;
  final bool isAvailable;
  final List<String>? allergens;
  final String? heatLevel;

  const AccessibleMenuItem({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    this.onTap,
    this.leading,
    this.isAvailable = true,
    this.allergens,
    this.heatLevel,
  });

  @override
  Widget build(BuildContext context) {
    final semanticLabel = _buildSemanticLabel();
    final semanticHint = _buildSemanticHint();

    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      enabled: isAvailable,
      onTap: onTap,
      child: AccessibleCard(
        onTap: isAvailable ? onTap : null,
        isButton: true,
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AccessibleText(
                    title.toUpperCase(),
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isAvailable ? null : Colors.grey,
                    ),
                    isHeading: true,
                  ),
                  const SizedBox(height: 4),
                  AccessibleText(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: isAvailable ? null : Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (allergens != null && allergens!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    AccessibleText(
                      'Contains: ${allergens!.join(', ')}',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                      semanticLabel: 'Allergen warning: Contains ${allergens!.join(', ')}',
                      isImportant: true,
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AccessibleText(
                  price,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  semanticLabel: 'Price: $price',
                ),
                if (heatLevel != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 4),
                      AccessibleText(
                        heatLevel!,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                        semanticLabel: 'Heat level: $heatLevel',
                      ),
                    ],
                  ),
                ],
                if (!isAvailable) ...[
                  const SizedBox(height: 4),
                  AccessibleText(
                    'UNAVAILABLE',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    semanticLabel: 'This item is currently unavailable',
                    isImportant: true,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _buildSemanticLabel() {
    final buffer = StringBuffer();
    buffer.write('Menu item: $title. ');
    buffer.write('$description. ');
    buffer.write('Price: $price. ');
    
    if (heatLevel != null) {
      buffer.write('Heat level: $heatLevel. ');
    }
    
    if (allergens != null && allergens!.isNotEmpty) {
      buffer.write('Allergen warning: Contains ${allergens!.join(', ')}. ');
    }
    
    if (!isAvailable) {
      buffer.write('Currently unavailable. ');
    }
    
    return buffer.toString();
  }

  String _buildSemanticHint() {
    if (!isAvailable) {
      return 'This item cannot be ordered at this time';
    }
    return 'Double tap to view details and add to cart';
  }
}

// Accessible form field with enhanced semantics
class AccessibleFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool required;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final bool readOnly;

  const AccessibleFormField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.required = false,
    this.suffixIcon,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final semanticLabel = required ? '$label (required)' : label;
    
    return Semantics(
      label: semanticLabel,
      hint: hint,
      textField: true,
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onTap: onTap,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixIcon: suffixIcon,
          helperText: required ? 'Required field' : null,
        ),
      ),
    );
  }
}

// Accessible navigation item
class AccessibleNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final int? badgeCount;

  const AccessibleNavItem({
    super.key,
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final semanticLabel = _buildSemanticLabel();
    
    return Semantics(
      label: semanticLabel,
      button: true,
      selected: isSelected,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Icon(
                    icon,
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary 
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  if (badgeCount != null && badgeCount! > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          badgeCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary 
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildSemanticLabel() {
    final buffer = StringBuffer();
    buffer.write('$label tab');
    
    if (isSelected) {
      buffer.write(', selected');
    }
    
    if (badgeCount != null && badgeCount! > 0) {
      buffer.write(', $badgeCount notifications');
    }
    
    return buffer.toString();
  }
}

// Accessible loading indicator
class AccessibleLoadingIndicator extends StatelessWidget {
  final String? message;
  final bool isVisible;

  const AccessibleLoadingIndicator({
    super.key,
    this.message,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    
    return Semantics(
      label: message ?? 'Loading',
      liveRegion: true,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              AccessibleText(
                message!,
                style: Theme.of(context).textTheme.bodyMedium,
                isImportant: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Accessible alert/snackbar
class AccessibleAlert extends StatelessWidget {
  final String message;
  final AlertType type;
  final VoidCallback? onDismiss;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AccessibleAlert({
    super.key,
    required this.message,
    this.type = AlertType.info,
    this.onDismiss,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final semanticLabel = '${type.name} alert: $message';
    
    return Semantics(
      label: semanticLabel,
      liveRegion: true,
      // Note: assertiveness is not available in current Flutter version
      // Will be handled by liveRegion property
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getBackgroundColor(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getBorderColor(context),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _getIcon(),
              color: _getIconColor(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AccessibleText(
                message,
                style: TextStyle(
                  color: _getTextColor(context),
                  fontWeight: FontWeight.w500,
                ),
                isImportant: type == AlertType.error,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(width: 12),
              AccessibleButton(
                onPressed: onAction,
                semanticLabel: actionLabel,
                isElevated: false,
                child: Text(actionLabel!),
              ),
            ],
            if (onDismiss != null) ...[
              const SizedBox(width: 8),
              AccessibleButton(
                onPressed: onDismiss,
                semanticLabel: 'Dismiss alert',
                isElevated: false,
                child: const Icon(Icons.close),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case AlertType.success:
        return Icons.check_circle;
      case AlertType.warning:
        return Icons.warning;
      case AlertType.error:
        return Icons.error;
      case AlertType.info:
        return Icons.info;
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (type) {
      case AlertType.success:
        return Colors.green.withValues(alpha: 0.1);
      case AlertType.warning:
        return Colors.orange.withValues(alpha: 0.1);
      case AlertType.error:
        return Colors.red.withValues(alpha: 0.1);
      case AlertType.info:
        return Colors.blue.withValues(alpha: 0.1);
    }
  }

  Color _getBorderColor(BuildContext context) {
    switch (type) {
      case AlertType.success:
        return Colors.green;
      case AlertType.warning:
        return Colors.orange;
      case AlertType.error:
        return Colors.red;
      case AlertType.info:
        return Colors.blue;
    }
  }

  Color _getIconColor(BuildContext context) {
    return _getBorderColor(context);
  }

  Color _getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }
}

enum AlertType { success, warning, error, info }

// Accessibility helper functions
class AccessibilityHelper {
  // Announce message to screen readers
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  // Check if screen reader is enabled
  static bool isScreenReaderEnabled(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  // Check if high contrast is enabled
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  // Get recommended minimum touch target size
  static double getMinimumTouchTargetSize() {
    return 48.0; // Material Design recommendation
  }

  // Ensure minimum touch target size
  static Widget ensureMinimumTouchTarget(Widget child) {
    return SizedBox(
      width: getMinimumTouchTargetSize(),
      height: getMinimumTouchTargetSize(),
      child: child,
    );
  }
}
