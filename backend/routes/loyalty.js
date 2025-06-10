 feedbackconst express = require('express');
const router = express.Router();
const { logger } = require('../utils/logger');

// 🏆 Loyalty Program Routes
// Implements points system: 1 point per $1 spent

// Mock data for testing (in production, use a database)
const loyaltyAccounts = new Map();
const pointsTransactions = new Map();
const loyaltyRewards = [
  {
    id: 'free_drink',
    name: 'Free Drink',
    description: 'Get any drink for free',
    pointsCost: 500,
    category: 'beverage',
    isAvailable: true,
    imageUrl: '/images/rewards/free_drink.jpg'
  },
  {
    id: 'free_side',
    name: 'Free Side',
    description: 'Get any side item for free',
    pointsCost: 750,
    category: 'side',
    isAvailable: true,
    imageUrl: '/images/rewards/free_side.jpg'
  },
  {
    id: 'discount_10',
    name: '10% Off Order',
    description: 'Get 10% off your entire order',
    pointsCost: 1000,
    category: 'discount',
    isAvailable: true,
    imageUrl: '/images/rewards/discount_10.jpg'
  },
  {
    id: 'free_sandwich',
    name: 'Free Sandwich',
    description: 'Get any sandwich for free',
    pointsCost: 1500,
    category: 'main',
    isAvailable: true,
    imageUrl: '/images/rewards/free_sandwich.jpg'
  }
];

// Helper function to get or create loyalty account
function getOrCreateLoyaltyAccount(userId) {
  if (!loyaltyAccounts.has(userId)) {
    loyaltyAccounts.set(userId, {
      userId,
      currentPoints: 100, // Welcome bonus
      lifetimePoints: 100,
      tier: 'bronze',
      joinDate: new Date().toISOString(),
      lastActivity: new Date().toISOString(),
      totalOrders: 0,
      totalSpent: 0.0,
      referralCode: `CHICA${userId.substring(0, 6).toUpperCase()}`
    });
  }
  return loyaltyAccounts.get(userId);
}

// Helper function to determine tier based on lifetime points
function calculateTier(lifetimePoints) {
  if (lifetimePoints >= 10000) return 'diamond';
  if (lifetimePoints >= 5000) return 'platinum';
  if (lifetimePoints >= 2500) return 'gold';
  if (lifetimePoints >= 1000) return 'silver';
  return 'bronze';
}

// 🏆 GET /api/users/:userId/loyalty - Get loyalty account
router.get('/users/:userId/loyalty', (req, res) => {
  try {
    const { userId } = req.params;
    logger.info(`Fetching loyalty account for user: ${userId}`);

    const account = getOrCreateLoyaltyAccount(userId);
    
    // Update tier based on lifetime points
    account.tier = calculateTier(account.lifetimePoints);

    res.json({
      success: true,
      data: account,
      message: 'Loyalty account retrieved successfully'
    });

  } catch (error) {
    logger.error('Error fetching loyalty account:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch loyalty account'
    });
  }
});

