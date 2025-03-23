import 'package:flutter/material.dart';

class GroceryItem {
  final String id;
  String name;
  String category;
  IconData icon;
  double quantity;
  String unit;
  bool isPurchased;
  bool needsRestock;

  GroceryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    this.quantity = 1,
    this.unit = 'item',
    this.isPurchased = false,
    this.needsRestock = false,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'iconIndex': _getIconIndex(icon),
      'quantity': quantity,
      'unit': unit,
      'isPurchased': isPurchased,
      'needsRestock': needsRestock,
    };
  }

  // Create from JSON for retrieval
  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      icon: _getIconFromIndex(json['iconIndex']),
      quantity: json['quantity'],
      unit: json['unit'],
      isPurchased: json['isPurchased'],
      needsRestock: json['needsRestock'],
    );
  }

  // Create a copy of the item with possible modifications
  GroceryItem copyWith({
    String? name,
    String? category,
    IconData? icon,
    double? quantity,
    String? unit,
    bool? isPurchased,
    bool? needsRestock,
  }) {
    return GroceryItem(
      id: this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isPurchased: isPurchased ?? this.isPurchased,
      needsRestock: needsRestock ?? this.needsRestock,
    );
  }

  // Helper method to convert IconData to index for storage
  static int _getIconIndex(IconData icon) {
    // This is a simple approach that maps common icons to integers
    // A more robust approach would be to create a registry of all used icons
    if (icon == Icons.breakfast_dining) return 0;
    if (icon == Icons.bakery_dining) return 1;
    if (icon == Icons.egg) return 2;
    if (icon == Icons.apple) return 3;
    if (icon == Icons.emoji_food_beverage) return 4;
    if (icon == Icons.set_meal) return 5;
    if (icon == Icons.dinner_dining) return 6;
    if (icon == Icons.ramen_dining) return 7;
    if (icon == Icons.eco) return 8;
    if (icon == Icons.shopping_basket) return 9;
    return 10; // Default to category icon
  }

  // Helper method to convert index back to IconData
  static IconData _getIconFromIndex(int index) {
    switch (index) {
      case 0:
        return Icons.breakfast_dining;
      case 1:
        return Icons.bakery_dining;
      case 2:
        return Icons.egg;
      case 3:
        return Icons.apple;
      case 4:
        return Icons.emoji_food_beverage;
      case 5:
        return Icons.set_meal;
      case 6:
        return Icons.dinner_dining;
      case 7:
        return Icons.ramen_dining;
      case 8:
        return Icons.eco;
      case 9:
        return Icons.shopping_basket;
      default:
        return Icons.category;
    }
  }
}

class GroceryCategory {
  final String name;
  final IconData icon;

  const GroceryCategory({
    required this.name,
    required this.icon,
  });
}
