import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserActivityService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable variables
  final RxBool isRecording = false.obs;
  final Rx<DateTime?> lastActivityTime = Rx<DateTime?>(null);
  final RxString emergencyContact = "".obs;

  // Constants
  static const String _lastActivityKey = 'last_activity_timestamp';
  static const Duration _minimumUpdateInterval = Duration(minutes: 10);

  // Singleton instance
  static UserActivityService get to => Get.find<UserActivityService>();

  // Initialize the service
  Future<UserActivityService> init() async {
    try {
      // Load last recorded time from shared preferences for comparison
      await _loadLastActivityTime();

      // Load emergency contact information
      await _loadEmergencyContact();

      // Start tracking app activity
      recordAppActivity();

      return this;
    } catch (e) {
      print('Error initializing UserActivityService: $e');
      return this;
    }
  }

  // Load emergency contact from Firestore
  Future<void> _loadEmergencyContact() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final userData =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (userData.exists && userData.data()!.containsKey('emergencyContact')) {
        emergencyContact.value = userData.data()!['emergencyContact'] ?? '';
        print('Loaded emergency contact: ${emergencyContact.value}');
      }
    } catch (e) {
      print('Error loading emergency contact: $e');
    }
  }

  // Record current app activity
  Future<void> recordAppActivity() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('Cannot record activity: No authenticated user');
        return;
      }

      final DateTime now = DateTime.now();

      // Check if we should update based on the minimum interval
      if (lastActivityTime.value != null) {
        final Duration timeSinceLastUpdate =
            now.difference(lastActivityTime.value!);
        if (timeSinceLastUpdate < _minimumUpdateInterval) {
          print(
              'Skipping activity update: Last update was only ${timeSinceLastUpdate.inMinutes} minutes ago');
          return;
        }
      }

      // Make sure we have the latest emergency contact
      if (emergencyContact.value.isEmpty) {
        await _loadEmergencyContact();
      }

      // Record that we're updating
      isRecording.value = true;

      // Update activity in Firestore
      await _firestore.collection('user_activity').doc(currentUser.uid).set({
        'last_active': Timestamp.fromDate(now),
        'email': currentUser.email,
        'display_name': currentUser.displayName,
        'emergency_contact': emergencyContact.value,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Save to shared preferences for local tracking
      await _saveLastActivityTime(now);

      print('User activity recorded at ${now.toString()}');
    } catch (e) {
      print('Error recording user activity: $e');
    } finally {
      isRecording.value = false;
    }
  }

  // Record app opened event
  Future<void> recordAppOpened() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('Cannot record app opened: No authenticated user');
        return;
      }

      final DateTime now = DateTime.now();

      // Make sure we have the latest emergency contact
      await _loadEmergencyContact();

      // Get user data including emergency contact
      final userData =
          await _firestore.collection('users').doc(currentUser.uid).get();
      final String emergencyContactValue =
          userData.exists && userData.data()!.containsKey('emergencyContact')
              ? userData.data()!['emergencyContact'] ?? ''
              : emergencyContact.value;

      // Update both activity and app_opened in Firestore
      await _firestore.collection('user_activity').doc(currentUser.uid).set({
        'last_active': Timestamp.fromDate(now),
        'app_opened_at': Timestamp.fromDate(now),
        'app_open_count': FieldValue.increment(1),
        'email': currentUser.email,
        'emergency_contact': emergencyContactValue,
        'device_info': {
          'platform': Theme.of(Get.context!).platform.toString(),
          'locale': Get.deviceLocale.toString(),
        },
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Save to shared preferences
      await _saveLastActivityTime(now);

      print('App opened event recorded at ${now.toString()}');
    } catch (e) {
      print('Error recording app opened event: $e');
    }
  }

  // Record app closed/background event
  Future<void> recordAppClosed() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('Cannot record app closed: No authenticated user');
        return;
      }

      final DateTime now = DateTime.now();

      // Track session duration if we have a last activity time
      Duration? sessionDuration;
      if (lastActivityTime.value != null) {
        sessionDuration = now.difference(lastActivityTime.value!);
      }

      // Update Firestore
      await _firestore.collection('user_activity').doc(currentUser.uid).set({
        'last_active': Timestamp.fromDate(now),
        'app_closed_at': Timestamp.fromDate(now),
        'last_session_duration': sessionDuration?.inSeconds,
        'emergency_contact': emergencyContact.value,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Save to shared preferences
      await _saveLastActivityTime(now);

      print('App closed event recorded at ${now.toString()}');
    } catch (e) {
      print('Error recording app closed event: $e');
    }
  }

  // Public method to update emergency contact when it changes
  Future<void> updateEmergencyContact(String contact) async {
    try {
      emergencyContact.value = contact;

      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Update the emergency contact in the activity document too
      await _firestore.collection('user_activity').doc(currentUser.uid).set({
        'emergency_contact': contact,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('Emergency contact updated: $contact');
    } catch (e) {
      print('Error updating emergency contact: $e');
    }
  }

  // Load the last activity time from SharedPreferences
  Future<void> _loadLastActivityTime() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? timestamp = prefs.getInt(_lastActivityKey);

      if (timestamp != null) {
        lastActivityTime.value = DateTime.fromMillisecondsSinceEpoch(timestamp);
        print(
            'Loaded last activity time: ${lastActivityTime.value.toString()}');
      }
    } catch (e) {
      print('Error loading last activity time: $e');
    }
  }

  // Save the last activity time to SharedPreferences
  Future<void> _saveLastActivityTime(DateTime time) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastActivityKey, time.millisecondsSinceEpoch);
      lastActivityTime.value = time;
    } catch (e) {
      print('Error saving last activity time: $e');
    }
  }
}