// ⭐ POST /api/users/:userId/loyalty/award - Award points
router.post('/users/:userId/loyalty/award', (req, res) => {
  try {
    const { userId } = req.params;
    const { points, orderId, orderAmount, type, description } = req.body;

    if (!points || points <= 0) {
      return res.status(400).json({
        success: false,
        error: 'Invalid points amount'
      });
    }

    logger.info(`Awarding ${points} points to user: ${userId}`);

    const account = getOrCreateLoyaltyAccount(userId);
    
    // Update account
    account.currentPoints += points;
    account.lifetimePoints += points;
    account.lastActivity = new Date().toISOString();
    
    if (orderAmount) {
      account.totalOrders += 1;
      account.totalSpent += orderAmount;
    }

    // Update tier
    account.tier = calculateTier(account.lifetimePoints);

    // Create transaction record
    const transactionId = `txn_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    const transaction = {
      id: transactionId,
      userId,
      points,
      type: type || 'purchase',
      description: description || `Points earned from order`,
      createdAt: new Date().toISOString(),
      orderId,
      metadata: { orderAmount }
    };

    // Store transaction
    if (!pointsTransactions.has(userId)) {
      pointsTransactions.set(userId, []);
    }
    pointsTransactions.get(userId).unshift(transaction);

    res.json({
      success: true,
      data: transaction,
      message: `${points} points awarded successfully`
    });

  } catch (error) {
    logger.error('Error awarding points:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to award points'
    });
  }
});

// 🎁 POST /api/users/:userId/loyalty/redeem - Redeem points
router.post('/users/:userId/loyalty/redeem', (req, res) => {
  try {
    const { userId } = req.params;
    const { points, orderId, type, description } = req.body;

    if (!points || points <= 0) {
      return res.status(400).json({
        success: false,
        error: 'Invalid points amount'
      });
    }

    const account = getOrCreateLoyaltyAccount(userId);

    if (account.currentPoints < points) {
      return res.status(400).json({
        success: false,
        error: 'Insufficient points'
      });
    }

    logger.info(`Redeeming ${points} points for user: ${userId}`);

    // Update account
    account.currentPoints -= points;
    account.lastActivity = new Date().toISOString();

    // Calculate discount amount (1 point = $0.01)
    const discountAmount = points * 0.01;

    // Create redemption transaction
    const transactionId = `red_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    const transaction = {
      id: transactionId,
      userId,
      points: -points, // Negative for redemption
      type: type || 'redemption',
      description: description || `Points redeemed for discount`,
      createdAt: new Date().toISOString(),
      orderId,
      metadata: { discountAmount }
    };

    // Store transaction
    if (!pointsTransactions.has(userId)) {
      pointsTransactions.set(userId, []);
    }
    pointsTransactions.get(userId).unshift(transaction);

    res.json({
      success: true,
      data: {
        redemptionId: transactionId,
        pointsRedeemed: points,
        discountAmount,
        success: true
      },
      message: `${points} points redeemed successfully`
    });

  } catch (error) {
    logger.error('Error redeeming points:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to redeem points'
    });
  }
});

// 📊 GET /api/users/:userId/loyalty/history - Get points history
router.get('/users/:userId/loyalty/history', (req, res) => {
  try {
    const { userId } = req.params;
    const { page = 1, limit = 20 } = req.query;

    logger.info(`Fetching points history for user: ${userId}`);

    const userTransactions = pointsTransactions.get(userId) || [];
    
    // Apply pagination
    const startIndex = (page - 1) * limit;
    const endIndex = startIndex + parseInt(limit);
    const paginatedTransactions = userTransactions.slice(startIndex, endIndex);

    res.json({
      success: true,
      data: paginatedTransactions,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(userTransactions.length / limit),
        totalItems: userTransactions.length,
        itemsPerPage: parseInt(limit)
      },
      message: `Retrieved ${paginatedTransactions.length} transactions`
    });

  } catch (error) {
    logger.error('Error fetching points history:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch points history'
    });
  }
});

// 🎁 GET /api/users/:userId/loyalty/rewards - Get available rewards
router.get('/users/:userId/loyalty/rewards', (req, res) => {
  try {
    const { userId } = req.params;
    logger.info(`Fetching available rewards for user: ${userId}`);

    const account = getOrCreateLoyaltyAccount(userId);
    
    // Add affordability info to rewards
    const rewardsWithAffordability = loyaltyRewards.map(reward => ({
      ...reward,
      canAfford: account.currentPoints >= reward.pointsCost
    }));

    res.json({
      success: true,
      data: rewardsWithAffordability,
      message: `Retrieved ${rewardsWithAffordability.length} rewards`
    });

  } catch (error) {
    logger.error('Error fetching rewards:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch rewards'
    });
  }
});

