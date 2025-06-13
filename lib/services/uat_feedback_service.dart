// 👥 User Acceptance Testing (UAT) Feedback Service
// Comprehensive feedback collection and analysis system for beta testing

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// NOTE: Uncomment when packages are installed
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:package_info_plus/package_info_plus.dart';

/// 👥 UAT Feedback Service
/// 
/// Manages user acceptance testing feedback collection:
/// - In-app feedback forms
/// - Bug reporting with screenshots
/// - Feature usage analytics
/// - User satisfaction surveys
/// - Beta tester management
class UATFeedbackService {
  static UATFeedbackService? _instance;
  static UATFeedbackService get instance => _instance ??= UATFeedbackService._();
  UATFeedbackService._();

  static const String _baseUrl = 'https://api.chicaschicken.com/uat';
  static const String _feedbackKey = 'uat_feedback_queue';
  
  String? _userId;
  String? _sessionId;
  Map<String, dynamic> _deviceInfo = {};
  List<Map<String, dynamic>> _feedbackQueue = [];
  
  /// 🚀 Initialize UAT feedback service
  Future<void> initialize({String? userId}) async {
    try {
      _userId = userId ?? await _generateAnonymousUserId();
      _sessionId = _generateSessionId();
      
      await _collectDeviceInfo();
      await _loadQueuedFeedback();
      
      debugPrint('👥 UAT Feedback Service initialized for user: $_userId');
    } catch (e) {
      debugPrint('❌ Failed to initialize UAT feedback service: $e');
    }
  }
  
  /// 📝 Submit general feedback
  Future<bool> submitFeedback({
    required String category,
    required String feedback,
    required int rating,
    List<String>? screenshots,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final feedbackData = {
        'id': _generateFeedbackId(),
        'user_id': _userId,
        'session_id': _sessionId,
        'category': category,
        'feedback': feedback,
        'rating': rating,
        'screenshots': screenshots ?? [],
        'metadata': metadata ?? {},
        'device_info': _deviceInfo,
        'timestamp': DateTime.now().toIso8601String(),
        'app_version': await _getAppVersion(),
        'type': 'general_feedback',
      };
      
      return await _submitFeedbackData(feedbackData);
    } catch (e) {
      debugPrint('❌ Failed to submit feedback: $e');
      return false;
    }
  }
  
  /// 🐛 Report bug with detailed context
  Future<bool> reportBug({
    required String title,
    required String description,
    required String stepsToReproduce,
    required String expectedBehavior,
    required String actualBehavior,
    String severity = 'medium',
    List<String>? screenshots,
    Map<String, dynamic>? technicalDetails,
  }) async {
    try {
      final bugReport = {
        'id': _generateFeedbackId(),
        'user_id': _userId,
        'session_id': _sessionId,
        'title': title,
        'description': description,
        'steps_to_reproduce': stepsToReproduce,
        'expected_behavior': expectedBehavior,
        'actual_behavior': actualBehavior,
        'severity': severity,
        'screenshots': screenshots ?? [],
        'technical_details': technicalDetails ?? {},
        'device_info': _deviceInfo,
        'timestamp': DateTime.now().toIso8601String(),
        'app_version': await _getAppVersion(),
        'type': 'bug_report',
      };
      
      return await _submitFeedbackData(bugReport);
    } catch (e) {
      debugPrint('❌ Failed to submit bug report: $e');
      return false;
    }
  }
  
  /// ⭐ Submit feature rating and feedback
  Future<bool> rateFeature({
    required String featureName,
    required int rating,
    required String usabilityFeedback,
    bool wouldRecommend = true,
    List<String>? suggestions,
  }) async {
    try {
      final featureRating = {
        'id': _generateFeedbackId(),
        'user_id': _userId,
        'session_id': _sessionId,
        'feature_name': featureName,
        'rating': rating,
        'usability_feedback': usabilityFeedback,
        'would_recommend': wouldRecommend,
        'suggestions': suggestions ?? [],
        'device_info': _deviceInfo,
        'timestamp': DateTime.now().toIso8601String(),
        'app_version': await _getAppVersion(),
        'type': 'feature_rating',
      };
      
      return await _submitFeedbackData(featureRating);
    } catch (e) {
      debugPrint('❌ Failed to submit feature rating: $e');
      return false;
    }
  }
  
