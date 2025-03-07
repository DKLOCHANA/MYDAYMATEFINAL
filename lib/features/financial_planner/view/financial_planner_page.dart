import 'package:flutter/material.dart';
import 'package:mydaymate/core/theme/app_text_styles.dart';
import 'package:get/get.dart';
import 'package:mydaymate/features/financial_planner/data/dummy_transactions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/devices.dart';
import '../../../widgets/category_card.dart';
import '../../../widgets/custom_appbar.dart';
import '../controller/financial_planner_controller.dart';

class FinancialPlannerPage extends GetView<FinancialPlannerController> {
  const FinancialPlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: 'Financial Planner'),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
        child: Column(
          children: [
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
                  Obx(() => Text(
                        'Rs ${controller.balance.value.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      )),
                  SizedBox(height: DeviceLayout.spacing(16)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBalanceItem(
                        context: context,
                        title: 'Income',
                        amount: DummyTransactions.totalIncome,
                        isIncome: true,
                      ),
                      _buildBalanceItem(
                        context: context,
                        title: 'Expense',
                        amount: DummyTransactions.totalExpense,
                        isIncome: false,
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: DeviceLayout.spacing(16)),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Transactions',
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
            SizedBox(height: DeviceLayout.spacing(16)),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: controller.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = controller.transactions[index];
                      return Padding(
                        padding:
                            EdgeInsets.only(bottom: DeviceLayout.spacing(8)),
                        child: CategoryCard(
                          avatarColor: transaction.color,
                          icon: transaction.icon,
                          categoryName: transaction.category,
                          amount: transaction.amount,
                          date: transaction.date,
                          isExpense: transaction.isExpense,
                        ),
                      );
                    },
                  )),
            ),
            ElevatedButton(
              onPressed: controller.showTransactionTypeDialog,
              child: Text(
                "New Transaction",
                style: AppTextStyles.titleLarge,
              ),
            ),
            SizedBox(height: DeviceLayout.spacing(16)),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem({
    required BuildContext context,
    required String title,
    required double? amount,
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
            Text('Rs ${amount?.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ],
    );
  }
}
