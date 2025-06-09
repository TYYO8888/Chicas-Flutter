import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/feedback.dart';

class FeedbackService {
  static const String baseUrl = 'http://localhost:3000/api';

  // Submit feedback
  Future<bool> submitFeedback(Feedback feedback) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/feedback'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(feedback.toJson()),
      );

      if (response.statusCode == 201) {
        print('Feedback submitted successfully');
        return true;
      } else {
        print('Failed to submit feedback: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error submitting feedback: $e');
      return false;
    }
  }

  // Get all feedback (for admin purposes)
  Future<List<Feedback>> getAllFeedback() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/feedback'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> feedbackList = data['data'];
          return feedbackList.map((json) => Feedback.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching feedback: $e');
      return [];
    }
  }

  // Get feedback by order ID
  Future<List<Feedback>> getFeedbackByOrderId(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/feedback/order/$orderId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> feedbackList = data['data'];
          return feedbackList.map((json) => Feedback.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching feedback for order: $e');
      return [];
    }
  }

  // Get feedback statistics
  Future<Map<String, dynamic>> getFeedbackStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/feedback/stats'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return {};
    } catch (e) {
      print('Error fetching feedback stats: $e');
      return {};
    }
  }
}
