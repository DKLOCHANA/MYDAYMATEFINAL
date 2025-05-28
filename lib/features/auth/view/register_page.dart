import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mydaymate/widgets/gradient_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/custom_textfield.dart';
import '../controller/auth_controller.dart';
import '../../../core/utils/devices.dart';

class RegisterPage extends GetView<AuthController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    DeviceLayout.init(context);

    // For responsive sizing
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      body: Obx(() => Stack(
            children: [
              // Background decoration
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.grey.shade50,
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16.0 : 24.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                            height:
                                DeviceLayout.getProportionateScreenHeight(40)),

                        // Enhanced header with styling
                        Container(
                          margin: EdgeInsets.only(
                              bottom: DeviceLayout.spacing(
                                  isSmallScreen ? 24 : 32)),
                          child: Column(
                            children: [
                              Text(
                                "Join Our Community!",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(
                                      fontSize: DeviceLayout.fontSize(
                                          isSmallScreen ? 24 : 28),
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Fill in your details to get started",
                                style: TextStyle(
                                  fontSize: DeviceLayout.fontSize(
                                      isSmallScreen ? 14 : 16),
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Form Card with shadow
                        Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Obx(() => Column(
                                children: [
                                  // Username field
                                  CustomTextfield(
                                    controller: controller.usernameController,
                                    hintText: "Username",
                                    prefixIcon: Icon(Icons.person_outline,
                                        color:
                                            AppColors.primary.withOpacity(0.7)),
                                  ),
                                  SizedBox(height: 12),

                                  // Email field
                                  CustomTextfield(
                                    controller: controller.emailController,
                                    hintText: "Email",
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: Icon(Icons.email_outlined,
                                        color:
                                            AppColors.primary.withOpacity(0.7)),
                                  ),
                                  SizedBox(height: 12),

                                  // Phone field
                                  CustomTextfield(
                                    controller: controller.phoneController,
                                    hintText: "Contact Number",
                                    keyboardType: TextInputType.phone,
                                    prefixIcon: Icon(Icons.phone_outlined,
                                        color:
                                            AppColors.primary.withOpacity(0.7)),
                                  ),
                                  SizedBox(height: 12),

                                  // Birth date field
                                  CustomTextfield(
                                    controller: controller.ageController,
                                    hintText: "Birth Date",
                                    readOnly: true,
                                    prefixIcon: Icon(Icons.cake_outlined,
                                        color:
                                            AppColors.primary.withOpacity(0.7)),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.calendar_today,
                                          color: AppColors.primary),
                                      onPressed: controller.selectDate,
                                    ),
                                  ),
                                  SizedBox(height: 12),

                                  // Password field
                                  CustomTextfield(
                                    controller: controller.passwordController,
                                    hintText: "Password",
                                    obscureText: controller.obscurePassword,
                                    prefixIcon: Icon(Icons.lock_outline,
                                        color:
                                            AppColors.primary.withOpacity(0.7)),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color:
                                            AppColors.primary.withOpacity(0.7),
                                      ),
                                      onPressed:
                                          controller.toggleObscurePassword,
                                    ),
                                  ),
                                  SizedBox(height: 12),

                                  // Confirm password field
                                  CustomTextfield(
                                    controller:
                                        controller.confirmPasswordController,
                                    hintText: "Confirm Password",
                                    obscureText:
                                        controller.obscureConfirmPassword,
                                    prefixIcon: Icon(Icons.lock_outline,
                                        color:
                                            AppColors.primary.withOpacity(0.7)),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.obscureConfirmPassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color:
                                            AppColors.primary.withOpacity(0.7),
                                      ),
                                      onPressed: controller
                                          .toggleObscureConfirmPassword,
                                    ),
                                  ),
                                ],
                              )),
                        ),

                        SizedBox(height: DeviceLayout.spacing(24)),

                        // Enhanced button with shadow
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: GradientButton(
                            text: "Create an account",
                            onTap: controller.register,
                          ),
                        ),

                        SizedBox(height: DeviceLayout.spacing(24)),

                        // Enhanced login prompt
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: DeviceLayout.spacing(10),
                              horizontal: DeviceLayout.spacing(16)),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius:
                                BorderRadius.circular(DeviceLayout.spacing(12)),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account?",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: DeviceLayout.fontSize(14),
                                ),
                              ),
                              TextButton(
                                onPressed: controller.goToLogin,
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                ),
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: DeviceLayout.fontSize(14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Enhanced loading overlay
              if (controller.isLoading.value)
                Container(
                  color: Colors.black.withOpacity(0.4),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
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
                          const SizedBox(height: 16),
                          Text(
                            "Creating your account...",
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
}
