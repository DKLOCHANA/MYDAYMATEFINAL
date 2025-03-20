import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/task_model.dart';
import '../controller/task_controller.dart';

class TaskListController extends GetxController {
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  CollectionReference get tasksCollection => _firestore.collection('tasks');

  // Reactive variables
  final _selectedDate = DateTime.now().obs;
  final _tasksList = <TaskModel>[].obs;
  final isLoading = false.obs;
  final isUserLoggedIn = false.obs;

  // Getters
  DateTime get selectedDate => _selectedDate.value;
  List<TaskModel> get tasksList => _tasksList;
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    checkUserAuth();
    loadTasks();
  }

  void checkUserAuth() {
    isUserLoggedIn.value = _auth.currentUser != null;

    // Listen to auth state changes
    _auth.authStateChanges().listen((user) {
      isUserLoggedIn.value = user != null;
      if (user != null) {
        loadTasks(); // Reload tasks when user logs in
      } else {
        _tasksList.clear(); // Clear tasks when user logs out
      }
    });
  }

  void selectDate(DateTime date) {
    _selectedDate.value = date;
    loadTasks();
  }

  // Firestore operations
  Stream<List<TaskModel>> getTasksByDate(DateTime date) {
    try {
      if (currentUserId == null) {
        return Stream.value([]);
      }

      final startDate = DateTime(date.year, date.month, date.day);
      final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);

      return tasksCollection
          .where('userId', isEqualTo: currentUserId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .snapshots()
          .handleError((error) {
        if (error.toString().contains('FAILED_PRECONDITION') &&
            error.toString().contains('requires an index')) {
          _handleMissingIndex(error.toString());
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

  Future<List<TaskModel>> getTasksByDateAlternative(DateTime date) async {
    try {
      if (currentUserId == null) {
        return [];
      }

      final startDate = DateTime(date.year, date.month, date.day);
      final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final snapshot =
          await tasksCollection.where('userId', isEqualTo: currentUserId).get();

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

  Future<void> toggleTaskCompletion(TaskModel task) async {
    try {
      // Optimistically update UI first
      final index = _tasksList.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        final updatedTask = TaskModel(
          id: task.id,
          title: task.title,
          note: task.note,
          date: task.date,
          time: TimeOfDay(hour: task.hour, minute: task.minute),
          remindMinutes: task.remindMinutes,
          priority: task.priority,
          isCompleted: !task.isCompleted,
          userId: task.userId,
        );

        _tasksList[index] = updatedTask;
        sortTasks();
      }

      // Update in database
      await tasksCollection.doc(task.id).update({
        'isCompleted': !task.isCompleted,
      });
    } catch (e) {
      loadTasks(); // If error, reload tasks
      Get.snackbar('Error', 'Failed to update task: ${e.toString()}');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await tasksCollection.doc(taskId).delete();
      _tasksList.removeWhere((task) => task.id == taskId);
      Get.snackbar(
        'Success',
        'Task deleted successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete task: ${e.toString()}');
    }
  }

  void editTask(TaskModel task) {
    // Create a fresh instance of TaskController each time we edit
    if (Get.isRegistered<TaskController>()) {
      Get.delete<TaskController>();
    }
    final TaskController taskController = Get.put(TaskController());

    // Set up the controller for editing
    taskController.isEditing.value = true;
    taskController.editingTaskId = task.id;
    taskController.populateFields(task);

    // Navigate to edit task page
    Get.toNamed('/add-task');
  }

  // Force refresh method that can be called from outside
  void forceRefresh() {
    loadTasks();
  }

  // Helper methods
  void _handleMissingIndex(String errorMessage) {
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

  Future<void> loadTasks() async {
    if (!isUserLoggedIn.value) {
      _tasksList.clear();
      return;
    }

    try {
      isLoading.value = true;

      try {
        getTasksByDate(_selectedDate.value).listen(
          (tasks) {
            _tasksList.assignAll(tasks);
            sortTasks();
            isLoading.value = false;
          },
          onError: (error) {
            _loadTasksAlternative();
          },
        );
      } catch (e) {
        _loadTasksAlternative();
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load tasks: ${e.toString()}');
    }
  }

  Future<void> _loadTasksAlternative() async {
    try {
      final tasks = await getTasksByDateAlternative(_selectedDate.value);
      _tasksList.assignAll(tasks);
      sortTasks();
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load tasks: ${e.toString()}');
    }
  }

  void sortTasks() {
    _tasksList.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute);
    });
  }

  String getRemindText(int minutes) {
    if (minutes < 60) {
      return '$minutes minutes before';
    } else if (minutes == 60) {
      return '1 hour before';
    } else if (minutes < 1440) {
      return '${minutes ~/ 60} hours before';
    } else {
      return '1 day before';
    }
  }
}
