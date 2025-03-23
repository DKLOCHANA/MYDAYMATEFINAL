import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:mydaymate/features/chatbot/model/chatbot_model.dart';
import 'package:mydaymate/features/chatbot/service/gemini_service.dart';

class ChatbotController extends GetxController {
  // Gemini service
  final GeminiService _geminiService = GeminiService();

  // Chat state
  final RxList<Message> messages = <Message>[].obs;
  final Rx<UserProfile> userProfile = UserProfile().obs;
  final RxBool isLoading = false.obs;
  final RxBool isFirstTime = true.obs;

  // Onboarding questions
  final List<String> onboardingQuestions = [
    "Hi there! I'm your personal assistant. What's your name?",
    "Nice to meet you! How old are you?",
    "Do you have any medical conditions I should know about?",
    "What time do you usually wake up in the morning?",
    "What time do you usually go to bed?",
    "What are some of your hobbies or interests?",
    "What time do you usually have breakfast?",
    "What time do you usually have lunch?",
    "What time do you usually have dinner?",
    "What are some of your favorite foods?",
    "Is there anything else you'd like me to know about you?",
  ];

  // Current question index
  final RxInt currentQuestionIndex = 0.obs;

  // Text controller for user input
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

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
    // Check notification permission
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // Request permission
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
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
          // Schedule notifications based on user routine
          scheduleRoutineNotifications();
        }
      } catch (e) {
        print('Error loading user profile: $e');
      }
    } else {
      isFirstTime.value = true;

      // Start onboarding if first time
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
      // Add welcome message if first time
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

  // Add a message from the user
  void addUserMessage(String text) {
    if (text.trim().isEmpty) return;

    final message = Message(text: text, isUser: true);
    messages.add(message);
    saveChatHistory();

    if (isFirstTime.value) {
      processOnboardingResponse(text);
    } else {
      generateBotResponse(text);
    }

    // Scroll to bottom
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

    // Scroll to bottom
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
      case 0: // Name
        userProfile.update((val) {
          val?.name = response;
        });
        break;
      case 1: // Age
        userProfile.update((val) {
          val?.age = response;
        });
        break;
      case 2: // Medical conditions
        userProfile.update((val) {
          val?.medicalConditions =
              response.split(',').map((e) => e.trim()).toList();
        });
        break;
      case 3: // Wake up time
        userProfile.update((val) {
          val?.dailyRoutine['wakeup'] = response;
        });
        break;
      case 4: // Bedtime
        userProfile.update((val) {
          val?.dailyRoutine['bedtime'] = response;
        });
        break;
      case 5: // Hobbies
        userProfile.update((val) {
          val?.hobbies = response.split(',').map((e) => e.trim()).toList();
        });
        break;
      case 6: // Breakfast time
        userProfile.update((val) {
          val?.mealTimes['breakfast'] = response;
        });
        break;
      case 7: // Lunch time
        userProfile.update((val) {
          val?.mealTimes['lunch'] = response;
        });
        break;
      case 8: // Dinner time
        userProfile.update((val) {
          val?.mealTimes['dinner'] = response;
        });
        break;
      case 9: // Favorite foods
        userProfile.update((val) {
          val?.favoriteFoods =
              response.split(',').map((e) => e.trim()).toList();
        });
        break;
      case 10: // Additional info
        userProfile.update((val) {
          val?.additionalInfo['misc'] = response;
          val?.onboardingCompleted = true;
        });
        break;
    }

    saveUserProfile();

    // Move to next question or complete onboarding
    currentQuestionIndex.value++;

    if (currentQuestionIndex.value < onboardingQuestions.length) {
      // Ask next question
      addBotMessage(onboardingQuestions[currentQuestionIndex.value]);
    } else {
      // Complete onboarding
      isFirstTime.value = false;
      userProfile.update((val) {
        val?.onboardingCompleted = true;
      });
      saveUserProfile();

      // Send completion message
      final botResponse =
          "Thank you! I've saved your information. I'll help you manage your day and send you reminders when needed. Feel free to ask me anything anytime!";
      addBotMessage(botResponse);

      // Schedule notifications based on user routine
      scheduleRoutineNotifications();
    }
  }

  // Generate response using Gemini API
  Future<void> generateBotResponse(String userMessage) async {
    isLoading.value = true;

    try {
      // Create system prompt with user profile
      final systemPrompt = """
You are a personal assistant chatbot named My Day Mate. You help users manage their daily routines and provide reminders about their activities. 
You have the following information about the user:

${userProfile.value.getSummary()}

Use this information to personalize your responses and provide helpful suggestions related to their routine, medical needs, interests, and meals.
Be friendly, supportive, and concise. If asked about topics outside the user's data, you can ask follow-up questions to learn more about them.
""";

      // Call the Gemini API through our service
      final response = await _geminiService.generateResponse(
        userMessage,
        context: systemPrompt,
      );

      // Add the response to chat
      addBotMessage(response);
    } catch (e) {
      print('Exception when generating response: $e');
      addBotMessage("Sorry, I encountered an error. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  // Schedule notifications based on user routine
  void scheduleRoutineNotifications() {
    try {
      // Cancel existing notifications
      AwesomeNotifications().cancelAll();

      // Get user routine times
      final wakeupTime = userProfile.value.dailyRoutine['wakeup'];
      final breakfastTime = userProfile.value.mealTimes['breakfast'];
      final lunchTime = userProfile.value.mealTimes['lunch'];
      final dinnerTime = userProfile.value.mealTimes['dinner'];
      final bedtime = userProfile.value.dailyRoutine['bedtime'];

      // Schedule wake-up notification
      if (wakeupTime != null) {
        _scheduleNotification(
          'Good Morning!',
          'Time to wake up. Have a great day!',
          _parseTimeString(wakeupTime),
          1,
        );
      }

      // Schedule meal reminders
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

      // Schedule bedtime notification
      if (bedtime != null) {
        _scheduleNotification(
          'Bedtime Reminder',
          'It\'s almost bedtime. Time to wind down.',
          _parseTimeString(bedtime),
          5,
        );
      }

      // Schedule medicine reminders if user has medical conditions
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

      // Schedule random check-ins
      _scheduleRandomCheckIn();
    } catch (e) {
      print('Error scheduling notifications: $e');
    }
  }

  // Parse time string to TimeOfDay
  TimeOfDay _parseTimeString(String timeString) {
    timeString = timeString.toLowerCase();

    // Try to parse various time formats
    try {
      if (timeString.contains(':')) {
        // Format like "8:00 AM" or "20:00"
        final parts = timeString.split(':');
        int hour = int.parse(parts[0].trim());

        final minutePart = parts[1].trim();
        int minute = 0;

        if (minutePart.contains(' ')) {
          // Format with AM/PM
          final subParts = minutePart.split(' ');
          minute = int.parse(subParts[0]);

          if (subParts[1].toLowerCase().contains('pm') && hour < 12) {
            hour += 12;
          } else if (subParts[1].toLowerCase().contains('am') && hour == 12) {
            hour = 0;
          }
        } else {
          // 24-hour format
          minute = int.parse(minutePart);
        }

        return TimeOfDay(hour: hour, minute: minute);
      } else if (timeString.contains('am') || timeString.contains('pm')) {
        // Format like "8 AM" or "8PM"
        String numPart = timeString.replaceAll(RegExp(r'[^0-9]'), '');
        int hour = int.parse(numPart);

        if (timeString.contains('pm') && hour < 12) {
          hour += 12;
        } else if (timeString.contains('am') && hour == 12) {
          hour = 0;
        }

        return TimeOfDay(hour: hour, minute: 0);
      }
    } catch (e) {
      print('Error parsing time string: $e');
    }

    // Default to 8:00 AM if parsing fails
    return const TimeOfDay(hour: 8, minute: 0);
  }

  // Schedule a notification
  Future<void> _scheduleNotification(
      String title, String body, TimeOfDay time, int id) async {
    try {
      final now = DateTime.now();
      DateTime scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // If the time has already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'reminder_channel',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
          wakeUpScreen: true,
        ),
        schedule: NotificationCalendar(
          hour: scheduledDate.hour,
          minute: scheduledDate.minute,
          second: 0,
          millisecond: 0,
          repeats: true, // Repeat daily
          preciseAlarm: true,
        ),
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  // Schedule random check-in notifications
  void _scheduleRandomCheckIn() {
    try {
      // Schedule 2-3 random check-ins throughout the day
      final random = Random();
      final numCheckIns = random.nextInt(2) + 2; // 2-3 check-ins

      final checkInMessages = [
        'How are you feeling today?',
        'Don\'t forget to stay hydrated!',
        'Taking a break? How about a quick stretch?',
        'How\'s your day going so far?',
        'Remember to take a moment for yourself today.',
        'Any plans for the weekend?',
      ];

      for (int i = 0; i < numCheckIns; i++) {
        // Random time between 9 AM and 7 PM
        final hour = random.nextInt(10) + 9; // 9 AM to 7 PM
        final minute = random.nextInt(60);

        final messageIndex = random.nextInt(checkInMessages.length);

        _scheduleNotification(
          'Check-in',
          checkInMessages[messageIndex],
          TimeOfDay(hour: hour, minute: minute),
          100 + i, // Use ID starting from 100 for check-ins
        );
      }
    } catch (e) {
      print('Error scheduling random check-ins: $e');
    }
  }

  // Send an immediate notification
  Future<void> sendImmediateNotification(String title, String body) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 0,
          channelKey: 'basic_channel',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
        ),
      );
    } catch (e) {
      print('Error sending immediate notification: $e');
    }
  }
}
