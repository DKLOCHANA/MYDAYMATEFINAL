import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_ml_kit/google_ml_kit.dart' as mlkit;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mydaymate/features/chatbot/model/chatbot_model.dart';
import 'package:mydaymate/features/chatbot/service/gemini_service.dart';
import 'package:mydaymate/features/chatbot/service/receipt_processor_service.dart';
import 'package:mydaymate/features/task/controller/task_list_controller.dart';
import 'package:mydaymate/features/task/model/task_model.dart';
import 'package:mydaymate/features/grocery/controller/grocery_controller.dart';
import 'package:mydaymate/features/grocery/model/grocery_item.dart';
import 'package:mydaymate/features/receipe_planner/controller/favorites_controller.dart';
import 'package:mydaymate/features/receipe_planner/controller/recipe_controller.dart';
import 'package:mydaymate/features/financial_planner/controller/financial_planner_controller.dart';
import 'package:mydaymate/features/financial_planner/model/transaction_model.dart';
import 'package:mydaymate/features/financial_planner/service/financial_service.dart';
import 'package:timezone/timezone.dart' as tz;

class ChatbotController extends GetxController {
  // Gemini service
  final GeminiService _geminiService = GeminiService();
  final ReceiptProcessorService _receiptProcessor = ReceiptProcessorService();
  final FinancialService _financialService = FinancialService();

  // Chat state
  final RxList<Message> messages = <Message>[].obs;
  final Rx<UserProfile> userProfile = UserProfile().obs;
  final RxBool isLoading = false.obs;
  final RxBool isFirstTime = true.obs;
  final RxBool isListening = false.obs;

  // Onboarding questions
  final List<String> onboardingQuestions = [
    "Hi there! I'm your personal assistant. What's your name?",
    "Nice to meet you! How old are you?",
    "Do you have any medical conditions I should know about?",
    "What time do you usually wake up in the morning? (e.g., 7:00 AM)",
    "What time do you usually go to bed? (e.g., 10:00 PM)",
    "What are some of your hobbies or interests?",
    "What time do you usually have breakfast? (e.g., 8:00 AM)",
    "What time do you usually have lunch? (e.g., 1:00 PM)",
    "What time do you usually have dinner? (e.g., 7:00 PM)",
    "What are some of your favorite foods?",
    "Is there anything else you'd like me to know about you?",
  ];

  // Current question index
  final RxInt currentQuestionIndex = 0.obs;

