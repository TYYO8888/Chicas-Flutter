import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/loyalty_program.dart';

/// 🏆 Unified Loyalty Service - Integrates games with loyalty program
/// 
/// This service handles:
/// - Traditional purchase-based loyalty points
/// - Game-earned loyalty points with conversion
/// - Daily challenges and streak bonuses
/// - Multiplier events and special promotions
/// - Unified point balance and transaction history
class UnifiedLoyaltyService extends ChangeNotifier {
  static final UnifiedLoyaltyService _instance = UnifiedLoyaltyService._internal();
  factory UnifiedLoyaltyService() => _instance;
  UnifiedLoyaltyService._internal();

  // Current user data (mock)
  String _currentUserId = 'user_123';
  LoyaltyAccount? _currentAccount;
  List<PointsTransaction> _transactionHistory = [];
  Map<String, dynamic> _gameStats = {};
  Map<String, dynamic> _dailyChallenges = {};
  int _currentStreak = 0;
  DateTime? _lastGamePlayDate;
  
  // Configuration
  static const double _pointsPerDollar = 1.0;
  static const double _dollarPerPoint = 0.01;
  static const int _dailyGameLimit = 500; // Max points per day from games
  static const int _streakBonusBase = 50; // Base streak bonus points
  
  // Getters
  String get currentUserId => _currentUserId;
  LoyaltyAccount? get currentAccount => _currentAccount;
  List<PointsTransaction> get transactionHistory => List.unmodifiable(_transactionHistory);
  int get currentStreak => _currentStreak;
  int get dailyGamePointsEarned => _getDailyGamePoints();

  /// Initialize the service
  Future<void> initialize() async {
    await _loadUserData();
    await _loadTransactionHistory();
    await _loadGameStats();
    await _checkDailyReset();
    notifyListeners();
  }

  /// Get current loyalty account
  Future<LoyaltyAccount> getLoyaltyAccount(String userId) async {
    _currentUserId = userId;
    
    if (_currentAccount == null) {
      await _loadUserData();
    }
    
    return _currentAccount ?? LoyaltyAccount(
      userId: userId,
      currentPoints: 0,
      lifetimePoints: 0,
      tier: LoyaltyTier.bronze,
      joinDate: DateTime.now(),
      lastActivity: DateTime.now(),
    );
  }

  /// Award points for game completion
  Future<PointsTransaction> awardPointsForGame({
    required String gameId,
    required int gamePoints,
    required double gameScore,
    required int timeSpent,
  }) async {
    // Check daily limit
    final dailyPoints = _getDailyGamePoints();
    if (dailyPoints >= _dailyGameLimit) {
      throw Exception('Daily game point limit reached');
    }
    
    // Convert game points to loyalty points with game-specific ratio
    final conversionRatio = _getGamePointConversionRatio(gameId);
    final loyaltyPoints = (gamePoints * conversionRatio).round();
    
    // Apply daily limit
    final remainingDaily = _dailyGameLimit - dailyPoints;
    final actualPoints = loyaltyPoints > remainingDaily ? remainingDaily : loyaltyPoints;
    
    // Create transaction
    final transaction = PointsTransaction(
      id: 'game_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUserId,
      points: actualPoints,
      type: 'game_completion',
      description: 'Points earned from $gameId (Score: ${gameScore.toStringAsFixed(0)})',
      timestamp: DateTime.now(),
      metadata: {
        'gameId': gameId,
        'gameScore': gameScore,
        'timeSpent': timeSpent,
        'originalGamePoints': gamePoints,
        'conversionRatio': conversionRatio,
      },
    );
    
    // Update account
    await _addPointsTransaction(transaction);
    
    // Update game stats
    await _updateGameStats(gameId, gameScore, timeSpent);
    
    // Check for streak bonus
    await _checkStreakBonus();
    
    return transaction;
  }

