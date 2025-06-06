import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/recommendation_service.dart';
import '../widgets/deal_card.dart';
import '../screens/menu_item_screen.dart';

class HotDealsSection extends StatefulWidget {
  const HotDealsSection({Key? key}) : super(key: key);

  @override
  State<HotDealsSection> createState() => _HotDealsSectionState();
}

class _HotDealsSectionState extends State<HotDealsSection> {
  final RecommendationService _recommendationService = RecommendationService();
  List<MenuItem> _deals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeals();
  }

  Future<void> _loadDeals() async {
    try {
      final deals = await _recommendationService.getHotDeals();
      setState(() {
        _deals = deals;
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
              Icon(Icons.local_fire_department, color: Colors.red[700], size: 28),
              const SizedBox(width: 8),
              Text(
                'HOT DEALS & SPECIALS',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
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
        else if (_deals.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'No active deals at the moment',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          SizedBox(
            height: 420, // Fixed height for the deal cards
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _deals.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 300, // Fixed width for each card
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: DealCard(
                      deal: _deals[index],                      onTap: () {
                        if (_deals[index].category.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MenuItemScreen(category: _deals[index].category),
                            ),
                          );
                        }
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
