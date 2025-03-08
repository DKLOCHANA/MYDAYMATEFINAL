import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mydaymate/core/routes/app_routes.dart';

class ProfileController extends GetxController {
  final userData = Rxn<Map<String, dynamic>>();
  final isLoading = false.obs;

  // Controllers for editing
  final editUsernameController = TextEditingController();
  final editEmailController = TextEditingController();
  final editPhoneController = TextEditingController();
  final editBirthDateController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          userData.value = doc.data();
          _initializeControllers();
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data');
    } finally {
      isLoading.value = false;
    }
  }

  void _initializeControllers() {
    final data = userData.value;
    if (data != null) {
      editUsernameController.text = data['username'] ?? '';
      editEmailController.text = data['email'] ?? '';
      editPhoneController.text = data['phone'] ?? '';
      editBirthDateController.text = data['birthDate'] ?? '';
    }
  }

  Future<void> updateField(String field, String value) async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({field: value});

        await loadUserData();
        Get.back();
        Get.snackbar('Success', 'Updated successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update $field');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final birthDate = "${picked.day}/${picked.month}/${picked.year}";
      editBirthDateController.text = birthDate;
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign out',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    editUsernameController.dispose();
    editEmailController.dispose();
    editPhoneController.dispose();
    editBirthDateController.dispose();
    super.dispose();
  }
}
