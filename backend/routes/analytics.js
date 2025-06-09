// 📊 Analytics Routes
// This handles analytics and reporting for business insights

const express = require('express');
const admin = require('firebase-admin');
const { verifyToken, requireAdmin } = require('../middleware/auth');
const { logger } = require('../utils/logger');

const router = express.Router();

// 📈 GET /api/analytics/dashboard - Get dashboard analytics (Admin only)
router.get('/dashboard', [verifyToken, requireAdmin], async (req, res) => {
  try {
    const { period = '7d' } = req.query; // 1d, 7d, 30d, 90d
    
    logger.info(`Fetching dashboard analytics for period: ${period}`);

    // Calculate date range
    const now = new Date();
    let startDate;
    
    switch (period) {
      case '1d':
        startDate = new Date(now.getTime() - 24 * 60 * 60 * 1000);
        break;
      case '7d':
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        break;
      case '30d':
        startDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
        break;
      case '90d':
        startDate = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);
        break;
      default:
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    }

    // Get orders in date range
    const ordersSnapshot = await admin.firestore()
      .collection('orders')
      .where('createdAt', '>=', startDate)
      .where('createdAt', '<=', now)
      .get();

    const orders = [];
    ordersSnapshot.forEach(doc => {
      orders.push({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt?.toDate()
      });
    });

    // Calculate metrics
    const totalOrders = orders.length;
    const totalRevenue = orders
      .filter(order => order.status !== 'cancelled')
      .reduce((sum, order) => sum + (order.totalAmount || 0), 0);
    
    const averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;
    
    // Order status breakdown
    const statusBreakdown = orders.reduce((acc, order) => {
      acc[order.status] = (acc[order.status] || 0) + 1;
      return acc;
    }, {});

    // Popular items analysis
    const itemCounts = {};
    orders.forEach(order => {
      if (order.items) {
        order.items.forEach(item => {
          const key = item.id || item.name;
          itemCounts[key] = (itemCounts[key] || 0) + item.quantity;
        });
      }
    });

    const popularItems = Object.entries(itemCounts)
      .sort(([,a], [,b]) => b - a)
      .slice(0, 10)
      .map(([item, count]) => ({ item, count }));

    // Hourly order distribution
    const hourlyDistribution = Array(24).fill(0);
    orders.forEach(order => {
      if (order.createdAt) {
        const hour = order.createdAt.getHours();
        hourlyDistribution[hour]++;
      }
    });

    // Peak hours (top 3)
    const peakHours = hourlyDistribution
      .map((count, hour) => ({ hour, count }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 3);

    const analytics = {
      period,
      dateRange: {
        start: startDate.toISOString(),
        end: now.toISOString()
      },
      summary: {
        totalOrders,
        totalRevenue: Math.round(totalRevenue * 100) / 100,
        averageOrderValue: Math.round(averageOrderValue * 100) / 100,
        completionRate: totalOrders > 0 ? 
          Math.round((statusBreakdown.completed || 0) / totalOrders * 100) : 0
      },
      orderStatus: statusBreakdown,
      popularItems,
      peakHours,
      hourlyDistribution
    };

    res.json({
      success: true,
      data: analytics,
      message: 'Dashboard analytics retrieved successfully'
    });

  } catch (error) {
    logger.error('Error fetching dashboard analytics:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch analytics'
    });
  }
});

