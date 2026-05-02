import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  double _totalBalance = 0;
  double _monthlyIncome = 0;
  double _monthlyExpense = 0;
  final double _budgetLimit = 1550000;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  double get totalBalance => _totalBalance;
  double get monthlyIncome => _monthlyIncome;
  double get monthlyExpense => _monthlyExpense;
  double get budgetLimit => _budgetLimit;
  double get budgetProgress => _budgetLimit > 0 ? _monthlyExpense / _budgetLimit : 0;

  Future<void> loadTransactions(String uid) async {
    _isLoading = true;
    notifyListeners();

    _transactions = await _dbService.getTransactions(uid);
    _calculateStats();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _dbService.insertTransaction(transaction);
    await loadTransactions(transaction.uid);
  }

  Future<void> deleteTransaction(int id, String uid) async {
    await _dbService.deleteTransaction(id);
    await loadTransactions(uid);
  }

  void _calculateStats() {
    _totalBalance = 0;
    _monthlyIncome = 0;
    _monthlyExpense = 0;

    final now = DateTime.now();
    for (var tx in _transactions) {
      if (tx.type == 'income') {
        _totalBalance += tx.amount;
        if (tx.date.month == now.month && tx.date.year == now.year) {
          _monthlyIncome += tx.amount;
        }
      } else {
        _totalBalance -= tx.amount;
        if (tx.date.month == now.month && tx.date.year == now.year) {
          _monthlyExpense += tx.amount;
        }
      }
    }
  }
}
