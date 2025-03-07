import 'package:flutter/material.dart';

class TransactionModel {
  final String category;
  final IconData icon;
  final Color color;
  final double amount;
  final String date;
  final bool isExpense;

  TransactionModel({
    required this.category,
    required this.icon,
    required this.color,
    required this.amount,
    required this.date,
    this.isExpense = true,
  });
}
