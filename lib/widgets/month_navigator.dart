import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class MonthNavigator extends StatelessWidget {
  final int month;
  final int year;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool isCurrentMonth;
  const MonthNavigator(
      {super.key,
      required this.month,
      required this.year,
      required this.onPrevious,
      required this.onNext,
      required this.isCurrentMonth});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
            color: AppColors.primary,
          ),
          Text(
            AppFormatters.monthYear(
              DateTime(year, month),
            ),
            style: TextStyle(
              fontSize: AppSizes.fontM,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
            color: isCurrentMonth
                ? AppColors.grey.withValues(alpha: 0.3)
                : AppColors.primary,
            // ↑ Greyed out if already on current month
          ),
        ],
      ),
    );
  }
}
