import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String category;
  final IconData icon;
  final Color color;
  final double amount;
  final DateTime date;
  final String note;
  final TransactionType type;
  final String userId;
  final String? receiptURL;

  TransactionModel({
    String? id,
    required this.category,
    required this.icon,
    required this.color,
    required this.amount,
    required this.date,
    this.note = '',
    required this.type,
    required this.userId,
    this.receiptURL,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  bool get isExpense => type == TransactionType.expense;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'colorValue': color.value,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'note': note,
      'type': type.index,
      'userId': userId,
      'receiptURL': receiptURL,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    final timestamp = map['date'] as Timestamp;
    return TransactionModel(
      id: map['id'] as String,
      category: map['category'] as String,
      icon: IconData(
        map['iconCodePoint'] as int,
        fontFamily: map['iconFontFamily'] as String?,
      ),
      color: Color(map['colorValue'] as int),
      amount: (map['amount'] as num).toDouble(),
      date: timestamp.toDate(),
      note: map['note'] as String? ?? '',
      type: TransactionType.values[map['type'] as int],
      userId: map['userId'] as String,
      receiptURL: map['receiptURL'] as String?,
    );
  }
}
