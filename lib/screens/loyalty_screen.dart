import 'package:flutter/material.dart';
import '../widgets/unified_loyalty_dashboard.dart';

/// 🏆 Loyalty Screen
/// Main screen for loyalty program features
class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({Key? key}) : super(key: key);

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  // Mock user ID for testing - in production this would come from auth service
  static const String _userId = 'test_user_123';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 LOYALTY REWARDS'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigate to full transaction history
              _showTransactionHistory();
            },
            tooltip: 'Transaction History',
          ),
          IconButton(
            icon: const Icon(Icons.card_giftcard),
            onPressed: () {
              // Navigate to rewards catalog
              _showRewardsCatalog();
            },
            tooltip: 'Rewards Catalog',
          ),
        ],
      ),
      body: const UnifiedLoyaltyDashboard(
        userId: _userId,
      ),
    );
  }

  /// 📋 Show transaction history
  void _showTransactionHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.history, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text(
                      'Transaction History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Transaction list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: 10, // Mock data
                  itemBuilder: (context, index) => _buildTransactionTile(index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎁 Show rewards catalog
  void _showRewardsCatalog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.6,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.card_giftcard, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text(
                      'Rewards Catalog',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Rewards grid
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 8, // Mock data
                  itemBuilder: (context, index) => _buildRewardCard(index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📋 Build transaction tile
  Widget _buildTransactionTile(int index) {
    final isEarned = index % 2 == 0;
    final points = isEarned ? 25 : -50;
    final description = isEarned 
        ? 'Points earned from order #${1000 + index}'
        : 'Points redeemed for discount';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isEarned 
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.orange.withValues(alpha: 0.1),
          child: Icon(
            isEarned ? Icons.add : Icons.remove,
            color: isEarned ? Colors.green : Colors.orange,
          ),
        ),
        title: Text(description),
        subtitle: Text('${DateTime.now().subtract(Duration(days: index)).toString().split(' ')[0]}'),
        trailing: Text(
          '${isEarned ? '+' : ''}$points pts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isEarned ? Colors.green : Colors.orange,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  /// 🎁 Build reward card
  Widget _buildRewardCard(int index) {
    final rewards = [
      {'name': 'Free Drink', 'points': 500, 'icon': Icons.local_drink, 'color': Colors.blue},
      {'name': 'Free Side', 'points': 750, 'icon': Icons.restaurant, 'color': Colors.green},
      {'name': '10% Off', 'points': 1000, 'icon': Icons.discount, 'color': Colors.orange},
      {'name': 'Free Sandwich', 'points': 1500, 'icon': Icons.lunch_dining, 'color': Colors.red},
      {'name': 'Free Dessert', 'points': 600, 'icon': Icons.cake, 'color': Colors.pink},
      {'name': '15% Off', 'points': 1250, 'icon': Icons.percent, 'color': Colors.purple},
      {'name': 'Free Combo', 'points': 2000, 'icon': Icons.fastfood, 'color': Colors.indigo},
      {'name': 'Birthday Special', 'points': 0, 'icon': Icons.celebration, 'color': Colors.amber},
    ];

    final reward = rewards[index % rewards.length];
    final canAfford = index < 3; // Mock affordability

    return Card(
      elevation: canAfford ? 4 : 1,
      child: InkWell(
        onTap: canAfford ? () => _redeemReward(reward) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                reward['icon'] as IconData,
                size: 48,
                color: canAfford 
                    ? reward['color'] as Color
                    : Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                reward['name'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: canAfford ? null : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (reward['points'] as int > 0) ...[
                Text(
                  '${reward['points']} pts',
                  style: TextStyle(
                    color: canAfford 
                        ? reward['color'] as Color
                        : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ] else ...[
                const Text(
                  'FREE',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              if (canAfford) ...[
                ElevatedButton(
                  onPressed: () => _redeemReward(reward),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: reward['color'] as Color,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 32),
                  ),
                  child: const Text('REDEEM'),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'INSUFFICIENT POINTS',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 🎁 Redeem reward
  void _redeemReward(Map<String, dynamic> reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              reward['icon'] as IconData,
              color: reward['color'] as Color,
            ),
            const SizedBox(width: 8),
            Text('Redeem ${reward['name']}?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are about to redeem:'),
            const SizedBox(height: 8),
            Text(
              reward['name'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            if (reward['points'] as int > 0)
              Text('Cost: ${reward['points']} points'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showRedemptionSuccess(reward);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: reward['color'] as Color,
              foregroundColor: Colors.white,
            ),
            child: const Text('REDEEM'),
          ),
        ],
      ),
    );
  }

  /// ✅ Show redemption success
  void _showRedemptionSuccess(Map<String, dynamic> reward) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${reward['name']} redeemed successfully!',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to order or rewards history
          },
        ),
      ),
    );
  }
}
