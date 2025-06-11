import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'unified_loyalty_service.dart';

/// 🎮 Game Service - Manages Godot game integration and rewards
/// 
/// This service handles:
/// - Game loading and lifecycle management
/// - Reward system integration with ordering app
/// - Game progress tracking
/// - Performance monitoring for games
class GameService extends ChangeNotifier {
  static final GameService _instance = GameService._internal();
  factory GameService() => _instance;
  GameService._internal();

  // Loyalty service integration
  final UnifiedLoyaltyService _loyaltyService = UnifiedLoyaltyService();

  // Game state management
  bool _isInitialized = false;
  bool _isGameLoading = false;
  String? _currentGameId;
  Map<String, dynamic> _gameProgress = {};
  Map<String, dynamic> _gameRewards = {};
  
  // Available games configuration
  final Map<String, GameConfig> _availableGames = {
    'chicken_catch': GameConfig(
      id: 'chicken_catch',
      name: 'Chicken Catch',
      description: 'Catch falling chicken pieces to earn discounts!',
      webUrl: 'assets/games/chicken_catch/index.html',
      rewardType: RewardType.discount,
      maxReward: 15.0, // 15% discount
      category: GameCategory.arcade,
      estimatedPlayTime: 60, // seconds
    ),
    'spice_mixer': GameConfig(
      id: 'spice_mixer',
      name: 'Spice Mixer',
      description: 'Mix the perfect spice blend for bonus points!',
      webUrl: 'assets/games/spice_mixer/index.html',
      rewardType: RewardType.points,
      maxReward: 100.0, // 100 loyalty points
      category: GameCategory.puzzle,
      estimatedPlayTime: 90,
    ),
    'delivery_dash': GameConfig(
      id: 'delivery_dash',
      name: 'Delivery Dash',
      description: 'Help deliver orders quickly for free sides!',
      webUrl: 'assets/games/delivery_dash/index.html',
      rewardType: RewardType.freeItem,
      maxReward: 1.0, // 1 free side
      category: GameCategory.action,
      estimatedPlayTime: 120,
    ),
  };

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isGameLoading => _isGameLoading;
  String? get currentGameId => _currentGameId;
  Map<String, GameConfig> get availableGames => Map.unmodifiable(_availableGames);
  Map<String, dynamic> get gameProgress => Map.unmodifiable(_gameProgress);
  Map<String, dynamic> get gameRewards => Map.unmodifiable(_gameRewards);

  /// Initialize the game service
  Future<void> initialize() async {
    try {
      await _loadGameProgress();
      await _loadGameRewards();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('🎮 GameService initialization error: $e');
    }
  }

  /// Load a specific game
  Future<bool> loadGame(String gameId) async {
    if (!_availableGames.containsKey(gameId)) {
      debugPrint('🎮 Game not found: $gameId');
      return false;
    }

    try {
      _isGameLoading = true;
      _currentGameId = gameId;
      notifyListeners();

      // Simulate game loading time
      await Future.delayed(const Duration(seconds: 2));

      _isGameLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('🎮 Error loading game $gameId: $e');
      _isGameLoading = false;
      _currentGameId = null;
      notifyListeners();
      return false;
    }
  }

  /// Handle game completion and rewards
  Future<GameResult> completeGame(String gameId, double score, int timeSpent) async {
    final game = _availableGames[gameId];
    if (game == null) {
      return GameResult(success: false, message: 'Game not found');
    }

    try {
      // Calculate game points based on performance
      final gamePoints = _calculateGamePoints(game, score, timeSpent);

      // Award loyalty points through unified service
      final loyaltyTransaction = await _loyaltyService.awardPointsForGame(
        gameId: gameId,
        gamePoints: gamePoints,
        gameScore: score,
        timeSpent: timeSpent,
      );

      // Check for multiplier events
      final multiplierEvent = _loyaltyService.getActiveMultiplierEvent();
      if (multiplierEvent != null && multiplierEvent.isActive) {
        await _loyaltyService.awardMultiplierBonus(
          eventId: multiplierEvent.id,
          basePoints: loyaltyTransaction.points,
          multiplier: multiplierEvent.multiplier,
        );
      }

      // Check daily challenges
      await _checkDailyChallenges(gameId, score);

      // Update game progress
      _gameProgress[gameId] = {
        'lastPlayed': DateTime.now().toIso8601String(),
        'bestScore': _getBestScore(gameId, score),
        'timesPlayed': (_gameProgress[gameId]?['timesPlayed'] ?? 0) + 1,
        'totalTimeSpent': (_gameProgress[gameId]?['totalTimeSpent'] ?? 0) + timeSpent,
        'totalLoyaltyPointsEarned': (_gameProgress[gameId]?['totalLoyaltyPointsEarned'] ?? 0) + loyaltyTransaction.points,
      };

      // Save progress
      await _saveGameProgress();

      _currentGameId = null;
      notifyListeners();

      // Create unified game result
      final gameReward = GameReward(
        id: loyaltyTransaction.id,
        gameId: gameId,
        type: RewardType.points,
        amount: loyaltyTransaction.points.toDouble(),
        description: '${loyaltyTransaction.points} loyalty points earned!',
        earnedAt: DateTime.now(),
        isRedeemed: false,
      );

      return GameResult(
        success: true,
        message: 'Game completed! ${loyaltyTransaction.points} loyalty points earned!',
        reward: gameReward,
        score: score,
        loyaltyPointsEarned: loyaltyTransaction.points,
        multiplierApplied: multiplierEvent?.multiplier ?? 1.0,
      );
    } catch (e) {
      debugPrint('🎮 Error completing game $gameId: $e');
      return GameResult(success: false, message: 'Error processing game result: $e');
    }
  }

