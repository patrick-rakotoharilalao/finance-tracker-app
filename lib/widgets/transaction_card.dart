import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import 'package:animate_do/animate_do.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onDelete;
  final int? index;

  const TransactionCard(
      {super.key, required this.transaction, this.onDelete, this.index = 0});

  @override
  Widget build(BuildContext context) {
    final category = transaction.categoryEnum;

    return FadeInUp(
        duration: const Duration(milliseconds: 300),
        delay: Duration(milliseconds: index! * 80),
        child: Dismissible(
          // ↑ Dismissible makes the card swipeable left to delete
          key: Key(transaction.id),
          direction: DismissDirection.endToStart,
          // ↑ Swipe right to left only
          background: _DeleteBackground(),
          onDismissed: (_) => onDelete?.call(),
          // ↑ "?." means call only if onDelete is not null
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
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
                // Category icon circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: AppSizes.iconM,
                  ),
                ),

                const SizedBox(width: AppSizes.paddingM),

                // Category name and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            category.label,
                            style: TextStyle(
                              fontSize: AppSizes.fontM,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          // AI badge — shown if categorized by Gemini
                          if (transaction.aiCategorized) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.leisure.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'AI',
                                style: TextStyle(
                                  fontSize: AppSizes.fontXS,
                                  color: AppColors.leisure,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        transaction.note != null && transaction.note!.isNotEmpty
                            ? transaction.note!
                            : AppFormatters.smartDate(transaction.date),
                        style: TextStyle(
                          fontSize: AppSizes.fontXS,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Amount
                Text(
                  AppFormatters.currencyWithSign(
                    transaction.amount,
                    transaction.type,
                  ),
                  style: TextStyle(
                    fontSize: AppSizes.fontM,
                    fontWeight: FontWeight.w600,
                    color: transaction.isIncome
                        ? AppColors.income
                        : AppColors.expense,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

// ─── DELETE BACKGROUND ───────────────────────────────────────
// Red background revealed when swiping left

class _DeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      padding: const EdgeInsets.only(right: AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.expense,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      alignment: Alignment.centerRight,
      child: const Icon(Icons.delete_outline, color: Colors.white),
    );
  }
}
