import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/formatters.dart';

class MonthlySummaryBar extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  const MonthlySummaryBar(
    {super.key, required this.totalIncome, required this.totalExpense});

  @override
  Widget build(BuildContext context) {
    // Monthly totals for the summary bar
    return Container(
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
    );
  }
}

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
