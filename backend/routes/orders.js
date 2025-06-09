// 🛒 Order Routes
// This handles order creation, tracking, and management

const express = require('express');
const { body, validationResult } = require('express-validator');
const admin = require('firebase-admin');
const { verifyToken, requireAdmin } = require('../middleware/auth');
const { logger } = require('../utils/logger');

const router = express.Router();

// Order status constants
const ORDER_STATUS = {
  PENDING: 'pending',
  CONFIRMED: 'confirmed',
  PREPARING: 'preparing',
  READY: 'ready',
  COMPLETED: 'completed',
  CANCELLED: 'cancelled'
};

// 📝 POST /api/orders - Create new order
router.post('/', [
  verifyToken,
  body('items').isArray({ min: 1 }),
  body('items.*.id').notEmpty(),
  body('items.*.quantity').isInt({ min: 1 }),
  body('totalAmount').isFloat({ min: 0 }),
  body('customerInfo.name').trim().notEmpty(),
  body('customerInfo.phone').isMobilePhone()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { items, totalAmount, customerInfo, specialInstructions, pickupTime } = req.body;
    
    logger.info(`Creating order for user: ${req.user.uid}`);

    // Generate order number
    const orderNumber = `CC${Date.now()}${Math.floor(Math.random() * 1000)}`;
    
    // Calculate estimated ready time (15-30 minutes from now)
    const estimatedMinutes = 15 + Math.floor(Math.random() * 15);
    const estimatedReady = new Date(Date.now() + estimatedMinutes * 60000);

    const orderData = {
      orderNumber,
      userId: req.user.uid,
      customerInfo: {
        name: customerInfo.name,
        phone: customerInfo.phone,
        email: req.user.email
      },
      items: items.map(item => ({
        id: item.id,
        name: item.name,
        quantity: item.quantity,
        price: item.price,
        customizations: item.customizations || {},
        selectedSize: item.selectedSize || null,
        selectedSauces: item.selectedSauces || []
      })),
      totalAmount,
      status: ORDER_STATUS.PENDING,
      specialInstructions: specialInstructions || '',
      pickupTime: pickupTime ? new Date(pickupTime) : null,
      estimatedReady,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };

    // Save order to Firestore
    const orderRef = await admin.firestore()
      .collection('orders')
      .add(orderData);

    logger.info(`Order created successfully: ${orderNumber}`);

    // TODO: Send order to kitchen system (Revel POS integration)
    // TODO: Send confirmation email/SMS to customer

    res.status(201).json({
      success: true,
      data: {
        orderId: orderRef.id,
        orderNumber,
        status: ORDER_STATUS.PENDING,
        estimatedReady,
        totalAmount
      },
      message: 'Order placed successfully'
    });

  } catch (error) {
    logger.error('Error creating order:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create order'
    });
  }
});

// 📋 GET /api/orders - Get user's order history
router.get('/', verifyToken, async (req, res) => {
  try {
    const { limit = 10, status } = req.query;
    
    logger.info(`Fetching orders for user: ${req.user.uid}`);

    let query = admin.firestore()
      .collection('orders')
      .where('userId', '==', req.user.uid)
      .orderBy('createdAt', 'desc')
      .limit(parseInt(limit));

    if (status) {
      query = query.where('status', '==', status);
    }

    const snapshot = await query.get();
    
    const orders = [];
    snapshot.forEach(doc => {
      orders.push({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt?.toDate(),
        updatedAt: doc.data().updatedAt?.toDate(),
        estimatedReady: doc.data().estimatedReady?.toDate(),
        pickupTime: doc.data().pickupTime?.toDate()
      });
    });

    res.json({
      success: true,
      data: orders,
      message: `Retrieved ${orders.length} orders`
    });

  } catch (error) {
    logger.error('Error fetching orders:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch orders'
    });
  }
});

// 🎯 GET /api/orders/:orderId - Get specific order details
router.get('/:orderId', verifyToken, async (req, res) => {
  try {
    const { orderId } = req.params;
    
    logger.info(`Fetching order details: ${orderId} for user: ${req.user.uid}`);

    const orderDoc = await admin.firestore()
      .collection('orders')
      .doc(orderId)
      .get();

    if (!orderDoc.exists) {
      return res.status(404).json({
        success: false,
        error: 'Order not found'
      });
    }

    const orderData = orderDoc.data();
    
    // Check if user owns this order
    if (orderData.userId !== req.user.uid) {
      return res.status(403).json({
        success: false,
        error: 'Access denied'
      });
    }

    res.json({
      success: true,
      data: {
        id: orderDoc.id,
        ...orderData,
        createdAt: orderData.createdAt?.toDate(),
        updatedAt: orderData.updatedAt?.toDate(),
        estimatedReady: orderData.estimatedReady?.toDate(),
        pickupTime: orderData.pickupTime?.toDate()
      },
      message: 'Order retrieved successfully'
    });

  } catch (error) {
    logger.error('Error fetching order:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch order'
    });
  }
});

// ✏️ PUT /api/orders/:orderId/status - Update order status (Admin only)
router.put('/:orderId/status', [
  verifyToken,
  requireAdmin,
  body('status').isIn(Object.values(ORDER_STATUS))
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: 'Invalid status',
        details: errors.array()
      });
    }

    const { orderId } = req.params;
    const { status, notes } = req.body;
    
    logger.info(`Updating order ${orderId} status to: ${status}`);

    const updateData = {
      status,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      ...(notes && { statusNotes: notes })
    };

    await admin.firestore()
      .collection('orders')
      .doc(orderId)
      .update(updateData);

    // TODO: Send status update notification to customer
    // TODO: Update kitchen display system

    logger.info(`Order ${orderId} status updated to: ${status}`);

    res.json({
      success: true,
      message: 'Order status updated successfully'
    });

  } catch (error) {
    logger.error('Error updating order status:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update order status'
    });
  }
});

// ❌ PUT /api/orders/:orderId/cancel - Cancel order
router.put('/:orderId/cancel', verifyToken, async (req, res) => {
  try {
    const { orderId } = req.params;
    const { reason } = req.body;
    
    logger.info(`Cancelling order: ${orderId} for user: ${req.user.uid}`);

    const orderDoc = await admin.firestore()
      .collection('orders')
      .doc(orderId)
      .get();

    if (!orderDoc.exists) {
      return res.status(404).json({
        success: false,
        error: 'Order not found'
      });
    }

    const orderData = orderDoc.data();
    
    // Check if user owns this order
    if (orderData.userId !== req.user.uid) {
      return res.status(403).json({
        success: false,
        error: 'Access denied'
      });
    }

    // Check if order can be cancelled
    if ([ORDER_STATUS.COMPLETED, ORDER_STATUS.CANCELLED].includes(orderData.status)) {
      return res.status(400).json({
        success: false,
        error: 'Order cannot be cancelled'
      });
    }

    await admin.firestore()
      .collection('orders')
      .doc(orderId)
      .update({
        status: ORDER_STATUS.CANCELLED,
        cancellationReason: reason || 'Customer request',
        cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

    logger.info(`Order cancelled successfully: ${orderId}`);

    res.json({
      success: true,
      message: 'Order cancelled successfully'
    });

  } catch (error) {
    logger.error('Error cancelling order:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to cancel order'
    });
  }
});

module.exports = router;
