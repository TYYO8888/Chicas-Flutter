import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/simple_offline_storage.dart';
import '../services/data_sync_service.dart';
import '../widgets/accessibility_widgets.dart';
import '../constants/typography.dart';
import '../constants/colors.dart';

class SyncStatusScreen extends StatefulWidget {
  const SyncStatusScreen({super.key});

  @override
  State<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends State<SyncStatusScreen> {
  final SimpleOfflineStorage _offlineStorage = SimpleOfflineStorage();
  final DataSyncService _syncService = DataSyncService();
  
  Map<String, dynamic> _syncStatus = {};
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadSyncStatus();
  }

  Future<void> _loadSyncStatus() async {
    setState(() => _isLoading = true);
    
    try {
      await _offlineStorage.initialize();
      final status = _offlineStorage.getSyncStatus();
      final isOnline = await _offlineStorage.isOnline();
      
      setState(() {
        _syncStatus = {
          ...status,
          'isOnline': isOnline,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _performSync() async {
    if (_isSyncing) return;
    
    setState(() => _isSyncing = true);
    
    try {
      await _syncService.performFullSync();
      await _loadSyncStatus();
      
      if (mounted) {
        AccessibilityHelper.announce(context, 'Sync completed successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SYNC COMPLETED SUCCESSFULLY'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        AccessibilityHelper.announce(context, 'Sync failed');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SYNC FAILED: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const AccessibleText('CLEAR CACHE', isHeading: true),
        content: const AccessibleText(
          'This will remove all cached data. The app will need to download fresh data when you go online. Continue?',
        ),
        actions: [
          AccessibleButton(
            onPressed: () => Navigator.of(context).pop(false),
            isElevated: false,
            child: const Text('CANCEL'),
          ),
          AccessibleButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _offlineStorage.clearCache();
        await _loadSyncStatus();
        
        if (mounted) {
          AccessibilityHelper.announce(context, 'Cache cleared successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('CACHE CLEARED SUCCESSFULLY'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('FAILED TO CLEAR CACHE: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AccessibleText(
          'SYNC STATUS',
          style: AppTypography.displaySmall.copyWith(color: AppColors.textPrimary),
          isHeading: true,
        ).animate()
          .fadeIn(duration: const Duration(milliseconds: 600))
          .slideX(begin: -0.2, end: 0),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const AccessibleLoadingIndicator(message: 'Loading sync status...')
          : RefreshIndicator(
              onRefresh: _loadSyncStatus,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildConnectionStatus(),
                    const SizedBox(height: 24),
                    _buildSyncActions(),
                    const SizedBox(height: 24),
                    _buildDataStatus(),
                    const SizedBox(height: 24),
                    _buildSyncHistory(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildConnectionStatus() {
    final isOnline = _syncStatus['isOnline'] ?? false;
    
    return AccessibleCard(
      semanticLabel: 'Connection status section',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOnline ? Icons.wifi : Icons.wifi_off,
                color: isOnline ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              AccessibleText(
                'CONNECTION STATUS',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                isHeading: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isOnline ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isOnline ? Colors.green : Colors.red,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isOnline ? Icons.check_circle : Icons.error,
                  color: isOnline ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AccessibleText(
                    isOnline ? 'ONLINE - Connected to server' : 'OFFLINE - Using cached data',
                    style: TextStyle(
                      color: isOnline ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                    semanticLabel: isOnline 
                        ? 'Status: Online. Connected to server'
                        : 'Status: Offline. Using cached data',
                    isImportant: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: const Duration(milliseconds: 100))
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildSyncActions() {
    final isOnline = _syncStatus['isOnline'] ?? false;
    
    return AccessibleCard(
      semanticLabel: 'Sync actions section',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccessibleText(
            'SYNC ACTIONS',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
            isHeading: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AccessibleButton(
                  onPressed: isOnline && !_isSyncing ? _performSync : null,
                  semanticLabel: _isSyncing 
                      ? 'Syncing data, please wait'
                      : isOnline 
                          ? 'Sync data now'
                          : 'Sync unavailable while offline',
                  child: _isSyncing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('SYNCING...'),
                          ],
                        )
                      : const Text('SYNC NOW'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AccessibleButton(
                  onPressed: _clearCache,
                  semanticLabel: 'Clear all cached data',
                  isElevated: false,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                  child: const Text('CLEAR CACHE'),
                ),
              ),
            ],
          ),
          if (!isOnline) ...[
            const SizedBox(height: 12),
            const AccessibleAlert(
              message: 'Sync is only available when connected to the internet',
              type: AlertType.info,
            ),
          ],
        ],
      ),
    ).animate()
      .fadeIn(delay: const Duration(milliseconds: 200))
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildDataStatus() {
    final menuItems = _syncStatus['menuItems'] ?? {};
    final categories = _syncStatus['categories'] ?? {};
    
    return AccessibleCard(
      semanticLabel: 'Cached data status section',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccessibleText(
            'CACHED DATA',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
            isHeading: true,
          ),
          const SizedBox(height: 16),
          _buildDataItem(
            'Menu Items',
            menuItems['recordCount'] ?? 0,
            menuItems['lastSync'],
            menuItems['hasCache'] ?? false,
          ),
          const SizedBox(height: 12),
          _buildDataItem(
            'Categories',
            categories['recordCount'] ?? 0,
            categories['lastSync'],
            categories['hasCache'] ?? false,
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: const Duration(milliseconds: 300))
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildDataItem(String name, int count, String? lastSync, bool hasCache) {
    final lastSyncDate = lastSync != null ? DateTime.tryParse(lastSync) : null;
    final timeAgo = lastSyncDate != null 
        ? _formatTimeAgo(lastSyncDate)
        : 'Never';
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasCache ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasCache ? Colors.green : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasCache ? Icons.check_circle : Icons.error_outline,
            color: hasCache ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AccessibleText(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                AccessibleText(
                  '$count items • Last sync: $timeAgo',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncHistory() {
    return AccessibleCard(
      semanticLabel: 'Sync history section',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccessibleText(
            'SYNC HISTORY',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
            isHeading: true,
          ),
          const SizedBox(height: 16),
          AccessibleText(
            'Recent sync activities will appear here when available.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: const Duration(milliseconds: 400))
      .slideY(begin: 0.2, end: 0);
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
