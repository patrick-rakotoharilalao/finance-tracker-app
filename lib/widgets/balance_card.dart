import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class BalanceCard extends StatelessWidget {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpenses;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpenses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            'Total Balance',
            style: TextStyle(
              fontSize: AppSizes.fontS,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 8),

          // Balance amount
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: totalBalance),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                AppFormatters.currency(value),
                style: const TextStyle(
                  fontSize: AppSizes.fontXXL,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Income and expense row
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Income',
                  amount: monthlyIncome,
                  icon: Icons.arrow_downward_rounded,
                  // ↑ Money coming IN = arrow pointing down into wallet
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Expenses',
                  amount: monthlyExpenses,
                  icon: Icons.arrow_upward_rounded,
                  // ↑ Money going OUT = arrow pointing up out of wallet
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── STAT ITEM ───────────────────────────────────────────────
// Income or expense mini card inside BalanceCard

class _StatItem extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Icon(icon, color: Colors.white, size: AppSizes.iconS),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: AppSizes.fontXS,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              Text(
                AppFormatters.currency(amount),
                style: const TextStyle(
                  fontSize: AppSizes.fontS,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
