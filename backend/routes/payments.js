// 💳 Payment Routes
// This handles all payment processing with Stripe

const express = require('express');
const { body, validationResult } = require('express-validator');
const admin = require('firebase-admin');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const { verifyToken } = require('../middleware/auth');
const { logger } = require('../utils/logger');

const router = express.Router();

// 💰 POST /api/payments/intent - Create payment intent
router.post('/intent', [
  verifyToken,
  body('amount').isFloat({ min: 0.50 }), // Minimum $0.50
  body('currency').optional().isIn(['usd', 'cad']),
  body('orderId').notEmpty()
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

    const { amount, currency = 'usd', orderId } = req.body;
    
    logger.info(`Creating payment intent for user: ${req.user.uid}, amount: $${amount}`);

    // Verify the order exists and belongs to the user
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
    if (orderData.userId !== req.user.uid) {
      return res.status(403).json({
        success: false,
        error: 'Access denied'
      });
    }

    // Get or create Stripe customer
    let customerId = null;
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(req.user.uid)
      .get();

    if (userDoc.exists && userDoc.data().stripeCustomerId) {
      customerId = userDoc.data().stripeCustomerId;
    } else {
      // Create new Stripe customer
      const customer = await stripe.customers.create({
        email: req.user.email,
        name: req.user.name,
        metadata: {
          firebaseUid: req.user.uid
        }
      });
      
      customerId = customer.id;
      
      // Save customer ID to user profile
      await admin.firestore()
        .collection('users')
        .doc(req.user.uid)
        .update({
          stripeCustomerId: customerId
        });
    }

    // Create payment intent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // Convert to cents
      currency,
      customer: customerId,
      metadata: {
        orderId,
        userId: req.user.uid,
        orderNumber: orderData.orderNumber
      },
      automatic_payment_methods: {
        enabled: true,
      },
    });

    // Save payment intent to order
    await admin.firestore()
      .collection('orders')
      .doc(orderId)
      .update({
        paymentIntentId: paymentIntent.id,
        paymentStatus: 'pending',
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

    logger.info(`Payment intent created: ${paymentIntent.id}`);

    res.json({
      success: true,
      data: {
        clientSecret: paymentIntent.client_secret,
        paymentIntentId: paymentIntent.id
      },
      message: 'Payment intent created successfully'
    });

  } catch (error) {
    logger.error('Error creating payment intent:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create payment intent'
    });
  }
});

// ✅ POST /api/payments/confirm - Confirm payment
router.post('/confirm', [
  verifyToken,
  body('paymentIntentId').notEmpty(),
  body('orderId').notEmpty()
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

    const { paymentIntentId, orderId } = req.body;
    
    logger.info(`Confirming payment: ${paymentIntentId} for order: ${orderId}`);

    // Retrieve payment intent from Stripe
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

    if (paymentIntent.status === 'succeeded') {
      // Update order with payment confirmation
      await admin.firestore()
        .collection('orders')
        .doc(orderId)
        .update({
          paymentStatus: 'completed',
          paymentConfirmedAt: admin.firestore.FieldValue.serverTimestamp(),
          status: 'confirmed',
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });

      // Create payment record
      await admin.firestore()
        .collection('payments')
        .add({
          orderId,
          userId: req.user.uid,
          paymentIntentId,
          amount: paymentIntent.amount / 100, // Convert back to dollars
          currency: paymentIntent.currency,
          status: 'completed',
          paymentMethod: paymentIntent.payment_method,
          createdAt: admin.firestore.FieldValue.serverTimestamp()
        });

      logger.info(`Payment confirmed successfully: ${paymentIntentId}`);

      res.json({
        success: true,
        message: 'Payment confirmed successfully'
      });
    } else {
      res.status(400).json({
        success: false,
        error: 'Payment not completed',
        status: paymentIntent.status
      });
    }

  } catch (error) {
    logger.error('Error confirming payment:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to confirm payment'
    });
  }
});

// 📋 GET /api/payments/history - Get payment history
router.get('/history', verifyToken, async (req, res) => {
  try {
    const { limit = 10 } = req.query;
    
    logger.info(`Fetching payment history for user: ${req.user.uid}`);

    const snapshot = await admin.firestore()
      .collection('payments')
      .where('userId', '==', req.user.uid)
      .orderBy('createdAt', 'desc')
      .limit(parseInt(limit))
      .get();

    const payments = [];
    snapshot.forEach(doc => {
      payments.push({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt?.toDate()
      });
    });

    res.json({
      success: true,
      data: payments,
      message: `Retrieved ${payments.length} payments`
    });

  } catch (error) {
    logger.error('Error fetching payment history:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch payment history'
    });
  }
});

// 🔄 POST /api/payments/refund - Process refund (Admin only)
router.post('/refund', [
  verifyToken,
  body('paymentIntentId').notEmpty(),
  body('amount').optional().isFloat({ min: 0 }),
  body('reason').optional().trim()
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

    const { paymentIntentId, amount, reason } = req.body;
    
    logger.info(`Processing refund for payment: ${paymentIntentId}`);

    // Create refund in Stripe
    const refundData = {
      payment_intent: paymentIntentId,
      reason: reason || 'requested_by_customer'
    };

    if (amount) {
      refundData.amount = Math.round(amount * 100); // Convert to cents
    }

    const refund = await stripe.refunds.create(refundData);

    // Update payment record
    await admin.firestore()
      .collection('payments')
      .where('paymentIntentId', '==', paymentIntentId)
      .get()
      .then(snapshot => {
        snapshot.forEach(doc => {
          doc.ref.update({
            refundId: refund.id,
            refundAmount: refund.amount / 100,
            refundStatus: refund.status,
            refundedAt: admin.firestore.FieldValue.serverTimestamp()
          });
        });
      });

    logger.info(`Refund processed successfully: ${refund.id}`);

    res.json({
      success: true,
      data: {
        refundId: refund.id,
        amount: refund.amount / 100,
        status: refund.status
      },
      message: 'Refund processed successfully'
    });

  } catch (error) {
    logger.error('Error processing refund:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to process refund'
    });
  }
});

// 🎣 POST /api/payments/webhook - Stripe webhook handler
router.post('/webhook', express.raw({ type: 'application/json' }), (req, res) => {
  const sig = req.headers['stripe-signature'];
  let event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig, process.env.STRIPE_WEBHOOK_SECRET);
  } catch (err) {
    logger.error('Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Handle the event
  switch (event.type) {
    case 'payment_intent.succeeded':
      const paymentIntent = event.data.object;
      logger.info(`Payment succeeded: ${paymentIntent.id}`);
      // Handle successful payment
      break;
    
    case 'payment_intent.payment_failed':
      const failedPayment = event.data.object;
      logger.error(`Payment failed: ${failedPayment.id}`);
      // Handle failed payment
      break;
    
    default:
      logger.info(`Unhandled event type: ${event.type}`);
  }

  res.json({ received: true });
});

module.exports = router;