  /// 📊 Submit user journey feedback
  Future<bool> submitJourneyFeedback({
    required String journeyName,
    required List<Map<String, dynamic>> steps,
    required int overallRating,
    required Duration completionTime,
    List<String>? painPoints,
    List<String>? positiveAspects,
  }) async {
    try {
      final journeyFeedback = {
        'id': _generateFeedbackId(),
        'user_id': _userId,
        'session_id': _sessionId,
        'journey_name': journeyName,
        'steps': steps,
        'overall_rating': overallRating,
        'completion_time_ms': completionTime.inMilliseconds,
        'pain_points': painPoints ?? [],
        'positive_aspects': positiveAspects ?? [],
        'device_info': _deviceInfo,
        'timestamp': DateTime.now().toIso8601String(),
        'app_version': await _getAppVersion(),
        'type': 'journey_feedback',
      };
      
      return await _submitFeedbackData(journeyFeedback);
    } catch (e) {
      debugPrint('❌ Failed to submit journey feedback: $e');
      return false;
    }
  }
  
  /// 📱 Track feature usage for analytics
  Future<void> trackFeatureUsage({
    required String featureName,
    required String action,
    Map<String, dynamic>? context,
  }) async {
    try {
      final usageData = {
        'user_id': _userId,
        'session_id': _sessionId,
        'feature_name': featureName,
        'action': action,
        'context': context ?? {},
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'feature_usage',
      };
      
      // Queue for batch submission
      _feedbackQueue.add(usageData);
      
      // Submit if queue is large enough
      if (_feedbackQueue.length >= 10) {
        await _submitQueuedFeedback();
      }
    } catch (e) {
      debugPrint('❌ Failed to track feature usage: $e');
    }
  }
  
  /// 🎯 Submit task completion feedback
  Future<bool> submitTaskCompletion({
    required String taskName,
    required bool completed,
    required Duration timeSpent,
    required int difficultyRating,
    String? failureReason,
    List<String>? suggestions,
  }) async {
    try {
      final taskFeedback = {
        'id': _generateFeedbackId(),
        'user_id': _userId,
        'session_id': _sessionId,
        'task_name': taskName,
        'completed': completed,
        'time_spent_ms': timeSpent.inMilliseconds,
        'difficulty_rating': difficultyRating,
        'failure_reason': failureReason,
        'suggestions': suggestions ?? [],
        'device_info': _deviceInfo,
        'timestamp': DateTime.now().toIso8601String(),
        'app_version': await _getAppVersion(),
        'type': 'task_completion',
      };
      
      return await _submitFeedbackData(taskFeedback);
    } catch (e) {
      debugPrint('❌ Failed to submit task completion: $e');
      return false;
    }
  }
  
