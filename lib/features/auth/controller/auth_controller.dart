import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mydaymate/core/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/routes/app_routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final isLoading = false.obs;
  final user = Rxn<User>();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final resetEmailController = TextEditingController();

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

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
  }

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime(2000), // Changed to start with year 2000
      firstDate: DateTime(1950), // Changed to allow dates from 1950
      lastDate: DateTime.now(), // Current date as max
      initialEntryMode:
          DatePickerEntryMode.calendarOnly, // Added to show calendar by default
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.backgroundColor,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final age = DateTime.now().year - picked.year;
      final birthDate = "${picked.day}/${picked.month}/${picked.year}";
      ageController.text =
          birthDate; // Changed to show full date instead of just age
    }
  }

  Future<void> register() async {
    if (!_validateRegistration()) return;

    try {
      isLoading.value = true;

      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Create user profile in Firestore first
      await _createUserProfile(userCredential.user!.uid).then((_) async {
        // Only send verification email if profile creation was successful
        await userCredential.user?.sendEmailVerification();

        Get.snackbar(
          'Success',
          'Registration successful. Please verify your email.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offAllNamed(AppRoutes.login);
      });
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print(
          "=================================================================");
      print('Error details: $e'); // For debugging
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login() async {
    if (!_validateLogin()) return;

    try {
      isLoading.value = true;

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: usernameController.text
            .trim(), // Changed from emailController to usernameController
        password: passwordController.text,
      );

      if (!userCredential.user!.emailVerified) {
        Get.snackbar(
          'Error',
          'Please verify your email first.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      Get.offAllNamed(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      isLoading.value = true;
      await _auth.currentUser?.sendEmailVerification();
      Get.snackbar(
        'Success',
        'Verification email sent!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email.trim());
      Get.snackbar(
        'Success',
        'Password reset email sent!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out');
    }
  }

  Future<void> _createUserProfile(String uid) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

      await userDoc.set({
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'birthDate': ageController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': uid, // Add user ID for reference
      }, SetOptions(merge: true)); // Use merge option to avoid overwriting
    } catch (e) {
      print('Firestore error details: $e'); // For debugging
      throw Exception('Failed to create user profile: $e');
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'email-already-in-use':
        message = 'Email is already registered';
        break;
      case 'invalid-email':
        message = 'Invalid email address';
        break;
      case 'weak-password':
        message = 'Password is too weak';
        break;
      case 'user-not-found':
        message = 'No user found with this email';
        break;
      case 'wrong-password':
        message = 'Wrong password';
        break;
      default:
        message = 'Authentication failed';
    }
    Get.snackbar('Error', message,
        backgroundColor: Colors.red, colorText: Colors.white);
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

  bool _validateLogin() {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      // Using usernameController instead of emailController
      Get.snackbar('Error', 'Please fill all fields');
      return false;
    }
    return true;
  }

  void goToRegister() => Get.toNamed(AppRoutes.register);
  void goToLogin() => Get.toNamed(AppRoutes.login);

  void showForgotPasswordDialog() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Reset Password',
          style: Get.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address to receive a password reset link',
              style: Get.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              resetPassword(resetEmailController.text);
              resetEmailController.clear();
            },
            child: Text('Send'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    ageController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    resetEmailController.dispose();
    super.dispose();
  }
}
