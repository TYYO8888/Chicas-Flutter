class CrewPackSelection {
  final String sandwichId;
  final String bunType;
  final double price;

  CrewPackSelection({
    required this.sandwichId,
    required this.bunType,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'sandwichId': sandwichId,
      'bunType': bunType,
      'price': price,
    };
  }
}

class CrewPackCustomization {
  final List<CrewPackSelection> selections;
  final int maxSelections;
  double get totalPrice => selections.fold(0.0, (sum, item) => sum + item.price);

  CrewPackCustomization({
    List<CrewPackSelection>? selections,
    this.maxSelections = 3,
  }) : selections = selections ?? [];

  bool canAddMore() => selections.length < maxSelections;

  void addSelection(CrewPackSelection selection) {
    if (canAddMore()) {
      selections.add(selection);
    }
  }

  void removeSelection(int index) {
    if (index >= 0 && index < selections.length) {
      selections.removeAt(index);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'selections': selections.map((s) => s.toMap()).toList(),
      'totalPrice': totalPrice,
    };
  }
}
