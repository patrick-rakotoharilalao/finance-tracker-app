import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/budget.dart';

class BudgetProvider extends ChangeNotifier {
  late Box<Budget> _box;
  List<Budget> _budgets = [];

  List<Budget> get budgets => _budgets;

  Future<void> init() async {
    _box = Hive.box<Budget>('budgets');
    _loadFromBox();
  }

  void _loadFromBox() {
    _budgets = _box.values.toList();
    notifyListeners();
  }

  // Get budget limit for a specific category and month
  double? getLimitFor(String category, int month, int year) {
    try {
      return _budgets
          .firstWhere((b) =>
              b.category == category && b.month == month && b.year == year)
          .limit;
    } catch (_) {
      return null; // no budget set for this category
    }
  }

  // Set or update a budget for a category
  Future<void> setBudget({
    required String category,
    required double limit,
    required int month,
    required int year,
  }) async {
    // Check if a budget already exists for this category/month
    final index = _box.values.toList().indexWhere(
        (b) => b.category == category && b.month == month && b.year == year);

    final budget = Budget(
      category: category,
      limit: limit,
      month: month,
      year: year,
    );

    if (index != -1) {
      await _box.putAt(index, budget); // update existing
    } else {
      await _box.add(budget); // add new
    }
    _loadFromBox();
  }

  // Delete a budget
  Future<void> deleteBudget(Budget budget) async {
    final index = _box.values.toList().indexOf(budget);
    if (index != -1) {
      await _box.deleteAt(index);
      _loadFromBox();
    }
  }
}
