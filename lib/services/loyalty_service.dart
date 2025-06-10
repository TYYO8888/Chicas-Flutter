import 'package:flutter/material.dart';
import '../models/loyalty_program.dart';
// import '../models/user.dart'; // TODO: Create user model
// import 'api_service.dart'; // TODO: Implement API integration

/// 🏆 Loyalty Program Service for Chica's Chicken
/// Manages points, rewards, and loyalty program features
class LoyaltyService {
  static final LoyaltyService _instance = LoyaltyService._internal();
  factory LoyaltyService() => _instance;
  LoyaltyService._internal();

  // final ApiService _apiService = ApiService(); // TODO: Implement API integration
  
  // Loyalty program configuration
  static const double _pointsPerDollar = 1.0;
  static const double _dollarPerPoint = 0.01; // 1 point = $0.01
  static const int _signupBonus = 100; // 100 points for signing up
  static const int _referralBonus = 500; // 500 points for successful referral

  /// 🏆 Get user's loyalty information
  Future<LoyaltyAccount> getLoyaltyAccount(String userId) async {
    try {
      // TODO: Implement API call when backend is ready
    // final response = await _apiService.get('/api/users/$userId/loyalty');
      // Return mock data for now
      return LoyaltyAccount(
        userId: userId,
        currentPoints: 1250,
        lifetimePoints: 2500,
        tier: LoyaltyTier.gold,
        joinDate: DateTime.now().subtract(const Duration(days: 90)),
        lastActivity: DateTime.now(),
        totalOrders: 25,
        totalSpent: 625.50,
        referralCode: 'CHICA${userId.substring(0, 6).toUpperCase()}',
      );
    } catch (e) {
      debugPrint('Failed to get loyalty account: $e');
      // Return default account if API fails
      return LoyaltyAccount(
        userId: userId,
        currentPoints: 0,
        lifetimePoints: 0,
        tier: LoyaltyTier.bronze,
        joinDate: DateTime.now(),
        lastActivity: DateTime.now(),
      );
    }
  }

  /// 💰 Calculate points for purchase
  int calculatePointsForPurchase(double amount) {
    return (amount * _pointsPerDollar).floor();
  }

  /// 💵 Calculate dollar value of points
  double calculateDollarValue(int points) {
    return points * _dollarPerPoint;
  }

  /// ⭐ Award points for purchase
  Future<PointsTransaction> awardPointsForPurchase({
    required String userId,
    required String orderId,
    required double orderAmount,
    String? description,
  }) async {
    try {
      final points = calculatePointsForPurchase(orderAmount);
      
      final response = await _apiService.post('/api/users/$userId/loyalty/award', {
        'orderId': orderId,
        'points': points,
        'orderAmount': orderAmount,
        'type': 'purchase',
        'description': description ?? 'Points earned from order #$orderId',
      });

      return PointsTransaction.fromJson(response['data']);
    } catch (e) {
      debugPrint('Failed to award points: $e');
      throw Exception('Failed to award loyalty points');
    }
  }

  /// 🎁 Redeem points for discount
  Future<RedemptionResult> redeemPoints({
    required String userId,
    required int pointsToRedeem,
    required String orderId,
    String? description,
  }) async {
    try {
      final response = await _apiService.post('/api/users/$userId/loyalty/redeem', {
        'points': pointsToRedeem,
        'orderId': orderId,
        'type': 'discount',
        'description': description ?? 'Points redeemed for order discount',
      });

      return RedemptionResult.fromJson(response['data']);
    } catch (e) {
      debugPrint('Failed to redeem points: $e');
      throw Exception('Failed to redeem loyalty points');
    }
  }

  /// 📊 Get points transaction history
  Future<List<PointsTransaction>> getPointsHistory({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/api/users/$userId/loyalty/history',
        queryParams: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      return (response['data'] as List)
          .map((transaction) => PointsTransaction.fromJson(transaction))
          .toList();
    } catch (e) {
      debugPrint('Failed to get points history: $e');
      return [];
    }
  }

