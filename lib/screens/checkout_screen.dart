import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../services/navigation_service.dart';
import '../screens/payment_screen.dart';
import 'feedback_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Cart cart;

  const CheckoutScreen({super.key, required this.cart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = false;
  bool _orderPlaced = false;
  String _orderId = '';

  // Navigate to payment screen
  void _navigateToPayment() {
    final totalAmount = widget.cart.totalPrice * 1.12; // Include taxes
    final orderId = 'CHK${DateTime.now().millisecondsSinceEpoch}';

    // Create order details for payment
    final orderDetails = {
      'items': widget.cart.items.map((item) => {
        'name': item.menuItem.name,
        'quantity': item.quantity,
        'price': item.itemPrice,
        'total': item.itemPrice * item.quantity,
        'customizations': item.customizations,
        'selectedSauces': item.menuItem.selectedSauces,
        'selectedSize': item.selectedSize,
        'selectedBunType': item.menuItem.selectedBunType,
      }).toList(),
      'subtotal': widget.cart.totalPrice,
      'gst': widget.cart.totalPrice * 0.05,
      'pst': widget.cart.totalPrice * 0.07,
      'total': totalAmount,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          totalAmount: totalAmount,
          orderId: orderId,
          orderDetails: orderDetails,
        ),
      ),
    ).then((result) {
      // Handle payment result
      if (result != null && result['success'] == true) {
        _handlePaymentSuccess(orderId, result);
      }
    });
  }

  // Handle successful payment
  void _handlePaymentSuccess(String orderId, Map<String, dynamic> paymentResult) {
    setState(() {
      _orderPlaced = true;
      _orderId = orderId;
    });
  }

  // This is like telling your friend to call the restaurant!
  Future<void> _submitOrder() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulating an API call to the restaurant
      // TODO: Replace with actual Revel API endpoint
      // Example: https://api.revel.com/v1/orders
      await Future.delayed(const Duration(seconds: 2)); // Like waiting on hold!

      /* When integrating with Revel's API, the order submission will look something like:
      final response = await http.post(
        Uri.parse('https://api.revel.com/v1/orders'),
        headers: {
          'Authorization': 'Bearer YOUR_API_TOKEN',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'establishment_id': 'YOUR_ESTABLISHMENT_ID',
          'items': widget.cart.items.map((item) => {
            'product_id': item.menuItem.revelProductId,
            'quantity': item.quantity,
            'modifiers': item.menuItem.selectedSauces?.map((sauce) => {
              'modifier_id': sauce.revelModifierId,
            }).toList(),
            // Add other Revel-specific fields as needed
          }).toList(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to place order');
      }
      */

      // For now, we'll just simulate a successful order
      final orderId = 'CHK${DateTime.now().millisecondsSinceEpoch}';
      setState(() {
        _isLoading = false;
        _orderPlaced = true;
        _orderId = orderId;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Oops! Something went wrong. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _orderPlaced
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 100,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Order Placed!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ORDER #$_orderId',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'YOUR DELICIOUS FOOD IS BEING PREPARED!',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Feedback Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FeedbackScreen(
                              orderId: _orderId,
                              customerEmail: 'customer@example.com', // TODO: Get from user profile
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5C22),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'RATE YOUR EXPERIENCE',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Return to Menu Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Navigate back to the main menu
                        NavigationService.navigateToMenu();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF5C22),
                        side: const BorderSide(color: Color(0xFFFF5C22)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text(
                        'RETURN TO MENU',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.cart.items.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = widget.cart.items[index];
                          return Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.menuItem.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '\$${(item.itemPrice * item.quantity).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Quantity
                                Text(
                                  'Quantity: ${item.quantity}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                // Bun type selection
                                if (item.menuItem.selectedBunType != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Bun: ${item.menuItem.selectedBunType}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                // Selected bun (for sandwich items)
                                if (item.selectedSize != null && item.menuItem.category.toLowerCase() == 'sandwiches')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Bun: ${item.selectedSize}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                // Selected size (for non-sandwich items)
                                if (item.selectedSize != null && item.menuItem.category.toLowerCase() != 'sandwiches')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Size: ${item.selectedSize}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                // Selected sauces
                                if (item.menuItem.selectedSauces?.isNotEmpty ?? false)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Sauces:',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: item.menuItem.selectedSauces!.map((sauce) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.orange[100],
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                sauce,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Crew pack customizations
                                if (item.crewPackCustomization != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey[300]!),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Crew Pack Selections:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.deepOrange,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ...item.crewPackCustomization!.selections.map((selection) {
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 4),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.restaurant, size: 14, color: Colors.grey),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      'Sandwich (${selection.bunType})',
                                                      style: const TextStyle(fontSize: 13),
                                                    ),
                                                  ),
                                                  if (selection.bunType == 'Brioche Bun')
                                                    const Text(
                                                      '+\$1.00',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.green,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ),
                                  ),

                                // Regular customizations
                                if (item.customizations?.isNotEmpty ?? false)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.blue[200]!),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Pack Includes:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ...item.customizations!.entries.map((entry) {
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 6),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${entry.value.length}x ${entry.key}:',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                  ...entry.value.map((menuItem) {
                                                    return Padding(
                                                      padding: const EdgeInsets.only(left: 12, top: 2),
                                                      child: Text(
                                                        '• ${menuItem.name}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Subtotal
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Subtotal:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '\$${widget.cart.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // GST
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'GST (5%):',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '\$${(widget.cart.totalPrice * 0.05).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // PST
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'PST (7%):',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '\$${(widget.cart.totalPrice * 0.07).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 8),
                            // Total with taxes
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total (incl. taxes):',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '\$${(widget.cart.totalPrice * 1.12).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _navigateToPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Text(
                                    'Processing...',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.payment, size: 24),
                                  SizedBox(width: 8),
                                  Text(
                                    'PROCEED TO PAYMENT',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
