import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mydaymate/widgets/gradient_button.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/devices.dart';
import '../controller/expense_controller.dart';

class AddExpencesPage extends GetView<ExpenseController> {
  const AddExpencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    DeviceLayout.init(context);

    // More granular screen size detection for better responsiveness
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isMediumScreen = screenSize.width >= 360 && screenSize.width < 600;
    final isLargeScreen = screenSize.width >= 600;

    // Calculate dynamic spacing based on screen size
    final verticalSpacing = isSmallScreen
        ? DeviceLayout.spacing(16)
        : (isMediumScreen
            ? DeviceLayout.spacing(20)
            : DeviceLayout.spacing(24));

    return Scaffold(
      appBar: const CustomAppbar(title: 'Add Expense'),
      body: Obx(() => Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.grey.shade50,
                    ],
                  ),
                ),
                // SafeArea added to respect system UI elements
                child: SafeArea(
                  // SingleChildScrollView added to prevent pixel overflow
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            DeviceLayout.spacing(isSmallScreen ? 12 : 16),
                        vertical: DeviceLayout.spacing(isSmallScreen ? 8 : 12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Amount Input Container with enhanced gradient styling
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(
                                DeviceLayout.spacing(isSmallScreen ? 16 : 20)),
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
                              borderRadius: BorderRadius.circular(
                                  DeviceLayout.spacing(16)),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Amount',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontSize: DeviceLayout.fontSize(
                                            isSmallScreen ? 13 : 16),
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                SizedBox(height: DeviceLayout.spacing(8)),
                                Center(
                                  child: IntrinsicWidth(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          'Rs ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineLarge
                                              ?.copyWith(
                                            color: Colors.white,
                                            fontSize: DeviceLayout.fontSize(
                                                isSmallScreen ? 24 : 28),
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                offset: const Offset(0, 2),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: TextField(
                                            controller:
                                                controller.amountController,
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineLarge
                                                ?.copyWith(
                                              fontSize: DeviceLayout.fontSize(
                                                  isSmallScreen ? 24 : 28),
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  offset: const Offset(0, 2),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            decoration: InputDecoration(
                                              hintText: '0',
                                              hintStyle: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.6),
                                                fontSize: DeviceLayout.fontSize(
                                                    isSmallScreen ? 24 : 28),
                                                fontWeight: FontWeight.w500,
                                              ),
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Optional - add a small decorative element
                                Container(
                                  margin: EdgeInsets.only(
                                      top: DeviceLayout.spacing(8)),
                                  width: DeviceLayout.spacing(40),
                                  height: DeviceLayout.spacing(2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(
                                        DeviceLayout.spacing(1)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: verticalSpacing),

                          // Category Container with improved styling
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: DeviceLayout.spacing(16),
                              vertical:
                                  DeviceLayout.spacing(isSmallScreen ? 6 : 8),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundColor,
                              borderRadius: BorderRadius.circular(
                                  DeviceLayout.spacing(15)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: DeviceLayout.spacing(8),
                                  offset: Offset(0, DeviceLayout.spacing(2)),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.primary,
                                  size: DeviceLayout.fontSize(
                                      isSmallScreen ? 24 : 28),
                                ),
                                borderRadius: BorderRadius.circular(
                                    DeviceLayout.spacing(15)),
                                value: controller.selectedCategory.value,
                                isExpanded: true,
                                hint: Row(
                                  children: [
                                    Icon(
                                      Icons.category_outlined,
                                      color: AppColors.primary.withOpacity(0.7),
                                      size: DeviceLayout.fontSize(
                                          isSmallScreen ? 20 : 22),
                                    ),
                                    SizedBox(width: DeviceLayout.spacing(8)),
                                    Text(
                                      'Select Category',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.grey[600],
                                            fontSize: DeviceLayout.fontSize(
                                                isSmallScreen ? 14 : 16),
                                          ),
                                    ),
                                  ],
                                ),
                                items: controller.expenseCategories
                                    .map((category) {
                                  return DropdownMenuItem<String>(
                                    value: category['name'] as String,
                                    child: Row(
                                      children: [
                                        Icon(
                                          category['icon'] as IconData,
                                          color: category['color'] as Color,
                                          size: DeviceLayout.fontSize(
                                              isSmallScreen ? 20 : 22),
                                        ),
                                        SizedBox(
                                            width: DeviceLayout.spacing(8)),
                                        Text(
                                          category['name'] as String,
                                          style: TextStyle(
                                            fontSize: DeviceLayout.fontSize(
                                                isSmallScreen ? 14 : 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    controller.selectedCategory.value =
                                        newValue;
                                  }
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: verticalSpacing),

                          // Note Container with improved styling
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: DeviceLayout.spacing(16),
                              vertical:
                                  DeviceLayout.spacing(isSmallScreen ? 6 : 8),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundColor,
                              borderRadius: BorderRadius.circular(
                                  DeviceLayout.spacing(15)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: DeviceLayout.spacing(8),
                                  offset: Offset(0, DeviceLayout.spacing(2)),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: controller.noteController,
                                    maxLines: 3,
                                    style: TextStyle(
                                      fontSize: DeviceLayout.fontSize(
                                          isSmallScreen ? 14 : 16),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Add note',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: DeviceLayout.fontSize(
                                            isSmallScreen ? 14 : 16),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: verticalSpacing),

                          // Date Container with improved styling
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: DeviceLayout.spacing(16),
                              vertical:
                                  DeviceLayout.spacing(isSmallScreen ? 6 : 8),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundColor,
                              borderRadius: BorderRadius.circular(
                                  DeviceLayout.spacing(15)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: DeviceLayout.spacing(8),
                                  offset: Offset(0, DeviceLayout.spacing(2)),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: controller.dateController,
                                    readOnly: true,
                                    style: TextStyle(
                                      fontSize: DeviceLayout.fontSize(
                                          isSmallScreen ? 14 : 16),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Select date',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: DeviceLayout.fontSize(
                                            isSmallScreen ? 14 : 16),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.calendar_month_outlined,
                                      color: AppColors.primary,
                                      size: DeviceLayout.fontSize(
                                          isSmallScreen ? 20 : 22),
                                    ),
                                    onPressed: controller.selectDate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: verticalSpacing),

                          // Receipt button with improved styling
                          GestureDetector(
                            onTap: controller.captureReceipt,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: DeviceLayout.spacing(16),
                                vertical: DeviceLayout.spacing(
                                    isSmallScreen ? 12 : 14),
                              ),
                              decoration: BoxDecoration(
                                color: controller.receiptImage.value != null
                                    ? Colors.green.withOpacity(0.1)
                                    : AppColors.captureReceipt,
                                borderRadius: BorderRadius.circular(
                                    DeviceLayout.spacing(15)),
                                border: Border.all(
                                  color: controller.receiptImage.value != null
                                      ? Colors.green.withOpacity(0.3)
                                      : Colors.grey.shade200,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: DeviceLayout.spacing(8),
                                    offset: Offset(0, DeviceLayout.spacing(2)),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    controller.receiptImage.value != null
                                        ? Icons.check_circle_outline
                                        : Icons.camera_alt_outlined,
                                    color: controller.receiptImage.value != null
                                        ? Colors.green
                                        : AppColors.primary,
                                    size: DeviceLayout.fontSize(
                                        isSmallScreen ? 20 : 22),
                                  ),
                                  SizedBox(width: DeviceLayout.spacing(10)),
                                  Text(
                                    controller.receiptImage.value != null
                                        ? "Receipt Captured"
                                        : "Capture Receipt",
                                    style: TextStyle(
                                      color:
                                          controller.receiptImage.value != null
                                              ? Colors.green
                                              : Colors.black87,
                                      fontWeight: FontWeight.w500,
                                      fontSize: DeviceLayout.fontSize(
                                          isSmallScreen ? 14 : 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: verticalSpacing * 1.5),

                          // Add Expense button with improved styling - No more Spacer() which doesn't work in ScrollView
                          GradientButton(
                              text: "Add Expense",
                              onTap: controller.saveExpense),
                          SizedBox(
                              height: DeviceLayout.spacing(
                                  isSmallScreen ? 16 : 20)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Enhanced loading overlay
              if (controller.isLoading.value)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(DeviceLayout.spacing(20)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(DeviceLayout.spacing(16)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                          SizedBox(height: DeviceLayout.spacing(16)),
                          Text(
                            "Saving expense...",
                            style: TextStyle(
                              fontSize: DeviceLayout.fontSize(14),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          )),
    );
  }
}