  // Text controller for user input
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  @override
  void onInit() {
    super.onInit();
    initializeNotifications();
    loadUserProfile();
    loadChatHistory();
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // Initialize notifications
  Future<void> initializeNotifications() async {
    try {
      // Check for permissions
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
        isAllowed = await AwesomeNotifications().isNotificationAllowed();
        if (!isAllowed) {
          Get.snackbar(
            'Notification Permission',
            'Please enable notifications in settings to receive reminders.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }

      // Request exact alarm permission for Android
      if (Platform.isAndroid) {
        bool exactAlarmAllowed =
            await AwesomeNotifications().isNotificationAllowed();
        if (!exactAlarmAllowed) {
          Get.snackbar(
            'Exact Alarm Permission',
            'Please allow exact alarms in settings for scheduled notifications.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  // Load user profile from SharedPreferences
  Future<void> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userProfileJson = prefs.getString('user_profile');

    if (userProfileJson != null) {
      try {
        userProfile.value = UserProfile.fromJson(json.decode(userProfileJson));
        isFirstTime.value = !userProfile.value.onboardingCompleted;

        if (!isFirstTime.value) {
          print('Scheduling notifications from loadUserProfile');
          scheduleRoutineNotifications();
        }
      } catch (e) {
        print('Error loading user profile: $e');
      }
    } else {
      isFirstTime.value = true;

      if (messages.isEmpty) {
        addBotMessage(onboardingQuestions[0]);
      }
    }
  }

  // Load chat history from SharedPreferences
  Future<void> loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? chatHistoryJson = prefs.getString('chat_history');

    if (chatHistoryJson != null) {
      try {
        final List<dynamic> chatHistory = json.decode(chatHistoryJson);
        messages.assignAll(
            chatHistory.map((message) => Message.fromJson(message)).toList());
      } catch (e) {
        print('Error loading chat history: $e');
      }
    } else if (isFirstTime.value && messages.isEmpty) {
      addBotMessage(onboardingQuestions[0]);
    }
  }

  // Save user profile to SharedPreferences
  Future<void> saveUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'user_profile', json.encode(userProfile.value.toJson()));
  }

  // Save chat history to SharedPreferences
  Future<void> saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_history',
        json.encode(messages.map((message) => message.toJson()).toList()));
  }

  // Add a message from the user with optional image
  void addUserMessage(String text, {String? imagePath}) {
    if (text.trim().isEmpty && imagePath == null) return;

    final message = Message(text: text, isUser: true, imageUrl: imagePath);
    messages.add(message);
    saveChatHistory();

    if (isFirstTime.value) {
      processOnboardingResponse(text);
    } else {
      generateBotResponse(text, imagePath: imagePath);
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Add a message from the bot
  void addBotMessage(String text) {
    final message = Message(text: text, isUser: false);
    messages.add(message);
    saveChatHistory();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Process user response during onboarding
  void processOnboardingResponse(String response) {
    switch (currentQuestionIndex.value) {
      case 0:
        userProfile.update((val) {
          val?.name = response;
        });
        break;
      case 1:
        userProfile.update((val) {
          val?.age = response;
        });
        break;
      case 2:
        userProfile.update((val) {
          val?.medicalConditions =
              response.split(',').map((e) => e.trim()).toList();
        });
        break;
      case 3:
        userProfile.update((val) {
          val?.dailyRoutine['wakeup'] = response;
        });
        break;
      case 4:
        userProfile.update((val) {
          val?.dailyRoutine['bedtime'] = response;
        });
        break;
      case 5:
        userProfile.update((val) {
          val?.hobbies = response.split(',').map((e) => e.trim()).toList();
        });
        break;
      case 6:
        userProfile.update((val) {
          val?.mealTimes['breakfast'] = response;
        });
        break;
      case 7:
        userProfile.update((val) {
          val?.mealTimes['lunch'] = response;
        });
        break;
      case 8:
        userProfile.update((val) {
          val?.mealTimes['dinner'] = response;
        });
        break;
      case 9:
        userProfile.update((val) {
          val?.favoriteFoods =
              response.split(',').map((e) => e.trim()).toList();
        });
        break;
      case 10:
        userProfile.update((val) {
          val?.additionalInfo['misc'] = response;
          val?.onboardingCompleted = true;
        });
        break;
    }

    saveUserProfile();

    currentQuestionIndex.value++;

    if (currentQuestionIndex.value < onboardingQuestions.length) {
      addBotMessage(onboardingQuestions[currentQuestionIndex.value]);
    } else {
      isFirstTime.value = false;
      userProfile.update((val) {
        val?.onboardingCompleted = true;
      });
      saveUserProfile();

      final botResponse =
          "Thank you! I've saved your information. I'll help you manage your day and send you reminders when needed. Feel free to ask me anything anytime!";
      addBotMessage(botResponse);

      print('Scheduling notifications after onboarding');
      scheduleRoutineNotifications();
    }
  }

  // Generate response using Gemini API
  Future<void> generateBotResponse(String userMessage,
      {String? imagePath}) async {
    isLoading.value = true;

    try {
      if (imagePath != null && userMessage.toLowerCase().contains('receipt')) {
        return;
      }

      if (userMessage.toLowerCase().contains("finance") ||
          userMessage.toLowerCase().contains("money") ||
          userMessage.toLowerCase().contains("budget") ||
          userMessage.toLowerCase().contains("expense") ||
          userMessage.toLowerCase().contains("income") ||
          userMessage.toLowerCase().contains("spending") ||
          userMessage.toLowerCase().contains("transaction")) {
        if (!Get.isRegistered<FinancialPlannerController>()) {
          try {
            Get.put(FinancialPlannerController());
            await Future.delayed(Duration(milliseconds: 500));
          } catch (e) {
            print('Error initializing FinancialPlannerController: $e');
          }
        }
      }

      final RegExp categoryPattern = RegExp(
          r'(how much|what|tell me about) (.+?) (spending|expenses|expense|costs|budget|income|transaction)',
          caseSensitive: false);
      final match = categoryPattern.firstMatch(userMessage.toLowerCase());

      if (match != null && match.groupCount >= 2) {
        final categoryName = match.group(2);
        if (categoryName != null && categoryName.length > 2) {
          final categoryDetails = getFinancialCategoryDetails(categoryName);
          if (categoryDetails.contains("Summary for")) {
            addBotMessage(categoryDetails);
            isLoading.value = false;
            return;
          }
        }
      }

      if (userMessage.toLowerCase().contains("grocery") ||
          userMessage.toLowerCase().contains("groceries") ||
          userMessage.toLowerCase().contains("shopping list")) {
        if (!Get.isRegistered<GroceryController>()) {
          Get.put(GroceryController());
          await Future.delayed(Duration(milliseconds: 300));
        }
      }

      final RegExp itemPattern = RegExp(
          r'(what|how much|do i have|is there|tell me about|show me|find) (.+?) (in groceries|in grocery|in my list)',
          caseSensitive: false);
      final matchGrocery = itemPattern.firstMatch(userMessage.toLowerCase());
      if (matchGrocery != null) {
        final itemName = matchGrocery.group(2);
        if (itemName != null) {
          final itemDetails = getGroceryItemDetails(itemName);
          if (itemDetails.contains("Found")) {
            addBotMessage(itemDetails);
            isLoading.value = false;
            return;
          }
        }
      }

      final appDataContext = await _getAppDataContext();

      final systemPrompt = """
You are a personal assistant chatbot named My Day Mate. You help users manage their daily routines and provide reminders about their activities.
You have the following information about the user:

${userProfile.value.getSummary()}

You also have access to the following app data:

$appDataContext

Use this information to answer user questions about their tasks, grocery items, finances, recipes, and other app features.
When asked about app data, provide specific information from the data above.
When asked about finances, provide specific information about income, expenses, balance, spending categories, and transactions.
When asked about groceries, provide specific information about items, categories, and restocking needs.
Be friendly, supportive, and concise. If asked about topics outside the user's data, you can ask follow-up questions to learn more about them.
""";

      final response = await _geminiService.generateResponse(
        userMessage,
        context: systemPrompt,
        imagePath: imagePath,
      );

      addBotMessage(response);
    } catch (e) {
      print('Exception when generating response: $e');
      addBotMessage("Sorry, I encountered an error. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  // Voice input methods
  Future<void> startListening() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          isListening.value = false;
        }
      },
    );

    if (available) {
      isListening.value = true;
      _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            String text = result.recognizedWords;
            if (text.isNotEmpty) {
              textController.text = text;
              addUserMessage(text);
              textController.clear();
            }
            isListening.value = false;
          }
        },
      );
    }
  }

  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
      isListening.value = false;
    }
  }

  // Process receipt image
  Future<void> processReceiptImage(String imagePath) async {
    isLoading.value = true;

    addUserMessage("Processing receipt...", imagePath: imagePath);

    try {
      final receiptData = await _receiptProcessor.processReceipt(imagePath);

      if (receiptData.isEmpty) {
        addBotMessage(
            "I couldn't extract any information from this receipt. Please try again with a clearer image.");
        isLoading.value = false;
        return;
      }

      await _saveReceiptItems(receiptData);

      final StringBuffer responseText = StringBuffer();
      responseText.writeln("✅ Receipt processed successfully!");
      responseText.writeln("\n📝 Items detected:");

      Map<String, List<Map<String, dynamic>>> categorizedItems = {};
      double total = 0.0;
      List<String> foodItems = [];

      for (var item in receiptData) {
        final category = item['category'] as String;
        if (!categorizedItems.containsKey(category)) {
          categorizedItems[category] = [];
        }
        categorizedItems[category]!.add(item);

        final price = item['price'] as double;
        total += price;

        if (_isFoodCategory(category)) {
          foodItems.add(item['name'] as String);
        }
      }

      for (var category in categorizedItems.keys) {
        final items = categorizedItems[category]!;
        double categoryTotal =
            items.fold(0, (sum, item) => sum + (item['price'] as double));

        responseText.writeln(
            "\n📋 ${category} (\$${categoryTotal.toStringAsFixed(2)}):");

        for (var item in items) {
          final itemName = item['name'] as String;
          final price = item['price'] as double;
          responseText.writeln("• $itemName: \$${price.toStringAsFixed(2)}");
        }
      }

      responseText.writeln("\n💰 Total: \$${total.toStringAsFixed(2)}");
      responseText.writeln("\n✓ Added all items to expense tracker");

      if (foodItems.isNotEmpty) {
        responseText.writeln("\n🛒 Food items added to grocery list:");
        for (int i = 0; i < min(foodItems.length, 10); i++) {
          responseText.writeln("• ${foodItems[i]}");
        }

        if (foodItems.length > 10) {
          responseText.writeln("• ...and ${foodItems.length - 10} more items");
        }
      } else {
        responseText
            .writeln("\n📝 No food items detected to add to grocery list");
      }

      addBotMessage(responseText.toString());
    } catch (e) {
      print('Error processing receipt: $e');
      addBotMessage(
          "Sorry, I encountered an error while processing your receipt. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  // Save receipt items to financial and grocery trackers
  Future<void> _saveReceiptItems(List<Map<String, dynamic>> receiptData) async {
    try {
      if (!Get.isRegistered<FinancialPlannerController>()) {
        Get.put(FinancialPlannerController());
        await Future.delayed(Duration(milliseconds: 500));
      }

      if (!Get.isRegistered<GroceryController>()) {
        Get.put(GroceryController());
        await Future.delayed(Duration(milliseconds: 300));
      }

      final financialController = Get.find<FinancialPlannerController>();
      final groceryController = Get.find<GroceryController>();

      Map<String, List<Map<String, dynamic>>> categorizedItems = {};

      for (var item in receiptData) {
        final category = item['category'] as String;
        if (!categorizedItems.containsKey(category)) {
          categorizedItems[category] = [];
        }
        categorizedItems[category]!.add(item);
      }

      final now = DateTime.now();

      List<String> foodItems = [];

      for (var entry in categorizedItems.entries) {
        final category = entry.key;
        final items = entry.value;

        double categoryTotal = 0;
        for (var item in items) {
          categoryTotal += item['price'] as double;
        }

        String note = items
            .map((item) =>
                "${item['name']}: \$${(item['price'] as double).toStringAsFixed(2)}")
            .join(", ");

        try {
          await _financialService.addTransaction(
            TransactionModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              amount: categoryTotal,
              category: category,
              date: now,
              note: note,
              type: TransactionType.expense,
              icon: _getCategoryIcon(category),
              color: _getCategoryColor(category),
              userId: '',
            ),
          );

          financialController.refreshData();
        } catch (e) {
          print('Error adding transaction: $e');
        }

        bool isFoodCategory = _isFoodCategory(category);

        if (isFoodCategory) {
          for (var item in items) {
            final itemName = item['name'] as String;
            final price = item['price'] as double;

            foodItems.add(itemName);

            groceryController.addItemWithDetails(
              name: itemName,
              category: category,
              quantity: 1,
              unit: 'item',
              needsRestock: false,
              isPurchased: true,
              price: price,
            );
          }
        }
      }
    } catch (e) {
      print('Error saving receipt data: $e');
      throw e;
    }
  }

  // Helper method to determine if a category is a food/grocery category
  bool _isFoodCategory(String category) {
    final lcCategory = category.toLowerCase();

    List<String> foodCategories = [
      'food',
      'grocery',
      'dairy',
      'meat',
      'fruits',
      'vegetables',
      'bakery',
      'beverages',
      'snacks',
      'condiments',
      'canned',
      'packaged',
      'produce',
      'deli',
      'seafood',
      'frozen'
    ];

    for (var foodCat in foodCategories) {
      if (lcCategory.contains(foodCat)) {
        return true;
      }
    }

    return false;
  }

  // Helper method to get appropriate icon for category
  IconData _getCategoryIcon(String category) {
    category = category.toLowerCase();

    if (category.contains('food') || category.contains('grocery')) {
      return Icons.restaurant;
    } else if (category.contains('transport')) {
      return Icons.directions_car;
    } else if (category.contains('medical') || category.contains('health')) {
      return Icons.medical_services;
    } else if (category.contains('household') || category.contains('home')) {
      return Icons.home;
    } else if (category.contains('entertainment')) {
      return Icons.movie;
    } else if (category.contains('clothes') || category.contains('apparel')) {
      return Icons.shopping_bag;
    } else {
      return Icons.receipt_long;
    }
  }

  // Helper method to get appropriate color for category
  Color _getCategoryColor(String category) {
    category = category.toLowerCase();

    if (category.contains('food') || category.contains('grocery')) {
      return Colors.green;
    } else if (category.contains('transport')) {
      return Colors.blue;
    } else if (category.contains('medical') || category.contains('health')) {
      return Colors.red;
    } else if (category.contains('household') || category.contains('home')) {
      return Colors.brown;
    } else if (category.contains('entertainment')) {
      return Colors.purple;
    } else if (category.contains('clothes') || category.contains('apparel')) {
      return Colors.amber;
    } else {
      return Colors.grey;
    }
  }

  // Get context data from all app features
  Future<String> _getAppDataContext() async {
    final StringBuffer context = StringBuffer();

    context.writeln("--- TASKS ---");
    context.writeln(await _getTasksData());
    context.writeln();

    context.writeln("--- GROCERY ITEMS ---");
    context.writeln(_getGroceryData());
    context.writeln();

    context.writeln("--- FINANCIAL DATA ---");
    context.writeln(await _getFinancialData());
    context.writeln();

    context.writeln("--- RECIPES AND MEAL PLANNING ---");
    context.writeln(_getRecipeData());

    return context.toString();
  }

  // Get financial data from FinancialPlannerController
  Future<String> _getFinancialData() async {
    try {
      if (!Get.isRegistered<FinancialPlannerController>()) {
        try {
          Get.put(FinancialPlannerController());
          await Future.delayed(Duration(milliseconds: 500));
        } catch (e) {
          print('Error initializing FinancialPlannerController: $e');
          return "Financial data isn't available right now.";
        }
      }

      final FinancialPlannerController financialController =
          Get.find<FinancialPlannerController>();

      financialController.refreshData();
      await Future.delayed(Duration(milliseconds: 300));

      final StringBuffer financialInfo = StringBuffer();

      financialInfo.writeln("Financial Summary");
      financialInfo.writeln(
          "Total Income: \$${financialController.totalIncome.value.toStringAsFixed(2)}");
      financialInfo.writeln(
          "Total Expenses: \$${financialController.totalExpense.value.toStringAsFixed(2)}");
      financialInfo.writeln(
          "Balance: \$${financialController.balance.value.toStringAsFixed(2)}");
      financialInfo.writeln(
          "Status: ${financialController.balance.value >= 0 ? 'Positive' : 'Negative'} balance");

      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;

      double currentMonthTotalIncome = 0;
      double currentMonthTotalExpenses = 0;

      for (var transaction in financialController.transactions) {
        if (transaction.date.month == currentMonth &&
            transaction.date.year == currentYear) {
          if (transaction.type == TransactionType.income) {
            currentMonthTotalIncome += transaction.amount;
          } else {
            currentMonthTotalExpenses += transaction.amount;
          }
        }
      }

      final currentMonthBalance =
          currentMonthTotalIncome - currentMonthTotalExpenses;

      financialInfo.writeln("\nCurrent Month (${_getMonthName(currentMonth)})");
      financialInfo.writeln(
          "Monthly Income: \$${currentMonthTotalIncome.toStringAsFixed(2)}");
      financialInfo.writeln(
          "Monthly Expenses: \$${currentMonthTotalExpenses.toStringAsFixed(2)}");
      financialInfo.writeln(
          "Monthly Balance: \$${currentMonthBalance.toStringAsFixed(2)}");

      final expenseCategoryTotals =
          financialController.getCategoryTotals(TransactionType.expense);

      if (expenseCategoryTotals.isNotEmpty) {
        financialInfo.writeln("\nExpenses by Category:");
        expenseCategoryTotals.sort(
            (a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

        for (var category in expenseCategoryTotals) {
          final amount = category['amount'] as double;
          final percentage =
              (amount / financialController.totalExpense.value) * 100;
          financialInfo.writeln(
              "${category['category']}: \$${amount.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)");
        }
      }

      final incomeCategoryTotals =
          financialController.getCategoryTotals(TransactionType.income);

      if (incomeCategoryTotals.isNotEmpty) {
        financialInfo.writeln("\nIncome Sources:");
        incomeCategoryTotals.sort(
            (a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

        for (var category in incomeCategoryTotals) {
          final amount = category['amount'] as double;
          final percentage =
              (amount / financialController.totalIncome.value) * 100;
          financialInfo.writeln(
              "${category['category']}: \$${amount.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)");
        }
      }

      if (financialController.transactions.isNotEmpty) {
        financialInfo.writeln("\nRecent Transactions:");
        final sortedTransactions =
            List<TransactionModel>.from(financialController.transactions)
              ..sort((a, b) => b.date.compareTo(a.date));

        final recentTransactions = sortedTransactions.take(5).toList();

        for (int i = 0; i < recentTransactions.length; i++) {
          final transaction = recentTransactions[i];
          final date = transaction.date;
          final formattedDate = "${date.day}/${date.month}/${date.year}";
          final prefix =
              transaction.type == TransactionType.income ? "[+]" : "[-]";
          final note =
              transaction.note.isNotEmpty ? " (${transaction.note})" : "";

          financialInfo.writeln(
              "${i + 1}. $formattedDate $prefix \$${transaction.amount.toStringAsFixed(2)} - ${transaction.category}$note");
        }
      }

      financialInfo.writeln("\nYou can ask me about:");
      financialInfo.writeln("- Your overall financial summary");
      financialInfo.writeln("- Income and expenses for this month");
      financialInfo.writeln("- Spending by categories");
      financialInfo.writeln("- Recent transactions");
      financialInfo.writeln("- Budget insights and trends");

      return financialInfo.toString();
    } catch (e) {
      print('Error getting financial data: $e');
      return "There was an error accessing your financial data. You can view your finances in the Financial Planner.";
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  // Get financial details for a specific category
  String getFinancialCategoryDetails(String categoryName) {
    try {
      if (!Get.isRegistered<FinancialPlannerController>()) {
        return "Financial data is not available yet.";
      }

      final FinancialPlannerController financialController =
          Get.find<FinancialPlannerController>();
      final lcCategoryName = categoryName.toLowerCase();

      final matchingTransactions = financialController.transactions
          .where((transaction) =>
              transaction.category.toLowerCase().contains(lcCategoryName))
          .toList();

      if (matchingTransactions.isEmpty) {
        return "I couldn't find any transactions in the '$categoryName' category.";
      }

      final expenses = matchingTransactions
          .where((t) => t.type == TransactionType.expense)
          .toList();
      final incomes = matchingTransactions
          .where((t) => t.type == TransactionType.income)
          .toList();

      double totalExpenses = 0;
      for (var t in expenses) {
        totalExpenses += t.amount;
      }

      double totalIncomes = 0;
      for (var t in incomes) {
        totalIncomes += t.amount;
      }

      matchingTransactions.sort((a, b) => b.date.compareTo(a.date));

      final StringBuffer categoryDetails = StringBuffer();
      categoryDetails.writeln("Summary for '$categoryName':");

      if (expenses.isNotEmpty) {
        categoryDetails
            .writeln("Total expenses: \$${totalExpenses.toStringAsFixed(2)}");
        categoryDetails
            .writeln("Number of expense transactions: ${expenses.length}");
      }

      if (incomes.isNotEmpty) {
        categoryDetails
            .writeln("Total income: \$${totalIncomes.toStringAsFixed(2)}");
        categoryDetails
            .writeln("Number of income transactions: ${incomes.length}");
      }

      categoryDetails.writeln("\nRecent transactions:");
      final recentItems = matchingTransactions.take(5).toList();

      for (int i = 0; i < recentItems.length; i++) {
        final transaction = recentItems[i];
        final date = transaction.date;
        final formattedDate = "${date.day}/${date.month}/${date.year}";
        final typeSymbol =
            transaction.type == TransactionType.income ? "[+]" : "[-]";
        final note =
            transaction.note.isNotEmpty ? " - ${transaction.note}" : "";

        categoryDetails.writeln(
            "${i + 1}. $formattedDate $typeSymbol \$${transaction.amount.toStringAsFixed(2)}$note");
      }

      return categoryDetails.toString();
    } catch (e) {
      print('Error getting category details: $e');
      return "I encountered an error while fetching details for '$categoryName'.";
    }
  }

  // Get tasks data from TaskListController
  Future<String> _getTasksData() async {
    try {
      if (!Get.isRegistered<TaskListController>()) {
        Get.put(TaskListController());
      }

      final TaskListController taskController = Get.find<TaskListController>();

      if (taskController.tasksList.isEmpty) {
        await taskController.loadTasks();
      }

      final StringBuffer tasksInfo = StringBuffer();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final List<TaskModel> todayTasks = taskController.tasksList.where((task) {
        if (task.date is DateTime) {
          final taskDate = task.date as DateTime;
          return taskDate.year == today.year &&
              taskDate.month == today.month &&
              taskDate.day == today.day;
        } else if (task.date is String) {
          try {
            final taskDate = DateTime.parse(task.date as String);
            return taskDate.year == today.year &&
                taskDate.month == today.month &&
                taskDate.day == today.day;
          } catch (e) {
            return false;
          }
        }
        return false;
      }).toList();

      final completedTasks =
          todayTasks.where((task) => task.isCompleted).toList();
      final incompleteTasks =
          todayTasks.where((task) => !task.isCompleted).toList();

      incompleteTasks.sort((a, b) {
        if (a.hour != b.hour) return a.hour - b.hour;
        return a.minute - b.minute;
      });

      tasksInfo
          .writeln("Today's date: ${today.day}/${today.month}/${today.year}");
      tasksInfo.writeln("Total tasks for today: ${todayTasks.length}");
      tasksInfo.writeln("Completed tasks: ${completedTasks.length}");
      tasksInfo.writeln("Remaining tasks: ${incompleteTasks.length}");

      if (incompleteTasks.isNotEmpty) {
        tasksInfo.writeln("\nIncomplete tasks for today:");
        for (int i = 0; i < incompleteTasks.length; i++) {
          final task = incompleteTasks[i];
          final time =
              '${task.hour.toString().padLeft(2, '0')}:${task.minute.toString().padLeft(2, '0')}';
          tasksInfo.writeln(
              "${i + 1}. ${task.title} (${getPriorityText(task.priority)}) at $time - ${task.note.isNotEmpty ? task.note : 'No description'}");
        }
      }

      if (completedTasks.isNotEmpty) {
        tasksInfo.writeln("\nCompleted tasks:");
        for (int i = 0; i < completedTasks.length; i++) {
          final task = completedTasks[i];
          final time =
              '${task.hour.toString().padLeft(2, '0')}:${task.minute.toString().padLeft(2, '0')}';
          tasksInfo.writeln(
              "${i + 1}. ${task.title} (${getPriorityText(task.priority)}) at $time");
        }
      }

      final List<TaskModel> upcomingTasks =
          taskController.tasksList.where((task) {
        if (task.date is DateTime) {
          final taskDate = task.date as DateTime;
          return taskDate.isAfter(today) && !task.isCompleted;
        } else if (task.date is String) {
          try {
            final taskDate = DateTime.parse(task.date as String);
            return taskDate.isAfter(today) && !task.isCompleted;
          } catch (e) {
            return false;
          }
        }
        return false;
      }).toList();

      if (upcomingTasks.isNotEmpty) {
        upcomingTasks.sort((a, b) {
          final dateA = a.date is DateTime
              ? a.date as DateTime
              : DateTime.parse(a.date.toString());
          final dateB = b.date is DateTime
              ? b.date as DateTime
              : DateTime.parse(b.date.toString());
          return dateA.compareTo(dateB);
        });

        tasksInfo.writeln("\nUpcoming tasks:");
        for (int i = 0; i < min(5, upcomingTasks.length); i++) {
          final task = upcomingTasks[i];
          final date = task.date is DateTime
              ? task.date as DateTime
              : DateTime.parse(task.date.toString());
          final formattedDate = "${date.day}/${date.month}/${date.year}";
          final time =
              '${task.hour.toString().padLeft(2, '0')}:${task.minute.toString().padLeft(2, '0')}';
          tasksInfo
              .writeln("${i + 1}. ${task.title} on $formattedDate at $time");
        }
      }

      return tasksInfo.toString();
    } catch (e) {
      print('Error getting tasks data: $e');
      return "No task data available.";
    }
  }

  String getPriorityText(TaskPriority? priority) {
    switch (priority) {
      case TaskPriority.low:
        return "Low Priority";
      case TaskPriority.medium:
        return "Medium Priority";
      case TaskPriority.high:
        return "High Priority";
      default:
        return "No Priority";
    }
  }

  // Get grocery data from GroceryController
  String _getGroceryData() {
    try {
      if (!Get.isRegistered<GroceryController>()) {
        Get.put(GroceryController());
        Future.delayed(Duration(milliseconds: 300));
      }

      final GroceryController groceryController = Get.find<GroceryController>();

      if (groceryController.items.isEmpty) {
        groceryController.loadItems();
        return "Loading grocery data...";
      }

      final List<GroceryItem> items = groceryController.items;

      if (items.isEmpty) {
        return "No grocery items in your list. You can add items through the Grocery Planner.";
      }

      final StringBuffer groceryInfo = StringBuffer();
      groceryInfo.writeln("Total grocery items: ${items.length}");

      final restockItems = items.where((item) => item.needsRestock).toList();
      groceryInfo.writeln("Items that need restocking: ${restockItems.length}");

      if (restockItems.isNotEmpty) {
        groceryInfo.writeln("\nRestock list:");
        for (int i = 0; i < restockItems.length; i++) {
          final item = restockItems[i];
          groceryInfo.writeln(
              "${i + 1}. ${item.name} - ${item.quantity} ${item.unit} (${item.category})");
        }
      }

      final Map<String, List<GroceryItem>> categorizedItems = {};
      for (var item in items) {
        if (!categorizedItems.containsKey(item.category)) {
          categorizedItems[item.category] = [];
        }
        categorizedItems[item.category]!.add(item);
      }

      groceryInfo.writeln("\nGrocery items by category:");
      categorizedItems.forEach((category, categoryItems) {
        final purchased =
            categoryItems.where((item) => item.isPurchased).length;

        groceryInfo.writeln(
            "\n$category (${categoryItems.length} items, $purchased purchased):");
        for (int i = 0; i < categoryItems.length; i++) {
          final item = categoryItems[i];
          groceryInfo.writeln(
              "${i + 1}. ${item.name} - ${item.quantity} ${item.unit}${item.isPurchased ? ' (Purchased)' : ''}${item.needsRestock ? ' (Needs Restock)' : ''}");
        }
      });

      groceryInfo.writeln("\nYou can ask me to:");
      groceryInfo.writeln("- Show items that need restocking");
      groceryInfo.writeln("- List items by category");
      groceryInfo.writeln("- Find specific items");
      groceryInfo.writeln("- Check item details");

      return groceryInfo.toString();
    } catch (e) {
      print('Error getting grocery data: $e');
      return "There was an issue accessing your grocery data. You can view your items in the Grocery Planner.";
    }
  }

  // Get detailed info about specific grocery items
  String getGroceryItemDetails(String itemName) {
    try {
      if (!Get.isRegistered<GroceryController>()) {
        return "Grocery data is not available yet.";
      }

      final GroceryController groceryController = Get.find<GroceryController>();
      final lcItemName = itemName.toLowerCase();

      final matchingItems = groceryController.items
          .where((item) => item.name.toLowerCase().contains(lcItemName))
          .toList();

      if (matchingItems.isEmpty) {
        return "I couldn't find any items matching '$itemName' in your grocery list.";
      }

      final StringBuffer itemDetails = StringBuffer();
      itemDetails.writeln(
          "Found ${matchingItems.length} item(s) matching '$itemName':");

      for (int i = 0; i < matchingItems.length; i++) {
        final item = matchingItems[i];
        itemDetails.writeln("\n${i + 1}. ${item.name}");
        itemDetails.writeln("   Category: ${item.category}");
        itemDetails.writeln("   Quantity: ${item.quantity} ${item.unit}");
        itemDetails.writeln(
            "   Status: ${item.isPurchased ? 'Purchased' : 'Not purchased'}");
        itemDetails.writeln(
            "   Needs restocking: ${item.needsRestock ? 'Yes' : 'No'}");
      }

      return itemDetails.toString();
    } catch (e) {
      print('Error getting grocery item details: $e');
      return "I encountered an error while fetching details for '$itemName'.";
    }
  }

  // Get recipe data from RecipeController and FavoritesController
  String _getRecipeData() {
    try {
      if (!Get.isRegistered<RecipeController>() ||
          !Get.isRegistered<FavoritesController>()) {
        return "Recipe data not available.";
      }

      final RecipeController recipeController = Get.find<RecipeController>();
      final FavoritesController favoritesController =
          Get.find<FavoritesController>();

      final StringBuffer recipeInfo = StringBuffer();

      final favorites = favoritesController.favorites;
      if (favorites.isNotEmpty) {
        recipeInfo.writeln("Favorite recipes (${favorites.length}):");
        for (int i = 0; i < favorites.length; i++) {
          final recipe = favorites[i];
          recipeInfo.writeln(
              "${i + 1}. ${recipe.title} (${recipe.readyInMinutes} min) - Servings: ${recipe.servings}");
          if (recipe.diets.isNotEmpty) {
            recipeInfo.writeln("   Diets: ${recipe.diets.join(', ')}");
          }
        }
      } else {
        recipeInfo.writeln("No favorite recipes saved yet.");
      }

      if (recipeController.selectedDiets.isNotEmpty) {
        recipeInfo.writeln(
            "\nCurrent diet filters: ${recipeController.selectedDiets.join(', ')}");
      }

      if (recipeController.availableIngredients.isNotEmpty) {
        recipeInfo.writeln(
            "\nAvailable ingredients: ${recipeController.availableIngredients.join(', ')}");
      }

      return recipeInfo.toString();
    } catch (e) {
      print('Error getting recipe data: $e');
      return "No recipe data available.";
    }
  }

  // Schedule notifications based on user routine
  void scheduleRoutineNotifications() {
    try {
      print('Starting to schedule routine notifications');
      AwesomeNotifications().cancelAll();

      final wakeupTime = userProfile.value.dailyRoutine['wakeup'];
      final breakfastTime = userProfile.value.mealTimes['breakfast'];
      final lunchTime = userProfile.value.mealTimes['lunch'];
      final dinnerTime = userProfile.value.mealTimes['dinner'];
      final bedtime = userProfile.value.dailyRoutine['bedtime'];

      print('User times: wakeup=$wakeupTime, breakfast=$breakfastTime, '
          'lunch=$lunchTime, dinner=$dinnerTime, bedtime=$bedtime');

      if (wakeupTime != null) {
        _scheduleNotification(
          'Good Morning!',
          'Time to wake up. Have a great day!',
          _parseTimeString(wakeupTime),
          1,
        );
      }

      if (breakfastTime != null) {
        _scheduleNotification(
          'Breakfast Time',
          'Don\'t forget to have your breakfast!',
          _parseTimeString(breakfastTime),
          2,
        );
      }

      if (lunchTime != null) {
        _scheduleNotification(
          'Lunch Time',
          'Time for lunch! Enjoy your meal.',
          _parseTimeString(lunchTime),
          3,
        );
      }

      if (dinnerTime != null) {
        _scheduleNotification(
          'Dinner Time',
          'Time for dinner! Enjoy your meal.',
          _parseTimeString(dinnerTime),
          4,
        );
      }

      if (bedtime != null) {
        _scheduleNotification(
          'Bedtime Reminder',
          'It\'s almost bedtime. Time to wind down.',
          _parseTimeString(bedtime),
          5,
        );
      }

      if (userProfile.value.medicalConditions.isNotEmpty) {
        _scheduleNotification(
          'Medication Reminder',
          'Time to take your medication.',
          _parseTimeString('8:00 AM'),
          6,
        );

        _scheduleNotification(
          'Medication Reminder',
          'Time to take your medication.',
          _parseTimeString('8:00 PM'),
          7,
        );
      }

      scheduleGoodNightNotification();
      _scheduleRandomCheckIn();

      sendImmediateNotification(
        'Notifications Scheduled',
        'Your daily routine notifications have been scheduled successfully.',
      );
    } catch (e) {
      print('Error scheduling notifications: $e');
      sendImmediateNotification(
        'Notification Error',
        'There was an error scheduling your notifications. Please try again.',
      );
    }
  }

  Future<void> scheduleGoodNightNotification() async {
    try {
      // Cancel any existing notification first
      await AwesomeNotifications().cancel(8);

      // Set time to 1:35 AM
      TimeOfDay notificationTime = TimeOfDay(hour: 16, minute: 40);

      // Get current time
      final now = DateTime.now();
      DateTime scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        notificationTime.hour,
        notificationTime.minute,
        0,
      );

      // If the time has already passed today, schedule it for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(Duration(days: 1));
      }

      print(
          "Scheduling Good Night notification for ${scheduledDate.toString()}");

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 8,
          channelKey: 'scheduled',
          title: 'Good Night Test',
          body: 'This is a test notification for 1:35 AM. Sweet dreams!',
          notificationLayout: NotificationLayout.Default,
          wakeUpScreen: true,
          category: NotificationCategory.Reminder,
          criticalAlert: true,
        ),
        schedule: NotificationCalendar(
          year: scheduledDate.year,
          month: scheduledDate.month,
          day: scheduledDate.day,
          hour: scheduledDate.hour,
          minute: scheduledDate.minute,
          second: 0,
          millisecond: 0,
          repeats: true,
          preciseAlarm: true,
          allowWhileIdle: true,
        ),
      );

      final scheduledNotifications =
          await AwesomeNotifications().listScheduledNotifications();
      bool isScheduled = scheduledNotifications
          .any((notification) => notification.content?.id == 8);

      if (isScheduled) {
        print(
            "Successfully scheduled Good Night notification for ${scheduledDate.toString()}");
      } else {
        print("Warning: Good Night notification might not have been scheduled");
      }

      // Also send an immediate notification to confirm
      await sendImmediateNotification(
          'Good Night Scheduled', 'Notification has been set for 1:35 AM.');
    } catch (e) {
      print('Error scheduling good night notification: $e');
    }
  }

  TimeOfDay _parseTimeString(String timeString) {
    timeString = timeString.trim().toLowerCase();
    print('Parsing time string: $timeString');

    try {
      // Handle formats like "7:30 AM", "7:30", "7 AM"
      final RegExp timeRegex =
          RegExp(r'(\d{1,2})(?::(\d{2}))?\s*(am|pm)?', caseSensitive: false);
      final match = timeRegex.firstMatch(timeString);

      if (match != null) {
        int hour = int.parse(match.group(1)!);
        int minute = match.group(2) != null ? int.parse(match.group(2)!) : 0;
        final period = match.group(3)?.toLowerCase();

        if (period == 'pm' && hour < 12) {
          hour += 12;
        } else if (period == 'am' && hour == 12) {
          hour = 0;
        }

        print('Parsed time: $hour:$minute');
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      print('Error parsing time string "$timeString": $e');
    }

    print('Using default time: 8:00 AM');
    return const TimeOfDay(hour: 8, minute: 0);
  }

  Future<void> _scheduleNotification(
      String title, String body, TimeOfDay time, int id) async {
    try {
      print(
          "Scheduling notification '$title' at ${time.hour}:${time.minute} (ID: $id)");

      // Cancel any existing notification with this ID
      await AwesomeNotifications().cancel(id);

      final now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledTime = tz.TZDateTime(
          tz.local, now.year, now.month, now.day, time.hour, time.minute);

      // If the scheduled time is in the past for today, schedule for tomorrow
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
        print(
            "Time already passed today, scheduling for tomorrow: ${scheduledTime.toString()}");
      }

      print("Final scheduled time: ${scheduledTime.toString()}");

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'scheduled',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar(
          hour: time.hour,
          minute: time.minute,
          second: 0,
          repeats: true,
          timeZone: tz.local.name,
        ),
      );

      // Verify the notification was scheduled
      final scheduledNotifications =
          await AwesomeNotifications().listScheduledNotifications();
      print("Scheduled notifications: ${scheduledNotifications.length}");
      final isScheduled = scheduledNotifications
          .any((notification) => notification.content?.id == id);

      if (isScheduled) {
        print(
            "✅ Successfully scheduled notification ID $id for ${scheduledTime.toString()}");
      } else {
        print("❌ Failed to schedule notification ID $id");
      }
    } catch (e, stackTrace) {
      print('Error scheduling notification: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void _scheduleRandomCheckIn() {
    try {
      final random = Random();
      final numCheckIns = random.nextInt(2) + 2;

      final checkInMessages = [
        'How are you feeling today?',
        'Don\'t forget to stay hydrated!',
        'Taking a break? How about a quick stretch?',
        'How\'s your day going so far?',
        'Remember to take a moment for yourself today.',
        'Any plans for the weekend?',
      ];

      for (int i = 0; i < numCheckIns; i++) {
        final hour = random.nextInt(10) + 9; // Between 9 AM and 7 PM
        final minute = random.nextInt(60);
        final messageIndex = random.nextInt(checkInMessages.length);

        _scheduleNotification(
          'Check-in',
          checkInMessages[messageIndex],
          TimeOfDay(hour: hour, minute: minute),
          100 + i,
        );
      }
    } catch (e) {
      print('Error scheduling random check-ins: $e');
    }
  }

  Future<void> sendImmediateNotification(String title, String body) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch % 100000;
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'basic_channel',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Message,
          autoDismissible: false,
          criticalAlert: true,
        ),
      );
      print("Immediate notification sent with ID $id");
    } catch (e) {
      print('Error sending immediate notification: $e');
    }
  }

  // Test specific notification
  Future<void> testSpecificNotification() async {
    try {
      await _scheduleNotification(
        'Test Notification',
        'This is a test notification scheduled for 1:35 AM',
        TimeOfDay(hour: 1, minute: 35),
        999,
      );

      await sendImmediateNotification(
        'Test Scheduled',
        'Notification has been scheduled for 1:35 AM. You will receive it at that time.',
      );
    } catch (e) {
      print('Error testing notification: $e');
      await sendImmediateNotification(
        'Test Failed',
        'There was an error scheduling the test notification.',
      );
    }
  }

  // Test immediate notification
  Future<void> sendTestNotification() async {
    try {
      print("Attempting to send test notification");

      // Use a unique ID based on current time
      int id = DateTime.now().millisecond;

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'basic_channel',
          title: 'Test Notification',
          body: 'This is a test notification. ID: $id',
          // Don't specify any icon - use the app's default
          notificationLayout: NotificationLayout.Default,
          // Don't set any custom sound
        ),
      );

      print("Test notification sent with ID: $id");
    } catch (e, stackTrace) {
      print('Error sending test notification: $e');
      print('Stack trace: $stackTrace');
    }
  }

  // Test scheduling a notification for 1 minute later
  Future<void> scheduleTestNotificationIn1Minute() async {
    try {
      final now = DateTime.now();
      final scheduledTime =
          DateTime(now.year, now.month, now.day, now.hour, now.minute + 1, 0);

      final timeOfDay =
          TimeOfDay(hour: scheduledTime.hour, minute: scheduledTime.minute);

      await _scheduleNotification(
          'Test Notification',
          'This notification was scheduled to appear 1 minute after setting it.',
          timeOfDay,
          999);

      await sendImmediateNotification('Test Scheduled',
          'A notification has been scheduled to appear in 1 minute.');

      print("Test notification scheduled for ${scheduledTime.toString()}");
    } catch (e) {
      print('Error scheduling test notification: $e');
    }
  }

  // Extract grocery items from image
  Future<void> _extractGroceryItemsFromImage(String imagePath) async {
    try {
      isLoading.value = true;

      final prompt = '''
      Analyze this receipt image and extract ONLY FOOD AND GROCERY ITEMS.
      
      For each food or grocery item found, provide:
      1. Item name
       2. Quantity/volume/weight if available (e.g., 500g, 2L, 12 pack)
      3. Price
      
      Format your response as JSON:
      {
        "groceryItems": [
          {"name": "ITEM NAME", "quantity": "QUANTITY", "price": PRICE}
        ],
        "totalAmount": TOTAL_AMOUNT
      }
      
      IMPORTANT GUIDELINES:
      - Extract ONLY food and grocery items (fruits, vegetables, meat, dairy, bread, beverages, snacks, etc.)
      - EXCLUDE all non-food items (magazines, electronics, household supplies, etc.)
      - EXCLUDE receipt metadata like tax, subtotal, store name, cashier info
      - If quantity isn't mentioned, make a reasonable estimate based on price and item type
      - For each item, provide the most accurate name possible
      - Ensure prices are properly formatted as numbers
      - If the total amount isn't visible, calculate it from the items
      ''';

      final response = await _geminiService.generateResponse(
        prompt,
        imagePath: imagePath,
      );

      _processGroceryData(response);
    } catch (e) {
      print('Error extracting grocery items: $e');
      addBotMessage(
          "I had trouble identifying grocery items in your receipt. Please try with a clearer image.");
    } finally {
      isLoading.value = false;
    }
  }

  // Process grocery data
  void _processGroceryData(String response) {
    try {
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch == null) {
        addBotMessage(
            "I couldn't extract grocery information from this receipt. Please try with a clearer image.");
        return;
      }

      final jsonString = jsonMatch.group(0);
      final Map<String, dynamic> data = json.decode(jsonString!);

      final List<dynamic> groceryItems =
          data['groceryItems'] as List<dynamic>? ?? [];
      final dynamic totalAmount = data['totalAmount'];

      if (groceryItems.isEmpty) {
        addBotMessage(
            "I couldn't find any food items on this receipt. It might not be a grocery receipt.");
        return;
      }

      if (!Get.isRegistered<GroceryController>()) {
        Get.put(GroceryController());
      }

      final groceryController = Get.find<GroceryController>();

      final StringBuffer messageText = StringBuffer();
      messageText.writeln("✅ Found ${groceryItems.length} grocery items:");
      messageText.writeln();

      final Map<String, List<String>> categorizedItems = {};

      int addedCount = 0;
      for (var item in groceryItems) {
        final name = item['name'] as String? ?? '';
        final quantity = item['quantity'] as String? ?? '';
        final price = item['price'] ?? 0;

        if (name.isEmpty) continue;

        double quantityNum = 1.0;
        String unit = 'item';

        final RegExp quantityRegex = RegExp(r'(\d+(?:\.\d+)?)\s*([a-zA-Z]+)?');
        final match = quantityRegex.firstMatch(quantity);

        if (match != null) {
          quantityNum = double.tryParse(match.group(1) ?? '1') ?? 1.0;
          unit = match.group(2) ?? 'item';
        }

        final category = _determineGroceryCategory(name);

        if (!categorizedItems.containsKey(category)) {
          categorizedItems[category] = [];
        }
        categorizedItems[category]!
            .add("$name ($quantity) - \$${price.toStringAsFixed(2)}");

        double priceValue = 0.0;
        if (price is num) {
          priceValue = price.toDouble();
        } else if (price is String) {
          priceValue =
              double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
        }

        groceryController.addItemWithDetails(
          name: name,
          category: category,
          quantity: quantityNum,
          unit: unit,
          needsRestock: false,
          isPurchased: true,
          price: priceValue,
        );

        addedCount++;
      }

      categorizedItems.forEach((category, items) {
        messageText.writeln("📋 $category:");
        for (final item in items) {
          messageText.writeln("• $item");
        }
        messageText.writeln();
      });

      if (totalAmount != null) {
        String totalText = totalAmount is num
            ? totalAmount.toStringAsFixed(2)
            : totalAmount.toString();
        messageText.writeln("💰 Total: \$$totalText");
      }

      messageText.writeln("\n✓ Added $addedCount grocery items to your list");

      addBotMessage(messageText.toString());
    } catch (e) {
      print('Error processing grocery data: $e');
      addBotMessage(
          "I encountered an error processing the grocery receipt. Please try again.");
    }
  }

  // Categorize grocery items
  String _determineGroceryCategory(String itemName) {
    itemName = itemName.toLowerCase();

    if (RegExp(r'milk|cheese|yogurt|butter|cream|dairy').hasMatch(itemName)) {
      return 'Dairy';
    } else if (RegExp(r'chicken|beef|pork|fish|meat|turkey|bacon|sausage')
        .hasMatch(itemName)) {
      return 'Meat & Seafood';
    } else if (RegExp(r'apple|banana|orange|grape|berry|fruit|melon|pear')
        .hasMatch(itemName)) {
      return 'Fruits';
    } else if (RegExp(
            r'lettuce|onion|potato|tomato|carrot|pepper|vegetable|veg')
        .hasMatch(itemName)) {
      return 'Vegetables';
    } else if (RegExp(r'bread|bun|roll|bagel|pastry|croissant')
        .hasMatch(itemName)) {
      return 'Bakery';
    } else if (RegExp(r'water|soda|juice|drink|beer|wine|coffee|tea')
        .hasMatch(itemName)) {
      return 'Beverages';
    } else if (RegExp(r'chip|crisp|snack|nut|candy|chocolate|cookie|biscuit')
        .hasMatch(itemName)) {
      return 'Snacks';
    } else if (RegExp(
            r'oil|vinegar|sauce|ketchup|mustard|spice|salt|pepper|seasoning')
        .hasMatch(itemName)) {
      return 'Condiments';
    } else if (RegExp(r'cereal|pasta|rice|flour|sugar|can|tin|jar')
        .hasMatch(itemName)) {
      return 'Pantry';
    } else if (RegExp(r'frozen|ice cream|pizza').hasMatch(itemName)) {
      return 'Frozen Foods';
    } else {
      return 'Other Groceries';
    }
  }

  // Capture grocery receipt
  Future<void> captureGroceryReceipt() async {
    try {
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

      addUserMessage("Scanning grocery receipt...");
      isLoading.value = true;

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (image != null) {
        await _extractGroceryItemsFromImage(image.path);
      } else {
        isLoading.value = false;
        addBotMessage("No image selected. Please try again.");
      }
    } catch (e) {
      print('Error capturing grocery receipt: $e');
      addBotMessage(
          "There was an error processing your grocery receipt. Please try again.");
      isLoading.value = false;
    }
  }

  // Add this method to test background notifications
  Future<void> testBackgroundNotifications() async {
    try {
      final now = DateTime.now();

      // Schedule notifications at 1, 2, and 3 minutes from now
      for (int i = 1; i <= 3; i++) {
        final scheduledTime = now.add(Duration(minutes: i));
        final timeOfDay =
            TimeOfDay(hour: scheduledTime.hour, minute: scheduledTime.minute);

        await _scheduleNotification(
            'Background Test #$i',
            'This notification was scheduled to appear $i minute(s) from now.',
            timeOfDay,
            900 + i);
      }

      // Show immediate confirmation
      await sendImmediateNotification('Background Test Active',
          'Three test notifications scheduled for the next few minutes.');

      print("Background test notifications scheduled!");
    } catch (e) {
      print('Error setting up background test: $e');
    }
  }
}
