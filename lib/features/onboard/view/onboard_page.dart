import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../controller/onboard_controller.dart';

class OnboardPage extends GetView<OnboardController> {
  const OnboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            itemCount: controller.pages.length,
            itemBuilder: (context, index) {
              final item = controller.pages[index];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Image.asset(
                      item.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '"${item.description}"',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Center(
                  child: AnimatedBuilder(
                    animation: controller.pageController,
                    builder: (context, child) {
                      return SmoothPageIndicator(
                        controller: controller.pageController,
                        count: controller.pages.length,
                        effect: WormEffect(
                          dotHeight: 10,
                          dotWidth: 10,
                          spacing: 8,
                          activeDotColor:
                              Theme.of(context).colorScheme.secondary,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        onPressed: controller.nextPage,
                        child: Text(
                          controller.currentPage.value ==
                                  controller.pages.length - 1
                              ? 'Get Started'
                              : 'Next',
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
