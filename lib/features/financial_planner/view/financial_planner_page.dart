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
    // Get screen dimensions for responsive sizing
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    // Refresh data when page is displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.onPageFocus();
    });

    return Scaffold(
      appBar: CustomAppbar(title: 'Financial Planner'),
      body: Container(
        // Add subtle gradient background to entire page
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey.shade50,
              Colors.grey.shade100.withOpacity(0.5),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: Obx(() {
          // Show loading indicator only when data is initially loading
          if (controller.isLoading.value && controller.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: DeviceLayout.spacing(isSmallScreen ? 8 : 10),
              horizontal: DeviceLayout.spacing(isSmallScreen ? 16 : 20),
            ),
            child: Column(
              children: [
                // Balance Card with radial gradient background and elegant styling
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topRight,
                      radius: 1.8,
                      colors: [
                        AppColors.primary.withOpacity(0.8),
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.7),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                    borderRadius:
                        BorderRadius.circular(DeviceLayout.spacing(16)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: DeviceLayout.spacing(12),
                        offset: Offset(0, DeviceLayout.spacing(4)),
                        spreadRadius: DeviceLayout.spacing(2),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: DeviceLayout.spacing(4),
                        offset: Offset(0, -DeviceLayout.spacing(1)),
                        spreadRadius: 0,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(
                        DeviceLayout.spacing(isSmallScreen ? 16 : 20)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Decorative circle element

                        SizedBox(height: DeviceLayout.spacing(4)),
                        Text(
                          'Total Balance',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: DeviceLayout.fontSize(
                                        isSmallScreen ? 14 : 16),
                                    color: Colors.white.withOpacity(0.9),
                                    letterSpacing: 0.5,
                                  ),
                        ),
                        Text(
                          'Rs ${controller.balance.value.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                            fontSize:
                                DeviceLayout.fontSize(isSmallScreen ? 28 : 34),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: DeviceLayout.spacing(16)),

                        // Income/Expense Row with glass effect background
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical:
                                DeviceLayout.spacing(isSmallScreen ? 10 : 12),
                            horizontal:
                                DeviceLayout.spacing(isSmallScreen ? 8 : 12),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius:
                                BorderRadius.circular(DeviceLayout.spacing(12)),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Calculate the max width for each side
                              final availableWidth = constraints.maxWidth;
                              final sideWidth =
                                  (availableWidth - DeviceLayout.spacing(10)) /
                                      2;

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Income side - constrained by calculated width
                                  SizedBox(
                                    width: sideWidth,
                                    child: _buildBalanceItem(
                                      context: context,
                                      title: 'Income',
                                      amount: controller.totalIncome.value,
                                      isIncome: true,
                                      isSmallScreen: isSmallScreen,
                                      textColor: Colors.white,
                                      highlightColor: Colors.greenAccent,
                                      bgColor: Colors.white.withOpacity(0.15),
                                      compact:
                                          isSmallScreen || availableWidth < 300,
                                    ),
                                  ),

                                  // Center divider
                                  Container(
                                    height: DeviceLayout.spacing(40),
                                    width: DeviceLayout.spacing(1),
                                    color: Colors.white.withOpacity(0.3),
                                  ),

                                  // Expense side - constrained by calculated width
                                  SizedBox(
                                    width: sideWidth,
                                    child: _buildBalanceItem(
                                      context: context,
                                      title: 'Expense',
                                      amount: controller.totalExpense.value,
                                      isIncome: false,
                                      isSmallScreen: isSmallScreen,
                                      textColor: Colors.white,
                                      highlightColor: Colors.redAccent,
                                      bgColor: Colors.white.withOpacity(0.15),
                                      compact:
                                          isSmallScreen || availableWidth < 300,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: DeviceLayout.spacing(isSmallScreen ? 16 : 20)),

                // Transactions Header with badge styling
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: DeviceLayout.spacing(4),
                          height: DeviceLayout.spacing(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius:
                                BorderRadius.circular(DeviceLayout.spacing(2)),
                          ),
                        ),
                        SizedBox(width: DeviceLayout.spacing(8)),
                        Text(
                          'Transactions',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: DeviceLayout.fontSize(
                                        isSmallScreen ? 16 : 18),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: DeviceLayout.spacing(10),
                        vertical: DeviceLayout.spacing(6),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius:
                            BorderRadius.circular(DeviceLayout.spacing(20)),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${controller.transactions.length} records',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: DeviceLayout.fontSize(
                                  isSmallScreen ? 11 : 12),
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: DeviceLayout.spacing(isSmallScreen ? 12 : 16)),

                // Income & Expense Sections with elevated tab bar
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(DeviceLayout.spacing(16)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: DeviceLayout.spacing(10),
                          offset: Offset(0, DeviceLayout.spacing(2)),
                          spreadRadius: DeviceLayout.spacing(1),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(
                          DeviceLayout.spacing(isSmallScreen ? 12 : 16)),
                      child: DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            // Custom tab bar with responsive height
                            Container(
                              height:
                                  DeviceLayout.spacing(isSmallScreen ? 45 : 50),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(
                                    DeviceLayout.spacing(25)),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: TabBar(
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.grey[700],
                                indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      DeviceLayout.spacing(25)),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.secondary.withOpacity(0.8),
                                      AppColors.secondary,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                labelStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                                dividerColor:
                                    Colors.transparent, // Remove divider
                                indicatorSize: TabBarIndicatorSize
                                    .tab, // Make indicator fill the tab
                                tabs: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: DeviceLayout.spacing(
                                          isSmallScreen ? 2 : 4),
                                    ),
                                    child: Tab(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.arrow_downward,
                                            size: DeviceLayout.fontSize(
                                                isSmallScreen ? 16 : 18),
                                          ),
                                          SizedBox(
                                              width: DeviceLayout.spacing(4)),
                                          Flexible(
                                            child: Text(
                                              'Expenses',
                                              style: TextStyle(
                                                fontSize: DeviceLayout.fontSize(
                                                    isSmallScreen ? 12 : 14),
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                    offset: const Offset(0, 1),
                                                    blurRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: DeviceLayout.spacing(
                                          isSmallScreen ? 2 : 4),
                                    ),
                                    child: Tab(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.arrow_upward,
                                            size: DeviceLayout.fontSize(
                                                isSmallScreen ? 16 : 18),
                                          ),
                                          SizedBox(
                                              width: DeviceLayout.spacing(4)),
                                          Flexible(
                                            child: Text(
                                              'Incomes',
                                              style: TextStyle(
                                                fontSize: DeviceLayout.fontSize(
                                                    isSmallScreen ? 12 : 14),
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                    offset: const Offset(0, 1),
                                                    blurRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                height: DeviceLayout.spacing(
                                    isSmallScreen ? 12 : 16)),

                            // Tab content with responsive padding
                            Expanded(
                              child: TabBarView(
                                children: [
                                  // Expenses Tab
                                  _buildCategoryList(
                                    context,
                                    controller.getCategoryTotals(
                                        TransactionType.expense),
                                    TransactionType.expense,
                                    isSmallScreen,
                                  ),

                                  // Income Tab
                                  _buildCategoryList(
                                    context,
                                    controller.getCategoryTotals(
                                        TransactionType.income),
                                    TransactionType.income,
                                    isSmallScreen,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Add Transaction Button with gradient and shadow
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(
                    vertical: DeviceLayout.spacing(isSmallScreen ? 16 : 20),
                  ),
                  height: DeviceLayout.spacing(isSmallScreen ? 52 : 58),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(DeviceLayout.spacing(12)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.3),
                        blurRadius: DeviceLayout.spacing(10),
                        offset: Offset(0, DeviceLayout.spacing(4)),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: controller.showTransactionTypeDialog,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(DeviceLayout.spacing(12)),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.secondary.withOpacity(0.9),
                            AppColors.secondary,
                            AppColors.secondary.withOpacity(0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius:
                            BorderRadius.circular(DeviceLayout.spacing(12)),
                      ),
                      child: Text(
                        "New Transaction",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              DeviceLayout.fontSize(isSmallScreen ? 14 : 16),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    List<Map<String, dynamic>> categories,
    TransactionType type,
    bool isSmallScreen,
  ) {
    if (categories.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: DeviceLayout.spacing(8)),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(DeviceLayout.spacing(12)),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(DeviceLayout.spacing(16)),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.grey.shade200,
                      Colors.grey.shade100,
                    ],
                    radius: 0.8,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Icon(
                  type == TransactionType.expense
                      ? Icons.money_off
                      : Icons.attach_money,
                  size: DeviceLayout.fontSize(isSmallScreen ? 40 : 48),
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(height: DeviceLayout.spacing(isSmallScreen ? 12 : 16)),
              Text(
                'No ${type == TransactionType.expense ? 'expenses' : 'income'} yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                      fontSize: DeviceLayout.fontSize(isSmallScreen ? 14 : 16),
                    ),
              ),
              SizedBox(height: DeviceLayout.spacing(8)),
              TextButton.icon(
                onPressed: controller.showTransactionTypeDialog,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade50,
                  padding: EdgeInsets.symmetric(
                    horizontal: DeviceLayout.spacing(16),
                    vertical: DeviceLayout.spacing(8),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(DeviceLayout.spacing(20)),
                    side: BorderSide(color: AppColors.primary, width: 1),
                  ),
                ),
                icon: Icon(
                  Icons.add,
                  size: DeviceLayout.fontSize(isSmallScreen ? 18 : 20),
                  color: AppColors.primary,
                ),
                label: Text(
                  'Add ${type == TransactionType.expense ? 'expense' : 'income'}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: DeviceLayout.fontSize(isSmallScreen ? 13 : 14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Create a responsive grid layout based on available width
    return LayoutBuilder(builder: (context, constraints) {
      // Determine if we should use grid or list view
      final useGrid = constraints.maxWidth > 400 && categories.length > 1;
      final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

      if (useGrid) {
        return GridView.builder(
          padding: EdgeInsets.all(DeviceLayout.spacing(isSmallScreen ? 4 : 8)),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 2.5,
            crossAxisSpacing: DeviceLayout.spacing(12),
            mainAxisSpacing: DeviceLayout.spacing(12),
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return _buildCategoryCard(
              context,
              categories[index],
              type,
              isSmallScreen,
              isGridCard: true,
            );
          },
        );
      }

      // Fall back to ListView for narrow screens
      return ListView.builder(
        padding: EdgeInsets.symmetric(
            vertical: DeviceLayout.spacing(isSmallScreen ? 4 : 8)),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return _buildCategoryCard(
            context,
            categories[index],
            type,
            isSmallScreen,
            isGridCard: false,
          );
        },
      );
    });
  }

  // Helper method to build individual category cards
  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> category,
      TransactionType type, bool isSmallScreen,
      {bool isGridCard = false}) {
    final color = category['color'] ??
        (type == TransactionType.expense
            ? Colors.redAccent
            : Colors.greenAccent);

    // Format amount for display
    final amount = category['amount'] as double;
    final formattedAmount = amount > 9999
        ? '${(amount / 1000).toStringAsFixed(1)}K'
        : amount.toStringAsFixed(2);

    return Padding(
      padding: EdgeInsets.only(
        bottom: isGridCard ? 0 : DeviceLayout.spacing(isSmallScreen ? 8 : 10),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DeviceLayout.spacing(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade100,
            width: 1,
          ),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(DeviceLayout.spacing(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(DeviceLayout.spacing(12)),
            onTap: () => controller.showCategoryTransactions(
              category['category'],
              type,
              category['color'],
              category['icon'],
            ),
            child: Padding(
              padding:
                  EdgeInsets.all(DeviceLayout.spacing(isSmallScreen ? 10 : 12)),
              child: Row(
                children: [
                  // Category icon with background
                  Container(
                    width: DeviceLayout.spacing(isSmallScreen ? 38 : 44),
                    height: DeviceLayout.spacing(isSmallScreen ? 38 : 44),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      category['icon'] ?? Icons.category,
                      color: color,
                      size: DeviceLayout.fontSize(isSmallScreen ? 18 : 20),
                    ),
                  ),
                  SizedBox(
                      width: DeviceLayout.spacing(isSmallScreen ? 10 : 12)),

                  // Category name and amount
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          category['category'] ?? 'Category',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: DeviceLayout.fontSize(
                                        isSmallScreen ? 13 : 14),
                                    fontWeight: FontWeight.w600,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: DeviceLayout.spacing(2)),
                        Text(
                          'Rs ${formattedAmount}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: DeviceLayout.fontSize(
                                        isSmallScreen ? 12 : 13),
                                    color: type == TransactionType.expense
                                        ? Colors.redAccent
                                        : Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow icon
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade400,
                    size: DeviceLayout.fontSize(isSmallScreen ? 14 : 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceItem({
    required BuildContext context,
    required String title,
    required double amount,
    required bool isIncome,
    required bool isSmallScreen,
    Color? textColor,
    Color? highlightColor,
    Color? bgColor,
    bool compact = false,
  }) {
    // Adjust sizes based on available space
    final iconSize =
        DeviceLayout.spacing(compact ? 30 : (isSmallScreen ? 36 : 40));

    // Format amount to avoid overflow with large numbers
    final formattedAmount = compact && amount > 9999
        ? '${(amount / 1000).toStringAsFixed(1)}K'
        : amount.toStringAsFixed(2);

    return Row(
      mainAxisSize: MainAxisSize.min, // Take minimum space
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor ??
                (isIncome
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1)),
            border: Border.all(
              color: highlightColor ??
                  (isIncome ? AppColors.primary : AppColors.error),
              width: compact ? 1.5 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isIncome ? Icons.arrow_upward : Icons.arrow_downward,
            color: highlightColor ??
                (isIncome ? AppColors.primary : AppColors.error),
            size:
                DeviceLayout.fontSize(compact ? 14 : (isSmallScreen ? 16 : 18)),
          ),
        ),
        SizedBox(width: DeviceLayout.spacing(compact ? 4 : 8)),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: DeviceLayout.fontSize(
                          compact ? 10 : (isSmallScreen ? 12 : 14)),
                      color: textColor ?? Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Rs ${formattedAmount}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: DeviceLayout.fontSize(
                          compact ? 12 : (isSmallScreen ? 14 : 16)),
                      fontWeight: FontWeight.w600,
                      color: textColor ??
                          (isIncome ? AppColors.primary : AppColors.error),
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
