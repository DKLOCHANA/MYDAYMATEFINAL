// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:mydaymate/features/grocery/model/grocery_item.dart';

// class GroceryStorageService {
//   static const String _key = 'grocery_items';

//   // Get all items
//   Future<List<GroceryItem>> getItems() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? itemsJson = prefs.getString(_key);

//     if (itemsJson == null) {
//       return _getSampleItems(); // Return sample items if nothing is stored
//     }

//     try {
//       final List<dynamic> itemsList = jsonDecode(itemsJson);
//       return itemsList.map((item) => GroceryItem.fromJson(item)).toList();
//     } catch (e) {
//       // If there's an error parsing, return empty list
//       return [];
//     }
//   }

//   // Add a new item
//   Future<void> addItem(GroceryItem item) async {
//     final prefs = await SharedPreferences.getInstance();
//     final items = await getItems();
//     items.add(item);
//     await _saveItems(prefs, items);
//   }

//   // Update an existing item
//   Future<void> updateItem(GroceryItem updatedItem) async {
//     final prefs = await SharedPreferences.getInstance();
//     final items = await getItems();

//     final index = items.indexWhere((item) => item.id == updatedItem.id);
//     if (index != -1) {
//       items[index] = updatedItem;
//       await _saveItems(prefs, items);
//     }
//   }

//   // Delete an item
//   Future<void> deleteItem(String id) async {
//     final prefs = await SharedPreferences.getInstance();
//     final items = await getItems();

//     items.removeWhere((item) => item.id == id);
//     await _saveItems(prefs, items);
//   }

//   // Helper method to save items to SharedPreferences
//   Future<void> _saveItems(
//       SharedPreferences prefs, List<GroceryItem> items) async {
//     final itemsJson = jsonEncode(items.map((item) => item.toJson()).toList());
//     await prefs.setString(_key, itemsJson);
//   }

//   // Return sample items for first-time users with updated categories
//   List<GroceryItem> _getSampleItems() {
//     // Get current date for more realistic sample data
//     final now = DateTime.now();
//     final itemId = now.millisecondsSinceEpoch.toString();

//     return [
//       GroceryItem(
//         id: '${itemId}_1',
//         name: 'Milk',
//         category: 'Dairy',
//         icon: Icons.breakfast_dining,
//         quantity: 2,
//         unit: 'liter',
//         needsRestock: true,
//       ),
//       GroceryItem(
//         id: '${itemId}_2',
//         name: 'Bread',
//         category: 'Bakery',
//         icon: Icons.bakery_dining,
//         quantity: 1,
//         unit: 'pack',
//         needsRestock: true,
//       ),
//       GroceryItem(
//         id: '${itemId}_3',
//         name: 'Eggs',
//         category: 'Dairy',
//         icon: Icons.egg,
//         quantity: 1,
//         unit: 'dozen',
//         needsRestock: false,
//       ),
//       GroceryItem(
//         id: '${itemId}_4',
//         name: 'Apples',
//         category: 'Fruits',
//         icon: Icons.apple,
//         quantity: 1,
//         unit: 'kg',
//         needsRestock: false,
//       ),
//       GroceryItem(
//         id: '${itemId}_5',
//         name: 'Chicken',
//         category: 'Meat',
//         icon: Icons.set_meal,
//         quantity: 0.5,
//         unit: 'kg',
//         needsRestock: true,
//       ),
//       GroceryItem(
//         id: '${itemId}_6',
//         name: 'Toilet Paper',
//         category: 'Sanitary',
//         icon: Icons.cleaning_services,
//         quantity: 2,
//         unit: 'pack',
//         needsRestock: false,
//       ),
//     ];
//   }
// }
