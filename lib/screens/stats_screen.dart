import 'package:finance_tracker/widgets/chart_widgets.dart';
import 'package:finance_tracker/widgets/empty_stats.dart';
import 'package:finance_tracker/widgets/month_navigator.dart';
import 'package:finance_tracker/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late int _month;
  late int _year;
  int? _touchedIndex;
  // ↑ Index of the pie chart slice currently touched
  //   null = nothing touched

  @override
  void initState() {
    super.initState();
    _month = DateTime.now().month;
    _year = DateTime.now().year;
  }

  void _previousMonth() {
    setState(() {
      if (_month == 1) {
        _month = 12;
        _year--;
      } else {
        _month--;
      }
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    if (_year == now.year && _month == now.month) return;
    setState(() {
      if (_month == 12) {
        _month = 1;
        _year++;
      } else {
        _month++;
      }
    });
  }

  bool _isCurrentMonth() {
    final now = DateTime.now();
    return _month == now.month && _year == now.year;
  }

  void _onTouchedIndexChanged(value) {
    setState(() => _touchedIndex = value);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final byCategory = provider.expensesByCategory(_month, _year);
    final monthly = provider.getByMonth(_month, _year);

    final totalExpense = byCategory.values.fold(0.0, (sum, v) => sum + v);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── APP BAR
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.paddingS,
                ),
                child: Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: AppSizes.fontL,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),

              // ── MONTH NAVIGATOR
              MonthNavigator(
                  month: _month,
                  year: _year,
                  onPrevious: _previousMonth,
                  onNext: _nextMonth,
                  isCurrentMonth: _isCurrentMonth()),

              const SizedBox(height: AppSizes.paddingM),

              // ── PIE CHART ──────────────────────────────────
              if (byCategory.isEmpty)
                const EmptyStats()
              else ...[
                const SectionHeader(title: 'Expenses by Category'),
                const SizedBox(height: AppSizes.paddingM),

                // Pie chart + legend side by side
                PieChartStat(
                    touchedIndex: _touchedIndex,
                    byCategory: byCategory,
                    totalExpense: totalExpense,
                    onTouchedIndexChanged: _onTouchedIndexChanged),

                const SizedBox(height: AppSizes.paddingL),

                // ── BAR CHART
                const SectionHeader(title: 'Income vs Expenses — this month'),
                const SizedBox(height: AppSizes.paddingM),

                SizedBox(
                  height: 200,
                  child: BarChartWidget(
                    month: _month,
                    year: _year,
                    transactions: monthly,
                  ),
                ),

                const SizedBox(height: AppSizes.paddingL),

                // ── CATEGORY BREAKDOWN ───────────────────────
                const SectionHeader(title: 'Breakdown by category'),
                const SizedBox(height: AppSizes.paddingM),

                ...byCategory.entries.map((entry) {
                  final category = CategoryExtension.fromString(entry.key);
                  final percent =
                      totalExpense > 0 ? entry.value / totalExpense : 0.0;

                  return CategoryRow(
                    category: category,
                    amount: entry.value,
                    percent: percent,
                  );
                }),

                const SizedBox(height: 80),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