  /// Award daily challenge bonus
  Future<PointsTransaction> awardDailyChallengeBonus({
    required String challengeId,
    required int bonusPoints,
  }) async {
    final transaction = PointsTransaction(
      id: 'challenge_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUserId,
      points: bonusPoints,
      type: 'daily_challenge',
      description: 'Daily challenge completed: $challengeId',
      timestamp: DateTime.now(),
      metadata: {'challengeId': challengeId},
    );
    
    await _addPointsTransaction(transaction);
    
    // Mark challenge as completed
    _dailyChallenges[challengeId] = {
      'completed': true,
      'completedAt': DateTime.now().toIso8601String(),
      'pointsAwarded': bonusPoints,
    };
    await _saveDailyChallenges();
    
    return transaction;
  }

  /// Award streak bonus
  Future<PointsTransaction> awardStreakBonus(int streakDays) async {
    final bonusPoints = _calculateStreakBonus(streakDays);
    
    final transaction = PointsTransaction(
      id: 'streak_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUserId,
      points: bonusPoints,
      type: 'streak_bonus',
      description: '$streakDays-day gaming streak bonus!',
      timestamp: DateTime.now(),
      metadata: {'streakDays': streakDays},
    );
    
    await _addPointsTransaction(transaction);
    return transaction;
  }

  /// Award multiplier event bonus
  Future<PointsTransaction> awardMultiplierBonus({
    required String eventId,
    required int basePoints,
    required double multiplier,
  }) async {
    final bonusPoints = (basePoints * (multiplier - 1.0)).round();
    
    final transaction = PointsTransaction(
      id: 'multiplier_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUserId,
      points: bonusPoints,
      type: 'multiplier_bonus',
      description: '${multiplier}x multiplier event bonus!',
      timestamp: DateTime.now(),
      metadata: {
        'eventId': eventId,
        'basePoints': basePoints,
        'multiplier': multiplier,
      },
    );
    
    await _addPointsTransaction(transaction);
    return transaction;
  }

  /// Award points for purchase
  Future<PointsTransaction> awardPointsForPurchase({
    required String orderId,
    required double orderAmount,
  }) async {
    final points = (orderAmount * _pointsPerDollar).floor();
    
    final transaction = PointsTransaction(
      id: 'purchase_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUserId,
      points: points,
      type: 'purchase',
      description: 'Points earned from order #$orderId',
      timestamp: DateTime.now(),
      metadata: {
        'orderId': orderId,
        'orderAmount': orderAmount,
      },
    );
    
    await _addPointsTransaction(transaction);
    return transaction;
  }

  /// Redeem points for discount
  Future<RedemptionResult> redeemPoints({
    required int pointsToRedeem,
    required String orderId,
  }) async {
    if (_currentAccount == null || _currentAccount!.currentPoints < pointsToRedeem) {
      throw Exception('Insufficient points');
    }
    
    final transaction = PointsTransaction(
      id: 'redeem_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUserId,
      points: -pointsToRedeem,
      type: 'redemption',
      description: 'Points redeemed for order discount',
      timestamp: DateTime.now(),
      metadata: {'orderId': orderId},
    );
    
    await _addPointsTransaction(transaction);
    
    return RedemptionResult(
      success: true,
      pointsRedeemed: pointsToRedeem,
      discountAmount: pointsToRedeem * _dollarPerPoint,
      redemptionId: transaction.id,
    );
  }

  /// Get available daily challenges
  List<DailyChallenge> getDailyChallenges() {
    final today = DateTime.now();
    final challenges = <DailyChallenge>[];
    
    // Game-based challenges
    challenges.addAll([
      DailyChallenge(
        id: 'play_chicken_catch',
        name: 'Chicken Catcher',
        description: 'Play Chicken Catch and score 100+ points',
        pointsReward: 50,
        isCompleted: _isDailyChallengeCompleted('play_chicken_catch'),
        gameId: 'chicken_catch',
        targetScore: 100,
      ),
      DailyChallenge(
        id: 'play_three_games',
        name: 'Game Master',
        description: 'Play 3 different games today',
        pointsReward: 100,
        isCompleted: _isDailyChallengeCompleted('play_three_games'),
        targetGames: 3,
      ),
      DailyChallenge(
        id: 'high_score',
        name: 'High Scorer',
        description: 'Achieve a personal best in any game',
        pointsReward: 75,
        isCompleted: _isDailyChallengeCompleted('high_score'),
      ),
    ]);
    
    return challenges;
  }

