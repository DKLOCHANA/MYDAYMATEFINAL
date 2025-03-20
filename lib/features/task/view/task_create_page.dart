import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../core/utils/devices.dart';
import '../controller/task_controller.dart';
import '../model/task_model.dart';

class TaskCreatePage extends GetView<TaskController> {
  const TaskCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: CustomAppbar(
            title: controller.isEditing.value ? 'Edit Task' : 'Add Task',
            showProfileImage: false,
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(DeviceLayout.spacing(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextfield(
                      controller: controller.titleController,
                      hintText: 'Task Title',
                    ),
                    SizedBox(height: DeviceLayout.spacing(16)),
                    CustomTextfield(
                      controller: controller.noteController,
                      hintText: 'Note',
                      maxLines: 3,
                    ),
                    SizedBox(height: DeviceLayout.spacing(16)),
                    CustomTextfield(
                      controller: controller.dateController,
                      hintText: 'Date',
                      readOnly: true,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: controller.selectDate,
                      ),
                    ),
                    SizedBox(height: DeviceLayout.spacing(16)),
                    CustomTextfield(
                      controller: controller.timeController,
                      hintText: 'Time',
                      readOnly: true,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: controller.selectTime,
                      ),
                    ),
                    SizedBox(height: DeviceLayout.spacing(16)),
                    Text('Remind me',
                        style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: DeviceLayout.spacing(8)),
                    _buildRemindDropdown(context),
                    SizedBox(height: DeviceLayout.spacing(16)),
                    Text('Priority',
                        style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: DeviceLayout.spacing(16)),
                    _buildPriorityOptions(context),
                    SizedBox(height: DeviceLayout.spacing(24)),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.saveTask,
                        child: Obx(() => Text(controller.isEditing.value
                            ? 'Update Task'
                            : 'Save Task')),
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.isLoading.value)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ));
  }

  Widget _buildPriorityOptions(BuildContext context) {
    final colors = {
      TaskPriority.low: Colors.yellow,
      TaskPriority.medium: Colors.blue,
      TaskPriority.high: Colors.red,
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: TaskPriority.values.map((priority) {
        return Obx(() {
          final isSelected = controller.selectedPriority.value == priority;
          return GestureDetector(
            onTap: () => controller.selectedPriority.value = priority,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? colors[priority] : Colors.transparent,
                    border: Border.all(
                      color: colors[priority]!,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                Text(
                  priority.name.capitalizeFirst!,
                  style: TextStyle(color: colors[priority]),
                ),
              ],
            ),
          );
        });
      }).toList(),
    );
  }

  Widget _buildRemindDropdown(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: DeviceLayout.spacing(16),
        vertical: DeviceLayout.spacing(8),
      ),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Obx(() => DropdownButton<int>(
            value: controller.selectedRemindMinutes.value,
            isExpanded: true,
            underline: const SizedBox(),
            items: controller.remindOptions.map((minutes) {
              return DropdownMenuItem<int>(
                value: minutes,
                child: Text(controller.getRemindText(minutes)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.selectedRemindMinutes.value = value;
              }
            },
          )),
    );
  }
}
