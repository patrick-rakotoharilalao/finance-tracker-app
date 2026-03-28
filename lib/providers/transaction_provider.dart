import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class TransactionProvider extends ChangeNotifier {
  // ↑ ChangeNotifier is the base class for all providers.
  //   It gives us the notifyListeners() method.

  // Reference to the Hive box — our local database
  late Box<Transaction> _box;

  // Internal list of transactions loaded from Hive
  List<Transaction> _transactions = [];

  // Public getter — widgets read this, cannot modify directly
  List<Transaction> get transactions => _transactions;

  // ─── INITIALIZATION ───────────────────────────────────────

  // Called once when the provider is created
  Future<void> init() async {
    _box = Hive.box<Transaction>('transactions');
    _loadFromBox();
  }

  // Loads all transactions from Hive into memory
  void _loadFromBox() {
    _transactions = _box.values.toList();
    // Sort by date — most recent first
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
    // ↑ Tells every widget listening to rebuild itself
  }

  // ─── COMPUTED VALUES ──────────────────────────────────────

  // Total balance (all incomes minus all expenses)
  double get totalBalance {
    double income  = _transactions
        .where((t) => t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
    double expense = _transactions
        .where((t) => t.isExpense)
        .fold(0, (sum, t) => sum + t.amount);
    return income - expense;
  }

  // Total income for the current month
  double get monthlyIncome {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.isIncome &&
            t.date.month == now.month &&
            t.date.year  == now.year)
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Total expenses for the current month
  double get monthlyExpenses {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.isExpense &&
            t.date.month == now.month &&
            t.date.year  == now.year)
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Transactions filtered by month and year
  List<Transaction> getByMonth(int month, int year) {
    return _transactions
        .where((t) => t.date.month == month && t.date.year == year)
        .toList();
  }

  // Total expenses grouped by category for a given month
  Map<String, double> expensesByCategory(int month, int year) {
    final monthly = getByMonth(month, year)
        .where((t) => t.isExpense);

    final Map<String, double> result = {};
    for (final t in monthly) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }

  // ─── CRUD OPERATIONS ──────────────────────────────────────

  // Add a new transaction
  Future<void> addTransaction({
    required double amount,
    required String type,
    required String category,
    String? note,
    bool aiCategorized = false,
  }) async {
    final transaction = Transaction(
      id:             const Uuid().v4(), // generates a unique id
      amount:         amount,
      type:           type,
      category:       category,
      date:           DateTime.now(),
      note:           note,
      aiCategorized:  aiCategorized,
    );

    await _box.add(transaction);
    _loadFromBox(); // reload and notify
  }

  // Update an existing transaction
  Future<void> updateTransaction(
    Transaction old,
    Transaction updated,
  ) async {
    final index = _box.values.toList().indexOf(old);
    if (index != -1) {
      await _box.putAt(index, updated);
      _loadFromBox();
    }
  }

  // Delete a transaction
  Future<void> deleteTransaction(Transaction transaction) async {
    final index = _box.values.toList().indexOf(transaction);
    if (index != -1) {
      await _box.deleteAt(index);
      _loadFromBox();
    }
  }
}