// 📊 GET /api/analytics/sales - Get sales analytics (Admin only)
router.get('/sales', [verifyToken, requireAdmin], async (req, res) => {
  try {
    const { period = '30d', groupBy = 'day' } = req.query; // day, week, month
    
    logger.info(`Fetching sales analytics for period: ${period}, grouped by: ${groupBy}`);

    // Calculate date range
    const now = new Date();
    let startDate;
    
    switch (period) {
      case '7d':
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        break;
      case '30d':
        startDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
        break;
      case '90d':
        startDate = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);
        break;
      case '1y':
        startDate = new Date(now.getTime() - 365 * 24 * 60 * 60 * 1000);
        break;
      default:
        startDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
    }

    // Get completed orders in date range
    const ordersSnapshot = await admin.firestore()
      .collection('orders')
      .where('createdAt', '>=', startDate)
      .where('createdAt', '<=', now)
      .where('status', '==', 'completed')
      .get();

    const orders = [];
    ordersSnapshot.forEach(doc => {
      orders.push({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt?.toDate()
      });
    });

    // Group sales data
    const salesData = {};
    
    orders.forEach(order => {
      let key;
      const date = order.createdAt;
      
      switch (groupBy) {
        case 'day':
          key = date.toISOString().split('T')[0]; // YYYY-MM-DD
          break;
        case 'week':
          const weekStart = new Date(date);
          weekStart.setDate(date.getDate() - date.getDay());
          key = weekStart.toISOString().split('T')[0];
          break;
        case 'month':
          key = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
          break;
        default:
          key = date.toISOString().split('T')[0];
      }
      
      if (!salesData[key]) {
        salesData[key] = {
          date: key,
          revenue: 0,
          orders: 0,
          averageOrderValue: 0
        };
      }
      
      salesData[key].revenue += order.totalAmount || 0;
      salesData[key].orders += 1;
    });

    // Calculate average order values
    Object.values(salesData).forEach(data => {
      data.averageOrderValue = data.orders > 0 ? data.revenue / data.orders : 0;
      data.revenue = Math.round(data.revenue * 100) / 100;
      data.averageOrderValue = Math.round(data.averageOrderValue * 100) / 100;
    });

    // Sort by date
    const sortedSalesData = Object.values(salesData).sort((a, b) => 
      new Date(a.date) - new Date(b.date)
    );

    res.json({
      success: true,
      data: {
        period,
        groupBy,
        salesData: sortedSalesData,
        totalRevenue: sortedSalesData.reduce((sum, data) => sum + data.revenue, 0),
        totalOrders: sortedSalesData.reduce((sum, data) => sum + data.orders, 0)
      },
      message: 'Sales analytics retrieved successfully'
    });

  } catch (error) {
    logger.error('Error fetching sales analytics:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch sales analytics'
    });
  }
});

// 🍗 GET /api/analytics/menu-performance - Get menu item performance
router.get('/menu-performance', [verifyToken, requireAdmin], async (req, res) => {
  try {
    const { period = '30d' } = req.query;
    
    logger.info(`Fetching menu performance analytics for period: ${period}`);

    // Calculate date range
    const now = new Date();
    let startDate;
    
    switch (period) {
      case '7d':
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        break;
      case '30d':
        startDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
        break;
      case '90d':
        startDate = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);
        break;
      default:
        startDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
    }

    // Get orders in date range
    const ordersSnapshot = await admin.firestore()
      .collection('orders')
      .where('createdAt', '>=', startDate)
      .where('createdAt', '<=', now)
      .where('status', '!=', 'cancelled')
      .get();

    const itemPerformance = {};
    let totalRevenue = 0;

    ordersSnapshot.forEach(doc => {
      const order = doc.data();
      if (order.items) {
        order.items.forEach(item => {
          const key = item.id || item.name;
          const itemRevenue = (item.price || 0) * (item.quantity || 1);
          
          if (!itemPerformance[key]) {
            itemPerformance[key] = {
              id: item.id,
              name: item.name || key,
              totalQuantity: 0,
              totalRevenue: 0,
              averagePrice: 0,
              orderCount: 0
            };
          }
          
          itemPerformance[key].totalQuantity += item.quantity || 1;
          itemPerformance[key].totalRevenue += itemRevenue;
          itemPerformance[key].orderCount += 1;
          totalRevenue += itemRevenue;
        });
      }
    });

    // Calculate percentages and sort
    const performanceData = Object.values(itemPerformance)
      .map(item => ({
        ...item,
        averagePrice: item.totalQuantity > 0 ? item.totalRevenue / item.totalQuantity : 0,
        revenuePercentage: totalRevenue > 0 ? (item.totalRevenue / totalRevenue) * 100 : 0,
        totalRevenue: Math.round(item.totalRevenue * 100) / 100,
        averagePrice: Math.round((item.totalRevenue / item.totalQuantity) * 100) / 100
      }))
      .sort((a, b) => b.totalRevenue - a.totalRevenue);

    res.json({
      success: true,
      data: {
        period,
        totalItems: performanceData.length,
        totalRevenue: Math.round(totalRevenue * 100) / 100,
        items: performanceData
      },
      message: 'Menu performance analytics retrieved successfully'
    });

  } catch (error) {
    logger.error('Error fetching menu performance:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch menu performance'
    });
  }
});

module.exports = router;
