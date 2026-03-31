import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/budget_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import '../widgets/settings_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final now = DateTime.now();
    final spentByCategory = txProvider.expensesByCategory(
      now.month,
      now.year,
    );
    final currentBudgets = budgetProvider.budgets
        .where((budget) => budget.month == now.month && budget.year == now.year)
        .toList();

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
              const SettingsHeader(),
              const SettingsSectionTitle('Appearance'),
              const SizedBox(height: AppSizes.paddingS),
              const AppearanceTile(),
              const SizedBox(height: AppSizes.paddingL),
              BudgetSectionHeader(onAdd: () => showAddBudgetSheet(context)),
              const SizedBox(height: AppSizes.paddingS),
              if (currentBudgets.isEmpty)
                EmptyBudgetCard(
                  onTap: () => showAddBudgetSheet(context),
                )
              else
                ...currentBudgets.map((budget) {
                  final spent = spentByCategory[budget.category] ?? 0;

                  return BudgetListItem(
                    budget: budget,
                    spent: spent,
                    onDelete: () => budgetProvider.deleteBudget(
                        budget,
                      ),
                  );
                }),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
