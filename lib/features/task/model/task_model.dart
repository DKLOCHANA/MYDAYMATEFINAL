import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high }

class TaskModel {
  final String id;
  final String title;
  final String note;
  final DateTime date;
  final int hour;
  final int minute;
  final int remindMinutes;
  final TaskPriority priority;
  final bool isCompleted;
  final String userId;

  TaskModel({
    String? id,
    required this.title,
    required this.note,
    required this.date,
    required TimeOfDay time,
    required this.remindMinutes,
    required this.priority,
    this.isCompleted = false,
    required this.userId,
  })  : hour = time.hour,
        minute = time.minute,
        id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'date': Timestamp.fromDate(date),
      'hour': hour,
      'minute': minute,
      'remindMinutes': remindMinutes,
      'priority': priority.index,
      'isCompleted': isCompleted,
      'userId': userId,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    final timestamp = map['date'] as Timestamp;
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      note: map['note'] as String,
      date: timestamp.toDate(),
      time: TimeOfDay(
        hour: map['hour'] as int,
        minute: map['minute'] as int,
      ),
      remindMinutes: map['remindMinutes'] as int,
      priority: TaskPriority.values[map['priority'] as int],
      isCompleted: map['isCompleted'] as bool,
      userId: map['userId'] as String,
    );
  }
}