  /// Check if multiplier event is active
  MultiplierEvent? getActiveMultiplierEvent() {
    final now = DateTime.now();
    final hour = now.hour;
    
    // Happy hour multiplier (2-4 PM)
    if (hour >= 14 && hour < 16) {
      return MultiplierEvent(
        id: 'happy_hour',
        name: 'Happy Hour Bonus',
        description: '2x points from games!',
        multiplier: 2.0,
        startTime: DateTime(now.year, now.month, now.day, 14),
        endTime: DateTime(now.year, now.month, now.day, 16),
      );
    }
    
    // Late night multiplier (9-11 PM)
    if (hour >= 21 && hour < 23) {
      return MultiplierEvent(
        id: 'late_night',
        name: 'Night Owl Bonus',
        description: '1.5x points from games!',
        multiplier: 1.5,
        startTime: DateTime(now.year, now.month, now.day, 21),
        endTime: DateTime(now.year, now.month, now.day, 23),
      );
    }
    
    return null;
  }

  // Private methods
  double _getGamePointConversionRatio(String gameId) {
    switch (gameId) {
      case 'chicken_catch':
        return 1.0; // 1:1 conversion
      case 'spice_mixer':
        return 1.2; // Harder game, better conversion
      case 'delivery_dash':
        return 0.8; // Easier game, lower conversion
      default:
        return 1.0;
    }
  }

  int _getDailyGamePoints() {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    
    return _transactionHistory
        .where((t) => 
            t.type == 'game_completion' && 
            t.timestamp.year == today.year &&
            t.timestamp.month == today.month &&
            t.timestamp.day == today.day)
        .fold(0, (sum, t) => sum + t.points);
  }

  int _calculateStreakBonus(int streakDays) {
    // Exponential bonus: 50 * (1.2^days)
    return (_streakBonusBase * (1.2 * streakDays)).round();
  }

  bool _isDailyChallengeCompleted(String challengeId) {
    final challenge = _dailyChallenges[challengeId];
    if (challenge == null) return false;
    
    final completedAt = DateTime.tryParse(challenge['completedAt'] ?? '');
    if (completedAt == null) return false;
    
    final today = DateTime.now();
    return completedAt.year == today.year &&
           completedAt.month == today.month &&
           completedAt.day == today.day;
  }

  Future<void> _addPointsTransaction(PointsTransaction transaction) async {
    _transactionHistory.insert(0, transaction);
    
    // Update current account
    if (_currentAccount != null) {
      _currentAccount = LoyaltyAccount(
        userId: _currentAccount!.userId,
        currentPoints: _currentAccount!.currentPoints + transaction.points,
        lifetimePoints: transaction.points > 0 
            ? _currentAccount!.lifetimePoints + transaction.points 
            : _currentAccount!.lifetimePoints,
        tier: _calculateTier(_currentAccount!.lifetimePoints + (transaction.points > 0 ? transaction.points : 0)),
        joinDate: _currentAccount!.joinDate,
        lastActivity: DateTime.now(),
        referralCode: _currentAccount!.referralCode,
        totalOrders: _currentAccount!.totalOrders,
        totalSpent: _currentAccount!.totalSpent,
      );
    }
    
    await _saveUserData();
    await _saveTransactionHistory();
    notifyListeners();
  }

  LoyaltyTier _calculateTier(int lifetimePoints) {
    if (lifetimePoints >= 10000) return LoyaltyTier.diamond;
    if (lifetimePoints >= 5000) return LoyaltyTier.platinum;
    if (lifetimePoints >= 2500) return LoyaltyTier.gold;
    if (lifetimePoints >= 1000) return LoyaltyTier.silver;
    return LoyaltyTier.bronze;
  }

  Future<void> _checkStreakBonus() async {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    // Check if user played yesterday
    final playedYesterday = _transactionHistory.any((t) =>
        t.type == 'game_completion' &&
        t.timestamp.year == yesterday.year &&
        t.timestamp.month == yesterday.month &&
        t.timestamp.day == yesterday.day);
    
    if (playedYesterday || _lastGamePlayDate == null) {
      _currentStreak++;
    } else {
      _currentStreak = 1; // Reset streak
    }
    
    _lastGamePlayDate = today;
    
    // Award streak bonus for milestones
    if (_currentStreak > 1 && _currentStreak % 3 == 0) {
      await awardStreakBonus(_currentStreak);
    }
    
    await _saveGameStats();
  }

