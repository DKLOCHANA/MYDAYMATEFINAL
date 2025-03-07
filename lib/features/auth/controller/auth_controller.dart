import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';

class AuthController extends GetxController {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  final _obscurePassword = true.obs;
  final _obscureConfirmPassword = true.obs;

  bool get obscurePassword => _obscurePassword.value;
  bool get obscureConfirmPassword => _obscureConfirmPassword.value;

  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();
  void toggleObscurePassword() => _obscurePassword.toggle();
  void toggleObscureConfirmPassword() => _obscureConfirmPassword.toggle();

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final age = DateTime.now().year - picked.year;
      ageController.text = age.toString();
    }
  }

  void login() {
    // Add login logic here
    if (usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  void register() {
    if (_validateRegistration()) {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  bool _validateRegistration() {
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        ageController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match');
      return false;
    }

    return true;
  }

  void goToRegister() => Get.toNamed(AppRoutes.register);
  void goToLogin() => Get.toNamed(AppRoutes.login);

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    ageController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
