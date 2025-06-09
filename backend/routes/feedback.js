const express = require('express');
const router = express.Router();
const { logger } = require('../utils/logger');

// In-memory storage for feedback (in production, use a database)
let feedbackStorage = [];

// 📝 POST /api/feedback - Submit new feedback
router.post('/', (req, res) => {
  try {
    const { id, orderId, rating, comments, timestamp, customerEmail } = req.body;

    // Validate required fields
    if (!id || !orderId || !rating || !customerEmail) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: id, orderId, rating, customerEmail'
      });
    }

    // Validate rating range
    if (rating < 1 || rating > 5) {
      return res.status(400).json({
        success: false,
        error: 'Rating must be between 1 and 5'
      });
    }

    const feedback = {
      id,
      orderId,
      rating: parseInt(rating),
      comments: comments || '',
      timestamp: timestamp || new Date().toISOString(),
      customerEmail,
      createdAt: new Date().toISOString()
    };

    feedbackStorage.push(feedback);
    
    logger.info(`New feedback submitted for order ${orderId} with rating ${rating}`);

    res.status(201).json({
      success: true,
      data: feedback,
      message: 'Feedback submitted successfully'
    });
  } catch (error) {
    logger.error('Error submitting feedback:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to submit feedback'
    });
  }
});

// 📋 GET /api/feedback - Get all feedback
router.get('/', (req, res) => {
  try {
    logger.info('Fetching all feedback');
    
    // Sort by timestamp (newest first)
    const sortedFeedback = feedbackStorage.sort((a, b) => 
      new Date(b.timestamp) - new Date(a.timestamp)
    );

    res.json({
      success: true,
      data: sortedFeedback,
      count: sortedFeedback.length,
      message: 'Feedback retrieved successfully'
    });
  } catch (error) {
    logger.error('Error fetching feedback:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch feedback'
    });
  }
});

// 🔍 GET /api/feedback/order/:orderId - Get feedback by order ID
router.get('/order/:orderId', (req, res) => {
  try {
    const { orderId } = req.params;
    logger.info(`Fetching feedback for order: ${orderId}`);
    
    const orderFeedback = feedbackStorage.filter(feedback => 
      feedback.orderId === orderId
    );

    res.json({
      success: true,
      data: orderFeedback,
      count: orderFeedback.length,
      message: `Feedback for order ${orderId} retrieved successfully`
    });
  } catch (error) {
    logger.error('Error fetching order feedback:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch order feedback'
    });
  }
});

// 📊 GET /api/feedback/stats - Get feedback statistics
router.get('/stats', (req, res) => {
  try {
    logger.info('Fetching feedback statistics');
    
    if (feedbackStorage.length === 0) {
      return res.json({
        success: true,
        data: {
          totalFeedback: 0,
          averageRating: 0,
          ratingDistribution: { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 },
          recentFeedback: []
        },
        message: 'No feedback available'
      });
    }

    const totalFeedback = feedbackStorage.length;
    const totalRating = feedbackStorage.reduce((sum, feedback) => sum + feedback.rating, 0);
    const averageRating = (totalRating / totalFeedback).toFixed(2);

    const ratingDistribution = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
    feedbackStorage.forEach(feedback => {
      ratingDistribution[feedback.rating]++;
    });

    const recentFeedback = feedbackStorage
      .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp))
      .slice(0, 10);

    res.json({
      success: true,
      data: {
        totalFeedback,
        averageRating: parseFloat(averageRating),
        ratingDistribution,
        recentFeedback
      },
      message: 'Feedback statistics retrieved successfully'
    });
  } catch (error) {
    logger.error('Error fetching feedback stats:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch feedback statistics'
    });
  }
});

// 🗑️ DELETE /api/feedback/:id - Delete feedback (admin only)
router.delete('/:id', (req, res) => {
  try {
    const { id } = req.params;
    logger.info(`Deleting feedback: ${id}`);
    
    const initialLength = feedbackStorage.length;
    feedbackStorage = feedbackStorage.filter(feedback => feedback.id !== id);
    
    if (feedbackStorage.length === initialLength) {
      return res.status(404).json({
        success: false,
        error: 'Feedback not found'
      });
    }

    res.json({
      success: true,
      message: 'Feedback deleted successfully'
    });
  } catch (error) {
    logger.error('Error deleting feedback:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete feedback'
    });
  }
});

module.exports = router;
