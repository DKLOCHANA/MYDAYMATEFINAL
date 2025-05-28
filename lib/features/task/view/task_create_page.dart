import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../core/utils/devices.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/task_controller.dart';
import '../model/task_model.dart';

class TaskCreatePage extends GetView<TaskController> {
  const TaskCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    DeviceLayout.init(context);

    // More granular screen size detection for better responsiveness
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isMediumScreen = screenSize.width >= 360 && screenSize.width < 600;

    // Calculate dynamic spacing based on screen size
    final verticalSpacing = isSmallScreen
        ? DeviceLayout.spacing(14)
        : (isMediumScreen
            ? DeviceLayout.spacing(16)
            : DeviceLayout.spacing(20));

    return Obx(() => Scaffold(
          appBar: CustomAppbar(
            title: controller.isEditing.value ? 'Edit Task' : 'Add Task',
            showProfileImage: false,
          ),
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.grey.shade50,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(
                        DeviceLayout.spacing(isSmallScreen ? 14 : 16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task Title
                        _buildSectionTitle(
                            context, 'Task Information', isSmallScreen),
                        SizedBox(height: verticalSpacing * 0.5),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(DeviceLayout.spacing(12)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CustomTextfield(
                            controller: controller.titleController,
                            hintText: 'Task Title',
                          ),
                        ),
                        SizedBox(height: verticalSpacing),

                        // Note
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(DeviceLayout.spacing(12)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CustomTextfield(
                            controller: controller.noteController,
                            hintText: 'Note',
                            maxLines: 3,
                          ),
                        ),
                        SizedBox(height: verticalSpacing),

                        _buildSectionTitle(
                            context, 'Date & Time', isSmallScreen),
                        SizedBox(height: verticalSpacing * 0.5),

                        // Date
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(DeviceLayout.spacing(12)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CustomTextfield(
                            controller: controller.dateController,
                            hintText: 'Date',
                            readOnly: true,
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.calendar_month_outlined,
                                color: AppColors.primary,
                              ),
                              onPressed: controller.selectDate,
                            ),
                          ),
                        ),
                        SizedBox(height: verticalSpacing),

                        // Time
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(DeviceLayout.spacing(12)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CustomTextfield(
                            controller: controller.timeController,
                            hintText: 'Time',
                            readOnly: true,
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.access_time_filled_outlined,
                                color: AppColors.primary,
                              ),
                              onPressed: controller.selectTime,
                            ),
                          ),
                        ),
                        SizedBox(height: verticalSpacing),

                        // Reminder section
                        _buildSectionTitle(context, 'Reminder', isSmallScreen),
                        SizedBox(height: verticalSpacing * 0.5),

                        // Fixed Reminder dropdown - removed incorrect Expanded widget
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: DeviceLayout.spacing(16),
                            vertical:
                                DeviceLayout.spacing(isSmallScreen ? 6 : 8),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(DeviceLayout.spacing(12)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Obx(() => DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.primary,
                                    size: DeviceLayout.fontSize(
                                        isSmallScreen ? 24 : 28),
                                  ),
                                  value: controller.selectedRemindMinutes.value,
                                  isExpanded: true,
                                  items:
                                      controller.remindOptions.map((minutes) {
                                    return DropdownMenuItem<int>(
                                      value: minutes,
                                      child: Text(
                                        controller.getRemindText(minutes),
                                        style: TextStyle(
                                          fontSize: DeviceLayout.fontSize(
                                              isSmallScreen ? 14 : 16),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      controller.selectedRemindMinutes.value =
                                          value;
                                    }
                                  },
                                ),
                              )),
                        ),
                        SizedBox(height: verticalSpacing),

                        // Priority section
                        _buildSectionTitle(context, 'Priority', isSmallScreen),
                        SizedBox(height: verticalSpacing * 0.5),

                        // Enhanced Priority Options with segmented buttons style
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: DeviceLayout.spacing(8),
                            vertical:
                                DeviceLayout.spacing(isSmallScreen ? 12 : 16),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(DeviceLayout.spacing(12)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: _buildPrioritySegmentedControl(
                              context, isSmallScreen),
                        ),
                        SizedBox(height: verticalSpacing * 1.5),

                        // Save Button
                        Container(
                          width: double.infinity,
                          height: DeviceLayout.spacing(isSmallScreen ? 52 : 56),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(DeviceLayout.spacing(12)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: DeviceLayout.spacing(10),
                                offset: Offset(0, DeviceLayout.spacing(3)),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: controller.saveTask,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    DeviceLayout.spacing(12)),
                              ),
                            ),
                            child: Obx(() => Text(
                                  controller.isEditing.value
                                      ? 'Update Task'
                                      : 'Save Task',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: DeviceLayout.fontSize(
                                        isSmallScreen ? 14 : 16),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.5),
                                        offset: const Offset(0, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ),
                        SizedBox(height: verticalSpacing),
                      ],
                    ),
                  ),
                ),
              ),

              // Loading Overlay with improved styling
              if (controller.isLoading.value)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(DeviceLayout.spacing(20)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(DeviceLayout.spacing(16)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                          SizedBox(height: DeviceLayout.spacing(16)),
                          Text(
                            controller.isEditing.value
                                ? "Updating task..."
                                : "Saving task...",
                            style: TextStyle(
                              fontSize: DeviceLayout.fontSize(14),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ));
  }

  // New priority selection method using a segmented control style
  Widget _buildPrioritySegmentedControl(
      BuildContext context, bool isSmallScreen) {
    final colors = {
      TaskPriority.low: Colors.green,
      TaskPriority.medium: Colors.blue,
      TaskPriority.high: Colors.red,
    };

    final labels = {
      TaskPriority.low: "Low",
      TaskPriority.medium: "Medium",
      TaskPriority.high: "High",
    };

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DeviceLayout.spacing(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: TaskPriority.values.map((priority) {
          return Expanded(
            child: Obx(() {
              final isSelected = controller.selectedPriority.value == priority;
              return GestureDetector(
                onTap: () => controller.selectedPriority.value = priority,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: DeviceLayout.spacing(isSmallScreen ? 12 : 14),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors[priority]!.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(DeviceLayout.spacing(8)),
                    border: isSelected
                        ? Border(
                            bottom: BorderSide(
                              color: colors[priority]!,
                              width: 2.0,
                            ),
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: DeviceLayout.spacing(4),
                        width: DeviceLayout.spacing(isSmallScreen ? 32 : 42),
                        decoration: BoxDecoration(
                          color: colors[priority],
                          borderRadius:
                              BorderRadius.circular(DeviceLayout.spacing(2)),
                        ),
                      ),
                      SizedBox(height: DeviceLayout.spacing(8)),
                      Text(
                        labels[priority]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              isSelected ? colors[priority] : Colors.grey[600],
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize:
                              DeviceLayout.fontSize(isSmallScreen ? 13 : 14),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        }).toList(),
      ),
    );
  }

  // Helper method to create section titles
  Widget _buildSectionTitle(
      BuildContext context, String title, bool isSmallScreen) {
    return Row(
      children: [
        Container(
          width: DeviceLayout.spacing(3),
          height: DeviceLayout.spacing(isSmallScreen ? 16 : 18),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(DeviceLayout.spacing(1.5)),
          ),
        ),
        SizedBox(width: DeviceLayout.spacing(8)),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: DeviceLayout.fontSize(isSmallScreen ? 15 : 16),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
        ),
      ],
    );
  }
}
