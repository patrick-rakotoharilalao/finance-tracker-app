import 'package:finance_tracker/widgets/empty_month.dart';
import 'package:finance_tracker/widgets/month_navigator.dart';
import 'package:finance_tracker/widgets/monthly_summary_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/transaction_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late int _month;
  late int _year;

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

  Map<String, List<Transaction>> _groupByDate(List<Transaction> transactions) {
    final Map<String, List<Transaction>> grouped = {};

    for (final t in transactions) {
      final label = AppFormatters.smartDate(t.date);
      if (grouped[label] == null) grouped[label] = [];
      grouped[label]!.add(t);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final monthly = provider.getByMonth(_month, _year);
    final grouped = _groupByDate(monthly);

    // Monthly totals for the summary bar
    final totalIncome =
        monthly.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense =
        monthly.where((t) => t.isExpense).fold(0.0, (sum, t) => sum + t.amount);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── APP BAR
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
              child: Row(
                children: [
                  Text(
                    'History',
                    style: TextStyle(
                      fontSize: AppSizes.fontL,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // ── MONTH NAVIGATOR
            MonthNavigator(
                month: _month,
                year: _year,
                onPrevious: _previousMonth,
                onNext: _nextMonth,
                isCurrentMonth: _isCurrentMonth()),

            // ── MONTHLY SUMMARY BAR
            if (monthly.isNotEmpty)
              MonthlySummaryBar(
                  totalIncome: totalIncome, totalExpense: totalExpense),

            // ── TRANSACTION LIST
            Expanded(
              child: monthly.isEmpty
                  ? const EmptyMonth()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingM,
                      ),
                      itemCount: grouped.length,
                      itemBuilder: (context, index) {
                        final dateLabel = grouped.keys.elementAt(index);
                        final transactions = grouped[dateLabel]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date group header
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppSizes.paddingM,
                                bottom: AppSizes.paddingS,
                              ),
                              child: Text(
                                dateLabel,
                                style: TextStyle(
                                  fontSize: AppSizes.fontS,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ),

                            // Transactions for this date
                            ...transactions.map((t) => TransactionCard(
                                  transaction: t,
                                  onDelete: () => provider.deleteTransaction(t),
                                )),
                          ],
                        );
                      },
                    ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  bool _isCurrentMonth() {
    final now = DateTime.now();
    return _month == now.month && _year == now.year;
  }
}
