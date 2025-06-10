import 'package:flutter/material.dart';

/// 🏆 Loyalty Tier Levels
enum LoyaltyTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
}

extension LoyaltyTierExtension on LoyaltyTier {
  String get name {
    switch (this) {
      case LoyaltyTier.bronze:
        return 'Bronze';
      case LoyaltyTier.silver:
        return 'Silver';
      case LoyaltyTier.gold:
        return 'Gold';
      case LoyaltyTier.platinum:
        return 'Platinum';
      case LoyaltyTier.diamond:
        return 'Diamond';
    }
  }

  Color get color {
    switch (this) {
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

  IconData get icon {
    switch (this) {
      case LoyaltyTier.bronze:
        return Icons.military_tech;
      case LoyaltyTier.silver:
        return Icons.workspace_premium;
      case LoyaltyTier.gold:
        return Icons.emoji_events;
      case LoyaltyTier.platinum:
        return Icons.diamond;
      case LoyaltyTier.diamond:
        return Icons.auto_awesome;
    }
  }

  int get pointsRequired {
    switch (this) {
      case LoyaltyTier.bronze:
        return 0;
      case LoyaltyTier.silver:
        return 1000;
      case LoyaltyTier.gold:
        return 2500;
      case LoyaltyTier.platinum:
        return 5000;
      case LoyaltyTier.diamond:
        return 10000;
    }
  }

  double get multiplier {
    switch (this) {
      case LoyaltyTier.bronze:
        return 1.0;
      case LoyaltyTier.silver:
        return 1.1;
      case LoyaltyTier.gold:
        return 1.25;
      case LoyaltyTier.platinum:
        return 1.5;
      case LoyaltyTier.diamond:
        return 2.0;
    }
  }

  List<String> get benefits {
    switch (this) {
      case LoyaltyTier.bronze:
        return ['Earn 1 point per \$1 spent', 'Birthday bonus'];
      case LoyaltyTier.silver:
        return ['Earn 1.1x points', 'Free drink on birthday', 'Early access to new items'];
      case LoyaltyTier.gold:
        return ['Earn 1.25x points', 'Free meal on birthday', 'Priority customer service'];
      case LoyaltyTier.platinum:
        return ['Earn 1.5x points', 'Free meal + dessert on birthday', 'Exclusive menu items'];
      case LoyaltyTier.diamond:
        return ['Earn 2x points', 'VIP treatment', 'Personal chef consultation'];
    }
  }
}

/// 🏆 Loyalty Account
class LoyaltyAccount {
  final String userId;
  final int currentPoints;
  final int lifetimePoints;
  final LoyaltyTier tier;
  final DateTime joinDate;
  final DateTime lastActivity;
  final String? referralCode;
  final int totalOrders;
  final double totalSpent;

  LoyaltyAccount({
    required this.userId,
    required this.currentPoints,
    required this.lifetimePoints,
    required this.tier,
    required this.joinDate,
    required this.lastActivity,
    this.referralCode,
    this.totalOrders = 0,
    this.totalSpent = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentPoints': currentPoints,
      'lifetimePoints': lifetimePoints,
      'tier': tier.toString(),
      'joinDate': joinDate.toIso8601String(),
      'lastActivity': lastActivity.toIso8601String(),
      'referralCode': referralCode,
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
    };
  }

  factory LoyaltyAccount.fromJson(Map<String, dynamic> json) {
    return LoyaltyAccount(
      userId: json['userId'],
      currentPoints: json['currentPoints'],
      lifetimePoints: json['lifetimePoints'],
      tier: LoyaltyTier.values.firstWhere(
        (e) => e.toString() == json['tier'],
        orElse: () => LoyaltyTier.bronze,
      ),
      joinDate: DateTime.parse(json['joinDate']),
      lastActivity: DateTime.parse(json['lastActivity']),
      referralCode: json['referralCode'],
      totalOrders: json['totalOrders'] ?? 0,
      totalSpent: (json['totalSpent'] ?? 0.0).toDouble(),
    );
  }

  double get dollarValue => currentPoints * 0.01; // 1 point = $0.01
  
  bool get canRedeemPoints => currentPoints >= 100; // Minimum 100 points to redeem
  
  int get daysAsMember => DateTime.now().difference(joinDate).inDays;
}

/// 💰 Points Transaction
class PointsTransaction {
  final String id;
  final String userId;
  final int points;
  final String type;
  final String description;
  final DateTime createdAt;
  final String? orderId;
  final String? rewardId;
  final Map<String, dynamic>? metadata;

  PointsTransaction({
    required this.id,
    required this.userId,
    required this.points,
    required this.type,
    required this.description,
    required this.createdAt,
    this.orderId,
    this.rewardId,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'points': points,
      'type': type,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'orderId': orderId,
      'rewardId': rewardId,
      'metadata': metadata,
    };
  }

  factory PointsTransaction.fromJson(Map<String, dynamic> json) {
    return PointsTransaction(
      id: json['id'],
      userId: json['userId'],
      points: json['points'],
      type: json['type'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      orderId: json['orderId'],
      rewardId: json['rewardId'],
      metadata: json['metadata'],
    );
  }

  bool get isEarned => points > 0;
  bool get isRedeemed => points < 0;

  IconData get icon {
    switch (type) {
      case 'purchase':
        return Icons.shopping_cart;
      case 'signup_bonus':
        return Icons.card_giftcard;
      case 'referral_bonus':
        return Icons.people;
      case 'birthday_bonus':
        return Icons.cake;
      case 'challenge_completion':
        return Icons.emoji_events;
      case 'redemption':
        return Icons.redeem;
      default:
        return Icons.stars;
    }
  }

  Color get color {
    return isEarned ? Colors.green : Colors.orange;
  }
}

/// 🎁 Loyalty Reward
class LoyaltyReward {
  final String id;
  final String name;
  final String description;
  final int pointsCost;
  final String category;
  final bool isAvailable;
  final String? imageUrl;
  final DateTime? expiresAt;
  final int? maxRedemptions;
  final int? currentRedemptions;

  LoyaltyReward({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsCost,
    required this.category,
    required this.isAvailable,
    this.imageUrl,
    this.expiresAt,
    this.maxRedemptions,
    this.currentRedemptions,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pointsCost': pointsCost,
      'category': category,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
      'expiresAt': expiresAt?.toIso8601String(),
      'maxRedemptions': maxRedemptions,
      'currentRedemptions': currentRedemptions,
    };
  }

  factory LoyaltyReward.fromJson(Map<String, dynamic> json) {
    return LoyaltyReward(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      pointsCost: json['pointsCost'],
      category: json['category'],
      isAvailable: json['isAvailable'],
      imageUrl: json['imageUrl'],
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : null,
      maxRedemptions: json['maxRedemptions'],
      currentRedemptions: json['currentRedemptions'],
    );
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  
  bool get isLimitReached => maxRedemptions != null && 
      currentRedemptions != null && 
      currentRedemptions! >= maxRedemptions!;

  double get dollarValue => pointsCost * 0.01;

  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'beverage':
        return Icons.local_drink;
      case 'side':
        return Icons.restaurant;
      case 'main':
        return Icons.lunch_dining;
      case 'dessert':
        return Icons.cake;
      case 'discount':
        return Icons.discount;
      default:
        return Icons.card_giftcard;
    }
  }
}

/// 🎁 Redemption Result
class RedemptionResult {
  final bool success;
  final String? redemptionId;
  final int pointsRedeemed;
  final double discountAmount;
  final String? error;
  final DateTime? expiresAt;

  RedemptionResult({
    required this.success,
    this.redemptionId,
    required this.pointsRedeemed,
    required this.discountAmount,
    this.error,
    this.expiresAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'redemptionId': redemptionId,
      'pointsRedeemed': pointsRedeemed,
      'discountAmount': discountAmount,
      'error': error,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  factory RedemptionResult.fromJson(Map<String, dynamic> json) {
    return RedemptionResult(
      success: json['success'],
      redemptionId: json['redemptionId'],
      pointsRedeemed: json['pointsRedeemed'],
      discountAmount: (json['discountAmount'] ?? 0.0).toDouble(),
      error: json['error'],
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : null,
    );
  }
}

/// 📈 Tier Progress
class TierProgress {
  final LoyaltyTier currentTier;
  final int currentPoints;
  final int pointsToNextTier;
  final LoyaltyTier? nextTier;

  TierProgress({
    required this.currentTier,
    required this.currentPoints,
    required this.pointsToNextTier,
    this.nextTier,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentTier': currentTier.toString(),
      'currentPoints': currentPoints,
      'pointsToNextTier': pointsToNextTier,
      'nextTier': nextTier?.toString(),
    };
  }

  factory TierProgress.fromJson(Map<String, dynamic> json) {
    return TierProgress(
      currentTier: LoyaltyTier.values.firstWhere(
        (e) => e.toString() == json['currentTier'],
        orElse: () => LoyaltyTier.bronze,
      ),
      currentPoints: json['currentPoints'],
      pointsToNextTier: json['pointsToNextTier'],
      nextTier: json['nextTier'] != null
          ? LoyaltyTier.values.firstWhere(
              (e) => e.toString() == json['nextTier'],
              orElse: () => LoyaltyTier.bronze,
            )
          : null,
    );
  }

  double get progressPercentage {
    if (nextTier == null) return 1.0; // Max tier reached
    
    final currentTierPoints = currentTier.pointsRequired;
    final nextTierPoints = nextTier!.pointsRequired;
    final totalPointsNeeded = nextTierPoints - currentTierPoints;
    final pointsEarned = currentPoints - currentTierPoints;
    
    return (pointsEarned / totalPointsNeeded).clamp(0.0, 1.0);
  }

  bool get isMaxTier => nextTier == null;
}

/// 🏆 Leaderboard Entry
class LoyaltyLeaderboardEntry {
  final String userId;
  final String userName;
  final String? userAvatar;
  final int points;
  final LoyaltyTier tier;
  final int rank;

  LoyaltyLeaderboardEntry({
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.points,
    required this.tier,
    required this.rank,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'points': points,
      'tier': tier.toString(),
      'rank': rank,
    };
  }

  factory LoyaltyLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LoyaltyLeaderboardEntry(
      userId: json['userId'],
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      points: json['points'],
      tier: LoyaltyTier.values.firstWhere(
        (e) => e.toString() == json['tier'],
        orElse: () => LoyaltyTier.bronze,
      ),
      rank: json['rank'],
    );
  }
}

/// 🎯 Loyalty Challenge
class LoyaltyChallenge {
  final String id;
  final String name;
  final String description;
  final int pointsReward;
  final int progress;
  final int target;
  final bool isCompleted;
  final DateTime expiresAt;
  final String? category;

  LoyaltyChallenge({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsReward,
    required this.progress,
    required this.target,
    required this.isCompleted,
    required this.expiresAt,
    this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pointsReward': pointsReward,
      'progress': progress,
      'target': target,
      'isCompleted': isCompleted,
      'expiresAt': expiresAt.toIso8601String(),
      'category': category,
    };
  }

  factory LoyaltyChallenge.fromJson(Map<String, dynamic> json) {
    return LoyaltyChallenge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      pointsReward: json['pointsReward'],
      progress: json['progress'],
      target: json['target'],
      isCompleted: json['isCompleted'],
      expiresAt: DateTime.parse(json['expiresAt']),
      category: json['category'],
    );
  }

  double get progressPercentage => (progress / target).clamp(0.0, 1.0);
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  int get daysLeft => expiresAt.difference(DateTime.now()).inDays;
}

/// 📊 Loyalty Statistics
class LoyaltyStatistics {
  final int totalPointsEarned;
  final int totalPointsRedeemed;
  final int totalOrdersWithPoints;
  final double averagePointsPerOrder;
  final String favoriteRewardCategory;
  final DateTime memberSince;

  LoyaltyStatistics({
    required this.totalPointsEarned,
    required this.totalPointsRedeemed,
    required this.totalOrdersWithPoints,
    required this.averagePointsPerOrder,
    required this.favoriteRewardCategory,
    required this.memberSince,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalPointsEarned': totalPointsEarned,
      'totalPointsRedeemed': totalPointsRedeemed,
      'totalOrdersWithPoints': totalOrdersWithPoints,
      'averagePointsPerOrder': averagePointsPerOrder,
      'favoriteRewardCategory': favoriteRewardCategory,
      'memberSince': memberSince.toIso8601String(),
    };
  }

  factory LoyaltyStatistics.fromJson(Map<String, dynamic> json) {
    return LoyaltyStatistics(
      totalPointsEarned: json['totalPointsEarned'],
      totalPointsRedeemed: json['totalPointsRedeemed'],
      totalOrdersWithPoints: json['totalOrdersWithPoints'],
      averagePointsPerOrder: (json['averagePointsPerOrder'] ?? 0.0).toDouble(),
      favoriteRewardCategory: json['favoriteRewardCategory'],
      memberSince: DateTime.parse(json['memberSince']),
    );
  }

  int get netPoints => totalPointsEarned - totalPointsRedeemed;
  
  double get totalDollarValueEarned => totalPointsEarned * 0.01;
  
  double get totalDollarValueRedeemed => totalPointsRedeemed * 0.01;
}
