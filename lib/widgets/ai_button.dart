import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mydaymate/core/routes/app_routes.dart';
import 'package:mydaymate/core/theme/app_colors.dart';
import 'package:mydaymate/core/theme/app_text_styles.dart';
// Adjust path as needed

class PulsingChatBotButton extends StatelessWidget {
  final double verticalPadding;
  final double horizontalPadding;
  final double imageSize;
  final Size screenSize;

  const PulsingChatBotButton({
    Key? key,
    required this.verticalPadding,
    required this.horizontalPadding,
    required this.imageSize,
    required this.screenSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatBotButtonController>(
      init: ChatBotButtonController(),
      builder: (controller) {
        return AnimatedBuilder(
          animation: controller.glowController,
          builder: (context, child) {
            return GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.chatbot),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1C2526),
                      Color(0xFF2D3E50),
                      Color(0xFF4B5EAA),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(screenSize.width * 0.04),
                  border: Border.all(
                    color: AppColors.primaryVariant,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.6),
                      blurRadius: controller.glowAnimation.value,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.5),
                        Colors.transparent,
                        Colors.white.withOpacity(0.5),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      tileMode: TileMode.mirror,
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcATop,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/images/home/gif.json',
                        height: screenSize.height * 0.08,
                        width: screenSize.width * 0.2,
                        repeat: true, // or false if you want it to play once
                      ),
                      Text(
                        "Need Any Assistance?",
                        style: AppTextStyles.bodyLarge(context)
                            .copyWith(color: AppColors.white),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ChatBotButtonController extends GetxController
    with GetTickerProviderStateMixin {
  late AnimationController glowController;
  late Animation<double> glowAnimation;

  @override
  void onInit() {
    super.onInit();
    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    glowAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void onClose() {
    glowController.dispose();
    super.onClose();
  }
}
