import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/recommendation_service.dart';
import '../widgets/deal_card.dart';

class PersonalizedRecommendationsSection extends StatefulWidget {
  const PersonalizedRecommendationsSection({Key? key}) : super(key: key);

  @override
  State<PersonalizedRecommendationsSection> createState() =>
      _PersonalizedRecommendationsSectionState();
}

class _PersonalizedRecommendationsSectionState
    extends State<PersonalizedRecommendationsSection> {
  final RecommendationService _recommendationService = RecommendationService();
  List<MenuItem> _recommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      final recommendations =
          await _recommendationService.getPersonalizedRecommendations();
      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber[700], size: 28),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'JUST FOR YOU',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[700],
                        ),
                  ),
                  Text(
                    'Based on your previous orders',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_recommendations.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'Check back later for personalized recommendations!',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          SizedBox(
            height: 420, // Fixed height for the recommendation cards
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _recommendations.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 300, // Fixed width for each card
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: DealCard(
                      deal: _recommendations[index],
                      onTap: () {
                        // TODO: Handle recommendation selection
                      },
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
