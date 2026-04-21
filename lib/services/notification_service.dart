import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/budget.dart';
import '../models/category.dart';
import '../models/transaction.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'smart_reminders',
    'Smart reminders',
    description: 'Context-aware finance reminders',
    importance: Importance.high,
  );

  static const _androidDetails = AndroidNotificationDetails(
    'smart_reminders',
    'Smart reminders',
    channelDescription: 'Context-aware finance reminders',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const _details = NotificationDetails(android: _androidDetails);

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    _initialized = true;
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> refreshSmartReminders({
    required List<Transaction> transactions,
    required List<Budget> budgets,
  }) async {
    await init();

    final now = DateTime.now();
    final currentMonthTransactions = transactions
        .where((tx) => tx.date.month == now.month && tx.date.year == now.year)
        .toList();
    final currentMonthBudgets = budgets
        .where((budget) => budget.month == now.month && budget.year == now.year)
        .toList();

    await _maybeSendMissingActivityReminder(
      now: now,
      transactions: currentMonthTransactions,
    );
    await _maybeSendBudgetReminders(
      now: now,
      transactions: currentMonthTransactions,
      budgets: currentMonthBudgets,
    );
    await _maybeSendLateSalaryReminder(
      now: now,
      transactions: currentMonthTransactions,
    );
  }

  Future<void> _maybeSendMissingActivityReminder({
    required DateTime now,
    required List<Transaction> transactions,
  }) async {
    if (transactions.isNotEmpty || now.day < 3) return;

    await _showOncePerWindow(
      key: 'missing_activity_${now.year}_${now.month}',
      window: _ReminderWindow.monthly,
      id: 1001,
      title: 'Log your first transaction',
      body: 'A quick update today helps keep your monthly stats accurate.',
    );
  }

  Future<void> _maybeSendBudgetReminders({
    required DateTime now,
    required List<Transaction> transactions,
    required List<Budget> budgets,
  }) async {
    final expenseByCategory = <String, double>{};
    for (final transaction in transactions.where((tx) => tx.isExpense)) {
      expenseByCategory.update(
        transaction.category,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    for (final budget in budgets) {
      if (budget.limit <= 0) continue;

      final spent = expenseByCategory[budget.category] ?? 0;
      final ratio = spent / budget.limit;
      final categoryName =
          CategoryExtension.fromString(budget.category).label.toLowerCase();

      if (ratio >= 1) {
        await _showOncePerWindow(
          key: 'budget_exceeded_${budget.category}_${now.year}_${now.month}',
          window: _ReminderWindow.monthly,
          id: _stableId('budget_exceeded_${budget.category}'),
          title: 'Budget exceeded',
          body:
              'Your $categoryName budget is over the limit. Review recent expenses.',
        );
        continue;
      }

      if (ratio >= 0.8) {
        await _showOncePerWindow(
          key: 'budget_warning_${budget.category}_${now.year}_${now.month}',
          window: _ReminderWindow.monthly,
          id: _stableId('budget_warning_${budget.category}'),
          title: 'Budget almost reached',
          body:
              'You have used ${(ratio * 100).round()}% of your $categoryName budget.',
        );
      }
    }
  }

  Future<void> _maybeSendLateSalaryReminder({
    required DateTime now,
    required List<Transaction> transactions,
  }) async {
    if (now.day < 20) return;

    final monthlyIncome = transactions
        .where((tx) => tx.isIncome)
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    if (monthlyIncome > 0) return;

    await _showOncePerWindow(
      key: 'late_income_${now.year}_${now.month}',
      window: _ReminderWindow.monthly,
      id: 1002,
      title: 'Income check-in',
      body:
          'No income has been logged yet this month. Add it to track cash flow.',
    );
  }

  Future<void> _showOncePerWindow({
    required String key,
    required _ReminderWindow window,
    required int id,
    required String title,
    required String body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final periodKey = switch (window) {
      _ReminderWindow.monthly => '${now.year}-${now.month}',
    };

    if (prefs.getString(key) == periodKey) return;

    await _plugin.show(id, title, body, _details);
    await prefs.setString(key, periodKey);
  }

  int _stableId(String value) {
    return 2000 +
        value.codeUnits.fold<int>(0, (sum, unit) => sum + unit) % 8000;
  }
}

enum _ReminderWindow { monthly }
