import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mydaymate/widgets/gradient_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../core/utils/devices.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/auth_controller.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    DeviceLayout.init(context);

    // Check if we're on a small device
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      body: Obx(() => Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.grey.shade100,
                      Colors.grey.shade200.withOpacity(0.5),
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: screenSize.height -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              DeviceLayout.spacing(isSmallScreen ? 16 : 24),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // App Logo with enhanced shadow
                            Container(
                              height: DeviceLayout.getProportionateScreenHeight(
                                  isSmallScreen ? 100 : 120),
                              width: DeviceLayout.getProportionateScreenHeight(
                                  isSmallScreen ? 100 : 120),
                              margin: EdgeInsets.only(
                                top: DeviceLayout.getProportionateScreenHeight(
                                    40),
                                bottom:
                                    DeviceLayout.getProportionateScreenHeight(
                                        20),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.15),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  height:
                                      DeviceLayout.getProportionateScreenHeight(
                                          70),
                                  width:
                                      DeviceLayout.getProportionateScreenHeight(
                                          70),
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.schedule,
                                      size: DeviceLayout
                                          .getProportionateScreenHeight(50),
                                      color: AppColors.primary,
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Welcome Text with improved styling
                            Text(
                              "Welcome Back!",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                    fontSize: DeviceLayout.fontSize(
                                        isSmallScreen ? 24 : 28),
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                            ),
                            SizedBox(height: DeviceLayout.spacing(8)),
                            Text(
                              "Sign in to continue your productivity journey",
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontSize: DeviceLayout.fontSize(
                                        isSmallScreen ? 14 : 16),
                                    color: Colors.grey[600],
                                  ),
                            ),
                            SizedBox(
                                height: DeviceLayout.spacing(
                                    isSmallScreen ? 32 : 40)),

                            // Form Card with shadow matching register page style
                            Container(
                              padding: EdgeInsets.all(DeviceLayout.spacing(
                                  isSmallScreen ? 16 : 20)),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    DeviceLayout.spacing(16)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Email TextField with improved styling
                                  CustomTextfield(
                                    controller: controller.usernameController,
                                    hintText: "Email",
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: AppColors.primary.withOpacity(0.7),
                                    ),
                                  ),
                                  SizedBox(
                                      height: DeviceLayout.spacing(
                                          isSmallScreen ? 12 : 16)),

                                  // Password TextField with improved styling
                                  Obx(() => CustomTextfield(
                                        controller:
                                            controller.passwordController,
                                        hintText: "Password",
                                        obscureText:
                                            !controller.isPasswordVisible.value,
                                        prefixIcon: Icon(
                                          Icons.lock_outline,
                                          color: AppColors.primary
                                              .withOpacity(0.7),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            controller.isPasswordVisible.value
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: AppColors.primary
                                                .withOpacity(0.7),
                                          ),
                                          onPressed: controller
                                              .togglePasswordVisibility,
                                        ),
                                      )),

                                  // Forgot Password
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed:
                                          controller.showForgotPasswordDialog,
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                      ),
                                      child: Text(
                                        "Forgot Password?",
                                        style: TextStyle(
                                          fontSize: DeviceLayout.fontSize(
                                              isSmallScreen ? 13 : 14),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(
                                height: DeviceLayout.spacing(
                                    isSmallScreen ? 24 : 28)),

                            // Login Button with enhanced shadow
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    DeviceLayout.spacing(12)),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: GradientButton(
                                text: "Login",
                                onTap: controller.login,
                              ),
                            ),

                            SizedBox(
                                height: DeviceLayout.spacing(
                                    isSmallScreen ? 20 : 28)),

                            // Register Prompt with improved styling
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: DeviceLayout.spacing(10),
                                  horizontal: DeviceLayout.spacing(16)),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(
                                    DeviceLayout.spacing(12)),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: DeviceLayout.fontSize(
                                          isSmallScreen ? 13 : 14),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: controller.goToRegister,
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: DeviceLayout.spacing(8),
                                        vertical: DeviceLayout.spacing(4),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            DeviceLayout.spacing(8)),
                                      ),
                                    ),
                                    child: Text(
                                      "Register",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: DeviceLayout.fontSize(
                                            isSmallScreen ? 13 : 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                height:
                                    DeviceLayout.getProportionateScreenHeight(
                                        30)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Loading Overlay with improved styling
              if (controller.isLoading.value)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(DeviceLayout.spacing(24)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(DeviceLayout.spacing(16)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                          SizedBox(height: DeviceLayout.spacing(16)),
                          Text(
                            "Logging in...",
                            style: TextStyle(
                              fontSize: DeviceLayout.fontSize(14),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          )),
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onTap,
    required String icon,
    required IconData fallbackIcon,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DeviceLayout.spacing(12)),
        child: Container(
          width: DeviceLayout.spacing(50),
          height: DeviceLayout.spacing(50),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Center(
            child: Image.asset(
              icon,
              width: DeviceLayout.spacing(24),
              height: DeviceLayout.spacing(24),
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  fallbackIcon,
                  size: DeviceLayout.spacing(28),
                  color: AppColors.primary,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
