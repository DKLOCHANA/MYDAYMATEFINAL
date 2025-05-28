import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Observable variables
  final Rx<Map<String, dynamic>?> userData = Rx<Map<String, dynamic>?>(null);
  final RxBool isLoading = false.obs;
  final RxString profileImagePath = ''.obs;

  // Text controllers
  final TextEditingController editUsernameController = TextEditingController();
  final TextEditingController editEmailController = TextEditingController();
  final TextEditingController editPhoneController = TextEditingController();
  final TextEditingController editBirthDateController = TextEditingController();
  final TextEditingController editEmergencyContactController =
      TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadProfileImage();
  }

  @override
  void onClose() {
    editUsernameController.dispose();
    editEmailController.dispose();
    editPhoneController.dispose();
    editBirthDateController.dispose();
    editEmergencyContactController.dispose();
    super.onClose();
  }

  Future<void> loadUserData() async {
    isLoading.value = true;
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final docSnapshot =
            await _firestore.collection('users').doc(user.uid).get();

        if (docSnapshot.exists) {
          userData.value = docSnapshot.data();

          // Set initial values for text controllers
          editUsernameController.text = userData.value?['username'] ?? '';
          editEmailController.text =
              userData.value?['email'] ?? user.email ?? '';
          editPhoneController.text = userData.value?['phone'] ?? '';
          editBirthDateController.text = userData.value?['birthDate'] ?? '';
          editEmergencyContactController.text =
              userData.value?['emergencyContact'] ?? '';
        } else {
          // Create default user data if it doesn't exist
          final defaultData = {
            'username': user.displayName ?? 'User',
            'email': user.email ?? '',
            'phone': user.phoneNumber ?? '',
            'birthDate': '',
            'emergencyContact': '',
          };

          await _firestore.collection('users').doc(user.uid).set(defaultData);
          userData.value = defaultData;

          // Set initial values for text controllers
          editUsernameController.text = defaultData['username']!;
          editEmailController.text = defaultData['email']!;
          editPhoneController.text = defaultData['phone']!;
          editBirthDateController.text = defaultData['birthDate']!;
          editEmergencyContactController.text =
              defaultData['emergencyContact']!;
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      Get.snackbar('Error', 'Failed to load user data');
    } finally {
      isLoading.value = false;
    }
  }

  // Load profile image from local storage
  Future<void> loadProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedImagePath = prefs.getString('profile_image_path');

      if (savedImagePath != null && File(savedImagePath).existsSync()) {
        profileImagePath.value = savedImagePath;
      }
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }

  // Pick image from gallery or camera
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80, // Adjust quality as needed
      );

      if (pickedFile == null) return;

      // Get the app's documents directory for persistent storage
      final directory = await getApplicationDocumentsDirectory();

      // Create a unique filename for the image
      final userId = _auth.currentUser?.uid ?? 'user';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'profile_$userId$timestamp${path.extension(pickedFile.path)}';

      // Copy the picked image to the app's documents directory
      final File newImage = File(pickedFile.path);
      final savedImagePath = path.join(directory.path, fileName);

      await newImage.copy(savedImagePath);

      // Update the profile image path and save it to SharedPreferences
      profileImagePath.value = savedImagePath;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', savedImagePath);

      // Update user data with image path reference (optional, if you want to store in Firestore)
      await updateField('profileImageFileName', fileName);

      Get.snackbar('Success', 'Profile picture updated');
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar('Error', 'Failed to update profile picture');
    }
  }

  // Remove profile image
  Future<void> removeProfileImage() async {
    try {
      if (profileImagePath.value.isNotEmpty) {
        // Delete the file from storage
        final file = File(profileImagePath.value);
        if (await file.exists()) {
          await file.delete();
        }

        // Clear the saved path
        profileImagePath.value = '';

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('profile_image_path');

        // Update user data to remove image reference (optional)
        await updateField('profileImageFileName', null);

        Get.snackbar('Success', 'Profile picture removed');
      }
    } catch (e) {
      print('Error removing profile image: $e');
      Get.snackbar('Error', 'Failed to remove profile picture');
    }
  }

  // Update user data field
  Future<void> updateField(String field, dynamic value) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .update({field: value});

        // Update local userData
        if (userData.value != null) {
          final updatedData = Map<String, dynamic>.from(userData.value!);
          if (value == null) {
            updatedData.remove(field);
          } else {
            updatedData[field] = value;
          }
          userData.value = updatedData;
        }

        Get.back(); // Close the bottom sheet
        Get.snackbar('Success', 'Profile updated successfully');
      }
    } catch (e) {
      print('Error updating user data: $e');
      Get.snackbar('Error', 'Failed to update profile');
    }
  }

  // Select date
  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      editBirthDateController.text =
          "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      print('Error signing out: $e');
      Get.snackbar('Error', 'Failed to sign out');
    }
  }
}
