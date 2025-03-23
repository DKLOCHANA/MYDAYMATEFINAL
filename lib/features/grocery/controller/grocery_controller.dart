import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mydaymate/features/grocery/model/grocery_item.dart';

class GroceryController extends GetxController {
  // Storage key
  static const String _storageKey = 'grocery_items';

  // Observable list of grocery items
  final RxList<GroceryItem> _items = <GroceryItem>[].obs;
  List<GroceryItem> get items => _items;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  // Observable form values
  final selectedUnit = 'item'.obs;
  final selectedCategory = 'Other'.obs;
  final needsRestock = false.obs;

  // Category filter for view
  final selectedViewCategory = 'All'.obs;

  // Available units
  final List<String> units = [
    'item',
    'kg',
    'g',
    'liter',
    'ml',
    'pack',
    'dozen',
  ];

  // Categories with icons
  final List<GroceryCategory> categories = [
    GroceryCategory(name: 'All', icon: Icons.shopping_basket),
    GroceryCategory(name: 'Meat', icon: Icons.set_meal),
    GroceryCategory(name: 'Dairy', icon: Icons.breakfast_dining),
    GroceryCategory(name: 'Bakery', icon: Icons.bakery_dining),
    GroceryCategory(name: 'Fruits', icon: Icons.apple),
    GroceryCategory(name: 'Sanitary', icon: Icons.cleaning_services),
    GroceryCategory(name: 'Other', icon: Icons.category),
  ];

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  @override
  void onClose() {
    nameController.dispose();
    quantityController.dispose();
    super.onClose();
  }

  // Reset dialog fields
  void resetDialogFields() {
    nameController.clear();
    quantityController.clear();
    selectedUnit.value = 'item';
    selectedCategory.value = 'Other';
    needsRestock.value = false;
  }

  // Set dialog fields from an existing item
  void setDialogFieldsFromItem(GroceryItem item) {
    nameController.text = item.name;
    quantityController.text = item.quantity.toString();
    selectedUnit.value = item.unit;
    selectedCategory.value = item.category;
    needsRestock.value = item.needsRestock;
  }

  // Add item using current dialog field values
  void addItemFromFields() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter an item name',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final double quantity = double.tryParse(quantityController.text) ?? 1.0;

    addItem(
      name: nameController.text.trim(),
      category: selectedCategory.value,
      quantity: quantity,
      unit: selectedUnit.value,
      needsRestock: needsRestock.value,
    );

    Get.back();
  }

  // Update item using current dialog field values
  void updateItemFromFields(String id) {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter an item name',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final double quantity = double.tryParse(quantityController.text) ?? 1.0;

    updateItem(
      id: id,
      name: nameController.text.trim(),
      category: selectedCategory.value,
      quantity: quantity,
      unit: selectedUnit.value,
      needsRestock: needsRestock.value,
    );

    Get.back();
  }

  // Get icon for a category
  IconData getCategoryIcon(String categoryName) {
    final category = categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => const GroceryCategory(name: 'Other', icon: Icons.category),
    );
    return category.icon;
  }

  // STORAGE METHODS (Moved from GroceryStorageService)

  // Load all items from storage
  Future<void> loadItems() async {
    try {
      final items = await _getItems();
      _items.assignAll(items);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load grocery items',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Get all items from SharedPreferences
  Future<List<GroceryItem>> _getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? itemsJson = prefs.getString(_storageKey);

    if (itemsJson == null) {
      return _getSampleItems(); // Return sample items if nothing is stored
    }

    try {
      final List<dynamic> itemsList = jsonDecode(itemsJson);
      return itemsList.map((item) => GroceryItem.fromJson(item)).toList();
    } catch (e) {
      // If there's an error parsing, return empty list
      return [];
    }
  }

  // Helper method to save items to SharedPreferences
  Future<void> _saveItems(List<GroceryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, itemsJson);
  }

  // Add a new item
  Future<void> addItem({
    required String name,
    required String category,
    required double quantity,
    required String unit,
    required bool needsRestock,
  }) async {
    final item = GroceryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: category,
      icon: getCategoryIcon(category),
      quantity: quantity,
      unit: unit,
      needsRestock: needsRestock,
    );

    try {
      _items.add(item);
      await _saveItems(_items);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add item',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Update an existing item
  Future<void> updateItem({
    required String id,
    required String name,
    required String category,
    required double quantity,
    required String unit,
    required bool needsRestock,
  }) async {
    try {
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        final updatedItem = _items[index].copyWith(
          name: name,
          category: category,
          icon: getCategoryIcon(category),
          quantity: quantity,
          unit: unit,
          needsRestock: needsRestock,
        );

        _items[index] = updatedItem;
        await _saveItems(_items);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update item',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Delete an item
  Future<void> deleteItem(String id) async {
    try {
      _items.removeWhere((item) => item.id == id);
      await _saveItems(_items);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete item',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Toggle purchased status
  Future<void> togglePurchased(String id) async {
    try {
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        final item = _items[index];
        final updatedItem = item.copyWith(
          isPurchased: !item.isPurchased,
          // If item is purchased, it no longer needs restocking
          needsRestock: item.isPurchased ? false : item.needsRestock,
        );

        _items[index] = updatedItem;
        await _saveItems(_items);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update item',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Toggle restock status
  Future<void> toggleRestock(String id) async {
    try {
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        final item = _items[index];
        final updatedItem = item.copyWith(
          needsRestock: !item.needsRestock,
        );

        _items[index] = updatedItem;
        await _saveItems(_items);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update item',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Return sample items for first-time users
  List<GroceryItem> _getSampleItems() {
    // Get current date for more realistic sample data
    final now = DateTime.now();
    final itemId = now.millisecondsSinceEpoch.toString();

    return [
      GroceryItem(
        id: '${itemId}_1',
        name: 'Milk',
        category: 'Dairy',
        icon: Icons.breakfast_dining,
        quantity: 2,
        unit: 'liter',
        needsRestock: true,
      ),
      GroceryItem(
        id: '${itemId}_2',
        name: 'Bread',
        category: 'Bakery',
        icon: Icons.bakery_dining,
        quantity: 1,
        unit: 'pack',
        needsRestock: true,
      ),
      GroceryItem(
        id: '${itemId}_3',
        name: 'Eggs',
        category: 'Dairy',
        icon: Icons.egg,
        quantity: 1,
        unit: 'dozen',
        needsRestock: false,
      ),
      GroceryItem(
        id: '${itemId}_4',
        name: 'Apples',
        category: 'Fruits',
        icon: Icons.apple,
        quantity: 1,
        unit: 'kg',
        needsRestock: false,
      ),
      GroceryItem(
        id: '${itemId}_5',
        name: 'Chicken',
        category: 'Meat',
        icon: Icons.set_meal,
        quantity: 0.5,
        unit: 'kg',
        needsRestock: true,
      ),
      GroceryItem(
        id: '${itemId}_6',
        name: 'Toilet Paper',
        category: 'Sanitary',
        icon: Icons.cleaning_services,
        quantity: 2,
        unit: 'pack',
        needsRestock: false,
      ),
    ];
  }
}
