import 'package:flutter/material.dart';
import '../models/category.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class BudgetBar extends StatelessWidget {
  final Category category;
  final double spent;
  final double limit;

  const BudgetBar({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
  });

  // Percentage spent — capped at 1.0 (100%)
  double get _percent => (spent / limit).clamp(0.0, 1.0);

  // Color changes based on how much is spent
  Color get _barColor {
    if (_percent >= 1.0) return AppColors.expense;
    if (_percent >= 0.8) return AppColors.housing;
    return category.color;
  }

  @override
  Widget build(BuildContext context) {
    final isOver = spent > limit;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: isOver
              ? AppColors.expense.withOpacity(0.5)
              : Theme.of(context).colorScheme.outlineVariant,
          width: isOver ? 1 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category name + spent amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    category.icon,
                    size: AppSizes.iconS,
                    color: category.color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.label,
                    style: TextStyle(
                      fontSize: AppSizes.fontS,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                '${AppFormatters.currency(spent)} / ${AppFormatters.currency(limit)}',
                style: TextStyle(
                  fontSize: AppSizes.fontXS,
                  color: isOver
                      ? AppColors.expense
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                  fontWeight: isOver ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _percent,
              backgroundColor: _barColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(_barColor),
              minHeight: 8,
            ),
          ),

          // Over budget warning
          if (isOver) ...[
            const SizedBox(height: 6),
            Text(
              'Over budget by ${AppFormatters.currency(spent - limit)}',
              style: const TextStyle(
                fontSize: AppSizes.fontXS,
                color: AppColors.expense,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
