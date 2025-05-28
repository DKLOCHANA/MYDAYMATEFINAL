import 'dart:io';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  final username = 'User'.obs;
  final RxString profileImagePath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentUser();
    loadProfileImage();
  }

  Future<void> getCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userData.exists) {
          username.value = userData.get('username') ?? 'User';
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

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
}
