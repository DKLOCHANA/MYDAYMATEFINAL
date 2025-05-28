import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../model/transaction_model.dart';
import '../service/financial_service.dart';

class FinancialPlannerController extends GetxController {
  final FinancialService _service = FinancialService();

  final transactions = <TransactionModel>[].obs;
  final groupedTransactions = Rx<Map<String, List<TransactionModel>>>({});
  final balance = 0.0.obs;
  final totalIncome = 0.0.obs;
  final totalExpense = 0.0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  // Simple refresh method - just call this when needed
  void refreshData() {
    fetchTransactions();
    fetchFinancialSummary();
  }

  // Use this in onResume lifecycle
  void onPageFocus() {
    refreshData();
  }

  void fetchTransactions() {
    isLoading.value = true;
    _service.getTransactions().listen(
      (data) {
        transactions.assignAll(data);
        _groupTransactionsByCategory();
        isLoading.value = false;
      },
      onError: (e) {
        // Add more detailed error logging
        print('Transaction fetch error: ${e.toString()}');
        isLoading.value = false;
        // Don't show snackbar for every error
        // Get.snackbar('Error', 'Failed to load transactions');
      },
    );
  }

  // Group transactions by category
  void _groupTransactionsByCategory() {
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

  // Show category transaction history
  void showCategoryTransactions(
      String category, TransactionType type, Color color, IconData icon) {
    final categoryTransactions = getTransactionsForCategory(category, type);

    if (categoryTransactions.isEmpty) {
      Get.snackbar('Info', 'No transactions found for this category');
      return;
    }

    Get.bottomSheet(
      Container(
        height: Get.height * 0.5, // Set height to 50% of screen height
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color,
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${categoryTransactions.length} transactions',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(height: 20),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categoryTransactions.length,
                itemBuilder: (context, index) {
                  final tx = categoryTransactions[index];
                  return ListTile(
                    title: Text(tx.note.isEmpty ? tx.category : tx.note),
                    subtitle: Text(_formatDate(tx.date)),
                    trailing: Text(
                      'Rs ${tx.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: tx.isExpense ? Colors.red : Colors.green,
                      ),
                    ),
                    onTap: tx.receiptURL != null
                        ? () => _showReceiptImage(tx.receiptURL!)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showReceiptImage(String imageUrl) {
    Get.dialog(
      Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Receipt'),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
              ),
            ),
            Flexible(
              child: Image.network(
                imageUrl,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text('Error loading receipt'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchFinancialSummary() async {
    try {
      final summary = await _service.getFinancialSummary();
      totalIncome.value = summary['income'] ?? 0;
      totalExpense.value = summary['expense'] ?? 0;
      balance.value = summary['balance'] ?? 0;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load financial summary');
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _service.deleteTransaction(transactionId);
      fetchFinancialSummary();
      Get.snackbar('Success', 'Transaction deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete transaction');
      print('Error deleting transaction: $e');
    }
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
          'Transaction Type',
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
    final Color primaryColor =
        isIncome ? Colors.greenAccent.shade700 : Colors.redAccent.shade700;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.15),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                isIncome
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Get.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: primaryColor.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }
}
