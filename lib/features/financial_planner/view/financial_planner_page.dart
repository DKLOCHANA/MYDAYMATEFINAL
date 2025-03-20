import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mydaymate/widgets/category_total_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/devices.dart';
import '../../../widgets/category_card.dart';
import '../../../widgets/custom_appbar.dart';
import '../controller/financial_planner_controller.dart';
import '../model/transaction_model.dart';

class FinancialPlannerPage extends GetView<FinancialPlannerController> {
  const FinancialPlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Refresh data when page is displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.onPageFocus();
    });

    return Scaffold(
      appBar: CustomAppbar(title: 'Financial Planner'),
      body: Obx(() {
        // Show loading indicator only when data is initially loading
        if (controller.isLoading.value && controller.transactions.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
          child: Column(
            children: [
              // Balance Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(DeviceLayout.spacing(16)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Total Balance',
                        style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                      'Rs ${controller.balance.value.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: DeviceLayout.spacing(16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildBalanceItem(
                          context: context,
                          title: 'Income',
                          amount: controller.totalIncome.value,
                          isIncome: true,
                        ),
                        _buildBalanceItem(
                          context: context,
                          title: 'Expense',
                          amount: controller.totalExpense.value,
                          isIncome: false,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: DeviceLayout.spacing(16)),

              // Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Transactions',
                      style: Theme.of(context).textTheme.bodyMedium),
                  Text('${controller.transactions.length} records',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              SizedBox(height: DeviceLayout.spacing(8)),

              // Income & Expense Sections
              DefaultTabController(
                length: 2,
                child: Expanded(
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: Theme.of(context).primaryColor,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Theme.of(context).primaryColor,
                        tabs: const [
                          Tab(text: 'Expenses'),
                          Tab(text: 'Income'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Expenses Tab
                            _buildCategoryList(
                                context,
                                controller
                                    .getCategoryTotals(TransactionType.expense),
                                TransactionType.expense),

                            // Income Tab
                            _buildCategoryList(
                                context,
                                controller
                                    .getCategoryTotals(TransactionType.income),
                                TransactionType.income),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Add Transaction Button
              ElevatedButton(
                onPressed: controller.showTransactionTypeDialog,
                child: Text("New Transaction"),
              ),
              SizedBox(height: DeviceLayout.spacing(16)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCategoryList(BuildContext context,
      List<Map<String, dynamic>> categories, TransactionType type) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == TransactionType.expense
                  ? Icons.money_off
                  : Icons.attach_money,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${type == TransactionType.expense ? 'expenses' : 'income'} yet',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => controller.showCategoryTransactions(
              category['category'],
              type,
              category['color'],
              category['icon'],
            ),
            child: CategoryTotalCard(
              avatarColor: category['color'],
              icon: category['icon'],
              categoryName: category['category'],
              amount: category['amount'],
              isExpense: type == TransactionType.expense,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalanceItem({
    required BuildContext context,
    required String title,
    required double amount,
    required bool isIncome,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.backgroundColor,
            border: Border.all(
              color: isIncome ? AppColors.primary : AppColors.error,
              width: 2,
            ),
          ),
          child: Icon(
            isIncome ? Icons.arrow_upward : Icons.arrow_downward,
            color: isIncome ? AppColors.primary : AppColors.error,
          ),
        ),
        SizedBox(width: DeviceLayout.spacing(8)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            Text('Rs ${amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ],
    );
  }
}
