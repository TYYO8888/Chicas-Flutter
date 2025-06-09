import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/app_theme.dart';
import '../services/user_preferences_service.dart';

enum ThemeMode { light, dark, system }

class ThemeService extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  bool _isSystemDarkMode = false;
  final UserPreferencesService _preferencesService = UserPreferencesService();

  // Singleton pattern
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isSystemDarkMode => _isSystemDarkMode;
  
  bool get isDarkMode {
    switch (_themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return _isSystemDarkMode;
    }
  }

  ThemeData get currentTheme {
    return isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
  }

  // Initialize theme service
  Future<void> initialize() async {
    await _loadThemeMode();
    _updateSystemBrightness();
  }

  // Load saved theme mode
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_themeModeKey);
      
      if (savedMode != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == savedMode,
          orElse: () => ThemeMode.system,
        );
      }

      // Also check user preferences service
      final userPrefs = _preferencesService.currentPreferences;
      if (userPrefs != null) {
        _themeMode = userPrefs.darkModeEnabled ? ThemeMode.dark : ThemeMode.light;
      }
    } catch (e) {
      print('Error loading theme mode: $e');
      _themeMode = ThemeMode.system;
    }
  }

  // Save theme mode
  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, _themeMode.toString());

      // Also update user preferences service
      if (_themeMode != ThemeMode.system) {
        await _preferencesService.setDarkMode(_themeMode == ThemeMode.dark);
      }
    } catch (e) {
      print('Error saving theme mode: $e');
    }
  }

  // Update system brightness
  void _updateSystemBrightness() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _isSystemDarkMode = brightness == Brightness.dark;
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await _saveThemeMode();
      _updateSystemUIOverlay();
      notifyListeners();
    }
  }

  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  // Update system UI overlay style based on current theme
  void _updateSystemUIOverlay() {
    final isDark = isDarkMode;
    
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  // Handle system brightness changes
  void handleSystemBrightnessChange(Brightness brightness) {
    final wasSystemDarkMode = _isSystemDarkMode;
    _isSystemDarkMode = brightness == Brightness.dark;
    
    if (_themeMode == ThemeMode.system && wasSystemDarkMode != _isSystemDarkMode) {
      _updateSystemUIOverlay();
      notifyListeners();
    }
  }

  // Get theme mode display name
  String getThemeModeDisplayName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  // Get current theme mode display name
  String get currentThemeModeDisplayName {
    return getThemeModeDisplayName(_themeMode);
  }

  // Get theme icon
  IconData getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  // Get current theme icon
  IconData get currentThemeIcon {
    return getThemeIcon(_themeMode);
  }

  // Check if high contrast is needed (accessibility)
  bool get isHighContrastNeeded {
    return MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first)
        .accessibleNavigation;
  }

  // Get high contrast theme
  ThemeData get highContrastTheme {
    if (isDarkMode) {
      return _getHighContrastDarkTheme();
    } else {
      return _getHighContrastLightTheme();
    }
  }

  // High contrast light theme
  ThemeData _getHighContrastLightTheme() {
    final baseTheme = AppTheme.lightTheme;
    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: Colors.black,
        secondary: Colors.black,
        surface: Colors.white,
        background: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black,
        onBackground: Colors.black,
      ),
      textTheme: baseTheme.textTheme.apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
      iconTheme: const IconThemeData(color: Colors.black),
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
    );
  }

  // High contrast dark theme
  ThemeData _getHighContrastDarkTheme() {
    final baseTheme = AppTheme.darkTheme;
    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: Colors.white,
        secondary: Colors.white,
        surface: Colors.black,
        background: Colors.black,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      textTheme: baseTheme.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    );
  }

  // Get effective theme (considering high contrast)
  ThemeData get effectiveTheme {
    if (isHighContrastNeeded) {
      return highContrastTheme;
    }
    return currentTheme;
  }

  // Theme transition animation
  Widget buildThemeTransition({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return AnimatedTheme(
      data: effectiveTheme,
      duration: duration,
      child: child,
    );
  }

  // Dispose resources
  @override
  void dispose() {
    super.dispose();
  }
}

// Theme mode selector widget
class ThemeModeSelector extends StatelessWidget {
  final ThemeService themeService;
  final Function(ThemeMode)? onThemeChanged;

  const ThemeModeSelector({
    super.key,
    required this.themeService,
    this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THEME',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...ThemeMode.values.map((mode) => RadioListTile<ThemeMode>(
          title: Row(
            children: [
              Icon(themeService.getThemeIcon(mode)),
              const SizedBox(width: 12),
              Text(themeService.getThemeModeDisplayName(mode)),
            ],
          ),
          value: mode,
          groupValue: themeService.themeMode,
          onChanged: (ThemeMode? value) {
            if (value != null) {
              themeService.setThemeMode(value);
              onThemeChanged?.call(value);
            }
          },
          activeColor: Theme.of(context).colorScheme.primary,
        )).toList(),
      ],
    );
  }
}

// Quick theme toggle button
class ThemeToggleButton extends StatelessWidget {
  final ThemeService themeService;

  const ThemeToggleButton({
    super.key,
    required this.themeService,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => themeService.toggleTheme(),
      icon: Icon(themeService.currentThemeIcon),
      tooltip: 'Toggle ${themeService.isDarkMode ? 'Light' : 'Dark'} Mode',
    );
  }
}
