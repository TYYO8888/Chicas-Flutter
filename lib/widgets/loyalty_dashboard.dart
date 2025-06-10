import 'package:flutter/material.dart';
import '../models/loyalty_program.dart';
import '../services/loyalty_service_mock.dart';

/// 🏆 Loyalty Dashboard Widget
/// Displays loyalty points, tier progress, and rewards
class LoyaltyDashboard extends StatefulWidget {
  final String userId;

  const LoyaltyDashboard({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<LoyaltyDashboard> createState() => _LoyaltyDashboardState();
}

class _LoyaltyDashboardState extends State<LoyaltyDashboard> {
  final LoyaltyService _loyaltyService = LoyaltyService();
  
  LoyaltyAccount? _loyaltyAccount;
  TierProgress? _tierProgress;
  List<LoyaltyReward> _rewards = [];
  List<PointsTransaction> _recentTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoyaltyData();
  }

  /// 📊 Load all loyalty data
  Future<void> _loadLoyaltyData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _loyaltyService.getLoyaltyAccount(widget.userId),
        _loyaltyService.getTierProgress(widget.userId),
        _loyaltyService.getAvailableRewards(widget.userId),
        _loyaltyService.getPointsHistory(userId: widget.userId, limit: 5),
      ]);

      setState(() {
        _loyaltyAccount = results[0] as LoyaltyAccount;
        _tierProgress = results[1] as TierProgress;
        _rewards = results[2] as List<LoyaltyReward>;
        _recentTransactions = results[3] as List<PointsTransaction>;
      });
    } catch (e) {
      debugPrint('Failed to load loyalty data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_loyaltyAccount == null) {
      return const Center(
        child: Text('Failed to load loyalty information'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLoyaltyData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLoyaltyHeader(),
            const SizedBox(height: 24),
            _buildTierProgress(),
            const SizedBox(height: 24),
            _buildQuickStats(),
            const SizedBox(height: 24),
            _buildRewardsSection(),
            const SizedBox(height: 24),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  /// 🏆 Build loyalty header
  Widget _buildLoyaltyHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _loyaltyAccount!.tier.color,
            _loyaltyAccount!.tier.color.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _loyaltyAccount!.tier.color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _loyaltyAccount!.tier.icon,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            '${_loyaltyAccount!.tier.name} MEMBER',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_loyaltyAccount!.currentPoints} POINTS',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Worth \$${_loyaltyAccount!.dollarValue.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  /// 📈 Build tier progress
  Widget _buildTierProgress() {
    if (_tierProgress == null || _tierProgress!.isMaxTier) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'TIER PROGRESS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_tierProgress!.currentTier.name),
                Text(_tierProgress!.nextTier!.name),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _tierProgress!.progressPercentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(_tierProgress!.nextTier!.color),
            ),
            const SizedBox(height: 8),
            Text(
              '${_tierProgress!.pointsToNextTier} points to ${_tierProgress!.nextTier!.name}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// 📊 Build quick stats
  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Lifetime Points',
            '${_loyaltyAccount!.lifetimePoints}',
            Icons.stars,
            Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Orders',
            '${_loyaltyAccount!.totalOrders}',
            Icons.shopping_bag,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Member Days',
            '${_loyaltyAccount!.daysAsMember}',
            Icons.calendar_today,
            Colors.green,
          ),
        ),
      ],
    );
  }

  /// 📊 Build stat card
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 🎁 Build rewards section
  Widget _buildRewardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '🎁 AVAILABLE REWARDS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full rewards screen
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _rewards.take(5).length,
            itemBuilder: (context, index) {
              final reward = _rewards[index];
              return _buildRewardCard(reward);
            },
          ),
        ),
      ],
    );
  }

  /// 🎁 Build reward card
  Widget _buildRewardCard(LoyaltyReward reward) {
    final canAfford = _loyaltyAccount!.currentPoints >= reward.pointsCost;
    
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                reward.categoryIcon,
                size: 32,
                color: canAfford ? Theme.of(context).primaryColor : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                reward.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: canAfford ? null : Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                reward.description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${reward.pointsCost} pts',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: canAfford ? Theme.of(context).primaryColor : Colors.grey,
                    ),
                  ),
                  if (canAfford)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                      size: 16,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📋 Build recent activity
  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📋 RECENT ACTIVITY',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: _recentTransactions.isEmpty
                ? [
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'No recent activity',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ]
                : _recentTransactions
                    .map((transaction) => _buildTransactionTile(transaction))
                    .toList(),
          ),
        ),
      ],
    );
  }

  /// 📋 Build transaction tile
  Widget _buildTransactionTile(PointsTransaction transaction) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: transaction.color.withValues(alpha: 0.1),
        child: Icon(
          transaction.icon,
          color: transaction.color,
        ),
      ),
      title: Text(transaction.description),
      subtitle: Text(
        transaction.createdAt.toString().split(' ')[0], // Date only
      ),
      trailing: Text(
        '${transaction.isEarned ? '+' : ''}${transaction.points} pts',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: transaction.color,
        ),
      ),
    );
  }
}