  /// 🏆 Get available rewards
  Future<List<LoyaltyReward>> getAvailableRewards(String userId) async {
    try {
      final response = await _apiService.get('/api/users/$userId/loyalty/rewards');
      return (response['data'] as List)
          .map((reward) => LoyaltyReward.fromJson(reward))
          .toList();
    } catch (e) {
      debugPrint('Failed to get available rewards: $e');
      return _getDefaultRewards();
    }
  }

  /// 🎁 Redeem reward
  Future<RedemptionResult> redeemReward({
    required String userId,
    required String rewardId,
    required String orderId,
  }) async {
    try {
      final response = await _apiService.post('/api/users/$userId/loyalty/rewards/$rewardId/redeem', {
        'orderId': orderId,
      });

      return RedemptionResult.fromJson(response['data']);
    } catch (e) {
      debugPrint('Failed to redeem reward: $e');
      throw Exception('Failed to redeem reward');
    }
  }

  /// 📈 Check tier progress
  Future<TierProgress> getTierProgress(String userId) async {
    try {
      final response = await _apiService.get('/api/users/$userId/loyalty/tier-progress');
      return TierProgress.fromJson(response['data']);
    } catch (e) {
      debugPrint('Failed to get tier progress: $e');
      return TierProgress(
        currentTier: LoyaltyTier.bronze,
        currentPoints: 0,
        pointsToNextTier: 1000,
        nextTier: LoyaltyTier.silver,
      );
    }
  }

  /// 🎉 Award signup bonus
  Future<PointsTransaction> awardSignupBonus(String userId) async {
    try {
      final response = await _apiService.post('/api/users/$userId/loyalty/award', {
        'points': _signupBonus,
        'type': 'signup_bonus',
        'description': 'Welcome bonus for joining Chica\'s Chicken loyalty program!',
      });

      return PointsTransaction.fromJson(response['data']);
    } catch (e) {
      debugPrint('Failed to award signup bonus: $e');
      throw Exception('Failed to award signup bonus');
    }
  }

  /// 👥 Award referral bonus
  Future<PointsTransaction> awardReferralBonus({
    required String userId,
    required String referredUserId,
  }) async {
    try {
      final response = await _apiService.post('/api/users/$userId/loyalty/award', {
        'points': _referralBonus,
        'type': 'referral_bonus',
        'description': 'Referral bonus for inviting a friend!',
        'metadata': {
          'referredUserId': referredUserId,
        },
      });

      return PointsTransaction.fromJson(response['data']);
    } catch (e) {
      debugPrint('Failed to award referral bonus: $e');
      throw Exception('Failed to award referral bonus');
    }
  }

  /// 🎂 Award birthday bonus
  Future<PointsTransaction> awardBirthdayBonus(String userId) async {
    try {
      final response = await _apiService.post('/api/users/$userId/loyalty/award', {
        'points': 250,
        'type': 'birthday_bonus',
        'description': 'Happy Birthday! Enjoy your special bonus points!',
      });

      return PointsTransaction.fromJson(response['data']);
    } catch (e) {
      debugPrint('Failed to award birthday bonus: $e');
      throw Exception('Failed to award birthday bonus');
    }
  }

  /// 📱 Generate referral code
  Future<String> generateReferralCode(String userId) async {
    try {
      final response = await _apiService.post('/api/users/$userId/loyalty/referral-code', {});
      return response['data']['referralCode'];
    } catch (e) {
      debugPrint('Failed to generate referral code: $e');
      // Generate a simple code as fallback
      return 'CHICA${userId.substring(0, 6).toUpperCase()}';
    }
  }

  /// 🔗 Apply referral code
  Future<bool> applyReferralCode({
    required String userId,
    required String referralCode,
  }) async {
    try {
      await _apiService.post('/api/users/$userId/loyalty/apply-referral', {
        'referralCode': referralCode,
      });
      return true;
    } catch (e) {
      debugPrint('Failed to apply referral code: $e');
      return false;
    }
  }