  /// Get game statistics for a specific game
  GameStats? getGameStats(String gameId) {
    final progress = _gameProgress[gameId];
    if (progress == null) return null;

    return GameStats(
      gameId: gameId,
      timesPlayed: progress['timesPlayed'] ?? 0,
      bestScore: progress['bestScore'] ?? 0.0,
      totalTimeSpent: progress['totalTimeSpent'] ?? 0,
      lastPlayed: progress['lastPlayed'] != null 
        ? DateTime.parse(progress['lastPlayed']) 
        : null,
    );
  }

  /// Get available rewards for redemption
  List<GameReward> getAvailableRewards() {
    return _gameRewards.entries
        .where((entry) => entry.value['isRedeemed'] == false)
        .map((entry) => GameReward.fromJson(entry.key, entry.value))
        .toList();
  }

  /// Redeem a game reward
  Future<bool> redeemReward(String rewardId) async {
    if (!_gameRewards.containsKey(rewardId)) return false;

    try {
      _gameRewards[rewardId]['isRedeemed'] = true;
      _gameRewards[rewardId]['redeemedAt'] = DateTime.now().toIso8601String();

      await _saveGameRewards();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('🎮 Error redeeming reward $rewardId: $e');
      return false;
    }
  }

  /// Perform full sync of game data (missing method)
  Future<bool> performFullSync() async {
    try {
      await _loadGameProgress();
      await _loadGameRewards();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('🎮 Error performing full sync: $e');
      return false;
    }
  }

  // Private methods
  double _getBestScore(String gameId, double newScore) {
    final currentBest = _gameProgress[gameId]?['bestScore'] ?? 0.0;
    return newScore > currentBest ? newScore : currentBest;
  }

  /// Calculate game points based on performance
  int _calculateGamePoints(GameConfig game, double score, int timeSpent) {
    // Base points from score (1 point per score point)
    int basePoints = score.round();

    // Time bonus (faster completion = more points)
    double timeBonus = 1.0;
    if (timeSpent < game.estimatedPlayTime * 0.8) {
      timeBonus = 1.5; // 50% bonus for fast completion
    } else if (timeSpent < game.estimatedPlayTime) {
      timeBonus = 1.2; // 20% bonus for normal completion
    }

    // Apply time bonus
    final totalPoints = (basePoints * timeBonus).round();

    // Cap points based on game difficulty
    final maxPoints = _getMaxPointsForGame(game);
    return totalPoints > maxPoints ? maxPoints : totalPoints;
  }

  /// Get maximum points for a specific game
  int _getMaxPointsForGame(GameConfig game) {
    switch (game.category) {
      case GameCategory.arcade:
        return 200; // Max 200 points for arcade games
      case GameCategory.puzzle:
        return 300; // Max 300 points for puzzle games
      case GameCategory.action:
        return 250; // Max 250 points for action games
      case GameCategory.strategy:
        return 400; // Max 400 points for strategy games
    }
  }

