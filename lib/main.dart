import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mydaymate/core/api/emergency_sms/send_data.dart';
import 'package:mydaymate/core/services/useractivityservice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import 'package:mydaymate/core/routes/app_pages.dart';
import 'package:mydaymate/core/routes/app_routes.dart';
import 'package:mydaymate/core/theme/app_theme.dart';
import 'package:mydaymate/core/utils/devices.dart';
import 'package:mydaymate/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  print('Notification action received: ${receivedAction.toMap()}');

  // You can navigate to different screens based on the notification type
  if (receivedAction.channelKey == 'reminder_channel') {
    // Handle reminder notifications
    Get.toNamed(AppRoutes.home);
  } else if (receivedAction.channelKey == 'basic_channel') {
    // Handle basic notifications
    Get.toNamed(AppRoutes.home);
  }
}

@pragma('vm:entry-point')
Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification) async {
  print('Notification created: ${receivedNotification.toMap()}');
}

@pragma('vm:entry-point')
Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification) async {
  print('Notification displayed: ${receivedNotification.toMap()}');
}

@pragma('vm:entry-point')
Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction) async {
  print('Notification dismissed: ${receivedAction.toMap()}');
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize timezone data
    tz_data.initializeTimeZones();
    tz.setLocalLocation(
        tz.getLocation('Asia/Colombo')); // Use your local timezone

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize notifications
    await initializeNotifications();

    // Initialize services
    //await Get.putAsync(() => NotificationService().init());
    await Get.putAsync(() => UserActivityService().init());

    // Get initial route based on authentication status
    final String initialRoute = await determineInitialRoute();

    // Configure GetX
    configureGetX();

    // Record app opened event
    await UserActivityService.to.recordAppOpened();

    final retriever = UserActivityRetriever();
    await retriever.sendToApi().then((success) {
      print(success
          ? 'User activity sent to API successfully'
          : 'Failed to send user activity to API');
    });

    runApp(MyApp(initialRoute: initialRoute));
  } catch (e) {
    print('Error during initialization: $e');
    // Run app with default route if initialization fails
    runApp(const MyApp(initialRoute: AppRoutes.onboard));
  }
}

void configureGetX() {
  // Configure GetX settings
  Get.config(
    enableLog: true,
    logWriterCallback: (String text, {bool isError = false}) {
      if (isError) {
        print('GETX ERROR: $text');
      } else {
        print('GETX: $text');
      }
    },
    defaultTransition: Transition.fade,
    defaultDurationTransition: const Duration(milliseconds: 300),
  );
}

Future<void> initializeNotifications() async {
  try {
    // Initialize Awesome Notifications for Android
    await AwesomeNotifications().initialize(
      null, // Use null for default app icon
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Basic notification channel for general alerts',
          defaultColor: Colors.blue,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
        ),
        NotificationChannel(
          channelKey: 'scheduled',
          channelName: 'Daily Notifications',
          channelDescription: 'Scheduled notifications for daily reminders',
          defaultColor: Colors.teal,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
        ),
        NotificationChannel(
          channelKey: 'scheduled',
          channelName: 'Reminders',
          channelDescription: 'Scheduled reminders for daily activities',
          defaultColor: Colors.green,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
        ),
      ],
      debug: true,
    );

    // Request notification permissions
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
      isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        print('Notification permission denied');
        Get.snackbar(
          'Notification Permission',
          'Please enable notifications in settings to receive reminders.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      }
    }

    // Request exact alarm permission for Android
    if (Platform.isAndroid) {
      PermissionStatus exactAlarmStatus =
          await Permission.scheduleExactAlarm.request();
      if (exactAlarmStatus.isDenied) {
        print('Exact alarm permission denied');
        Get.snackbar(
          'Exact Alarm Permission',
          'Please allow exact alarms in settings for scheduled notifications.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      }
    }

    // Prompt to disable battery optimization
    await requestBatteryOptimizationExemption();

    // Schedule a test daily notification at 2:22 PM
    await scheduleDailyNotification();

    // Set up notification action listeners
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  } catch (e) {
    print('Error initializing notifications: $e');
  }
}

Future<void> scheduleDailyNotification() async {
  final now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledTime =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, 15, 57);

  if (scheduledTime.isBefore(now)) {
    scheduledTime = scheduledTime.add(const Duration(days: 1));
  }

  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
      channelKey: 'scheduled',
      title: '⏰ Daily Reminder',
      body: 'This is your scheduled notification!',
      notificationLayout: NotificationLayout.Default,
    ),
    schedule: NotificationCalendar(
      hour: 15,
      minute: 57,
      second: 0,
      repeats: true,
      timeZone: tz.local.name,
    ),
  );

  print("Scheduled daily notification for ${scheduledTime.toString()}");
}

Future<void> requestBatteryOptimizationExemption() async {
  try {
    const String prefKey = 'battery_optimization_prompted';
    final prefs = await SharedPreferences.getInstance();
    bool alreadyPrompted = prefs.getBool(prefKey) ?? false;

    if (!alreadyPrompted) {
      Get.dialog(
        AlertDialog(
          title: const Text('Battery Optimization'),
          content: const Text(
              'To ensure reminders work reliably, please disable battery optimization for MyDayMate.'),
          actions: [
            TextButton(
              onPressed: () async {
                await prefs.setBool(prefKey, true);
                Get.back();
              },
              child: const Text('Later'),
            ),
            TextButton(
              onPressed: () async {
                await prefs.setBool(prefKey, true);
                Get.back();
                // Open app settings to disable battery optimization
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    print('Error prompting for battery optimization: $e');
  }
}

Future<String> determineInitialRoute() async {
  try {
    // Check if user is already logged in
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // User is logged in, go to home page
      return AppRoutes.home;
    } else {
      // Check if user has completed onboarding
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedOnboarding =
          prefs.getBool('onboarding_completed') ?? false;

      // If onboarding completed, go to login page, otherwise go to onboarding
      return hasCompletedOnboarding ? AppRoutes.login : AppRoutes.onboard;
    }
  } catch (e) {
    print('Error determining initial route: $e');
    return AppRoutes.onboard; // Default to onboarding if there's an error
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyDayMate',
      theme: AppTheme.theme(context),
      initialRoute: initialRoute,
      getPages: AppPages.pages,
      builder: (context, child) {
        DeviceLayout.init(context);
        return child ?? const SizedBox();
      },
    );
  }
}
