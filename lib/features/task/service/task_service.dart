import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID with null safety
  String? get currentUserId => _auth.currentUser?.uid;
  CollectionReference get tasksCollection => _firestore.collection('tasks');

  // Create a new task
  Future<void> createTask(TaskModel task) async {
    try {
      // Additional validation to ensure userId is present
      if (task.userId.isEmpty) {
        throw Exception('User ID is missing');
      }

      await tasksCollection.doc(task.id).set(task.toMap());
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  // Get tasks for a specific date
  Stream<List<TaskModel>> getTasksByDate(DateTime date) {
    try {
      // Ensure user is logged in
      final userId = currentUserId;
      if (userId == null) {
        // Return empty stream if not logged in
        return Stream.value([]);
      }

      // Create start and end date for the given day
      final startDate = DateTime(date.year, date.month, date.day);
      final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);

      return tasksCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .snapshots()
          .handleError((error) {
        // Check if the error is about missing index
        if (error.toString().contains('FAILED_PRECONDITION') &&
            error.toString().contains('requires an index')) {
          _handleMissingIndex(error.toString());
          // Return empty list while index is being created
          return <DocumentSnapshot>[];
        }
        throw error;
      }).map((snapshot) {
        return snapshot.docs
            .map((doc) => TaskModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to get tasks by date: $e');
    }
  }

  // Alternative method that doesn't require index
  Future<List<TaskModel>> getTasksByDateAlternative(DateTime date) async {
    try {
      // Ensure user is logged in
      final userId = currentUserId;
      if (userId == null) {
        return [];
      }

      // Create start and end date for the given day
      final startDate = DateTime(date.year, date.month, date.day);
      final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);

      // First get all user's tasks
      final snapshot =
          await tasksCollection.where('userId', isEqualTo: userId).get();

      // Then filter by date in memory
      return snapshot.docs
          .map((doc) => TaskModel.fromMap(doc.data() as Map<String, dynamic>))
          .where((task) {
        return task.date.isAfter(startDate.subtract(Duration(minutes: 1))) &&
            task.date.isBefore(endDate.add(Duration(minutes: 1)));
      }).toList();
    } catch (e) {
      throw Exception('Failed to get tasks by date: $e');
    }
  }

  void _handleMissingIndex(String errorMessage) {
    // Extract index creation URL from error message
    final RegExp urlRegex =
        RegExp(r'https://console\.firebase\.google\.com[^\s]+');
    final match = urlRegex.firstMatch(errorMessage);

    if (match != null) {
      final indexUrl = match.group(0);

      Get.snackbar(
        'Index Required',
        'This query requires a Firestore index. Would you like to create it?',
        duration: Duration(seconds: 10),
        mainButton: TextButton(
          child: Text('CREATE INDEX', style: TextStyle(color: Colors.white)),
          onPressed: () async {
            if (indexUrl != null && await canLaunchUrl(Uri.parse(indexUrl))) {
              await launchUrl(Uri.parse(indexUrl));
            } else {
              Get.snackbar('Error', 'Could not open browser to create index');
            }
          },
        ),
      );
    }
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(TaskModel task) async {
    try {
      await tasksCollection.doc(task.id).update({
        'isCompleted': !task.isCompleted,
      });
    } catch (e) {
      throw Exception('Failed to toggle task completion: $e');
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    try {
      await tasksCollection.doc(taskId).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
}
