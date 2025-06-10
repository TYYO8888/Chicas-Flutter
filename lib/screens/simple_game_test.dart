import 'package:flutter/material.dart';
import '../services/game_service.dart';

/// 🎮 Simple Game Test Screen
/// 
/// This is a simplified test screen to verify game integration
/// without complex WebView dependencies
class SimpleGameTest extends StatefulWidget {
  const SimpleGameTest({super.key});

  @override
  State<SimpleGameTest> createState() => _SimpleGameTestState();
}

class _SimpleGameTestState extends State<SimpleGameTest> {
  final GameService _gameService = GameService();
  bool _isGameActive = false;
  int _score = 0;
  int _timeLeft = 30;
  String _gameStatus = 'Ready to play!';

  @override
  void initState() {
    super.initState();
    _initializeGameService();
  }

  Future<void> _initializeGameService() async {
    await _gameService.initialize();
    setState(() {});
  }

  void _startSimpleGame() {
    setState(() {
      _isGameActive = true;
      _score = 0;
      _timeLeft = 30;
      _gameStatus = 'Game in progress...';
    });

    // Simulate a simple game with timer
    _runGameTimer();
  }

  void _runGameTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isGameActive && _timeLeft > 0) {
        setState(() {
          _timeLeft--;
          // Simulate score increase
          _score += (10 + (30 - _timeLeft) * 2);
        });
        _runGameTimer();
      } else if (_timeLeft <= 0) {
        _endGame();
      }
    });
  }

  void _endGame() async {
    setState(() {
      _isGameActive = false;
      _gameStatus = 'Game completed!';
    });

    // Complete the game and get rewards
    final result = await _gameService.completeGame('chicken_catch', _score.toDouble(), 30 - _timeLeft);
    
    if (mounted) {
      _showGameResult(result);
    }
  }

  void _showGameResult(GameResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result.success ? '🎉 Game Complete!' : '😞 Game Over'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Final Score: $_score'),
            const SizedBox(height: 16),
            Text(result.message),
            if (result.reward != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      '🎁 Reward Earned!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(result.reward!.description),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 GAME TEST'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Game status
            Container(
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
                children: [
                  const Text(
                    '🐔 CHICKEN CATCH TEST',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _gameStatus,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  
                  // Game stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'SCORE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '$_score',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6B35),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'TIME',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '${_timeLeft}s',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6B35),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Game controls
            if (!_isGameActive) ...[
              ElevatedButton(
                onPressed: _startSimpleGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'START GAME',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ] else ...[
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Game in progress...',
                style: TextStyle(fontSize: 16),
              ),
            ],
            
            const SizedBox(height: 40),
            
            // Available rewards
            _buildRewardsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsSection() {
    final availableRewards = _gameService.getAvailableRewards();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎁 AVAILABLE REWARDS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B35),
            ),
          ),
          const SizedBox(height: 12),
          
          if (availableRewards.isEmpty) ...[
            const Text(
              'No rewards yet. Play games to earn rewards!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ] else ...[
            ...availableRewards.map((reward) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    _getRewardIcon(reward.type),
                    color: const Color(0xFFFF6B35),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reward.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _redeemReward(reward),
                    child: const Text(
                      'REDEEM',
                      style: TextStyle(
                        color: Color(0xFFFF6B35),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  IconData _getRewardIcon(RewardType type) {
    switch (type) {
      case RewardType.discount:
        return Icons.percent;
      case RewardType.points:
        return Icons.stars;
      case RewardType.freeItem:
        return Icons.card_giftcard;
    }
  }

  void _redeemReward(GameReward reward) async {
    final success = await _gameService.redeemReward(reward.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reward redeemed: ${reward.description}'),
          backgroundColor: const Color(0xFFFF6B35),
        ),
      );
      setState(() {});
    }
  }
}
