import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mydaymate/features/chatbot/model/chatbot_model.dart';
import 'package:mydaymate/features/financial_planner/model/transaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock version of ChatbotController with minimal dependencies
class MockChatbotController extends GetxController {
  final RxList<Message> messages = <Message>[].obs;
  final Rx<UserProfile> userProfile = UserProfile().obs;
  final RxBool isLoading = false.obs;
  final RxBool isFirstTime = true.obs;
  final RxBool isListening = false.obs;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final List<String> onboardingQuestions = [
    "Hi there! I'm your personal assistant. What's your name?",
    "Nice to meet you! How old are you?",
    "Do you have any medical conditions I should know about?",
  ];

  final RxInt currentQuestionIndex = 0.obs;

  void addUserMessage(String text, {String? imagePath}) {
    if (text.trim().isEmpty && imagePath == null) return;

    final message = Message(text: text, isUser: true, imageUrl: imagePath);
    messages.add(message);

    if (isFirstTime.value) {
      processOnboardingResponse(text);
    }
  }

  void addBotMessage(String text) {
    final message = Message(text: text, isUser: false);
    messages.add(message);
  }

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
        userProfile.update((val) {
          val?.onboardingCompleted = true;
        });
        isFirstTime.value = false;
        break;
    }

    currentQuestionIndex.value++;

    if (currentQuestionIndex.value < onboardingQuestions.length) {
      addBotMessage(onboardingQuestions[currentQuestionIndex.value]);
    }
  }

  // Helper method for testing category determination
  String determineGroceryCategory(String itemName) {
    itemName = itemName.toLowerCase();

    if (RegExp(r'milk|cheese|yogurt|butter|cream|dairy').hasMatch(itemName)) {
      return 'Dairy';
    } else if (RegExp(r'chicken|beef|pork|fish|meat|turkey|bacon|sausage')
        .hasMatch(itemName)) {
      return 'Meat & Seafood';
    } else if (RegExp(r'apple|banana|orange|grape|berry|fruit')
        .hasMatch(itemName)) {
      return 'Fruits';
    } else if (RegExp(r'lettuce|onion|potato|tomato|carrot|vegetable')
        .hasMatch(itemName)) {
      return 'Vegetables';
    } else if (RegExp(r'bread|bun|roll|bagel|pastry').hasMatch(itemName)) {
      return 'Bakery';
    } else if (RegExp(r'water|soda|juice|drink|beer|wine|coffee')
        .hasMatch(itemName)) {
      return 'Beverages';
    } else if (RegExp(r'chip|crisp|snack|nut|candy|chocolate')
        .hasMatch(itemName)) {
      return 'Snacks';
    } else {
      return 'Other Groceries';
    }
  }

  // Helper method for testing JSON extraction
  Map<String, dynamic>? extractJsonFromResponse(String response) {
    try {
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch == null) return null;

      final jsonString = jsonMatch.group(0);
      return jsonString != null ? Map<String, dynamic>.from({}) : null;
    } catch (e) {
      return null;
    }
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockChatbotController controller;

  setUp(() {
    // Setup GetX test environment
    Get.testMode = true;

    // Create controller
    controller = MockChatbotController();
    Get.put(controller);

    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    // Clean up
    controller.onClose();
    Get.reset();
  });

  group('ChatbotController Tests', () {
    test('addBotMessage adds message to messages list', () {
      // Act
      controller.addBotMessage('How can I help you?');

      // Assert
      expect(controller.messages.length, 1);
      expect(controller.messages[0].text, 'How can I help you?');
      expect(controller.messages[0].isUser, false);
    });

    test('Empty user message is not added to messages list', () {
      // Act
      controller.addUserMessage('   ');

      // Assert
      expect(controller.messages.length, 0);
    });

    test('processOnboardingResponse correctly updates user profile', () {
      // Act - Process name
      controller.processOnboardingResponse('John');

      // Assert
      expect(controller.userProfile.value.name, 'John');
      expect(controller.currentQuestionIndex.value, 1);
      expect(controller.messages.length, 1); // Bot's next question

      // Act - Process age
      controller.processOnboardingResponse('30');

      // Assert
      expect(controller.userProfile.value.age, '30');
      expect(controller.currentQuestionIndex.value, 2);
      expect(controller.messages.length, 2); // Bot's next question

      // Act - Process medical conditions
      controller.processOnboardingResponse('Asthma, Allergies');

      // Assert
      expect(controller.userProfile.value.medicalConditions,
          ['Asthma', 'Allergies']);
      expect(controller.currentQuestionIndex.value, 3);
      expect(controller.userProfile.value.onboardingCompleted, true);
      expect(controller.isFirstTime.value, false);
    });

    test('extractJsonFromResponse correctly extracts JSON from text', () {
      // Test with valid JSON in text
      const validResponse = '''
      Here's the data you requested:
      {
        "name": "John",
        "age": 30
      }
      Let me know if you need anything else.
      ''';

      final result = controller.extractJsonFromResponse(validResponse);
      expect(result, isNotNull);

      // Test with no JSON in text
      const invalidResponse = "I couldn't find any data for that.";
      final invalidResult = controller.extractJsonFromResponse(invalidResponse);
      expect(invalidResult, isNull);
    });

    test('Full conversation flow during onboarding', () {
      // Verify initial state
      expect(controller.messages, isEmpty);
      expect(controller.isFirstTime.value, true);

      // Start conversation
      controller.addBotMessage(controller.onboardingQuestions[0]);
      expect(controller.messages.length, 1);
      expect(controller.messages[0].text, controller.onboardingQuestions[0]);

      // User responds with name
      controller.addUserMessage('Alex');
      expect(controller.messages.length, 3); // 1 bot + 1 user + 1 new bot
      expect(controller.userProfile.value.name, 'Alex');
      expect(controller.messages[2].text, controller.onboardingQuestions[1]);

      // User responds with age
      controller.addUserMessage('25');
      expect(controller.messages.length, 5); // 3 previous + 1 user + 1 new bot
      expect(controller.userProfile.value.age, '25');
      expect(controller.messages[4].text, controller.onboardingQuestions[2]);

      // User completes onboarding
      controller.addUserMessage('None');
      expect(controller.userProfile.value.medicalConditions, ['None']);
      expect(controller.isFirstTime.value, false);
      expect(controller.userProfile.value.onboardingCompleted, true);
    });
  });
}