  /// 🏆 Get leaderboard
  Future<List<LoyaltyLeaderboardEntry>> getLeaderboard({
    int limit = 10,
    String period = 'monthly',
  }) async {
    try {
      final response = await _apiService.get('/api/loyalty/leaderboard', queryParams: {
        'limit': limit.toString(),
        'period': period,
      });

      return (response['data'] as List)
          .map((entry) => LoyaltyLeaderboardEntry.fromJson(entry))
          .toList();
    } catch (e) {
      debugPrint('Failed to get leaderboard: $e');
      return [];
    }
  }

  /// 🎯 Get challenges
  Future<List<LoyaltyChallenge>> getActiveChallenges(String userId) async {
    try {
      final response = await _apiService.get('/api/users/$userId/loyalty/challenges');
      return (response['data'] as List)
          .map((challenge) => LoyaltyChallenge.fromJson(challenge))
          .toList();
    } catch (e) {
      debugPrint('Failed to get challenges: $e');
      return _getDefaultChallenges();
    }
  }

  /// ✅ Complete challenge
  Future<PointsTransaction> completeChallenge({
    required String userId,
    required String challengeId,
  }) async {
    try {
      final response = await _apiService.post('/api/users/$userId/loyalty/challenges/$challengeId/complete', {});
      return PointsTransaction.fromJson(response['data']);
    } catch (e) {
      debugPrint('Failed to complete challenge: $e');
      throw Exception('Failed to complete challenge');
    }
  }

  /// 🎁 Get default rewards (fallback)
  List<LoyaltyReward> _getDefaultRewards() {
    return [
      LoyaltyReward(
        id: 'free_drink',
        name: 'Free Drink',
        description: 'Get any drink for free',
        pointsCost: 500,
        category: 'beverage',
        isAvailable: true,
        imageUrl: 'assets/images/rewards/free_drink.jpg',
      ),
      LoyaltyReward(
        id: 'free_side',
        name: 'Free Side',
        description: 'Get any side item for free',
        pointsCost: 750,
        category: 'side',
        isAvailable: true,
        imageUrl: 'assets/images/rewards/free_side.jpg',
      ),
      LoyaltyReward(
        id: 'discount_10',
        name: '10% Off Order',
        description: 'Get 10% off your entire order',
        pointsCost: 1000,
        category: 'discount',
        isAvailable: true,
        imageUrl: 'assets/images/rewards/discount_10.jpg',
      ),
      LoyaltyReward(
        id: 'free_sandwich',
        name: 'Free Sandwich',
        description: 'Get any sandwich for free',
        pointsCost: 1500,
        category: 'main',
        isAvailable: true,
        imageUrl: 'assets/images/rewards/free_sandwich.jpg',
      ),
    ];
  }

  /// 🎯 Get default challenges (fallback)
  List<LoyaltyChallenge> _getDefaultChallenges() {
    return [
      LoyaltyChallenge(
        id: 'first_order',
        name: 'First Order',
        description: 'Place your first order this month',
        pointsReward: 100,
        progress: 0,
        target: 1,
        isCompleted: false,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      ),
      LoyaltyChallenge(
        id: 'five_orders',
        name: 'Regular Customer',
        description: 'Place 5 orders this month',
        pointsReward: 500,
        progress: 0,
        target: 5,
        isCompleted: false,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      ),
      LoyaltyChallenge(
        id: 'weekend_warrior',
        name: 'Weekend Warrior',
        description: 'Order on both Saturday and Sunday',
        pointsReward: 200,
        progress: 0,
        target: 2,
        isCompleted: false,
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      ),
    ];
  }

  /// 📊 Get loyalty statistics
  Future<LoyaltyStatistics> getLoyaltyStatistics(String userId) async {
    try {
      final response = await _apiService.get('/api/users/$userId/loyalty/statistics');
      return LoyaltyStatistics.fromJson(response['data']);
    } catch (e) {
      debugPrint('Failed to get loyalty statistics: $e');
      return LoyaltyStatistics(
        totalPointsEarned: 0,
        totalPointsRedeemed: 0,
        totalOrdersWithPoints: 0,
        averagePointsPerOrder: 0,
        favoriteRewardCategory: 'beverage',
        memberSince: DateTime.now(),
      );
    }
  }
}
