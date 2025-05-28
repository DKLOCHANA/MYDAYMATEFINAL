import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mydaymate/core/routes/app_routes.dart';
import 'package:mydaymate/core/theme/app_colors.dart';
import 'package:mydaymate/core/theme/app_text_styles.dart';
import 'package:mydaymate/core/utils/devices.dart';
import 'package:mydaymate/features/task/controller/task_list_controller.dart';
import 'package:mydaymate/features/task/model/task_model.dart';
import 'package:mydaymate/widgets/ai_button.dart';
import 'package:mydaymate/widgets/animated_gradient.dart';
import 'package:mydaymate/widgets/home_card.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the TaskListController if not already initialized
    if (!Get.isRegistered<TaskListController>()) {
      Get.put(TaskListController());
    }

    // Get the controller instance
    final TaskListController taskController = Get.find<TaskListController>();

    // Calculate responsive values based on screen size
    final screenSize = MediaQuery.of(context).size;
    final topSectionHeight = screenSize.height * 0.31; // 35% of screen height
    final horizontalPadding = screenSize.width * 0.05; // 5% of screen width
    final bottomPadding = screenSize.height * 0.02; // 2% of screen height
    final topPadding =
        DeviceLayout.safeTopPadding(context) + (screenSize.height * 0.02);

    return Scaffold(
      body: SafeArea(
        top: false, // Extend behind status bar for gradient effect
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top gradient section with flexible height
              AnimatedGradient(
                minHeight: topSectionHeight,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(screenSize.width * 0.08),
                  bottomRight: Radius.circular(screenSize.width * 0.08),
                ),
                boxShadow: BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  spreadRadius: screenSize.width * 0.005,
                  blurRadius: screenSize.width * 0.03,
                  offset: Offset(0, screenSize.height * 0.008),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: topPadding,
                    left: horizontalPadding,
                    right: horizontalPadding,
                    bottom: bottomPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App title and profile image
                      Row(
                        children: [
                          Text(
                            "MyDayMate",
                            style:
                                AppTextStyles.headlineMedium(context).copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                          const Spacer(),
                          _buildProfileAvatar(context),
                        ],
                      ),

                      // Responsive spacing
                      SizedBox(height: screenSize.height * 0.01),

                      // Greeting with username
                      Obx(
                        () {
                          // Get current time and determine appropriate greeting
                          final hour = DateTime.now().hour;
                          String greeting;

                          if (hour < 12) {
                            greeting = "Good Morning";
                          } else if (hour < 17) {
                            greeting = "Good Afternoon";
                          } else {
                            greeting = "Good Evening";
                          }

                          return Text(
                            "$greeting, ${controller.username.value}!",
                            style: AppTextStyles.bodyLarge(context).copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.white.withOpacity(0.8),
                            ),
                          );
                        },
                      ),

                      // Adaptive spacing based on screen height
                      SizedBox(height: screenSize.height * 0.025),

                      // Today's plan section
                      Text(
                        "Today's Plan",
                        style: AppTextStyles.bodySmall(context).copyWith(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white.withOpacity(0.8),
                        ),
                      ),

                      // Smaller spacing for compact layout
                      SizedBox(height: screenSize.height * 0.01),

                      // Task display with constrained height
                      Row(
                        children: [
                          TaskDisplayWidget(
                            taskController: taskController,
                            maxHeight: screenSize.height * 0.1,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Responsive spacing between sections
              SizedBox(height: screenSize.height * 0.02),

              // Bottom section with cards
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: [
                    // Chatbot assistance card
                    _buildChatbotCard(context),

                    // Adaptive spacing
                    SizedBox(height: screenSize.height * 0.02),

                    // Feature cards grid
                    _buildFeatureCardsGrid(context),

                    // Bottom padding
                    SizedBox(height: screenSize.height * 0.02),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 0,
                    ),
                    child: FloatingActionButton(
                      onPressed: () async {
                        // Send emergency SMS
                        final Uri smsUri =
                            Uri.parse('sms:0711710593?body=Im%20in%20DANGER');
                        try {
                          if (!await launchUrl(smsUri)) {
                            // Fallback to call if SMS fails
                            final Uri callUri = Uri.parse('tel:0711710593');
                            if (!await launchUrl(callUri)) {
                              throw Exception(
                                  'Could not launch emergency services');
                            }
                          }
                        } catch (e) {
                          Get.snackbar(
                            'Error',
                            'Could not send emergency message: $e',
                            backgroundColor: AppColors.error.withOpacity(0.8),
                            colorText: Colors.white,
                          );
                        }
                      },
                      child: const Icon(Icons.emergency, color: Colors.white),
                      backgroundColor: AppColors.error,
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenSize.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  // Profile avatar with responsive sizing
  Widget _buildProfileAvatar(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final avatarRadius = screenSize.width * 0.06; // 6% of screen width

    return Hero(
      tag: 'profileImage',
      child: Obx(() => GestureDetector(
            onTap: () => Get.toNamed('/profile'),
            child: CircleAvatar(
              radius: avatarRadius,
              backgroundColor: Colors.white,
              backgroundImage: controller.profileImagePath.value.isNotEmpty
                  ? FileImage(File(controller.profileImagePath.value))
                  : const AssetImage('assets/images/home/profile.png')
                      as ImageProvider,
            ),
          )),
    );
  }

  // Chatbot assistance card with responsive design
  Widget _buildChatbotCard(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final verticalPadding = screenSize.height * 0.015; // 1.5% of screen height
    final horizontalPadding = screenSize.width * 0.04; // 4% of screen width
    final imageSize = screenSize.width * 0.06; // 6% of screen width

    return PulsingChatBotButton(
        verticalPadding: verticalPadding,
        horizontalPadding: horizontalPadding,
        imageSize: imageSize,
        screenSize: screenSize);
  }

  // Feature cards grid with responsive layout
  Widget _buildFeatureCardsGrid(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Determine grid properties based on screen size
    final int crossAxisCount =
        screenSize.width < 600 ? 2 : (screenSize.width < 900 ? 3 : 4);
    final double childAspectRatio =
        screenSize.width < 360 ? 0.85 : (screenSize.width < 600 ? 0.9 : 1.2);

    final double spacing = screenSize.width * 0.03; // 3% of screen width

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
      children: [
        // Task Manager Card
        HomeCardContainer(
          title: 'Task Manager',
          subtitle: 'Organize your tasks',
          backgroundImage: 'assets/images/home/f5.png',
          onTap: () => Get.toNamed(AppRoutes.taskList),
        ),

        // Meal Planner Card
        HomeCardContainer(
          title: 'Meal Planner',
          subtitle: 'Plan your diet',
          backgroundImage: 'assets/images/home/f2.png',
          onTap: () => Get.toNamed(AppRoutes.recipe),
        ),

        // Finance Tracker Card
        HomeCardContainer(
          title: 'Finance Tracker',
          subtitle: 'Manage expenses',
          backgroundImage: 'assets/images/home/f1.png',
          onTap: () => Get.toNamed(AppRoutes.financial),
        ),

        // Smart Assistant Card
        HomeCardContainer(
          title: 'Grocery Planner',
          subtitle: 'List It. Buy It.',
          backgroundImage: 'assets/images/home/f3.png',
          onTap: () => Get.toNamed(AppRoutes.grocery),
        ),
      ],
    );
    floatingActionButton:
    FloatingActionButton(
      onPressed: () {
        // Navigate to the add task page
        Get.toNamed(AppRoutes.addTask);
      },
      child: const Icon(Icons.add),
      backgroundColor: AppColors.primary,
    );
  }
}

class TaskDisplayWidget extends StatelessWidget {
  final TaskListController taskController;
  final double? maxHeight;

  const TaskDisplayWidget(
      {required this.taskController, this.maxHeight, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create controllers with GetX
    final taskRotationController = Get.put(TaskRotationController());

    // Initialize the task loading if needed
    if (taskController.tasksList.isEmpty) {
      taskController.loadTasks();
    }

    // Get screen dimensions for responsive sizing
    final screenSize = MediaQuery.of(context).size;

    // Observe changes to the task list
    return Obx(() {
      final todayTasks = _getTodayTasks(taskController);
      final incompleteTasks = _getIncompleteTasks(todayTasks);

      // Update the rotation controller with the current tasks
      taskRotationController.updateTasks(incompleteTasks);

      // Create a container with constrained height for the task display
      return Expanded(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: maxHeight ?? double.infinity,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (todayTasks.isEmpty)
                  _buildNoTasksMessage(context)
                else if (incompleteTasks.isEmpty)
                  _buildAllCompletedMessage(context, todayTasks.length)
                else
                  _buildTaskDisplay(
                      context, taskRotationController, incompleteTasks),
              ],
            ),
          ),
        ),
      );
    });
  }

  List<TaskModel> _getTodayTasks(TaskListController controller) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return controller.tasksList.where((task) {
      // Handle different date types (DateTime or String)
      if (task.date is DateTime) {
        final taskDate = task.date as DateTime;
        return taskDate.year == today.year &&
            taskDate.month == today.month &&
            taskDate.day == today.day;
      } else if (task.date is String) {
        try {
          final taskDate = DateTime.parse(task.date as String);
          return taskDate.year == today.year &&
              taskDate.month == today.month &&
              taskDate.day == today.day;
        } catch (e) {
          return false;
        }
      }
      return false;
    }).toList();
  }

  List<TaskModel> _getIncompleteTasks(List<TaskModel> tasks) {
    return tasks.where((task) => !task.isCompleted).toList()
      ..sort((a, b) {
        if (a.hour != b.hour) return a.hour - b.hour;
        return a.minute - b.minute;
      });
  }

  Widget _buildNoTasksMessage(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "No tasks for today",
          style: AppTextStyles.bodyMedium(context),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.addTask),
          child: Text(
            "Tap to add a new task",
            style:
                AppTextStyles.bodySmall(context).copyWith(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildAllCompletedMessage(BuildContext context, int taskCount) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle,
                size: screenSize.width * 0.04, color: Colors.green),
            SizedBox(width: screenSize.width * 0.02),
            Text(
              "All tasks completed!",
              style: AppTextStyles.bodyMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        Text(
          "Great job, you've completed $taskCount task${taskCount > 1 ? 's' : ''}",
          style: AppTextStyles.bodySmall(context).copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTaskDisplay(BuildContext context,
      TaskRotationController rotationController, List<TaskModel> tasks) {
    final screenSize = MediaQuery.of(context).size;

    return Obx(() {
      final currentIndex = rotationController.currentIndex.value;
      if (currentIndex >= tasks.length) return SizedBox();

      final task = tasks[currentIndex];
      final time =
          '${task.hour.toString().padLeft(2, '0')}:${task.minute.toString().padLeft(2, '0')}';

      // Task priority colors
      final colors = {
        TaskPriority.low: Colors.yellow,
        TaskPriority.medium: Colors.blue,
        TaskPriority.high: Colors.red,
      };

      return AnimatedOpacity(
        opacity: rotationController.opacity.value,
        duration: const Duration(milliseconds: 300),
        child: Row(
          children: [
            // Priority color indicator dot
            Container(
              width: screenSize.width * 0.025,
              height: screenSize.width * 0.025,
              decoration: BoxDecoration(
                color: colors[task.priority] ?? Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: screenSize.width * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: AppTextStyles.bodyLarge(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: screenSize.width * 0.02),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.015,
                            vertical: screenSize.height * 0.003),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(screenSize.width * 0.01),
                        ),
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: screenSize.width * 0.03,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (task.note.isNotEmpty)
                    Text(
                      task.note,
                      style: AppTextStyles.bodySmall(context)
                          .copyWith(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (tasks.length > 1)
                    Padding(
                      padding: EdgeInsets.only(top: screenSize.height * 0.006),
                      child: Row(
                        children: List.generate(tasks.length, (index) {
                          return Container(
                            width: screenSize.width * 0.015,
                            height: screenSize.width * 0.015,
                            margin: EdgeInsets.symmetric(
                                horizontal: screenSize.width * 0.005),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == currentIndex
                                  ? Colors.black54
                                  : Colors.black12,
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class TaskRotationController extends GetxController {
  var currentIndex = 0.obs;
  var opacity = 1.0.obs;
  List<TaskModel> tasks = [];

  @override
  void onInit() {
    super.onInit();
    // Start rotation timer
    _startRotation();
  }

  void updateTasks(List<TaskModel> newTasks) {
    tasks = newTasks;
    if (currentIndex.value >= tasks.length && tasks.isNotEmpty) {
      currentIndex.value = 0;
    }
  }

  void _startRotation() {
    // Run every 3 seconds
    ever(opacity, (_) {}); // Dummy to keep reactive

    // Rotate tasks every 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      _rotateTask();
      _startRotation();
    });
  }

  void _rotateTask() {
    if (tasks.isEmpty) return;

    // Fade out
    opacity.value = 0.0;

    Future.delayed(Duration(milliseconds: 300), () {
      // Change index
      currentIndex.value = (currentIndex.value + 1) % tasks.length;

      // Fade in
      opacity.value = 1.0;
    });
  }
}