// 🎁 POST /api/users/:userId/loyalty/rewards/:rewardId/redeem - Redeem specific reward
router.post('/users/:userId/loyalty/rewards/:rewardId/redeem', (req, res) => {
  try {
    const { userId, rewardId } = req.params;
    const { orderId } = req.body;

    const reward = loyaltyRewards.find(r => r.id === rewardId);
    if (!reward) {
      return res.status(404).json({
        success: false,
        error: 'Reward not found'
      });
    }

    const account = getOrCreateLoyaltyAccount(userId);

    if (account.currentPoints < reward.pointsCost) {
      return res.status(400).json({
        success: false,
        error: 'Insufficient points for this reward'
      });
    }

    logger.info(`Redeeming reward ${rewardId} for user: ${userId}`);

    // Update account
    account.currentPoints -= reward.pointsCost;
    account.lastActivity = new Date().toISOString();

    // Create redemption transaction
    const transactionId = `rew_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    const transaction = {
      id: transactionId,
      userId,
      points: -reward.pointsCost,
      type: 'reward_redemption',
      description: `Redeemed: ${reward.name}`,
      createdAt: new Date().toISOString(),
      orderId,
      rewardId,
      metadata: { rewardName: reward.name, rewardCategory: reward.category }
    };

    // Store transaction
    if (!pointsTransactions.has(userId)) {
      pointsTransactions.set(userId, []);
    }
    pointsTransactions.get(userId).unshift(transaction);

    res.json({
      success: true,
      data: {
        redemptionId: transactionId,
        pointsRedeemed: reward.pointsCost,
        reward: reward,
        success: true
      },
      message: `${reward.name} redeemed successfully`
    });

  } catch (error) {
    logger.error('Error redeeming reward:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to redeem reward'
    });
  }
});

// 📈 GET /api/users/:userId/loyalty/tier-progress - Get tier progress
router.get('/users/:userId/loyalty/tier-progress', (req, res) => {
  try {
    const { userId } = req.params;
    logger.info(`Fetching tier progress for user: ${userId}`);

    const account = getOrCreateLoyaltyAccount(userId);
    
    const tierThresholds = {
      bronze: 0,
      silver: 1000,
      gold: 2500,
      platinum: 5000,
      diamond: 10000
    };

    const currentTier = account.tier;
    const currentPoints = account.lifetimePoints;
    
    // Find next tier
    const tiers = Object.keys(tierThresholds);
    const currentTierIndex = tiers.indexOf(currentTier);
    const nextTier = currentTierIndex < tiers.length - 1 ? tiers[currentTierIndex + 1] : null;
    
    let pointsToNextTier = 0;
    if (nextTier) {
      pointsToNextTier = tierThresholds[nextTier] - currentPoints;
    }

    res.json({
      success: true,
      data: {
        currentTier,
        currentPoints,
        pointsToNextTier,
        nextTier
      },
      message: 'Tier progress retrieved successfully'
    });

  } catch (error) {
    logger.error('Error fetching tier progress:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch tier progress'
    });
  }
});

// 📊 GET /api/users/:userId/loyalty/statistics - Get loyalty statistics
router.get('/users/:userId/loyalty/statistics', (req, res) => {
  try {
    const { userId } = req.params;
    logger.info(`Fetching loyalty statistics for user: ${userId}`);

    const account = getOrCreateLoyaltyAccount(userId);
    const userTransactions = pointsTransactions.get(userId) || [];
    
    const earnedTransactions = userTransactions.filter(t => t.points > 0);
    const redeemedTransactions = userTransactions.filter(t => t.points < 0);
    
    const totalPointsEarned = earnedTransactions.reduce((sum, t) => sum + t.points, 0);
    const totalPointsRedeemed = Math.abs(redeemedTransactions.reduce((sum, t) => sum + t.points, 0));
    
    const statistics = {
      totalPointsEarned,
      totalPointsRedeemed,
      totalOrdersWithPoints: account.totalOrders,
      averagePointsPerOrder: account.totalOrders > 0 ? totalPointsEarned / account.totalOrders : 0,
      favoriteRewardCategory: 'beverage', // Could be calculated from redemption history
      memberSince: account.joinDate
    };

    res.json({
      success: true,
      data: statistics,
      message: 'Loyalty statistics retrieved successfully'
    });

  } catch (error) {
    logger.error('Error fetching loyalty statistics:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch loyalty statistics'
    });
  }
});

module.exports = router;