  /// 📋 Get feedback prompts for current context
  Future<List<Map<String, dynamic>>> getFeedbackPrompts({
    String? screenName,
    String? featureName,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/prompts'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': _userId ?? '',
          'X-Session-ID': _sessionId ?? '',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['prompts'] ?? []);
      }
    } catch (e) {
      debugPrint('❌ Failed to get feedback prompts: $e');
    }
    
    return _getDefaultPrompts();
  }
  
  /// 📤 Submit feedback data to server
  Future<bool> _submitFeedbackData(Map<String, dynamic> feedbackData) async {
    try {
      // Try to submit immediately
      final response = await http.post(
        Uri.parse('$_baseUrl/feedback'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': _userId ?? '',
          'X-Session-ID': _sessionId ?? '',
        },
        body: jsonEncode(feedbackData),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Feedback submitted successfully');
        return true;
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Failed to submit feedback, queuing for later: $e');
      
      // Queue for later submission
      _feedbackQueue.add(feedbackData);
      await _saveQueuedFeedback();
      return false;
    }
  }
  
  /// 📦 Submit queued feedback in batch
  Future<void> _submitQueuedFeedback() async {
    if (_feedbackQueue.isEmpty) return;
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/feedback/batch'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': _userId ?? '',
          'X-Session-ID': _sessionId ?? '',
        },
        body: jsonEncode({'feedback_items': _feedbackQueue}),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Batch feedback submitted successfully');
        _feedbackQueue.clear();
        await _saveQueuedFeedback();
      }
    } catch (e) {
      debugPrint('❌ Failed to submit batch feedback: $e');
    }
  }
  
  /// 💾 Save queued feedback to local storage
  Future<void> _saveQueuedFeedback() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final feedbackJson = jsonEncode(_feedbackQueue);
      await prefs.setString(_feedbackKey, feedbackJson);
    } catch (e) {
      debugPrint('❌ Failed to save queued feedback: $e');
    }
  }
  
  /// 📂 Load queued feedback from local storage
  Future<void> _loadQueuedFeedback() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final feedbackJson = prefs.getString(_feedbackKey);
      
      if (feedbackJson != null) {
        final feedbackList = jsonDecode(feedbackJson) as List;
        _feedbackQueue = feedbackList.cast<Map<String, dynamic>>();
        
        // Try to submit queued feedback
        if (_feedbackQueue.isNotEmpty) {
          await _submitQueuedFeedback();
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to load queued feedback: $e');
    }
  }
  
  /// 📱 Collect device information
  Future<void> _collectDeviceInfo() async {
    try {
      // NOTE: Uncomment when packages are available
      /*
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      _deviceInfo = {
        'app_version': packageInfo.version,
        'app_build': packageInfo.buildNumber,
        'platform': Platform.operatingSystem,
        'platform_version': Platform.operatingSystemVersion,
      };

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceInfo.addAll({
          'device_model': androidInfo.model,
          'device_manufacturer': androidInfo.manufacturer,
          'android_version': androidInfo.version.release,
        });
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceInfo.addAll({
          'device_model': iosInfo.model,
          'device_name': iosInfo.name,
          'ios_version': iosInfo.systemVersion,
        });
      }
      */

      // Fallback basic info
      _deviceInfo = {
        'platform': Platform.operatingSystem,
        'platform_version': Platform.operatingSystemVersion,
        'app_version': '1.0.0', // Placeholder
      };
    } catch (e) {
      debugPrint('❌ Failed to collect device info: $e');
    }
  }
  
  /// 🆔 Generate anonymous user ID
  Future<String> _generateAnonymousUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('uat_user_id');
    
    if (userId == null) {
      userId = 'uat_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('uat_user_id', userId);
    }
    
    return userId;
  }
  
  /// 🎲 Generate session ID
  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }
  
  /// 🎲 Generate feedback ID
  String _generateFeedbackId() {
    return 'feedback_${DateTime.now().millisecondsSinceEpoch}';
  }
  
  /// 📱 Get app version
  Future<String> _getAppVersion() async {
    try {
      // NOTE: Uncomment when package_info_plus is available
      // final packageInfo = await PackageInfo.fromPlatform();
      // return '${packageInfo.version}+${packageInfo.buildNumber}';
      return '1.0.0+1'; // Placeholder
    } catch (e) {
      return '1.0.0+1';
    }
  }
  
  /// 📋 Get default feedback prompts
  List<Map<String, dynamic>> _getDefaultPrompts() {
    return [
      {
        'id': 'general_satisfaction',
        'type': 'rating',
        'question': 'How satisfied are you with this feature?',
        'scale': 5,
      },
      {
        'id': 'ease_of_use',
        'type': 'rating',
        'question': 'How easy was it to complete this task?',
        'scale': 5,
      },
      {
        'id': 'improvement_suggestions',
        'type': 'text',
        'question': 'What would you improve about this experience?',
      },
    ];
  }
}
