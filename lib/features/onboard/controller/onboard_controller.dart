import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mydaymate/core/routes/app_routes.dart';
import '../data/data.dart';
import '../model/model.dart';

class OnboardController extends GetxController {
  final PageController pageController = PageController();
  final OnboardingData _onboardingData = OnboardingData();
  final RxInt currentPage = 0.obs;

  List<OnboardModel> get pages => _onboardingData.items;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Get.offAllNamed(AppRoutes.register); // Navigate to home using new routes
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
