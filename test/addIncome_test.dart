import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Simple mock version of the controller with just what we need for testing
class MockIncomeController extends GetxController {
  final TextEditingController amountController = TextEditingController();
  final RxnString selectedCategory = RxnString();

  bool validateIncome() {
    if (amountController.text.isEmpty) {
      return false;
    }

    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(amountController.text)) {
      return false;
    }

    if (selectedCategory.value == null) {
      return false;
    }

    return true;
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }
}

void main() {
  late MockIncomeController controller;

  setUp(() {
    // Initialize GetX test mode
    Get.testMode = true;

    // Create the controller
    controller = MockIncomeController();
  });

  tearDown(() {
    // Clean up
    controller.onClose();
    Get.reset();
  });

  group('Income Validation Tests', () {
    test('validateIncome returns false when amount is empty', () {
      // Arrange
      controller.amountController.text = '';
      controller.selectedCategory.value = 'Salary';

      // Act
      final result = controller.validateIncome();

      // Assert
      expect(result, false);
    });

    test('validateIncome returns false when amount is invalid', () {
      // Arrange
      controller.amountController.text = 'abc';
      controller.selectedCategory.value = 'Salary';

      // Act
      final result = controller.validateIncome();

      // Assert
      expect(result, false);
    });

    test('validateIncome returns false when category is null', () {
      // Arrange
      controller.amountController.text = '100.50';
      controller.selectedCategory.value = null;

      // Act
      final result = controller.validateIncome();

      // Assert
      expect(result, false);
    });

    test('validateIncome returns true with valid inputs', () {
      // Arrange
      controller.amountController.text = '100.50';
      controller.selectedCategory.value = 'Salary';

      // Act
      final result = controller.validateIncome();

      // Assert
      expect(result, true);
    });
  });
}
