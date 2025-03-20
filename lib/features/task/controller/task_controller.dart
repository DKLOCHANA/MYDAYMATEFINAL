import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mydaymate/features/task/controller/task_list_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/task_model.dart';

class TaskController extends GetxController {
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  CollectionReference get tasksCollection => _firestore.collection('tasks');

  // Form controllers
  final titleController = TextEditingController();
  final noteController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  // Reactive variables
  final isLoading = false.obs;
  final selectedDate = Rx<DateTime?>(null);
  final selectedTime = Rx<TimeOfDay?>(null);
  final selectedPriority = Rx<TaskPriority>(TaskPriority.low);
  final remindOptions = [5, 10, 15, 30, 60, 120, 1440];
  final selectedRemindMinutes = Rx<int>(10);
  final isEditing = false.obs;
  String? editingTaskId;

  // Auth and user related
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    checkUserAuth();

    // Check if we're editing a task
    if (Get.arguments != null && Get.arguments['isEditing'] == true) {
      isEditing.value = true;
      editingTaskId = Get.arguments['taskId'];

      // Get the task from the injected instance
      try {
        final task = Get.find<TaskModel>(tag: 'edit_task');
        populateFields(task);
      } catch (e) {
        print('Error getting task for editing: $e');
      }
    }
  }

  void checkUserAuth() {
    if (_auth.currentUser == null) {
      Get.snackbar(
        'Authentication Required',
        'Please login to manage tasks',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          child: const Text('LOGIN', style: TextStyle(color: Colors.white)),
          onPressed: () => Get.toNamed('/login'),
        ),
      );
    }
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

  void selectDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      selectedDate.value = picked;
      dateController.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  void selectTime() async {
    final picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      selectedTime.value = picked;
      timeController.text = picked.format(Get.context!);
    }
  }

  // Firebase operations
  Future<void> createTask(TaskModel task) async {
    try {
      if (task.userId.isEmpty) {
        throw Exception('User ID is missing');
      }
      await tasksCollection.doc(task.id).set(task.toMap());
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  Future<void> saveTask() async {
    if (!validateTask()) return;

    if (currentUserId == null) {
      Get.snackbar('Error', 'You must be logged in to create tasks',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      final task = TaskModel(
        id: isEditing.value ? editingTaskId : null,
        title: titleController.text,
        note: noteController.text,
        date: selectedDate.value!,
        time: selectedTime.value!,
        remindMinutes: selectedRemindMinutes.value,
        priority: selectedPriority.value,
        userId: currentUserId!,
      );

      if (isEditing.value) {
        await updateTask(task);
      } else {
        await createTask(task);
      }

      clearForm();

      // Notify TaskListController to refresh
      if (Get.isRegistered<TaskListController>()) {
        final taskListController = Get.find<TaskListController>();
        taskListController.loadTasks();
      }

      Get.back();
      Get.snackbar(
        'Success',
        isEditing.value
            ? 'Task updated successfully'
            : 'Task created successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to save task: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await tasksCollection.doc(task.id).update(task.toMap());
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  void clearForm() {
    titleController.clear();
    noteController.clear();
    dateController.clear();
    timeController.clear();
    selectedDate.value = null;
    selectedTime.value = null;
    selectedPriority.value = TaskPriority.low;
    selectedRemindMinutes.value = 10;
  }

  bool validateTask() {
    if (titleController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a title');
      return false;
    }
    if (selectedDate.value == null) {
      Get.snackbar('Error', 'Please select a date');
      return false;
    }
    if (selectedTime.value == null) {
      Get.snackbar('Error', 'Please select a time');
      return false;
    }
    return true;
  }

  void populateFields(TaskModel task) {
    titleController.text = task.title;
    noteController.text = task.note;
    selectedDate.value = task.date;
    dateController.text =
        "${task.date.day}/${task.date.month}/${task.date.year}";
    selectedTime.value = task.timeOfDay;
    timeController.text =
        "${task.hour.toString().padLeft(2, '0')}:${task.minute.toString().padLeft(2, '0')}";
    selectedRemindMinutes.value = task.remindMinutes;
    selectedPriority.value = task.priority;
  }

  @override
  void dispose() {
    titleController.dispose();
    noteController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }
}
