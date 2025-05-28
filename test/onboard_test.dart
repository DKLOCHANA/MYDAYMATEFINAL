import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mydaymate/core/routes/app_routes.dart';
import 'package:mydaymate/features/onboard/controller/onboard_controller.dart';

void main() {
  late OnboardController onboardController;

  setUp(() {
    // Initialize GetX test mode and controller
    Get.testMode = true;
    onboardController = OnboardController();
    Get.put(onboardController);
  });

  tearDown(() {
    Get.reset(); // Clean up GetX bindings
  });

  group('OnboardController Simple Tests', () {
    test('Initial page is 0', () {
      // Assert
      expect(onboardController.currentPage.value, 0);
    });

    test('onPageChanged updates current page', () {
      // Act
      onboardController.onPageChanged(1);

      // Assert
      expect(onboardController.currentPage.value, 1);
    });
  });
}
