import 'package:flutter/material.dart';
import '../models/feedback.dart' as feedback_model;
import '../services/feedback_service.dart';
import '../services/navigation_service.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class FeedbackScreen extends StatefulWidget {
  final String orderId;
  final String customerEmail;

  const FeedbackScreen({
    Key? key,
    required this.orderId,
    required this.customerEmail,
  }) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final FeedbackService _feedbackService = FeedbackService();
  final TextEditingController _commentsController = TextEditingController();
  int _selectedRating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PLEASE SELECT A RATING'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final feedback = feedback_model.Feedback(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      orderId: widget.orderId,
      rating: _selectedRating,
      comments: _commentsController.text.trim(),
      timestamp: DateTime.now(),
      customerEmail: widget.customerEmail,
    );

    final success = await _feedbackService.submitFeedback(feedback);

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('THANK YOU FOR YOUR FEEDBACK!'),
            backgroundColor: Colors.green,
          ),
        );
        NavigationService.navigateToHome();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('FAILED TO SUBMIT FEEDBACK. PLEASE TRY AGAIN.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedRating = index + 1;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              index < _selectedRating ? Icons.star : Icons.star_border,
              size: 40,
              color: index < _selectedRating ? Colors.amber : Colors.grey,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FEEDBACK'),
        backgroundColor: const Color(0xFFFF5C22),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.feedback,
                    size: 80,
                    color: const Color(0xFFFF5C22),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'HOW WAS YOUR EXPERIENCE?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ORDER #${widget.orderId}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Rating Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  const Text(
                    'RATE YOUR EXPERIENCE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStarRating(),
                  const SizedBox(height: 8),
                  if (_selectedRating > 0)
                    Text(
                      _selectedRating == 5
                          ? 'EXCELLENT!'
                          : _selectedRating == 4
                              ? 'VERY GOOD!'
                              : _selectedRating == 3
                                  ? 'GOOD'
                                  : _selectedRating == 2
                                      ? 'FAIR'
                                      : 'POOR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _selectedRating >= 4
                            ? Colors.green
                            : _selectedRating == 3
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Comments Section
            const Text(
              'ADDITIONAL COMMENTS (OPTIONAL)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _commentsController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'TELL US MORE ABOUT YOUR EXPERIENCE...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5C22),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'SUBMIT FEEDBACK',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 0, // Home selected
        onItemSelected: (index) {
          switch (index) {
            case 0:
              NavigationService.navigateToHome();
              break;
            case 1:
              NavigationService.navigateToScan();
              break;
            case 2:
              NavigationService.navigateToMenu();
              break;
            case 3:
              NavigationService.navigateToCart();
              break;
            case 4:
              NavigationService.navigateToMore();
              break;
          }
        },
      ),
    );
  }
}
