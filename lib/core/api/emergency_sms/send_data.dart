import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

// Service class to retrieve user activity data and send to API
class UserActivityRetriever {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _apiUrl =
      'https://api-production-6b02.up.railway.app/save-number';

  // Retrieve last active time for the current user
  Future<DateTime?> getLastActiveTime() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('Cannot retrieve last active time: No authenticated user');
        return null;
      }

      final doc = await _firestore
          .collection('user_activity')
          .doc(currentUser.uid)
          .get();

      if (doc.exists && doc.data()!.containsKey('last_active')) {
        final timestamp = doc.data()!['last_active'] as Timestamp?;
        if (timestamp != null) {
          final lastActive = timestamp.toDate();
          print('Retrieved last active time: ${lastActive.toString()}');
          return lastActive;
        }
      }

      print('No last active time found for user: ${currentUser.uid}');
      return null;
    } catch (e) {
      print('Error retrieving last active time: $e');
      return null;
    }
  }

  // Retrieve emergency contact for the current user
  Future<String?> getEmergencyContact() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('Cannot retrieve emergency contact: No authenticated user');
        return null;
      }

      final doc = await _firestore
          .collection('user_activity')
          .doc(currentUser.uid)
          .get();

      if (doc.exists && doc.data()!.containsKey('emergency_contact')) {
        final emergencyContact = doc.data()!['emergency_contact'] as String?;
        if (emergencyContact != null && emergencyContact.isNotEmpty) {
          print('Retrieved emergency contact: $emergencyContact');
          return emergencyContact;
        }
      }

      print('No emergency contact found for user: ${currentUser.uid}');
      return null;
    } catch (e) {
      print('Error retrieving emergency contact: $e');
      return null;
    }
  }

  // Send data to the API endpoint
  Future<bool> sendToApi() async {
    try {
      // Retrieve last active time and emergency contact
      final lastActiveTime = await getLastActiveTime();
      final emergencyContact = await getEmergencyContact();

      if (lastActiveTime == null || emergencyContact == null) {
        print(
            'Cannot send data: Missing last active time or emergency contact');
        return false;
      }

      // Convert last active time to Sri Lanka Time (SLT, UTC+5:30)
      final slt = tz.getLocation('Asia/Colombo');
      final sltTime = tz.TZDateTime.from(lastActiveTime, slt);

      // Format timestamp to ISO 8601 with SLT offset
      final formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
      final formattedTime = formatter.format(sltTime);
      final offset = '+05:30';
      final timestamp = '$formattedTime$offset';

      // Prepare JSON payload
      final payload = {
        // 'phone': emergencyContact,
        'phone': '+94711710593',
        'timestamp': timestamp,
      };

      print('Prepared payload: ${jsonEncode(payload)}');

      // Send POST request to the API
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print('Successfully sent data to API: ${response.body}');
        return true;
      } else {
        print(
            'Failed to send data to API: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending data to API: $e');
      return false;
    }
  }
}
