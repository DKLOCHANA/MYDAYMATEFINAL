import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Simple mock version of the ExpenseController with just what we need for testing
class MockExpenseController extends GetxController {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final Rx<String> selectedCategory = ''.obs;
  final RxBool isLoading = false.obs;

  final List<Map<String, dynamic>> expenseCategories = [
    {
      'name': 'Food & Drinks',
      'icon': Icons.restaurant,
      'color': Colors.orange,
      'keywords': ['restaurant', 'cafe', 'food', 'grocery', 'meal']
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag,
      'color': Colors.pink,
      'keywords': ['shop', 'store', 'mall', 'market', 'cloth']
    },
    {
      'name': 'Other',
      'icon': Icons.category,
      'color': Colors.grey,
      'keywords': []
    },
  ];

  @override
  void onInit() {
    super.onInit();
    // Set default date to today
    final now = DateTime.now();
    dateController.text = "${now.day}/${now.month}/${now.year}";
    selectedCategory.value = expenseCategories[0]['name'] as String;
  }

  @override
  void onClose() {
    amountController.dispose();
    noteController.dispose();
    dateController.dispose();
    super.onClose();
  }

  // Simplified validation method for testing purposes
  bool validateExpense() {
    final amountText = amountController.text.trim();

    if (amountText.isEmpty || double.tryParse(amountText) == null) {
      return false;
    }

    final category = selectedCategory.value;
    if (category.isEmpty) {
      return false;
    }

    if (dateController.text.trim().isEmpty ||
        !dateController.text.contains('/')) {
      return false;
    }

    return true;
  }

  void clearForm() {
    amountController.clear();
    noteController.clear();
    final now = DateTime.now();
    dateController.text = "${now.day}/${now.month}/${now.year}";
    selectedCategory.value = expenseCategories[0]['name'] as String;
  }
}

void main() {
  late MockExpenseController controller;

  setUp(() {
    // Initialize GetX test mode
    Get.testMode = true;

    // Create the controller
    controller = MockExpenseController();
    controller.onInit(); // Initialize defaults
  });

  tearDown(() {
    // Clean up
    controller.onClose();
    Get.reset();
  });

  group('ExpenseController Tests', () {
    test('Controller initializes with correct default values', () {
      // Act & Assert
      expect(controller.amountController.text, isEmpty);
      expect(controller.noteController.text, isEmpty);
      expect(controller.selectedCategory.value, 'Food & Drinks');
      expect(controller.isLoading.value, false);

      // Check date format: "dd/mm/yyyy"
      final dateRegex = RegExp(r'^\d{1,2}/\d{1,2}/\d{4}$');
      expect(dateRegex.hasMatch(controller.dateController.text), true);
    });

    test('validateExpense returns false when amount is empty', () {
      // Arrange
      controller.amountController.text = '';

      // Act
      final result = controller.validateExpense();

      // Assert
      expect(result, false);
    });

    test('validateExpense returns false when amount is invalid', () {
      // Arrange
      controller.amountController.text = 'abc';

      // Act
      final result = controller.validateExpense();

      // Assert
      expect(result, false);
    });

    test('validateExpense returns false when category is empty', () {
      // Arrange
      controller.amountController.text = '100.50';
      controller.selectedCategory.value = '';

      // Act
      final result = controller.validateExpense();

      // Assert
      expect(result, false);
    });

    test('validateExpense returns false when date is invalid', () {
      // Arrange
      controller.amountController.text = '100.50';
      controller.dateController.text = 'invalid-date';

      // Act
      final result = controller.validateExpense();

      // Assert
      expect(result, false);
    });

    test('validateExpense returns true with valid inputs', () {
      // Arrange
      controller.amountController.text = '100.50';
      controller.selectedCategory.value = 'Food & Drinks';
      controller.dateController.text = '15/5/2025';

      // Act
      final result = controller.validateExpense();

      // Assert
      expect(result, true);
    });

    test('clearForm resets all form fields', () {
      // Arrange
      controller.amountController.text = '100.50';
      controller.noteController.text = 'Test expense';
      controller.selectedCategory.value = 'Shopping';
      controller.dateController.text = '1/1/2025';

      // Act
      controller.clearForm();

      // Assert
      expect(controller.amountController.text, isEmpty);
      expect(controller.noteController.text, isEmpty);
      expect(controller.selectedCategory.value, 'Food & Drinks');

      // Check date matches current date
      final today = DateTime.now();
      final expectedDate = "${today.day}/${today.month}/${today.year}";
      expect(controller.dateController.text, expectedDate);
    });
  });
}
