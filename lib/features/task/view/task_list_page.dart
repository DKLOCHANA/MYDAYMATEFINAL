import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
// Add this import
import '../../../widgets/custom_appbar.dart';
import '../../../core/utils/devices.dart';
import '../controller/task_list_controller.dart';
import '../model/task_model.dart';

class TaskListPage extends GetView<TaskListController> {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Refresh tasks when page is focused/reopened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadTasks();
    });

    return Scaffold(
      appBar: const CustomAppbar(title: 'Tasks'),
      body: Column(
        children: [
          _buildDatePicker(context),

          // Todo List Title
          Padding(
            padding: EdgeInsets.all(DeviceLayout.spacing(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Today\'s Tasks',
                    style: Theme.of(context).textTheme.titleLarge),
                Obx(() => Text(
                      '${controller.tasksList.length} Tasks',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )),
              ],
            ),
          ),

          // Tasks List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.tasksList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_note, size: 64, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'No tasks for ${_formatSelectedDate(controller.selectedDate)}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(DeviceLayout.spacing(16)),
                itemCount: controller.tasksList.length,
                itemBuilder: (context, index) =>
                    _buildTaskItem(context, controller.tasksList[index]),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add-task'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: DeviceLayout.spacing(16), vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Tasks',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Obx(() {
                      final selectedDate = controller.selectedDate;
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
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      );
                    }),
                  ],
                ),
                IconButton(
                  onPressed: () => _showDatePickerDialog(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.calendar_month,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: DeviceLayout.getProportionateScreenHeight(110),
            child: DatePicker(
              DateTime.now().subtract(const Duration(days: 2)),
              initialSelectedDate: controller.selectedDate,
              selectionColor: Theme.of(context).primaryColor,
              selectedTextColor: Colors.white,
              deactivatedColor: Colors.grey,
              daysCount: 14,
              width: DeviceLayout.getProportionateScreenWidth(60),
              height: DeviceLayout.getProportionateScreenHeight(80),
              dayTextStyle: TextStyle(
                fontSize: DeviceLayout.fontSize(12),
                color: Colors.grey,
              ),
              dateTextStyle: TextStyle(
                fontSize: DeviceLayout.fontSize(20),
                fontWeight: FontWeight.bold,
              ),
              monthTextStyle: TextStyle(
                fontSize: DeviceLayout.fontSize(10),
                color: Colors.grey[700],
              ),
              onDateChange: controller.selectDate,
            ),
          ),
        ],
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

  Widget _buildTaskItem(BuildContext context, TaskModel task) {
    final colors = {
      TaskPriority.low: Colors.yellow,
      TaskPriority.medium: Colors.blue,
      TaskPriority.high: Colors.red,
    };

    return Slidable(
      key: ValueKey(task.id), // Add key for uniqueness
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          // Edit action
          SlidableAction(
            onPressed: (_) => controller.editTask(task),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
          ),
          // Delete action
          SlidableAction(
            onPressed: (_) => controller.deleteTask(task.id),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: DeviceLayout.spacing(8)),
        decoration: BoxDecoration(
          color: colors[task.priority]?.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: colors[task.priority] ?? Colors.grey,
            width: 1,
          ),
        ),
        child: ListTile(
          leading: InkWell(
            onTap: () => controller.toggleTaskCompletion(task),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isCompleted
                    ? colors[task.priority]
                    : Colors.transparent,
                border: Border.all(
                  color: colors[task.priority]!,
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted ? Colors.grey : Colors.black,
            ),
          ),
          subtitle: Text(
            task.note,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted ? Colors.grey : Colors.black54,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${task.hour.toString().padLeft(2, '0')}:${task.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: task.isCompleted ? Colors.grey : colors[task.priority],
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                controller.getRemindText(task.remindMinutes),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
