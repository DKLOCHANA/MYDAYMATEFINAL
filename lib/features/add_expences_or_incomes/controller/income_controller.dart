import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../features/financial_planner/model/transaction_model.dart';
import '../../../features/financial_planner/service/financial_service.dart';
import '../../../features/financial_planner/controller/financial_planner_controller.dart';

class IncomeController extends GetxController {
  final FinancialService _service = FinancialService();

  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final dateController = TextEditingController();

  final selectedDate = Rx<DateTime>(DateTime.now());
  final selectedCategory = RxnString();
  final isLoading = false.obs;
  final receiptImage = Rxn<File>();

  final incomeCategories = [
    {
      'name': 'Salary',
      'icon': Icons.account_balance_wallet,
      'color': Colors.green,
    },
    {
      'name': 'Business',
      'icon': Icons.business,
      'color': Colors.blue,
    },
    {
      'name': 'Investments',
      'icon': Icons.trending_up,
      'color': Colors.purple,
    },
    {
      'name': 'Gifts',
      'icon': Icons.card_giftcard,
      'color': Colors.pink,
    },
    {
      'name': 'Others',
      'icon': Icons.more_horiz,
      'color': Colors.grey,
    },
  ];

  @override
  void onInit() {
    super.onInit();
    updateDateController();
  }

  void updateDateController() {
    final date = selectedDate.value;
    dateController.text = "${date.day}/${date.month}/${date.year}";
  }

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      selectedDate.value = picked;
      updateDateController();
    }
  }

  Future<void> captureReceipt() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        receiptImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture document');
    }
  }

  Future<void> saveIncome() async {
    if (!validateIncome()) return;

    try {
      isLoading.value = true;

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        Get.snackbar('Error', 'You must be logged in');
        return;
      }

      final categoryData = incomeCategories.firstWhere(
        (c) => c['name'] == selectedCategory.value,
      );

      String? receiptURL;
      if (receiptImage.value != null) {
        final transactionId = DateTime.now().millisecondsSinceEpoch.toString();
        receiptURL = await _service.uploadReceiptImage(
          receiptImage.value!,
          transactionId,
        );
      }

      final transaction = TransactionModel(
        category: selectedCategory.value!,
        icon: categoryData['icon'] as IconData,
        color: categoryData['color'] as Color,
        amount: double.parse(amountController.text),
        date: selectedDate.value,
        note: noteController.text,
        type: TransactionType.income,
        userId: userId,
        receiptURL: receiptURL,
      );

      await _service.addTransaction(transaction);
      clearForm();

      // Simple way to refresh the financial planner
      if (Get.isRegistered<FinancialPlannerController>()) {
        Get.find<FinancialPlannerController>().refreshData();
      }

      Get.back();
      Get.snackbar(
        'Success',
        'Income added successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to save income: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  bool validateIncome() {
    if (amountController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter amount');
      return false;
    }

    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(amountController.text)) {
      Get.snackbar('Error', 'Please enter a valid amount');
      return false;
    }

    if (selectedCategory.value == null) {
      Get.snackbar('Error', 'Please select a category');
      return false;
    }

    return true;
  }

  void clearForm() {
    amountController.clear();
    noteController.clear();
    selectedCategory.value = null;
    selectedDate.value = DateTime.now();
    updateDateController();
    receiptImage.value = null;
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    dateController.dispose();
    super.dispose();
  }
}