  /// Check and complete daily challenges
  Future<void> _checkDailyChallenges(String gameId, double score) async {
    final challenges = _loyaltyService.getDailyChallenges();

    for (final challenge in challenges) {
      if (challenge.isCompleted) continue;

      bool shouldComplete = false;

      // Game-specific challenges
      if (challenge.gameId == gameId && challenge.targetScore != null) {
        shouldComplete = score >= challenge.targetScore!;
      }

      // High score challenge
      if (challenge.id == 'high_score') {
        final currentBest = _gameProgress[gameId]?['bestScore'] ?? 0.0;
        shouldComplete = score > currentBest;
      }

      // Multiple games challenge
      if (challenge.id == 'play_three_games' && challenge.targetGames != null) {
        final today = DateTime.now();
        final todayGames = _gameProgress.keys.where((key) {
          final lastPlayed = _gameProgress[key]?['lastPlayed'];
          if (lastPlayed == null) return false;
          final playDate = DateTime.parse(lastPlayed);
          return playDate.year == today.year &&
                 playDate.month == today.month &&
                 playDate.day == today.day;
        }).length;
        shouldComplete = todayGames >= challenge.targetGames!;
      }

      if (shouldComplete) {
        try {
          await _loyaltyService.awardDailyChallengeBonus(
            challengeId: challenge.id,
            bonusPoints: challenge.pointsReward,
          );
        } catch (e) {
          debugPrint('🎯 Error completing daily challenge ${challenge.id}: $e');
        }
      }
    }
  }



  Future<void> _loadGameProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString('game_progress');
      if (progressJson != null) {
        _gameProgress = Map<String, dynamic>.from(json.decode(progressJson));
      }
    } catch (e) {
      debugPrint('🎮 Error loading game progress: $e');
    }
  }

  Future<void> _saveGameProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('game_progress', json.encode(_gameProgress));
    } catch (e) {
      debugPrint('🎮 Error saving game progress: $e');
    }
  }

  Future<void> _loadGameRewards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rewardsJson = prefs.getString('game_rewards');
      if (rewardsJson != null) {
        _gameRewards = Map<String, dynamic>.from(json.decode(rewardsJson));
      }
    } catch (e) {
      debugPrint('🎮 Error loading game rewards: $e');
    }
  }

  Future<void> _saveGameRewards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('game_rewards', json.encode(_gameRewards));
    } catch (e) {
      debugPrint('🎮 Error saving game rewards: $e');
    }
  }
}

// Data models
enum RewardType { discount, points, freeItem }
enum GameCategory { arcade, puzzle, action, strategy }

class GameConfig {
  final String id;
  final String name;
  final String description;
  final String webUrl;
  final RewardType rewardType;
  final double maxReward;
  final GameCategory category;
  final int estimatedPlayTime;

  GameConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.webUrl,
    required this.rewardType,
    required this.maxReward,
    required this.category,
    required this.estimatedPlayTime,
  });
}

class GameResult {
  final bool success;
  final String message;
  final GameReward? reward;
  final double? score;
  final int? loyaltyPointsEarned;
  final double? multiplierApplied;

  GameResult({
    required this.success,
    required this.message,
    this.reward,
    this.score,
    this.loyaltyPointsEarned,
    this.multiplierApplied,
  });
}

class GameStats {
  final String gameId;
  final int timesPlayed;
  final double bestScore;
  final int totalTimeSpent;
  final DateTime? lastPlayed;

  GameStats({
    required this.gameId,
    required this.timesPlayed,
    required this.bestScore,
    required this.totalTimeSpent,
    this.lastPlayed,
  });
}

class GameReward {
  final String id;
  final String gameId;
  final RewardType type;
  final double amount;
  final String description;
  final DateTime earnedAt;
  final bool isRedeemed;
  final DateTime? redeemedAt;

  GameReward({
    required this.id,
    required this.gameId,
    required this.type,
    required this.amount,
    required this.description,
    required this.earnedAt,
    required this.isRedeemed,
    this.redeemedAt,
  });

  factory GameReward.fromJson(String id, Map<String, dynamic> json) {
    return GameReward(
      id: id,
      gameId: json['gameId'],
      type: RewardType.values.firstWhere((e) => e.toString() == json['type']),
      amount: json['amount'].toDouble(),
      description: json['description'],
      earnedAt: DateTime.parse(json['earnedAt']),
      isRedeemed: json['isRedeemed'],
      redeemedAt: json['redeemedAt'] != null ? DateTime.parse(json['redeemedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'type': type.toString(),
      'amount': amount,
      'description': description,
      'earnedAt': earnedAt.toIso8601String(),
      'isRedeemed': isRedeemed,
      'redeemedAt': redeemedAt?.toIso8601String(),
    };
  }
}
