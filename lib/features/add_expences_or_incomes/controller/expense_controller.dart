import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mydaymate/core/theme/app_colors.dart';
import 'package:mydaymate/features/financial_planner/model/transaction_model.dart';
import 'package:mydaymate/features/financial_planner/service/financial_service.dart';
import 'package:mydaymate/features/financial_planner/controller/financial_planner_controller.dart';
import 'package:mydaymate/features/chatbot/service/gemini_service.dart';

class ExpenseController extends GetxController {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final Rx<String> selectedCategory = ''.obs;
  final Rx<File?> receiptImage = Rx<File?>(null);
  final RxBool isLoading = false.obs;

  final FinancialService _financialService = FinancialService();
  final GeminiService _geminiService = GeminiService();

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
      'name': 'Transportation',
      'icon': Icons.directions_car,
      'color': Colors.blue,
      'keywords': ['taxi', 'uber', 'bus', 'train', 'fuel', 'gas']
    },
    {
      'name': 'Entertainment',
      'icon': Icons.movie,
      'color': Colors.purple,
      'keywords': ['cinema', 'movie', 'game', 'theater', 'event']
    },
    {
      'name': 'Medical',
      'icon': Icons.medical_services,
      'color': Colors.red,
      'keywords': ['doctor', 'hospital', 'medicine', 'pharmacy', 'health']
    },
    {
      'name': 'Utilities',
      'icon': Icons.bolt,
      'color': Colors.amber,
      'keywords': ['bill', 'electric', 'water', 'internet', 'phone']
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

  // Select date method
  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      dateController.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  // Simplified capture receipt method - without explicit permission checks
  Future<void> captureReceipt() async {
    try {
      // Show image source selection dialog
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: Get.context!,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      // Let ImagePicker handle permissions internally
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        receiptImage.value = File(image.path);
        _processReceiptImageWithGemini(image.path);
      }
    } catch (e) {
      print('Error capturing receipt: $e');
      Get.snackbar(
        'Error',
        'Could not access camera or gallery. Please check app permissions in your device settings.',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 5),
        mainButton: TextButton(
          child: Text('Settings', style: TextStyle(color: Colors.white)),
          onPressed: () {
            // Import required package at the top: import 'package:app_settings/app_settings.dart';
            // AppSettings.openAppSettings();
            // Or use built-in methods if available
          },
        ),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Process receipt image using Gemini AI
  Future<void> _processReceiptImageWithGemini(String imagePath) async {
    isLoading.value = true;

    try {
      // Prepare prompt for Gemini
      final prompt = '''
      This image is a receipt. Please analyze it carefully and extract the following information:
      1. The total amount (just the number, not the currency symbol)
      2. The most appropriate expense category from this list: Food & Drinks, Shopping, Transportation, Entertainment, Medical, Utilities, or Other
      3. The name of the store or merchant (if available)
      4. The date of purchase (if available)

      Format your response as JSON like this:
      {
        "amount": "112.50",
        "category": "Food & Drinks",
        "merchant": "ABC Restaurant",
        "date": "12/04/2025",
        "items": ["item1", "item2"] 
      }
      
      If you can't find some information, just put an empty value.
      ''';

      // Call Gemini API with image
      final response = await _geminiService.generateResponse(
        prompt,
        imagePath: imagePath,
      );

      // Process the response
      _processGeminiResponse(response);
    } catch (e) {
      print('Error processing receipt: $e');
      Get.snackbar(
        'Processing error',
        'Failed to process receipt image. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Process Gemini's response
  void _processGeminiResponse(String response) {
    try {
      // Extract JSON from response
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;

      if (jsonStart < 0 || jsonEnd <= jsonStart) {
        // Try to find the amount directly in the response if JSON parsing fails
        _extractInfoFromText(response);
        return;
      }

      final jsonString = response.substring(jsonStart, jsonEnd);
      final Map<String, dynamic> data = json.decode(jsonString);

      // Extract values
      final amount = data['amount'] as String? ?? '';
      final category = data['category'] as String? ?? 'Other';
      final merchant = data['merchant'] as String? ?? '';
      final date = data['date'] as String? ?? '';
      final items = data['items'] as List<dynamic>? ?? [];

      // Set values in the UI
      if (amount.isNotEmpty) {
        amountController.text = amount;
      }

      // Find matching category
      final matchingCategory = expenseCategories.firstWhere(
        (cat) => cat['name'].toString().toLowerCase() == category.toLowerCase(),
        orElse: () => expenseCategories.last, // Default to "Other"
      );
      selectedCategory.value = matchingCategory['name'] as String;

      // Set note to include merchant name and items
      if (merchant.isNotEmpty) {
        String note = "Receipt from $merchant";
        if (items.isNotEmpty) {
          note += "\nItems: ${items.join(', ')}";
        }
        noteController.text = note;
      }

      // Set date if found and valid
      if (date.isNotEmpty) {
        try {
          final dateParts = date.split('/');
          if (dateParts.length == 3) {
            dateController.text = date;
          }
        } catch (e) {
          // Use current date (already set)
        }
      }

      // Show confirmation dialog
      _showReceiptConfirmationDialog(
        double.tryParse(amount) ?? 0.0,
        category,
        merchant,
        items.cast<String>(),
      );
    } catch (e) {
      print('Error parsing Gemini response: $e');
      // Try alternate extraction method if JSON parsing fails
      _extractInfoFromText(response);
    }
  }

  // Fallback extraction from text if JSON parsing fails
  void _extractInfoFromText(String text) {
    try {
      // Try to extract amount using regex
      final amountRegex = RegExp(r'\b(\d+[.,]\d{2})\b');
      final amountMatch = amountRegex.firstMatch(text);

      if (amountMatch != null) {
        final amount = amountMatch.group(1)?.replaceAll(',', '.') ?? '';
        amountController.text = amount;
      }

      // Try to determine category
      String bestCategory = 'Other';
      int bestScore = 0;

      for (var category in expenseCategories) {
        final keywords = category['keywords'] as List<String>;
        int score = 0;

        for (var keyword in keywords) {
          if (text.toLowerCase().contains(keyword.toLowerCase())) {
            score++;
          }
        }

        if (score > bestScore) {
          bestScore = score;
          bestCategory = category['name'] as String;
        }
      }

      selectedCategory.value = bestCategory;

      // Set note from text (truncated)
      noteController.text =
          "From receipt: ${text.substring(0, min(50, text.length))}...";

      // Show confirmation dialog
      final amount = double.tryParse(amountController.text) ?? 0.0;
      _showReceiptConfirmationDialog(amount, bestCategory, '', []);
    } catch (e) {
      print('Error in fallback extraction: $e');
      Get.snackbar(
        'Processing error',
        'Couldn\'t extract information from the receipt',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Show confirmation dialog for extracted receipt info
  void _showReceiptConfirmationDialog(
    double amount,
    String category,
    String merchant,
    List<String> items,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text('Receipt Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Detected the following information:'),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.attach_money, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Total: Rs ${amount.toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.category, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Category: $category',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              if (merchant.isNotEmpty) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.store, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Merchant: $merchant',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
              if (items.isNotEmpty) ...[
                SizedBox(height: 16),
                Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                ...items
                    .map((item) => Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                          child: Text('• $item'),
                        ))
                    .toList(),
              ],
              SizedBox(height: 16),
              Text('Is this correct?',
                  style: TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Edit'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Receipt Processed',
                'Receipt details have been applied. You can now add the expense.',
                snackPosition: SnackPosition.BOTTOM,
                duration: Duration(seconds: 3),
              );
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // Save expense method - Updated to refresh financial data
  Future<void> saveExpense() async {
    try {
      final amountText = amountController.text.trim();
      if (amountText.isEmpty || double.tryParse(amountText) == null) {
        Get.snackbar(
          'Invalid amount',
          'Please enter a valid amount',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final category = selectedCategory.value;
      if (category == null || category.isEmpty) {
        Get.snackbar(
          'Missing category',
          'Please select an expense category',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final note = noteController.text.trim();

      if (dateController.text.trim().isEmpty ||
          !dateController.text.contains('/')) {
        Get.snackbar(
          'Invalid date',
          'Please select a valid date',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final dateParts = dateController.text.split('/');
      final date = DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
      );

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        Get.snackbar('Error', 'You must be logged in');
        return;
      }

      IconData icon = Icons.category;
      Color color = Colors.grey;

      for (var categoryData in expenseCategories) {
        if (categoryData['name'] == category) {
          icon = categoryData['icon'] as IconData;
          color = categoryData['color'] as Color;
          break;
        }
      }

      isLoading.value = true;

      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: double.parse(amountText),
        category: category,
        date: date,
        note: note,
        type: TransactionType.expense,
        icon: icon,
        color: color,
        userId: userId,
      );

      await _financialService.addTransaction(transaction);

      // Refresh controller if exists
      if (Get.isRegistered<FinancialPlannerController>()) {
        Get.find<FinancialPlannerController>().refreshData();
      }

      // Optional but recommended
      clearForm();

      Get.back();
      Get.snackbar(
        'Success',
        'Expense added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error saving expense: $e');
      Get.snackbar(
        'Error',
        'Failed to save expense: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    amountController.clear();
    noteController.clear();
    dateController.clear();
    selectedCategory.value = expenseCategories[0]['name'] as String;
    receiptImage.value = null;
  }
}
