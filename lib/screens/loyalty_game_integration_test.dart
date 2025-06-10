import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/unified_loyalty_service.dart';
import '../services/game_service.dart';
import '../widgets/unified_loyalty_dashboard.dart';

/// 🎮🏆 Loyalty-Game Integration Test Screen
/// 
/// Comprehensive test screen that demonstrates:
/// - Game completion with loyalty point integration
/// - Daily challenges and streak bonuses
/// - Multiplier events and special promotions
/// - Real-time point balance updates
/// - Cross-system data flow validation
class LoyaltyGameIntegrationTest extends StatefulWidget {
  const LoyaltyGameIntegrationTest({super.key});

  @override
  State<LoyaltyGameIntegrationTest> createState() => _LoyaltyGameIntegrationTestState();
}

class _LoyaltyGameIntegrationTestState extends State<LoyaltyGameIntegrationTest> {
  final UnifiedLoyaltyService _loyaltyService = UnifiedLoyaltyService();
  final GameService _gameService = GameService();
  bool _isInitialized = false;
  String _lastResult = '';

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _loyaltyService.initialize();
    await _gameService.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮🏆 INTEGRATION TEST'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
      ),
      body: _isInitialized ? _buildTestInterface() : _buildLoadingScreen(),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
          ),
          SizedBox(height: 20),
          Text('Initializing loyalty and game services...'),
        ],
      ),
    );
  }

  Widget _buildTestInterface() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Integration status
          _buildIntegrationStatus(),
          const SizedBox(height: 20),
          
          // Test controls
          _buildTestControls(),
          const SizedBox(height: 20),
          
          // Last result
          if (_lastResult.isNotEmpty) ...[
            _buildLastResult(),
            const SizedBox(height: 20),
          ],
          
          // Live loyalty dashboard
          _buildLiveDashboard(),
        ],
      ),
    );
  }

  Widget _buildIntegrationStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF8A50)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔗 INTEGRATION STATUS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusItem('Game Service', _gameService.isInitialized),
          _buildStatusItem('Loyalty Service', _loyaltyService.currentAccount != null),
          _buildStatusItem('Daily Challenges', _loyaltyService.getDailyChallenges().isNotEmpty),
          _buildStatusItem('Multiplier Events', _loyaltyService.getActiveMultiplierEvent() != null),
        ],
      ),
    ).animate()
      .fadeIn()
      .slideY(begin: -0.2, end: 0);
  }

  Widget _buildStatusItem(String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isActive ? Colors.green : Colors.white70,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestControls() {
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
            '🧪 TEST CONTROLS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          
          // Game completion tests
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildTestButton(
                'Play Chicken Catch',
                Icons.sports_esports,
                () => _simulateGameCompletion('chicken_catch', 150, 45),
                Colors.green,
              ),
              _buildTestButton(
                'Play Spice Mixer',
                Icons.extension,
                () => _simulateGameCompletion('spice_mixer', 200, 60),
                Colors.blue,
              ),
              _buildTestButton(
                'Play Delivery Dash',
                Icons.flash_on,
                () => _simulateGameCompletion('delivery_dash', 120, 90),
                Colors.red,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Loyalty tests
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildTestButton(
                'Simulate Purchase',
                Icons.shopping_bag,
                () => _simulatePurchase(25.99),
                Colors.purple,
              ),
              _buildTestButton(
                'Complete Challenge',
                Icons.emoji_events,
                () => _completeRandomChallenge(),
                Colors.orange,
              ),
              _buildTestButton(
                'Redeem Points',
                Icons.redeem,
                () => _redeemPoints(100),
                Colors.teal,
              ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: const Duration(milliseconds: 200))
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildTestButton(String label, IconData icon, VoidCallback onPressed, Color color) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildLastResult() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'LAST RESULT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _lastResult,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    ).animate()
      .fadeIn()
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildLiveDashboard() {
    return Container(
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
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              '📊 LIVE LOYALTY DASHBOARD',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const UnifiedLoyaltyDashboard(userId: 'user_123'),
        ],
      ),
    ).animate()
      .fadeIn(delay: const Duration(milliseconds: 400))
      .slideY(begin: 0.2, end: 0);
  }

  // Test methods
  Future<void> _simulateGameCompletion(String gameId, double score, int timeSpent) async {
    try {
      final result = await _gameService.completeGame(gameId, score, timeSpent);
      
      setState(() {
        _lastResult = 'Game "$gameId" completed!\n'
            'Score: ${score.toStringAsFixed(0)}\n'
            'Loyalty Points Earned: ${result.loyaltyPointsEarned ?? 0}\n'
            'Multiplier Applied: ${result.multiplierApplied?.toStringAsFixed(1) ?? 1.0}x\n'
            'Message: ${result.message}';
      });
      
      _showSuccessSnackBar('Game completed! ${result.loyaltyPointsEarned ?? 0} points earned!');
    } catch (e) {
      setState(() {
        _lastResult = 'Error completing game: $e';
      });
      _showErrorSnackBar('Failed to complete game: $e');
    }
  }

  Future<void> _simulatePurchase(double amount) async {
    try {
      final transaction = await _loyaltyService.awardPointsForPurchase(
        orderId: 'test_${DateTime.now().millisecondsSinceEpoch}',
        orderAmount: amount,
      );
      
      setState(() {
        _lastResult = 'Purchase completed!\n'
            'Amount: \$${amount.toStringAsFixed(2)}\n'
            'Points Earned: ${transaction.points}\n'
            'Description: ${transaction.description}';
      });
      
      _showSuccessSnackBar('Purchase completed! ${transaction.points} points earned!');
    } catch (e) {
      setState(() {
        _lastResult = 'Error processing purchase: $e';
      });
      _showErrorSnackBar('Failed to process purchase: $e');
    }
  }

  Future<void> _completeRandomChallenge() async {
    try {
      final challenges = _loyaltyService.getDailyChallenges()
          .where((c) => !c.isCompleted)
          .toList();
      
      if (challenges.isEmpty) {
        setState(() {
          _lastResult = 'No incomplete challenges available';
        });
        _showErrorSnackBar('No challenges to complete');
        return;
      }
      
      final challenge = challenges.first;
      final transaction = await _loyaltyService.awardDailyChallengeBonus(
        challengeId: challenge.id,
        bonusPoints: challenge.pointsReward,
      );
      
      setState(() {
        _lastResult = 'Challenge completed!\n'
            'Challenge: ${challenge.name}\n'
            'Points Earned: ${transaction.points}\n'
            'Description: ${transaction.description}';
      });
      
      _showSuccessSnackBar('Challenge completed! ${transaction.points} points earned!');
    } catch (e) {
      setState(() {
        _lastResult = 'Error completing challenge: $e';
      });
      _showErrorSnackBar('Failed to complete challenge: $e');
    }
  }

  Future<void> _redeemPoints(int points) async {
    try {
      final result = await _loyaltyService.redeemPoints(
        pointsToRedeem: points,
        orderId: 'redeem_${DateTime.now().millisecondsSinceEpoch}',
      );
      
      setState(() {
        _lastResult = 'Points redeemed!\n'
            'Points Used: ${result.pointsRedeemed}\n'
            'Discount Amount: \$${result.discountAmount.toStringAsFixed(2)}\n'
            'Redemption ID: ${result.redemptionId}';
      });
      
      _showSuccessSnackBar('${result.pointsRedeemed} points redeemed for \$${result.discountAmount.toStringAsFixed(2)}!');
    } catch (e) {
      setState(() {
        _lastResult = 'Error redeeming points: $e';
      });
      _showErrorSnackBar('Failed to redeem points: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
