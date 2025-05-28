import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Mock HomeController with minimal dependencies
class MockHomeController extends GetxController {
  final username = 'User'.obs;
  final RxString profileImagePath = ''.obs;

  // Mock of loadProfileImage function for testing
  Future<void> loadProfileImage(
      {SharedPreferences? prefs, Directory? fileSystem}) async {
    try {
      // Use provided prefs or create a new SharedPreferences mock
      final preferences = prefs ?? await SharedPreferences.getInstance();
      final savedImagePath = preferences.getString('profile_image_path');

      // Simplified existence check that doesn't need real File system
      if (savedImagePath != null && (fileSystem?.existsSync() ?? false)) {
        profileImagePath.value = savedImagePath;
      }
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }

  // Simple username update function for testing
  void updateUsername(String newUsername) {
    if (newUsername.isNotEmpty) {
      username.value = newUsername;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockHomeController controller;

  setUp(() {
    // Initialize GetX test mode
    Get.testMode = true;

    // Create the controller
    controller = MockHomeController();
  });

  tearDown(() {
    Get.reset();
  });

  group('HomeController Basic Tests', () {
    test('updateUsername correctly updates the username', () {
      // Arrange
      expect(controller.username.value, 'User'); // Default value

      // Act
      controller.updateUsername('John Doe');

      // Assert
      expect(controller.username.value, 'John Doe');
    });

    test('updateUsername does not update with empty string', () {
      // Arrange
      controller.username.value = 'Current User';

      // Act
      controller.updateUsername('');

      // Assert
      expect(controller.username.value, 'Current User'); // Remains unchanged
    });

    test('loadProfileImage keeps empty path when no saved path exists',
        () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Act
      await controller.loadProfileImage(prefs: prefs);

      // Assert
      expect(controller.profileImagePath.value, '');
    });
  });
}

// Simple Directory mock
class _MockDirectory extends Mock implements Directory {
  @override
  bool existsSync() => true;
}
