import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../model/transaction_model.dart';
import '../data/dummy_transactions.dart';

class FinancialPlannerController extends GetxController {
  final transactions = DummyTransactions.transactions.obs;
  final balance = 0.0.obs;
  final totalIncome = 0.0.obs;
  final totalExpense = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    calculateTotals();
  }

  void calculateTotals() {
    totalIncome.value = DummyTransactions.totalIncome;
    totalExpense.value = DummyTransactions.totalExpense;
    balance.value = DummyTransactions.balance;
  }

  void addTransaction(TransactionModel transaction) {
    transactions.add(transaction);
    calculateTotals();
  }

  void navigateToAddIncome() {
    Get.toNamed(AppRoutes.addIncome);
  }

  void navigateToAddExpense() {
    Get.toNamed(AppRoutes.addExpense);
  }

  void showTransactionTypeDialog() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Select Transaction Type',
          style: Get.textTheme.titleLarge?.copyWith(
            color: Get.theme.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTransactionChoice(
              title: 'Income',
              isIncome: true,
              onTap: () {
                Get.back();
                navigateToAddIncome();
              },
            ),
            const SizedBox(height: 16),
            _buildTransactionChoice(
              title: 'Expense',
              isIncome: false,
              onTap: () {
                Get.back();
                navigateToAddExpense();
              },
            ),
          ],
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildTransactionChoice({
    required String title,
    required bool isIncome,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isIncome
                      ? Get.theme.primaryColor
                      : Get.theme.colorScheme.error,
                  width: 2,
                ),
              ),
              child: Icon(
                isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                color: isIncome
                    ? Get.theme.primaryColor
                    : Get.theme.colorScheme.error,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Get.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
