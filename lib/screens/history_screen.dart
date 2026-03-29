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
  // Currently displayed month and year
  late int _month;
  late int _year;

  @override
  void initState() {
    super.initState();
    // ↑ initState runs once when the widget is inserted into the tree
    //   Like onMounted() in Vue
    _month = DateTime.now().month;
    _year = DateTime.now().year;
  }

  // Navigate to previous month
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

  // Navigate to next month — blocked if current month
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

  // Groups a list of transactions by date
  // Returns a Map like { "Today": [...], "Yesterday": [...], "March 27, 2026": [...] }
  Map<String, List<Transaction>> _groupByDate(List<Transaction> transactions) {
    final Map<String, List<Transaction>> grouped = {};

    for (final t in transactions) {
      final label = AppFormatters.smartDate(t.date);
      grouped[label] = [...(grouped[label] ?? []), t];
      // ↑ "..." is the spread operator — same as in JavaScript
      //   Creates a new list with existing items + the new one
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
            // ── APP BAR ──────────────────────────────────────
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

            // ── MONTH NAVIGATOR ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _previousMonth,
                    icon: const Icon(Icons.chevron_left),
                    color: AppColors.primary,
                  ),
                  Text(
                    AppFormatters.monthYear(
                      DateTime(_year, _month),
                    ),
                    style: TextStyle(
                      fontSize: AppSizes.fontM,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: _nextMonth,
                    icon: const Icon(Icons.chevron_right),
                    color: _isCurrentMonth()
                        ? AppColors.grey.withValues(alpha: 0.3)
                        : AppColors.primary,
                    // ↑ Greyed out if already on current month
                  ),
                ],
              ),
            ),

            // ── MONTHLY SUMMARY BAR ──────────────────────────
            if (monthly.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                  vertical: AppSizes.paddingS,
                ),
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryItem(
                        label: 'Income',
                        amount: totalIncome,
                        color: AppColors.income,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    Expanded(
                      child: _SummaryItem(
                        label: 'Expenses',
                        amount: totalExpense,
                        color: AppColors.expense,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    Expanded(
                      child: _SummaryItem(
                        label: 'Balance',
                        amount: totalIncome - totalExpense,
                        color: totalIncome >= totalExpense
                            ? AppColors.income
                            : AppColors.expense,
                      ),
                    ),
                  ],
                ),
              ),

            // ── TRANSACTION LIST ─────────────────────────────
            Expanded(
              child: monthly.isEmpty
                  ? _EmptyMonth()
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

// ─── SUMMARY ITEM ─────────────────────────────────────────────

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.fontXS,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppFormatters.currency(amount.abs()),
          style: TextStyle(
            fontSize: AppSizes.fontS,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─── EMPTY MONTH ──────────────────────────────────────────────

class _EmptyMonth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 48,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            'No transactions this month',
            style: TextStyle(
              fontSize: AppSizes.fontM,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
