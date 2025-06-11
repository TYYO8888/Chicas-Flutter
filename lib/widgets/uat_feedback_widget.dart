// 👥 UAT Feedback Widget
// In-app feedback collection widget for beta testing

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/uat_feedback_service.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';

/// 👥 UAT Feedback Widget
/// 
/// Provides in-app feedback collection for beta testing:
/// - Quick rating system
/// - Detailed feedback forms
/// - Bug reporting
/// - Feature suggestions
/// - Context-aware prompts
class UATFeedbackWidget extends StatefulWidget {
  final String? screenName;
  final String? featureName;
  final bool showFloatingButton;
  final VoidCallback? onFeedbackSubmitted;

  const UATFeedbackWidget({
    super.key,
    this.screenName,
    this.featureName,
    this.showFloatingButton = true,
    this.onFeedbackSubmitted,
  });

  @override
  State<UATFeedbackWidget> createState() => _UATFeedbackWidgetState();
}

class _UATFeedbackWidgetState extends State<UATFeedbackWidget> {
  final UATFeedbackService _feedbackService = UATFeedbackService.instance;
  bool _isVisible = false;
  String _selectedCategory = 'general';
  int _rating = 5;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeFeedbackService();
  }

  Future<void> _initializeFeedbackService() async {
    await _feedbackService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showFloatingButton) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // Floating feedback button
        Positioned(
          bottom: 100,
          right: 16,
          child: _buildFloatingFeedbackButton(),
        ),
        
        // Feedback overlay
        if (_isVisible) _buildFeedbackOverlay(),
      ],
    );
  }

  Widget _buildFloatingFeedbackButton() {
    return FloatingActionButton(
      onPressed: () => setState(() => _isVisible = true),
      backgroundColor: AppColors.primary,
      child: const Icon(
        Icons.feedback,
        color: Colors.white,
      ),
    ).animate()
      .scale(delay: const Duration(seconds: 2))
      .then()
      .shake(duration: const Duration(milliseconds: 500));
  }

  Widget _buildFeedbackOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildCategorySelector(),
                const SizedBox(height: 20),
                _buildRatingSection(),
                const SizedBox(height: 20),
                _buildFeedbackInput(),
                const SizedBox(height: 20),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn()
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.feedback,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'BETA FEEDBACK',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          onPressed: () => setState(() => _isVisible = false),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    final categories = [
      {'id': 'general', 'label': 'GENERAL', 'icon': Icons.chat},
      {'id': 'bug', 'label': 'BUG REPORT', 'icon': Icons.bug_report},
      {'id': 'feature', 'label': 'FEATURE', 'icon': Icons.lightbulb},
      {'id': 'usability', 'label': 'USABILITY', 'icon': Icons.accessibility},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FEEDBACK CATEGORY',
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final isSelected = _selectedCategory == category['id'];
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category['id'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category['label'] as String,
                      style: AppTypography.bodySmall.copyWith(
                        color: isSelected ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HOW WOULD YOU RATE THIS EXPERIENCE?',
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            return GestureDetector(
              onTap: () => setState(() => _rating = starIndex),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  starIndex <= _rating ? Icons.star : Icons.star_border,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
            );
          }),
        ),
        Center(
          child: Text(
            _getRatingLabel(_rating),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TELL US MORE (OPTIONAL)',
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _feedbackController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: _getHintText(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSubmitting ? null : () => setState(() => _isVisible = false),
            child: const Text('CANCEL'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitFeedback,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('SUBMIT'),
          ),
        ),
      ],
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'VERY POOR';
      case 2:
        return 'POOR';
      case 3:
        return 'AVERAGE';
      case 4:
        return 'GOOD';
      case 5:
        return 'EXCELLENT';
      default:
        return 'RATE THIS';
    }
  }

  String _getHintText() {
    switch (_selectedCategory) {
      case 'bug':
        return 'Describe the bug: What happened? What did you expect to happen? Steps to reproduce...';
      case 'feature':
        return 'Describe your feature suggestion or improvement idea...';
      case 'usability':
        return 'How can we make this easier to use? What was confusing?';
      default:
        return 'Share your thoughts, suggestions, or any other feedback...';
    }
  }

  Future<void> _submitFeedback() async {
    setState(() => _isSubmitting = true);

    try {
      bool success = false;

      if (_selectedCategory == 'bug') {
        success = await _feedbackService.reportBug(
          title: 'Bug report from ${widget.screenName ?? 'app'}',
          description: _feedbackController.text,
          stepsToReproduce: 'User reported via in-app feedback',
          expectedBehavior: 'Normal operation',
          actualBehavior: _feedbackController.text,
          severity: _rating <= 2 ? 'high' : 'medium',
        );
      } else {
        success = await _feedbackService.submitFeedback(
          category: _selectedCategory,
          feedback: _feedbackController.text,
          rating: _rating,
          metadata: {
            'screen_name': widget.screenName,
            'feature_name': widget.featureName,
          },
        );
      }

      if (success) {
        _showSuccessMessage();
      } else {
        _showErrorMessage();
      }

      setState(() => _isVisible = false);
      widget.onFeedbackSubmitted?.call();

    } catch (e) {
      _showErrorMessage();
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ FEEDBACK SUBMITTED SUCCESSFULLY'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❌ FAILED TO SUBMIT FEEDBACK. SAVED FOR LATER.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}
