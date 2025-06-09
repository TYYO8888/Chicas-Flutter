class Feedback {
  final String id;
  final String orderId;
  final int rating; // 1-5 stars
  final String comments;
  final DateTime timestamp;
  final String customerEmail;

  Feedback({
    required this.id,
    required this.orderId,
    required this.rating,
    required this.comments,
    required this.timestamp,
    required this.customerEmail,
  });

  // Factory constructor for creating Feedback from JSON
  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['id'],
      orderId: json['orderId'],
      rating: json['rating'],
      comments: json['comments'],
      timestamp: DateTime.parse(json['timestamp']),
      customerEmail: json['customerEmail'],
    );
  }

  // Convert Feedback to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'rating': rating,
      'comments': comments,
      'timestamp': timestamp.toIso8601String(),
      'customerEmail': customerEmail,
    };
  }

  // Clone method for creating copies
  Feedback clone() {
    return Feedback(
      id: id,
      orderId: orderId,
      rating: rating,
      comments: comments,
      timestamp: timestamp,
      customerEmail: customerEmail,
    );
  }
}
