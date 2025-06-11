import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/unified_loyalty_service.dart';
import '../models/loyalty_program.dart';

/// 🏆 Unified Loyalty Dashboard Widget
/// 
/// Displays comprehensive loyalty information including:
/// - Current points and tier status
/// - Game-earned vs purchase-earned points breakdown
/// - Daily challenges and streak information
/// - Active multiplier events
/// - Recent transactions with source tracking
class UnifiedLoyaltyDashboard extends StatefulWidget {
  final String userId;

  const UnifiedLoyaltyDashboard({
    super.key,
    required this.userId,
  });

  @override
  State<UnifiedLoyaltyDashboard> createState() => _UnifiedLoyaltyDashboardState();
}

class _UnifiedLoyaltyDashboardState extends State<UnifiedLoyaltyDashboard> {
  final UnifiedLoyaltyService _loyaltyService = UnifiedLoyaltyService();
  LoyaltyAccount? _account;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoyaltyData();
  }

  Future<void> _loadLoyaltyData() async {
    try {
      await _loyaltyService.initialize();
      final account = await _loyaltyService.getLoyaltyAccount(widget.userId);
      setState(() {
        _account = account;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
        ),
      );
    }

    if (_account == null) {
      return const Center(
        child: Text('Unable to load loyalty information'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main loyalty card
          _buildLoyaltyCard(),
          const SizedBox(height: 20),
          
          // Points breakdown
          _buildPointsBreakdown(),
          const SizedBox(height: 20),
          
          // Daily challenges
          _buildDailyChallenges(),
          const SizedBox(height: 20),
          
          // Active events
          _buildActiveEvents(),
          const SizedBox(height: 20),
          
          // Recent transactions
          _buildRecentTransactions(),
        ],
      ),
    );
  }

  Widget _buildLoyaltyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getTierColor(_account!.tier),
            _getTierColor(_account!.tier).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getTierColor(_account!.tier).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_account!.currentPoints}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'LOYALTY POINTS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _account!.tier.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Worth \$${_account!.dollarValue.toStringAsFixed(2)} • ${_account!.daysAsMember} days member',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn()
      .slideY(begin: -0.2, end: 0);
  }

  Widget _buildPointsBreakdown() {
    final gamePoints = _getGamePointsToday();
    final purchasePoints = _getPurchasePointsToday();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TODAY\'S POINTS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPointsSource(
                  icon: Icons.sports_esports,
                  label: 'Games',
                  points: gamePoints,
                  color: const Color(0xFFFF6B35),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPointsSource(
                  icon: Icons.shopping_bag,
                  label: 'Purchases',
                  points: purchasePoints,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: gamePoints / 500, // Daily game limit
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
          ),
          const SizedBox(height: 8),
          Text(
            'Daily game limit: $gamePoints/500 points',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: const Duration(milliseconds: 200))
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildPointsSource({
    required IconData icon,
    required String label,
    required int points,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            '$points',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChallenges() {
    final challenges = _loyaltyService.getDailyChallenges();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 DAILY CHALLENGES',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          ...challenges.map((challenge) => _buildChallengeItem(challenge)),
        ],
      ),
    ).animate()
      .fadeIn(delay: const Duration(milliseconds: 400))
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildChallengeItem(DailyChallenge challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: challenge.isCompleted 
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: challenge.isCompleted 
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            challenge.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: challenge.isCompleted ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  challenge.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${challenge.pointsReward}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: challenge.isCompleted ? Colors.green : const Color(0xFFFF6B35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveEvents() {
    final multiplierEvent = _loyaltyService.getActiveMultiplierEvent();
    final streak = _loyaltyService.currentStreak;
    
    if (multiplierEvent == null && streak <= 1) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚡ ACTIVE BONUSES',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          
          if (multiplierEvent != null && multiplierEvent.isActive) ...[
            _buildEventItem(
              icon: Icons.flash_on,
              title: multiplierEvent.name,
              description: multiplierEvent.description,
              color: Colors.yellow,
            ),
          ],
          
          if (streak > 1) ...[
            _buildEventItem(
              icon: Icons.local_fire_department,
              title: '$streak-Day Streak',
              description: 'Keep playing daily for bigger bonuses!',
              color: Colors.orange,
            ),
          ],
        ],
      ),
    ).animate()
      .fadeIn(delay: const Duration(milliseconds: 600))
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildEventItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final transactions = _loyaltyService.transactionHistory.take(5).toList();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 RECENT ACTIVITY',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          
          if (transactions.isEmpty) ...[
            const Text(
              'No recent activity',
              style: TextStyle(color: Colors.grey),
            ),
          ] else ...[
            ...transactions.map((transaction) => _buildTransactionItem(transaction)),
          ],
        ],
      ),
    ).animate()
      .fadeIn(delay: const Duration(milliseconds: 800))
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildTransactionItem(PointsTransaction transaction) {
    final isPositive = transaction.points > 0;
    final icon = _getTransactionIcon(transaction.type);
    final color = isPositive ? Colors.green : Colors.red;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                Text(
                  _formatDate(transaction.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : ''}${transaction.points}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getTierColor(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.bronze:
        return const Color(0xFFCD7F32);
      case LoyaltyTier.silver:
        return const Color(0xFFC0C0C0);
      case LoyaltyTier.gold:
        return const Color(0xFFFFD700);
      case LoyaltyTier.platinum:
        return const Color(0xFFE5E4E2);
      case LoyaltyTier.diamond:
        return const Color(0xFFB9F2FF);
    }
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'game_completion':
        return Icons.sports_esports;
      case 'purchase':
        return Icons.shopping_bag;
      case 'daily_challenge':
        return Icons.emoji_events;
      case 'streak_bonus':
        return Icons.local_fire_department;
      case 'multiplier_bonus':
        return Icons.flash_on;
      case 'redemption':
        return Icons.redeem;
      default:
        return Icons.star;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  int _getGamePointsToday() {
    return _loyaltyService.dailyGamePointsEarned;
  }

  int _getPurchasePointsToday() {
    final today = DateTime.now();
    return _loyaltyService.transactionHistory
        .where((t) =>
            t.type == 'purchase' &&
            t.createdAt.year == today.year &&
            t.createdAt.month == today.month &&
            t.createdAt.day == today.day)
        .fold(0, (sum, t) => sum + t.points);
  }
}
