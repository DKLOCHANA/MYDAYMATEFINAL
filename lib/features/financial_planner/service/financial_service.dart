import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../model/transaction_model.dart';

class FinancialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get currentUserId => _auth.currentUser?.uid;
  CollectionReference get transactionsCollection =>
      _firestore.collection('transactions');

  // Get all transactions
  Stream<List<TransactionModel>> getTransactions() {
    if (currentUserId == null) return Stream.value([]);

    try {
      return transactionsCollection
          .where('userId', isEqualTo: currentUserId)
          .orderBy('date', descending: true)
          .snapshots()
          .handleError((error) {
        print('Firestore error: $error');
        // Handle specific Firestore errors here
        if (error.toString().contains('FAILED_PRECONDITION') &&
            error.toString().contains('requires an index')) {
          // Handle missing index error
          _handleMissingIndex(error.toString());
        }
        // Return empty list instead of throwing
        return [];
      }).map((snapshot) {
        return snapshot.docs
            .map((doc) =>
                TransactionModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      print('General error in getTransactions: $e');
      // Return empty stream for any general errors
      return Stream.value([]);
    }
  }

  // Add a helper method to handle missing index
  void _handleMissingIndex(String errorMessage) {
    final RegExp urlRegex =
        RegExp(r'https://console\.firebase\.google\.com[^\s]+');
    final match = urlRegex.firstMatch(errorMessage);

    if (match != null) {
      final indexUrl = match.group(0);
      print('Missing index URL: $indexUrl');

      // Handle UI notification about missing index if needed
    }
  }

  // Create transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await transactionsCollection.doc(transaction.id).set(transaction.toMap());
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await transactionsCollection.doc(transactionId).delete();
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  // Upload receipt image
  Future<String?> uploadReceiptImage(
      File imageFile, String transactionId) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      final ref = _storage
          .ref()
          .child('receipts')
          .child(userId)
          .child('$transactionId.jpg');

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading receipt: $e');
      return null;
    }
  }

  // Get income/expense data for statistics
  Future<Map<String, double>> getCategoryTotals(TransactionType type) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      final snapshot = await transactionsCollection
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type.index)
          .get();

      final transactions = snapshot.docs
          .map((doc) =>
              TransactionModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      final Map<String, double> result = {};

      for (var transaction in transactions) {
        final category = transaction.category;
        result[category] = (result[category] ?? 0) + transaction.amount;
      }

      return result;
    } catch (e) {
      throw Exception('Failed to get category totals: $e');
    }
  }

  // Get total income, expense and balance
  Future<Map<String, double>> getFinancialSummary() async {
    try {
      final userId = currentUserId;
      if (userId == null) return {'income': 0, 'expense': 0, 'balance': 0};

      final snapshot =
          await transactionsCollection.where('userId', isEqualTo: userId).get();

      final transactions = snapshot.docs
          .map((doc) =>
              TransactionModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      double totalIncome = 0;
      double totalExpense = 0;

      for (var transaction in transactions) {
        if (transaction.type == TransactionType.income) {
          totalIncome += transaction.amount;
        } else {
          totalExpense += transaction.amount;
        }
      }

      return {
        'income': totalIncome,
        'expense': totalExpense,
        'balance': totalIncome - totalExpense
      };
    } catch (e) {
      throw Exception('Failed to get financial summary: $e');
    }
  }
}
