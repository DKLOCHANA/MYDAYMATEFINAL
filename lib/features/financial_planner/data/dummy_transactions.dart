import 'package:flutter/material.dart';
import '../model/transaction_model.dart';

class DummyTransactions {
  static final List<TransactionModel> transactions = [
    TransactionModel(
      category: 'Salary',
      icon: Icons.account_balance_wallet,
      color: Colors.green,
      amount: 50000.00,
      date: '2024-01-01',
      isExpense: false,
    ),
    TransactionModel(
      category: 'Food',
      icon: Icons.fastfood_rounded,
      color: Colors.orange,
      amount: 1200.00,
      date: '2024-01-02',
    ),
    TransactionModel(
      category: 'Travel',
      icon: Icons.directions_car,
      color: Colors.blue,
      amount: 2500.00,
      date: '2024-01-02',
    ),
    TransactionModel(
      category: 'Medicine',
      icon: Icons.medical_services,
      color: Colors.red,
      amount: 800.00,
      date: '2024-01-03',
    ),
    TransactionModel(
      category: 'Others',
      icon: Icons.more_horiz,
      color: Colors.purple,
      amount: 1500.00,
      date: '2024-01-03',
    ),
  ];

  static double get totalIncome => transactions
      .where((t) => !t.isExpense)
      .fold(0, (sum, item) => sum + item.amount);

  static double get totalExpense => transactions
      .where((t) => t.isExpense)
      .fold(0, (sum, item) => sum + item.amount);

  static double get balance => totalIncome - totalExpense;
}