  Future<void> _checkDailyReset() async {
    final today = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final lastResetStr = prefs.getString('last_daily_reset');
    
    if (lastResetStr != null) {
      final lastReset = DateTime.parse(lastResetStr);
      if (lastReset.day != today.day || 
          lastReset.month != today.month || 
          lastReset.year != today.year) {
        // Reset daily challenges
        _dailyChallenges.clear();
        await _saveDailyChallenges();
      }
    }
    
    await prefs.setString('last_daily_reset', today.toIso8601String());
  }

  // Storage methods
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final accountJson = prefs.getString('loyalty_account_$_currentUserId');
    
    if (accountJson != null) {
      final data = json.decode(accountJson);
      _currentAccount = LoyaltyAccount.fromJson(data);
    } else {
      // Create new account
      _currentAccount = LoyaltyAccount(
        userId: _currentUserId,
        currentPoints: 100, // Welcome bonus
        lifetimePoints: 100,
        tier: LoyaltyTier.bronze,
        joinDate: DateTime.now(),
        lastActivity: DateTime.now(),
        referralCode: 'CHICA${_currentUserId.substring(0, 6).toUpperCase()}',
      );
      await _saveUserData();
    }
  }

  Future<void> _saveUserData() async {
    if (_currentAccount == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'loyalty_account_$_currentUserId',
      json.encode(_currentAccount!.toJson()),
    );
  }

  Future<void> _loadTransactionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('transaction_history_$_currentUserId');
    
    if (historyJson != null) {
      final data = json.decode(historyJson) as List;
      _transactionHistory = data
          .map((item) => PointsTransaction.fromJson(item))
          .toList();
    }
  }

  Future<void> _saveTransactionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'transaction_history_$_currentUserId',
      json.encode(_transactionHistory.map((t) => t.toJson()).toList()),
    );
  }

  Future<void> _loadGameStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString('game_stats_$_currentUserId');
    
    if (statsJson != null) {
      _gameStats = Map<String, dynamic>.from(json.decode(statsJson));
      _currentStreak = _gameStats['currentStreak'] ?? 0;
      _lastGamePlayDate = _gameStats['lastGamePlayDate'] != null
          ? DateTime.parse(_gameStats['lastGamePlayDate'])
          : null;
    }
  }

  Future<void> _saveGameStats() async {
    _gameStats['currentStreak'] = _currentStreak;
    _gameStats['lastGamePlayDate'] = _lastGamePlayDate?.toIso8601String();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'game_stats_$_currentUserId',
      json.encode(_gameStats),
    );
  }

  Future<void> _updateGameStats(String gameId, double score, int timeSpent) async {
    final gameKey = 'game_$gameId';
    final currentStats = _gameStats[gameKey] ?? {};
    
    currentStats['lastScore'] = score;
    currentStats['bestScore'] = (currentStats['bestScore'] ?? 0.0) > score 
        ? currentStats['bestScore'] 
        : score;
    currentStats['timesPlayed'] = (currentStats['timesPlayed'] ?? 0) + 1;
    currentStats['totalTimeSpent'] = (currentStats['totalTimeSpent'] ?? 0) + timeSpent;
    currentStats['lastPlayed'] = DateTime.now().toIso8601String();
    
    _gameStats[gameKey] = currentStats;
    await _saveGameStats();
  }

  Future<void> _saveDailyChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'daily_challenges_$_currentUserId',
      json.encode(_dailyChallenges),
    );
  }
}

// Additional models for game integration
class DailyChallenge {
  final String id;
  final String name;
  final String description;
  final int pointsReward;
  final bool isCompleted;
  final String? gameId;
  final double? targetScore;
  final int? targetGames;

  DailyChallenge({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsReward,
    required this.isCompleted,
    this.gameId,
    this.targetScore,
    this.targetGames,
  });
}

class MultiplierEvent {
  final String id;
  final String name;
  final String description;
  final double multiplier;
  final DateTime startTime;
  final DateTime endTime;

  MultiplierEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.multiplier,
    required this.startTime,
    required this.endTime,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }
}
