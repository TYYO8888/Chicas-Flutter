import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/game_service.dart';
import '../services/unified_loyalty_service.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../services/navigation_service.dart';
import 'game_screen.dart';

/// 🎮 Games Hub Screen - Main games section
/// 
/// Features:
/// - Available games showcase
/// - Player statistics
/// - Rewards overview
/// - Game categories
class GamesHubScreen extends StatefulWidget {
  const GamesHubScreen({super.key});

  @override
  State<GamesHubScreen> createState() => _GamesHubScreenState();
}

class _GamesHubScreenState extends State<GamesHubScreen> with TickerProviderStateMixin {
  final GameService _gameService = GameService();
  final UnifiedLoyaltyService _loyaltyService = UnifiedLoyaltyService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeGameService();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeGameService() async {
    if (!_gameService.isInitialized) {
      await _gameService.initialize();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGamesTab(),
          _buildStatsTab(),
          _buildRewardsTab(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 1, // Games section
        onItemSelected: (index) {
          _handleNavigation(index);
        },
        cartService: null, // ✅ No cart service in games hub context
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'GAMES HUB',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFFFF6B35),
        labelColor: const Color(0xFFFF6B35),
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(text: 'GAMES'),
          Tab(text: 'STATS'),
          Tab(text: 'REWARDS'),
        ],
      ),
    );
  }

  Widget _buildGamesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          _buildHeaderSection(),
          const SizedBox(height: 24),
          
          // Featured game
          _buildFeaturedGame(),
          const SizedBox(height: 32),
          
          // All games grid
          _buildGamesGrid(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return FutureBuilder(
      future: _loyaltyService.getLoyaltyAccount(_loyaltyService.currentUserId),
      builder: (context, snapshot) {
        final account = snapshot.data;
        final multiplierEvent = _loyaltyService.getActiveMultiplierEvent();
        final dailyPoints = _loyaltyService.dailyGamePointsEarned;
        final streak = _loyaltyService.currentStreak;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF6B35),
                Color(0xFFFF8A50),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🎮 PLAY & EARN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ).animate()
                    .fadeIn()
                    .slideX(begin: -0.3, end: 0),

                  // Loyalty points display
                  if (account != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.stars, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${account.currentPoints}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ).animate()
                      .fadeIn(delay: const Duration(milliseconds: 300))
                      .scale(begin: const Offset(0.8, 0.8)),
                ],
              ),
              const SizedBox(height: 12),

              // Active multiplier or streak info
              if (multiplierEvent != null && multiplierEvent.isActive) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.yellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.yellow.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.flash_on, color: Colors.yellow, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${multiplierEvent.multiplier}x ${multiplierEvent.name}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ).animate()
                  .fadeIn(delay: const Duration(milliseconds: 400))
                  .slideX(begin: 0.3, end: 0),
                const SizedBox(height: 8),
              ] else if (streak > 1) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '$streak-day streak!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ).animate()
                  .fadeIn(delay: const Duration(milliseconds: 400))
                  .slideX(begin: 0.3, end: 0),
                const SizedBox(height: 8),
              ],

              Text(
                'Play games to earn loyalty points! Daily limit: $dailyPoints/500 points',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.4,
                ),
              ).animate()
                .fadeIn(delay: const Duration(milliseconds: 200))
                .slideX(begin: 0.3, end: 0),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturedGame() {
    final featuredGame = _gameService.availableGames['chicken_catch'];
    if (featuredGame == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF4CAF50),
                    Color(0xFF2E7D32),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'FEATURED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    featuredGame.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    featuredGame.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _launchGame(featuredGame.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('PLAY NOW'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(delay: const Duration(milliseconds: 400))
      .slideY(begin: 0.3, end: 0);
  }

  Widget _buildGamesGrid() {
    final games = _gameService.availableGames.values.toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ALL GAMES',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ).animate()
          .fadeIn(delay: const Duration(milliseconds: 600))
          .slideX(begin: -0.2, end: 0),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: games.length,
          itemBuilder: (context, index) {
            return _buildGameCard(games[index], index);
          },
        ),
      ],
    );
  }

  Widget _buildGameCard(GameConfig game, int index) {
    final stats = _gameService.getGameStats(game.id);
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _launchGame(game.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Game icon/category
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor(game.category).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(game.category),
                  color: _getCategoryColor(game.category),
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              
              // Game name
              Text(
                game.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              
              // Game description
              Text(
                game.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              
              // Stats or reward info
              if (stats != null) ...[
                Text(
                  'Best: ${stats.bestScore.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ] else ...[
                Text(
                  'Up to ${_getRewardText(game)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFF6B35),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(delay: Duration(milliseconds: 800 + (index * 100)))
      .slideY(begin: 0.3, end: 0);
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR GAMING STATS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          
          // Overall stats cards
          _buildOverallStats(),
          const SizedBox(height: 24),
          
          // Individual game stats
          _buildIndividualGameStats(),
        ],
      ),
    );
  }

  Widget _buildRewardsTab() {
    final availableRewards = _gameService.getAvailableRewards();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR REWARDS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          
          if (availableRewards.isEmpty) ...[
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.card_giftcard,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No rewards yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Play games to earn rewards!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: availableRewards.length,
              itemBuilder: (context, index) {
                return _buildRewardCard(availableRewards[index]);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverallStats() {
    // Implementation for overall stats
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Overall stats coming soon...'),
      ),
    );
  }

  Widget _buildIndividualGameStats() {
    // Implementation for individual game stats
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Individual game stats coming soon...'),
      ),
    );
  }

  Widget _buildRewardCard(GameReward reward) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFF6B35),
          child: Icon(
            _getRewardIcon(reward.type),
            color: Colors.white,
          ),
        ),
        title: Text(reward.description),
        subtitle: Text('Earned: ${_formatDate(reward.earnedAt)}'),
        trailing: ElevatedButton(
          onPressed: () => _redeemReward(reward),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            foregroundColor: Colors.white,
          ),
          child: const Text('REDEEM'),
        ),
      ),
    );
  }

  // Helper methods
  Color _getCategoryColor(GameCategory category) {
    switch (category) {
      case GameCategory.arcade:
        return Colors.green;
      case GameCategory.puzzle:
        return Colors.blue;
      case GameCategory.action:
        return Colors.red;
      case GameCategory.strategy:
        return Colors.purple;
    }
  }

  IconData _getCategoryIcon(GameCategory category) {
    switch (category) {
      case GameCategory.arcade:
        return Icons.sports_esports;
      case GameCategory.puzzle:
        return Icons.extension;
      case GameCategory.action:
        return Icons.flash_on;
      case GameCategory.strategy:
        return Icons.psychology;
    }
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

  String _getRewardText(GameConfig game) {
    switch (game.rewardType) {
      case RewardType.discount:
        return '${game.maxReward.toStringAsFixed(0)}% off';
      case RewardType.points:
        return '${game.maxReward.toStringAsFixed(0)} points';
      case RewardType.freeItem:
        return 'Free item';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _launchGame(String gameId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(gameId: gameId),
      ),
    );
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

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        NavigationService.navigateToHome();
        break;
      case 1:
        // Already on games section
        break;
      case 2:
        NavigationService.navigateToMenu();
        break;
      case 3:
        NavigationService.navigateToCart();
        break;
      case 4:
        NavigationService.navigateToMore();
        break;
    }
  }
}
