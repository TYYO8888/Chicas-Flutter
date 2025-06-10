import 'package:flutter/material.dart';
import '../models/loyalty_program.dart';

/// 🏆 Simple Mock Loyalty Program Service for Chica's Chicken
/// Provides basic mock data for demonstration purposes
class LoyaltyService {
  static final LoyaltyService _instance = LoyaltyService._internal();
  factory LoyaltyService() => _instance;
  LoyaltyService._internal();

  /// 🏆 Get user's loyalty information
  Future<LoyaltyAccount> getLoyaltyAccount(String userId) async {
    // Return mock data for demonstration
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
  }

  /// 💰 Calculate points for purchase
  int calculatePointsForPurchase(double amount) {
    return (amount * 1.0).floor(); // 1 point per dollar
  }

  /// 💵 Calculate dollar value of points
  double calculateDollarValue(int points) {
    return points * 0.01; // 1 point = $0.01
  }

  /// ⭐ Award points for purchase
  Future<bool> awardPointsForPurchase({
    required String userId,
    required String orderId,
    required double orderAmount,
  }) async {
    final points = calculatePointsForPurchase(orderAmount);
    debugPrint('Awarding $points points to user $userId for order $orderId');
    return true;
  }

  /// 🎁 Redeem points for discount
  Future<RedemptionResult> redeemPoints({
    required String userId,
    required int pointsToRedeem,
    required String orderId,
    String? description,
  }) async {
    final discountAmount = calculateDollarValue(pointsToRedeem);
    debugPrint('Redeeming $pointsToRedeem points for user $userId');

    return RedemptionResult(
      success: true,
      pointsRedeemed: pointsToRedeem,
      discountAmount: discountAmount,
      redemptionId: 'red_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// 📊 Get points transaction history
  Future<List<PointsTransaction>> getPointsHistory({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    // Return mock transaction history
    return [
      PointsTransaction(
        id: 'txn_1',
        userId: userId,
        points: 25,
        type: 'purchase',
        description: 'Points earned from order #1001',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        orderId: 'order_1001',
        metadata: {'orderAmount': 25.99},
      ),
      PointsTransaction(
        id: 'txn_2',
        userId: userId,
        points: -50,
        type: 'redemption',
        description: 'Points redeemed for discount',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        orderId: 'order_1002',
        metadata: {'discountAmount': 0.50},
      ),
      PointsTransaction(
        id: 'txn_3',
        userId: userId,
        points: 100,
        type: 'signup_bonus',
        description: 'Welcome bonus',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        metadata: {'bonusType': 'signup'},
      ),
    ];
  }

  /// 🏆 Get available rewards
  Future<List<LoyaltyReward>> getAvailableRewards(String userId) async {
    // Return mock rewards
    return [
      LoyaltyReward(
        id: 'free_drink',
        name: 'Free Drink',
        description: 'Get any drink for free',
        pointsCost: 500,
        category: 'beverage',
        isAvailable: true,
        imageUrl: '/images/rewards/free_drink.jpg',
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      ),
      LoyaltyReward(
        id: 'free_side',
        name: 'Free Side',
        description: 'Get any side item for free',
        pointsCost: 750,
        category: 'side',
        isAvailable: true,
        imageUrl: '/images/rewards/free_side.jpg',
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      ),
      LoyaltyReward(
        id: 'discount_10',
        name: '10% Off Order',
        description: 'Get 10% off your entire order',
        pointsCost: 1000,
        category: 'discount',
        isAvailable: true,
        imageUrl: '/images/rewards/discount_10.jpg',
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      ),
      LoyaltyReward(
        id: 'free_sandwich',
        name: 'Free Sandwich',
        description: 'Get any sandwich for free',
        pointsCost: 1500,
        category: 'main',
        isAvailable: true,
        imageUrl: '/images/rewards/free_sandwich.jpg',
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      ),
    ];
  }

  /// 🎁 Redeem specific reward
  Future<RedemptionResult> redeemReward({
    required String userId,
    required String rewardId,
    required String orderId,
  }) async {
    debugPrint('Redeeming reward $rewardId for user $userId');

    return RedemptionResult(
      success: true,
      pointsRedeemed: 500, // Mock points cost
      discountAmount: 0.0, // Rewards don't have discount amounts
      redemptionId: 'rew_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// 📈 Get tier progress
  Future<TierProgress> getTierProgress(String userId) async {
    // Mock tier progress
    return TierProgress(
      currentTier: LoyaltyTier.gold,
      nextTier: LoyaltyTier.platinum,
      currentPoints: 2500,
      pointsToNextTier: 2500, // Need 5000 total for platinum
    );
  }

  /// 🎯 Check if user can redeem points
  bool canRedeemPoints(int currentPoints, {int minimumPoints = 100}) {
    return currentPoints >= minimumPoints;
  }
}
