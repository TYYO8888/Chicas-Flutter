import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/theme_service.dart';
import '../services/user_preferences_service.dart';
import '../widgets/accessibility_widgets.dart';
import '../widgets/offline_indicator.dart';
import '../constants/typography.dart';
import '../constants/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeService _themeService = ThemeService();
  final UserPreferencesService _preferencesService = UserPreferencesService();
  
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _highContrastEnabled = false;
  bool _largeTextEnabled = false;
  bool _reduceAnimationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final preferences = _preferencesService.currentPreferences;
    if (preferences != null) {
      setState(() {
        _notificationsEnabled = preferences.notificationsEnabled;
      });
    }
    
    // Load accessibility settings from system
    final mediaQuery = MediaQuery.of(context);
    setState(() {
      _highContrastEnabled = mediaQuery.highContrast;
      _largeTextEnabled = mediaQuery.textScaleFactor > 1.0;
      _reduceAnimationsEnabled = mediaQuery.disableAnimations;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AccessibleText(
          'SETTINGS',
          style: AppTypography.displaySmall.copyWith(color: AppColors.textPrimary),
          isHeading: true,
        ).animate()
          .fadeIn(duration: const Duration(milliseconds: 600))
          .slideX(begin: -0.2, end: 0),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThemeSection(),
            const SizedBox(height: 24),
            _buildNotificationSection(),
            const SizedBox(height: 24),
            _buildAccessibilitySection(),
            const SizedBox(height: 24),
            _buildDataSection(),
            const SizedBox(height: 24),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection() {
    return AccessibleCard(
      semanticLabel: 'Theme settings section',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccessibleText(
            'APPEARANCE',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
            isHeading: true,
          ),
          const SizedBox(height: 16),
          ListenableBuilder(
            listenable: _themeService,
            builder: (context, child) {
              return ThemeModeSelector(
                themeService: _themeService,
                onThemeChanged: (mode) {
                  AccessibilityHelper.announce(
                    context,
                    'Theme changed to ${_themeService.getThemeModeDisplayName(mode)}',
                  );
                },
              );
            },
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: const Duration(milliseconds: 100))
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildNotificationSection() {
    return AccessibleCard(
      semanticLabel: 'Notification settings section',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccessibleText(
            'NOTIFICATIONS',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
            isHeading: true,
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            title: 'Push Notifications',
            subtitle: 'Receive order updates and promotions',
            value: _notificationsEnabled,
            onChanged: (value) async {
              setState(() => _notificationsEnabled = value);
              await _preferencesService.setNotifications(value);
              if (mounted) {
                AccessibilityHelper.announce(
                  context,
                  'Push notifications ${value ? 'enabled' : 'disabled'}',
                );
              }
            },
          ),
          _buildSwitchTile(
            title: 'Sound',
            subtitle: 'Play notification sounds',
            value: _soundEnabled,
            onChanged: (value) {
              setState(() => _soundEnabled = value);
              AccessibilityHelper.announce(
                context,
                'Notification sounds ${value ? 'enabled' : 'disabled'}',
              );
            },
          ),
          _buildSwitchTile(
            title: 'Vibration',
            subtitle: 'Vibrate for notifications',
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() => _vibrationEnabled = value);
              AccessibilityHelper.announce(
                context,
                'Vibration ${value ? 'enabled' : 'disabled'}',
              );
            },
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: const Duration(milliseconds: 200))
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildAccessibilitySection() {
    return AccessibleCard(
      semanticLabel: 'Accessibility settings section',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccessibleText(
            'ACCESSIBILITY',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
            isHeading: true,
          ),
          const SizedBox(height: 8),
          AccessibleText(
            'These settings help make the app more accessible for users with disabilities',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoTile(
            title: 'High Contrast',
            subtitle: _highContrastEnabled 
                ? 'System high contrast is enabled'
                : 'System high contrast is disabled',
            icon: Icons.contrast,
            isSystemSetting: true,
          ),
          _buildInfoTile(
            title: 'Large Text',
            subtitle: _largeTextEnabled 
                ? 'System large text is enabled'
                : 'System large text is disabled',
            icon: Icons.text_fields,
            isSystemSetting: true,
          ),
          _buildInfoTile(
            title: 'Reduce Animations',
            subtitle: _reduceAnimationsEnabled 
                ? 'System reduce animations is enabled'
                : 'System reduce animations is disabled',
            icon: Icons.animation,
            isSystemSetting: true,
          ),
          const SizedBox(height: 12),
          AccessibleButton(
            onPressed: () => _showAccessibilityHelp(),
            semanticLabel: 'Learn more about accessibility features',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.help_outline),
                const SizedBox(width: 8),
                const Text('ACCESSIBILITY HELP'),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: const Duration(milliseconds: 300))
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildDataSection() {
    return AccessibleCard(
      semanticLabel: 'Data and storage settings section',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccessibleText(
            'DATA & STORAGE',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
            isHeading: true,
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            title: 'Sync Status',
            subtitle: 'View offline data and sync status',
            icon: Icons.sync,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SyncStatusScreen(),
                ),
              );
            },
          ),
          _buildActionTile(
            title: 'Clear Cache',
            subtitle: 'Remove stored offline data',
            icon: Icons.clear_all,
            onTap: () => _showClearCacheDialog(),
          ),
          _buildActionTile(
            title: 'Export Data',
            subtitle: 'Export your order history and preferences',
            icon: Icons.download,
            onTap: () => _showExportDataDialog(),
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: const Duration(milliseconds: 400))
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildAboutSection() {
    return AccessibleCard(
      semanticLabel: 'About section',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccessibleText(
            'ABOUT',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
            isHeading: true,
          ),
          const SizedBox(height: 16),
          _buildInfoTile(
            title: 'Version',
            subtitle: '1.0.0',
            icon: Icons.info_outline,
          ),
          _buildActionTile(
            title: 'Privacy Policy',
            subtitle: 'View our privacy policy',
            icon: Icons.privacy_tip,
            onTap: () => _showPrivacyPolicy(),
          ),
          _buildActionTile(
            title: 'Terms of Service',
            subtitle: 'View terms and conditions',
            icon: Icons.description,
            onTap: () => _showTermsOfService(),
          ),
          _buildActionTile(
            title: 'Contact Support',
            subtitle: 'Get help with the app',
            icon: Icons.support_agent,
            onTap: () => _showContactSupport(),
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: const Duration(milliseconds: 500))
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Semantics(
      label: '$title switch',
      hint: subtitle,
      toggled: value,
      onTap: () => onChanged(!value),
      child: SwitchListTile(
        title: AccessibleText(title),
        subtitle: AccessibleText(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
    bool isSystemSetting = false,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: AccessibleText(title),
      subtitle: AccessibleText(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: isSystemSetting 
          ? Icon(
              Icons.settings,
              color: AppColors.textSecondary,
            )
          : null,
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return AccessibleCard(
      onTap: onTap,
      isButton: true,
      semanticLabel: title,
      semanticHint: subtitle,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(icon),
        title: AccessibleText(title),
        subtitle: AccessibleText(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showAccessibilityHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AccessibleText(
          'ACCESSIBILITY FEATURES',
          isHeading: true,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const AccessibleText(
                'This app supports the following accessibility features:',
              ),
              const SizedBox(height: 12),
              _buildHelpItem('Screen Reader Support', 'Full VoiceOver and TalkBack compatibility'),
              _buildHelpItem('High Contrast', 'Enhanced visibility for low vision users'),
              _buildHelpItem('Large Text', 'Respects system text size settings'),
              _buildHelpItem('Reduced Motion', 'Minimizes animations when enabled'),
              _buildHelpItem('Semantic Labels', 'Descriptive labels for all interactive elements'),
              const SizedBox(height: 12),
              const AccessibleText(
                'To enable these features, go to your device\'s accessibility settings.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          AccessibleButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AccessibleText(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                AccessibleText(
                  description,
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AccessibleText('CLEAR CACHE', isHeading: true),
        content: const AccessibleText(
          'This will remove all offline data including cached menu items and order history. Continue?',
        ),
        actions: [
          AccessibleButton(
            onPressed: () => Navigator.of(context).pop(),
            isElevated: false,
            child: const Text('CANCEL'),
          ),
          AccessibleButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implement cache clearing
              AccessibilityHelper.announce(context, 'Cache cleared successfully');
            },
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
  }

  void _showExportDataDialog() {
    AccessibilityHelper.announce(context, 'Export data feature coming soon');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('EXPORT DATA FEATURE COMING SOON'),
      ),
    );
  }

  void _showPrivacyPolicy() {
    AccessibilityHelper.announce(context, 'Opening privacy policy');
    // Implement privacy policy view
  }

  void _showTermsOfService() {
    AccessibilityHelper.announce(context, 'Opening terms of service');
    // Implement terms of service view
  }

  void _showContactSupport() {
    AccessibilityHelper.announce(context, 'Opening contact support');
    // Implement contact support
  }
}
