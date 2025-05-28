import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mydaymate/features/grocery/controller/grocery_controller.dart';
import 'package:mydaymate/features/grocery/model/grocery_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GroceryController controller;

  setUp(() {
    // Set up SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});

    // Initialize GetX test mode
    Get.testMode = true;

    // Create the controller
    controller = GroceryController();
  });

  tearDown(() {
    // Clean up
    controller.onClose();
    Get.reset();
  });

  group('GroceryController Tests', () {
    test('addItem correctly adds a grocery item', () async {
      // Arrange - make sure we start with an empty list
      expect(controller.items.length, 0);

      // Act - add a new item
      await controller.addItem(
        name: 'Test Item',
        category: 'Fruits',
        quantity: 2.5,
        unit: 'kg',
        needsRestock: true,
      );

      // Assert
      expect(controller.items.length, 1);
      expect(controller.items.first.name, 'Test Item');
      expect(controller.items.first.category, 'Fruits');
      expect(controller.items.first.quantity, 2.5);
      expect(controller.items.first.unit, 'kg');
      expect(controller.items.first.needsRestock, true);
      expect(
          controller.items.first.icon, Icons.apple); // Icon for Fruits category
    });

    test('toggleRestock correctly toggles the restock status', () async {
      // Arrange - add an item first
      await controller.addItem(
        name: 'Milk',
        category: 'Dairy',
        quantity: 1.0,
        unit: 'liter',
        needsRestock: false,
      );
      final itemId = controller.items.first.id;

      // Verify initial state
      expect(controller.items.first.needsRestock, false);

      // Act - toggle restock status
      await controller.toggleRestock(itemId);

      // Assert - should now be true
      expect(controller.items.first.needsRestock, true);

      // Act again - toggle back
      await controller.toggleRestock(itemId);

      // Assert - should be false again
      expect(controller.items.first.needsRestock, false);
    });

    test('hasIngredient correctly identifies ingredients in the list',
        () async {
      // Arrange - add a few items
      await controller.addItem(
        name: 'Chicken Breast',
        category: 'Meat',
        quantity: 1.0,
        unit: 'kg',
        needsRestock: false,
      );

      await controller.addItem(
        name: 'Olive Oil',
        category: 'Other',
        quantity: 1.0,
        unit: 'bottle',
        needsRestock: false,
      );

      // Act & Assert - exact match
      expect(controller.hasIngredient('Chicken Breast'), true);

      // Act & Assert - partial match
      expect(controller.hasIngredient('Chicken'), true);

      // Act & Assert - case insensitive
      expect(controller.hasIngredient('olive oil'), true);

      // Act & Assert - with extra spaces
      expect(controller.hasIngredient('  Olive Oil  '), true);

      // Act & Assert - not in list
      expect(controller.hasIngredient('Tomatoes'), false);
    });
  });
}
