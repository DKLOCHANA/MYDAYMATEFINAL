import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mydaymate/features/financial_planner/model/transaction_model.dart';

// Simple mock version of the FinancialPlannerController
class MockFinancialPlannerController extends GetxController {
  final transactions = <TransactionModel>[].obs;
  final groupedTransactions = Rx<Map<String, List<TransactionModel>>>({});
  final balance = 0.0.obs;
  final totalIncome = 0.0.obs;
  final totalExpense = 0.0.obs;

  // Add some test transactions for testing
  void addTestTransactions() {
    transactions.assignAll([
      TransactionModel(
        id: '1',
        amount: 1000.0,
        category: 'Salary',
        date: DateTime(2023, 5, 15),
        note: 'Monthly salary',
        userId: 'user1',
        type: TransactionType.income,
        icon: Icons.work,
        color: Colors.green,
      ),
      TransactionModel(
        id: '2',
        amount: 200.0,
        category: 'Groceries',
        date: DateTime(2023, 5, 16),
        note: 'Weekly groceries',
        userId: 'user1',
        type: TransactionType.expense,
        icon: Icons.shopping_cart,
        color: Colors.red,
      ),
      TransactionModel(
        id: '3',
        amount: 50.0,
        category: 'Food',
        date: DateTime(2023, 5, 17),
        note: 'Restaurant',
        userId: 'user1',
        type: TransactionType.expense,
        icon: Icons.restaurant,
        color: Colors.orange,
      ),
      TransactionModel(
        id: '4',
        amount: 300.0,
        category: 'Bonus',
        date: DateTime(2023, 5, 18),
        note: 'Performance bonus',
        userId: 'user1',
        type: TransactionType.income,
        icon: Icons.attach_money,
        color: Colors.green,
      ),
    ]);
  }

  // Group transactions by category - simplified version of the original method
  void groupTransactionsByCategory() {
    final Map<String, List<TransactionModel>> grouped = {};

    for (var transaction in transactions) {
      final key = '${transaction.category}_${transaction.type.index}';
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(transaction);
    }

    groupedTransactions.value = grouped;
  }

  // Get transaction totals by category
  List<Map<String, dynamic>> getCategoryTotals(TransactionType type) {
    final List<Map<String, dynamic>> result = [];
    final Map<String, double> categoryAmounts = {};
    final Map<String, IconData> categoryIcons = {};
    final Map<String, Color> categoryColors = {};

    for (var transaction in transactions) {
      if (transaction.type == type) {
        final categoryKey = transaction.category;

        categoryAmounts[categoryKey] =
            (categoryAmounts[categoryKey] ?? 0) + transaction.amount;
        categoryIcons[categoryKey] = transaction.icon;
        categoryColors[categoryKey] = transaction.color;
      }
    }

    categoryAmounts.forEach((category, amount) {
      result.add({
        'category': category,
        'amount': amount,
        'icon': categoryIcons[category],
        'color': categoryColors[category],
      });
    });

    return result;
  }

  // Get all transactions for a specific category and type
  List<TransactionModel> getTransactionsForCategory(
      String category, TransactionType type) {
    final key = '${category}_${type.index}';
    return groupedTransactions.value[key] ?? [];
  }
}

void main() {
  late MockFinancialPlannerController controller;

  setUp(() {
    // Initialize GetX test mode
    Get.testMode = true;

    // Create the controller
    controller = MockFinancialPlannerController();
    controller.addTestTransactions();
    controller.groupTransactionsByCategory();
  });

  tearDown(() {
    Get.reset();
  });

  group('FinancialPlannerController Tests', () {
    test('getCategoryTotals should correctly sum up amounts by category', () {
      // Act - Get income category totals
      final incomeTotals = controller.getCategoryTotals(TransactionType.income);

      // Assert
      expect(incomeTotals.length, 2); // Should have 2 income categories

      // Find the 'Salary' category
      final salaryCategory = incomeTotals.firstWhere(
        (category) => category['category'] == 'Salary',
      );

      // Find the 'Bonus' category
      final bonusCategory = incomeTotals.firstWhere(
        (category) => category['category'] == 'Bonus',
      );

      // Check amounts
      expect(salaryCategory['amount'], 1000.0);
      expect(bonusCategory['amount'], 300.0);

      // Check icons and colors
      expect(salaryCategory['icon'], Icons.work);
      expect(salaryCategory['color'], Colors.green);
      expect(bonusCategory['icon'], Icons.attach_money);
      expect(bonusCategory['color'], Colors.green);

      // Now test expense categories
      final expenseTotals =
          controller.getCategoryTotals(TransactionType.expense);
      expect(expenseTotals.length, 2); // Should have 2 expense categories

      // Find the 'Groceries' category
      final groceriesCategory = expenseTotals.firstWhere(
        (category) => category['category'] == 'Groceries',
      );

      // Check amount
      expect(groceriesCategory['amount'], 200.0);
    });

    test(
        'getTransactionsForCategory should return transactions for specific category',
        () {
      // Act - Get all Salary transactions
      final salaryTransactions = controller.getTransactionsForCategory(
          'Salary', TransactionType.income);

      // Assert
      expect(salaryTransactions.length, 1);
      expect(salaryTransactions[0].amount, 1000.0);
      expect(salaryTransactions[0].note, 'Monthly salary');

      // Test another category
      final foodTransactions = controller.getTransactionsForCategory(
          'Food', TransactionType.expense);

      expect(foodTransactions.length, 1);
      expect(foodTransactions[0].amount, 50.0);
      expect(foodTransactions[0].note, 'Restaurant');

      // Test a non-existent category
      final nonExistentTransactions = controller.getTransactionsForCategory(
          'Entertainment', TransactionType.expense);

      expect(nonExistentTransactions.length, 0);
    });
  });
}
