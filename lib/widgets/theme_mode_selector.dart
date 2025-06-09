import 'package:flutter/material.dart';
import '../services/theme_service.dart' as theme_service;
import '../widgets/accessibility_widgets.dart';
import '../constants/typography.dart';

class ThemeModeSelector extends StatelessWidget {
  final theme_service.ThemeService themeService;
  final Function(theme_service.ThemeMode)? onThemeChanged;

  const ThemeModeSelector({
    super.key,
    required this.themeService,
    this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildThemeOption(
          context,
          theme_service.ThemeMode.light,
          'Light Mode',
          'Bright theme with light backgrounds',
          Icons.light_mode,
        ),
        const SizedBox(height: 12),
        _buildThemeOption(
          context,
          theme_service.ThemeMode.dark,
          'Dark Mode',
          'Dark theme for low-light environments',
          Icons.dark_mode,
        ),
        const SizedBox(height: 12),
        _buildThemeOption(
          context,
          theme_service.ThemeMode.system,
          'System Default',
          'Follow device theme settings',
          Icons.settings_system_daydream,
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    theme_service.ThemeMode mode,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = themeService.themeMode == mode;
    
    return AccessibleCard(
      onTap: () => _selectTheme(mode),
      isButton: true,
      semanticLabel: '$title theme option',
      semanticHint: description + (isSelected ? '. Currently selected' : '. Tap to select'),
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : null,
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isSelected 
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          title: AccessibleText(
            title,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
          ),
          subtitle: AccessibleText(
            description,
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          trailing: isSelected
              ? Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                )
              : Icon(
                  Icons.radio_button_unchecked,
                  color: Colors.grey.withValues(alpha: 0.5),
                ),
          onTap: () => _selectTheme(mode),
        ),
      ),
    );
  }

  void _selectTheme(theme_service.ThemeMode mode) {
    themeService.setThemeMode(mode);
    onThemeChanged?.call(mode);
  }
}

// Quick theme toggle button for easy switching
class ThemeToggleButton extends StatelessWidget {
  final theme_service.ThemeService themeService;

  const ThemeToggleButton({
    super.key,
    required this.themeService,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibleButton(
      onPressed: _toggleTheme,
      semanticLabel: 'Toggle between light and dark theme',
      tooltip: 'Switch Theme',
      child: Icon(
        _getThemeIcon(),
        size: 24,
      ),
    );
  }

  IconData _getThemeIcon() {
    switch (themeService.themeMode) {
      case theme_service.ThemeMode.light:
        return Icons.dark_mode;
      case theme_service.ThemeMode.dark:
        return Icons.light_mode;
      case theme_service.ThemeMode.system:
        return Icons.settings_system_daydream;
    }
  }

  void _toggleTheme() {
    switch (themeService.themeMode) {
      case theme_service.ThemeMode.light:
        themeService.setThemeMode(theme_service.ThemeMode.dark);
        break;
      case theme_service.ThemeMode.dark:
        themeService.setThemeMode(theme_service.ThemeMode.light);
        break;
      case theme_service.ThemeMode.system:
        themeService.setThemeMode(theme_service.ThemeMode.light);
        break;
    }
  }
}

// Theme preview widget
class ThemePreview extends StatelessWidget {
  final theme_service.ThemeMode themeMode;
  final bool isSelected;

  const ThemePreview({
    super.key,
    required this.themeMode,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary 
              : Colors.grey.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Column(
          children: [
            // App bar preview
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                color: _getAppBarColor(),
                child: Center(
                  child: Container(
                    width: 20,
                    height: 2,
                    color: _getTextColor(),
                  ),
                ),
              ),
            ),
            // Body preview
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: _getBackgroundColor(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 2,
                      color: _getTextColor(),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 20,
                      height: 2,
                      color: _getTextColor().withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (themeMode) {
      case theme_service.ThemeMode.light:
        return Colors.white;
      case theme_service.ThemeMode.dark:
        return const Color(0xFF121212);
      case theme_service.ThemeMode.system:
        return Colors.grey.shade100;
    }
  }

  Color _getAppBarColor() {
    switch (themeMode) {
      case theme_service.ThemeMode.light:
        return Colors.white;
      case theme_service.ThemeMode.dark:
        return const Color(0xFF1E1E1E);
      case theme_service.ThemeMode.system:
        return Colors.grey.shade200;
    }
  }

  Color _getTextColor() {
    switch (themeMode) {
      case theme_service.ThemeMode.light:
        return Colors.black;
      case theme_service.ThemeMode.dark:
        return Colors.white;
      case theme_service.ThemeMode.system:
        return Colors.black54;
    }
  }
}

// Animated theme transition widget
class ThemeTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const ThemeTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: child,
    );
  }
}
