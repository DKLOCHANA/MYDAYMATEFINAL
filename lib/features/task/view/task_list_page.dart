import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../core/utils/devices.dart';
import '../controller/task_list_controller.dart';
import '../model/task_model.dart';

class TaskListPage extends GetView<TaskListController> {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize responsive utilities
    DeviceLayout.init(context);

    // Get theme and dimensions
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isTablet = DeviceLayout.isTablet(context);

    // Refresh tasks when page is focused/reopened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadTasks();
    });

    return Scaffold(
      appBar: CustomAppbar(title: 'Task Manager'),
      body: Container(
        // Gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey.shade50,
              Colors.grey.shade100.withOpacity(0.5),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive sizing calculations
              final horizontalPadding = constraints.maxWidth * 0.045;
              final verticalPadding = constraints.maxHeight * 0.01;
              final iconSize = constraints.maxWidth * 0.05;
              final cardRadius = constraints.maxWidth * 0.04;
              final contentSpacing = constraints.maxHeight * 0.01;
              final isSmallScreen = constraints.maxWidth < 360;

              return Column(
                children: [
                  // App bar

                  // Summary card
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding * 2,
                    ),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topRight,
                        radius: 1.8,
                        colors: [
                          primaryColor.withOpacity(0.8),
                          primaryColor,
                          primaryColor.withOpacity(0.7),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(cardRadius),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: constraints.maxWidth * 0.03,
                          offset: Offset(0, constraints.maxHeight * 0.005),
                          spreadRadius: constraints.maxWidth * 0.005,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Header
                        Padding(
                          padding: EdgeInsets.all(constraints.maxWidth * 0.04),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'My Tasks',
                                    style: TextStyle(
                                      fontSize: constraints.maxWidth *
                                          (isSmallScreen ? 0.045 : 0.05),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.1),
                                          offset: const Offset(0, 1),
                                          blurRadius: 3,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: contentSpacing / 2),
                                  Obx(() {
                                    final selectedDate =
                                        controller.selectedDate;
                                    final now = DateTime.now();
                                    String dateText;

                                    if (selectedDate.year == now.year &&
                                        selectedDate.month == now.month &&
                                        selectedDate.day == now.day) {
                                      dateText =
                                          'Today, ${_getMonthName(selectedDate)} ${selectedDate.day}';
                                    } else {
                                      dateText =
                                          '${_getDayName(selectedDate)}, ${_getMonthName(selectedDate)} ${selectedDate.day}';
                                    }

                                    return Text(
                                      dateText,
                                      style: TextStyle(
                                        fontSize: constraints.maxWidth *
                                            (isSmallScreen ? 0.035 : 0.038),
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => _showDatePickerDialog(context),
                                child: Container(
                                  padding: EdgeInsets.all(
                                      constraints.maxWidth * 0.025),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(
                                        cardRadius * 0.75),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.calendar_month,
                                    color: Colors.white,
                                    size: iconSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Date picker
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: constraints.maxHeight * 0.015,
                            horizontal: constraints.maxWidth * 0.02,
                          ),
                          margin: EdgeInsets.only(
                            left: horizontalPadding * 0.8,
                            right: horizontalPadding * 0.8,
                            bottom: verticalPadding * 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius:
                                BorderRadius.circular(cardRadius * 0.75),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          height: constraints.maxHeight * 0.2,
                          child: DatePicker(
                            DateTime.now().subtract(const Duration(days: 2)),
                            initialSelectedDate: controller.selectedDate,
                            selectionColor: Colors.white.withOpacity(0.25),
                            selectedTextColor: Colors.white,
                            deactivatedColor: Colors.white.withOpacity(0.5),
                            daysCount: 14,
                            width: constraints.maxWidth *
                                (isSmallScreen ? 0.15 : 0.16),
                            height: constraints.maxHeight * 0.09,
                            dayTextStyle: TextStyle(
                              fontSize: constraints.maxWidth * 0.03,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                            dateTextStyle: TextStyle(
                              fontSize: constraints.maxWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            monthTextStyle: TextStyle(
                              fontSize: constraints.maxWidth * 0.025,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            onDateChange: controller.selectDate,
                          ),
                        ),

                        // Task statistics
                        Container(
                          margin: EdgeInsets.only(
                            left: horizontalPadding * 0.8,
                            right: horizontalPadding * 0.8,
                            bottom: verticalPadding * 2,
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: constraints.maxHeight * 0.015,
                            horizontal: constraints.maxWidth * 0.05,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius:
                                BorderRadius.circular(cardRadius * 0.75),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Obx(() => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStatItem(
                                    icon: Icons.check_circle_outline,
                                    title: 'Total Tasks',
                                    value: '${controller.tasksList.length}',
                                    constraints: constraints,
                                  ),
                                  _buildStatItem(
                                    icon: Icons.task_alt,
                                    title: 'Completed',
                                    value:
                                        '${controller.tasksList.where((task) => task.isCompleted).length}',
                                    constraints: constraints,
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),

                  // Task List Section Header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding * 2,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: constraints.maxWidth * 0.01,
                          height: constraints.maxHeight * 0.025,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(
                                constraints.maxWidth * 0.005),
                          ),
                        ),
                        SizedBox(width: constraints.maxWidth * 0.02),
                        Text(
                          'Today\'s Tasks',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: DeviceLayout.fontSize(
                                        isSmallScreen ? 16 : 18),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                        ),
                        const Spacer(),
                        Obx(() => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: constraints.maxWidth * 0.025,
                                vertical: constraints.maxHeight * 0.008,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(
                                    constraints.maxWidth * 0.05),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${controller.tasksList.length} tasks',
                                style: TextStyle(
                                  fontSize: constraints.maxWidth * 0.03,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),

                  // Tasks List
                  Expanded(
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(cardRadius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: constraints.maxWidth * 0.025,
                            offset: Offset(0, constraints.maxHeight * 0.003),
                            spreadRadius: constraints.maxWidth * 0.002,
                          ),
                        ],
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (controller.tasksList.isEmpty) {
                          return _buildEmptyState(
                              context, constraints, primaryColor, cardRadius);
                        }

                        return ListView.separated(
                          padding: EdgeInsets.all(constraints.maxWidth * 0.03),
                          itemCount: controller.tasksList.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            indent: constraints.maxWidth * 0.04,
                            endIndent: constraints.maxWidth * 0.04,
                            color: Colors.grey.shade200,
                          ),
                          itemBuilder: (context, index) => _buildTaskItem(
                              context,
                              controller.tasksList[index],
                              constraints,
                              cardRadius),
                        );
                      }),
                    ),
                  ),
                  SizedBox(
                      height: DeviceLayout.spacing(
                          kFloatingActionButtonMargin + 56)),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          final cardRadius = constraints.maxWidth * 0.04;
          return _buildResponsiveFAB(
              context, constraints, primaryColor, cardRadius);
        },
      ),
    );
  }

  // Responsive stat item
  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required BoxConstraints constraints,
  }) {
    final iconSize = constraints.maxWidth * 0.045;
    final circleSize = constraints.maxWidth * 0.1;

    return Row(
      children: [
        Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.15),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: iconSize,
          ),
        ),
        SizedBox(width: constraints.maxWidth * 0.03),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: constraints.maxWidth * 0.032,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: constraints.maxWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Responsive empty state
  Widget _buildEmptyState(BuildContext context, BoxConstraints constraints,
      Color primaryColor, double cardRadius) {
    return Center(
      child: Container(
        width: constraints.maxWidth * 0.8,
        margin: EdgeInsets.symmetric(vertical: constraints.maxHeight * 0.01),
        padding: EdgeInsets.all(constraints.maxWidth * 0.05),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(cardRadius * 0.75),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(constraints.maxWidth * 0.04),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.grey.shade200,
                    Colors.grey.shade100,
                  ],
                  radius: 0.8,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.event_note,
                size: constraints.maxWidth * 0.12,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: constraints.maxHeight * 0.02),
            Text(
              'No tasks for ${_formatSelectedDate(controller.selectedDate)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: constraints.maxWidth * 0.04,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: constraints.maxHeight * 0.01),
          ],
        ),
      ),
    );
  }

  // Responsive floating action button
  // Responsive floating action button
  Widget _buildResponsiveFAB(BuildContext context, BoxConstraints constraints,
      Color primaryColor, double cardRadius) {
    // Calculate responsive dimensions based on screen width
    // Use smaller percentage for width to prevent overflow
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Adjust width based on screen size
    final fabWidth = isSmallScreen
        ? constraints.maxWidth * 0.28
        : constraints.maxWidth * 0.32;

    final fabHeight = constraints.maxWidth * 0.13;
    final fontSize = isSmallScreen
        ? constraints.maxWidth * 0.035
        : constraints.maxWidth * 0.04;

    final iconSize = isSmallScreen
        ? constraints.maxWidth * 0.055
        : constraints.maxWidth * 0.06;

    return Container(
      width: fabWidth,
      height: fabHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(fabHeight / 2), // More rounded
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: constraints.maxWidth * 0.025,
            offset: Offset(0, constraints.maxHeight * 0.005),
            spreadRadius: 0,
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/add-task'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        extendedPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(fabHeight / 2),
        ),
        label: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor.withOpacity(0.9),
                primaryColor,
                primaryColor.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(fabHeight / 2),
          ),
          child: Container(
            width: fabWidth,
            height: fabHeight,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: iconSize,
                  color: Colors.white,
                ),
                SizedBox(width: constraints.maxWidth * 0.01),
                Text(
                  'Add Task',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced task item
  Widget _buildTaskItem(BuildContext context, TaskModel task,
      BoxConstraints constraints, double cardRadius) {
    final colors = {
      TaskPriority.low: Colors.green[300]!,
      TaskPriority.medium: Colors.blue[400]!,
      TaskPriority.high: Colors.red[400]!,
    };

    // Responsive sizing
    final checkboxSize = constraints.maxWidth * 0.1;
    final innerCheckboxSize = constraints.maxWidth * 0.06;
    final textSize = constraints.maxWidth * 0.038;
    final noteSize = constraints.maxWidth * 0.033;
    final pillTextSize = constraints.maxWidth * 0.028;
    final pillIconSize = constraints.maxWidth * 0.03;
    final itemPadding = EdgeInsets.symmetric(
      horizontal: constraints.maxWidth * 0.03,
      vertical: constraints.maxHeight * 0.01,
    );

    return Slidable(
      key: ValueKey(task.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => controller.editTask(task),
            backgroundColor: Colors.blue[600]!,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(cardRadius * 0.75),
              bottomLeft: Radius.circular(cardRadius * 0.75),
            ),
          ),
          SlidableAction(
            onPressed: (_) => controller.deleteTask(task.id),
            backgroundColor: Colors.red[600]!,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(cardRadius * 0.75),
              bottomRight: Radius.circular(cardRadius * 0.75),
            ),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: constraints.maxHeight * 0.005),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(cardRadius * 0.75),
          border: Border.all(
            color: Colors.grey.shade100,
            width: 1,
          ),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              colors[task.priority]!.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(cardRadius * 0.75),
          child: InkWell(
            borderRadius: BorderRadius.circular(cardRadius * 0.75),
            onTap: () => controller.editTask(task),
            child: Padding(
              padding: itemPadding,
              child: Row(
                children: [
                  // Checkbox
                  GestureDetector(
                    onTap: () => controller.toggleTaskCompletion(task),
                    child: Container(
                      width: checkboxSize,
                      height: checkboxSize,
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? colors[task.priority]!.withOpacity(0.15)
                            : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors[task.priority]!.withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors[task.priority]!.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          width: innerCheckboxSize,
                          height: innerCheckboxSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: task.isCompleted
                                ? colors[task.priority]!
                                : Colors.transparent,
                            border: Border.all(
                              color: colors[task.priority]!,
                              width: 2,
                            ),
                            boxShadow: task.isCompleted
                                ? [
                                    BoxShadow(
                                      color: colors[task.priority]!
                                          .withOpacity(0.3),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                          ),
                          child: task.isCompleted
                              ? Icon(
                                  Icons.check,
                                  size: pillIconSize * 1.2,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: constraints.maxWidth * 0.03),

                  // Task details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // style: TextStyle(
                          //             fontSize: constraints.maxWidth *
                          //                 (isSmallScreen ? 0.045 : 0.05),
                          //             fontWeight: FontWeight.bold,
                          //             color: Colors.white,
                          //             letterSpacing: 0.5,
                          //             shadows: [
                          //               Shadow(
                          //                 color: Colors.black.withOpacity(0.1),
                          //                 offset: const Offset(0, 1),
                          //                 blurRadius: 3,
                          //               ),
                          //             ],
                          //           ),
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: textSize,
                            letterSpacing: 0.2,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isCompleted
                                ? Colors.grey[600]
                                : const Color.fromARGB(255, 104, 104, 104),
                          ),
                        ),
                        if (task.note.isNotEmpty) ...[
                          SizedBox(height: constraints.maxHeight * 0.005),
                          Text(
                            task.note,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: noteSize,
                              color: task.isCompleted
                                  ? Colors.grey[500]
                                  : Colors.grey[700],
                              height: 1.3,
                            ),
                          ),
                        ],
                        SizedBox(height: constraints.maxHeight * 0.008),

                        // Pills
                        Wrap(
                          spacing: constraints.maxWidth * 0.015,
                          runSpacing: constraints.maxHeight * 0.006,
                          children: [
                            // Time pill
                            Container(
                              margin: EdgeInsets.only(
                                  bottom: constraints.maxHeight * 0.004),
                              padding: EdgeInsets.symmetric(
                                horizontal: constraints.maxWidth * 0.02,
                                vertical: constraints.maxHeight * 0.005,
                              ),
                              decoration: BoxDecoration(
                                color: colors[task.priority]!.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    constraints.maxWidth * 0.025),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: pillIconSize,
                                    color: colors[task.priority],
                                  ),
                                  SizedBox(width: constraints.maxWidth * 0.01),
                                  Text(
                                    '${task.hour.toString().padLeft(2, '0')}:${task.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: pillTextSize,
                                      fontWeight: FontWeight.w600,
                                      color: task.isCompleted
                                          ? Colors.grey
                                          : colors[task.priority],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Reminder pill
                            if (task.remindMinutes > 0)
                              Container(
                                margin: EdgeInsets.only(
                                    bottom: constraints.maxHeight * 0.004),
                                padding: EdgeInsets.symmetric(
                                  horizontal: constraints.maxWidth * 0.02,
                                  vertical: constraints.maxHeight * 0.005,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(
                                      constraints.maxWidth * 0.025),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.notifications_none,
                                      size: pillIconSize,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(
                                        width: constraints.maxWidth * 0.01),
                                    Text(
                                      controller
                                          .getRemindText(task.remindMinutes),
                                      style: TextStyle(
                                        fontSize: pillTextSize,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Priority pill
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for date formatting
  String _getDayName(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _getMonthName(DateTime date) {
    switch (date.month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  String _formatSelectedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (selectedDate.isAtSameMomentAs(today)) {
      return 'today';
    } else if (selectedDate.isAtSameMomentAs(tomorrow)) {
      return 'tomorrow';
    } else if (selectedDate.isBefore(today)) {
      return _getMonthName(date) + ' ' + date.day.toString();
    } else {
      return _getDayName(date) +
          ', ' +
          _getMonthName(date) +
          ' ' +
          date.day.toString();
    }
  }

  void _showDatePickerDialog(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.selectDate(picked);
    }
  }
}
