#!/usr/bin/env node

/**
 * 🧪 Loyalty API Test Script
 * Tests all loyalty program endpoints
 */

const axios = require('axios');

const BASE_URL = 'http://localhost:3001/api';
const TEST_USER_ID = 'test_user_123';

async function testLoyaltyAPI() {
  console.log('🧪 Testing Loyalty Program API...\n');

  try {
    // Test 1: Get loyalty account
    console.log('1️⃣ Testing: Get Loyalty Account');
    const accountResponse = await axios.get(`${BASE_URL}/users/${TEST_USER_ID}/loyalty`);
    console.log('✅ Success:', accountResponse.data);
    console.log('');

    // Test 2: Award points for purchase
    console.log('2️⃣ Testing: Award Points for Purchase');
    const awardResponse = await axios.post(`${BASE_URL}/users/${TEST_USER_ID}/loyalty/award`, {
      points: 25,
      orderId: 'test_order_001',
      orderAmount: 25.99,
      type: 'purchase',
      description: 'Points earned from test order'
    });
    console.log('✅ Success:', awardResponse.data);
    console.log('');

    // Test 3: Get updated account
    console.log('3️⃣ Testing: Get Updated Account');
    const updatedAccountResponse = await axios.get(`${BASE_URL}/users/${TEST_USER_ID}/loyalty`);
    console.log('✅ Success:', updatedAccountResponse.data);
    console.log('');

    // Test 4: Get available rewards
    console.log('4️⃣ Testing: Get Available Rewards');
    const rewardsResponse = await axios.get(`${BASE_URL}/users/${TEST_USER_ID}/loyalty/rewards`);
    console.log('✅ Success:', rewardsResponse.data);
    console.log('');

    // Test 5: Redeem points
    console.log('5️⃣ Testing: Redeem Points');
    const redeemResponse = await axios.post(`${BASE_URL}/users/${TEST_USER_ID}/loyalty/redeem`, {
      points: 50,
      orderId: 'test_order_002',
      type: 'discount',
      description: 'Points redeemed for test discount'
    });
    console.log('✅ Success:', redeemResponse.data);
    console.log('');

    // Test 6: Get points history
    console.log('6️⃣ Testing: Get Points History');
    const historyResponse = await axios.get(`${BASE_URL}/users/${TEST_USER_ID}/loyalty/history`);
    console.log('✅ Success:', historyResponse.data);
    console.log('');

    // Test 7: Get tier progress
    console.log('7️⃣ Testing: Get Tier Progress');
    const tierResponse = await axios.get(`${BASE_URL}/users/${TEST_USER_ID}/loyalty/tier-progress`);
    console.log('✅ Success:', tierResponse.data);
    console.log('');

    // Test 8: Redeem specific reward
    console.log('8️⃣ Testing: Redeem Specific Reward');
    const rewardRedeemResponse = await axios.post(`${BASE_URL}/users/${TEST_USER_ID}/loyalty/rewards/free_drink/redeem`, {
      orderId: 'test_order_003'
    });
    console.log('✅ Success:', rewardRedeemResponse.data);
    console.log('');

    // Test 9: Get loyalty statistics
    console.log('9️⃣ Testing: Get Loyalty Statistics');
    const statsResponse = await axios.get(`${BASE_URL}/users/${TEST_USER_ID}/loyalty/statistics`);
    console.log('✅ Success:', statsResponse.data);
    console.log('');

    console.log('🎉 All loyalty API tests passed successfully!');

  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
  }
}

// Run tests
testLoyaltyAPI();
