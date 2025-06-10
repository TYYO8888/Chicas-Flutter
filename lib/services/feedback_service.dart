import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feedback.dart';

class FeedbackService {
  static const String baseUrl = 'http://localhost:3000/api';
  static const String _feedbackKey = 'stored_feedback';

  /// 📝 Submit feedback (with local storage fallback)
  Future<bool> submitFeedback(Feedback feedback) async {
    try {
      // Try to submit to backend first (if available)
      if (!kIsWeb) {
        // For mobile apps, try HTTP request
        try {
          // This will fail gracefully if no backend is available
          await _submitToBackend(feedback);
        } catch (e) {
          debugPrint('Backend not available, storing locally: $e');
        }
      }

      // Always store locally as backup/primary storage
      await _storeLocally(feedback);

      debugPrint('✅ Feedback submitted successfully');
      debugPrint('📝 Order: ${feedback.orderId}');
      debugPrint('⭐ Rating: ${feedback.rating}/5');
      debugPrint('💬 Comment: ${feedback.comments}');

      return true;
    } catch (e) {
      debugPrint('❌ Error submitting feedback: $e');
      return false;
    }
  }

  /// 🌐 Submit to backend server
  Future<void> _submitToBackend(Feedback feedback) async {
    // This is kept for future backend integration
    // For now, it will timeout gracefully
    throw Exception('Backend not configured');
  }

  /// 💾 Store feedback locally
  Future<void> _storeLocally(Feedback feedback) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing feedback
      final existingFeedbackJson = prefs.getStringList(_feedbackKey) ?? [];

      // Add new feedback
      existingFeedbackJson.add(jsonEncode(feedback.toJson()));

      // Store updated list
      await prefs.setStringList(_feedbackKey, existingFeedbackJson);

      debugPrint('💾 Feedback stored locally');
    } catch (e) {
      debugPrint('❌ Failed to store feedback locally: $e');
      rethrow;
    }
  }

  /// 📋 Get all feedback (from local storage)
  Future<List<Feedback>> getAllFeedback() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final feedbackJsonList = prefs.getStringList(_feedbackKey) ?? [];

      return feedbackJsonList.map((jsonString) {
        final json = jsonDecode(jsonString);
        return Feedback.fromJson(json);
      }).toList();
    } catch (e) {
      debugPrint('❌ Error fetching feedback: $e');
      return [];
    }
  }

  /// 🔍 Get feedback by order ID (from local storage)
  Future<List<Feedback>> getFeedbackByOrderId(String orderId) async {
    try {
      final allFeedback = await getAllFeedback();
      return allFeedback.where((feedback) => feedback.orderId == orderId).toList();
    } catch (e) {
      debugPrint('❌ Error fetching feedback for order: $e');
      return [];
    }
  }

  /// 📊 Get feedback statistics (from local storage)
  Future<Map<String, dynamic>> getFeedbackStats() async {
    try {
      final allFeedback = await getAllFeedback();

      if (allFeedback.isEmpty) {
        return {
          'totalFeedback': 0,
          'averageRating': 0.0,
          'ratingDistribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        };
      }

      final totalFeedback = allFeedback.length;
      final totalRating = allFeedback.fold(0, (sum, feedback) => sum + feedback.rating);
      final averageRating = totalRating / totalFeedback;

      final ratingDistribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (final feedback in allFeedback) {
        ratingDistribution[feedback.rating] = (ratingDistribution[feedback.rating] ?? 0) + 1;
      }

      return {
        'totalFeedback': totalFeedback,
        'averageRating': averageRating,
        'ratingDistribution': ratingDistribution,
      };
    } catch (e) {
      debugPrint('❌ Error fetching feedback stats: $e');
      return {};
    }
  }

  /// 🗑️ Clear all feedback (for testing purposes)
  Future<bool> clearAllFeedback() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_feedbackKey);
      debugPrint('🗑️ All feedback cleared');
      return true;
    } catch (e) {
      debugPrint('❌ Error clearing feedback: $e');
      return false;
    }
  }
}
