import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/budget_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import '../widgets/budget_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final now = DateTime.now();

    // Get expenses for current month grouped by category
    final spentByCategory = txProvider.expensesByCategory(
      now.month,
      now.year,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── APP BAR ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.paddingS,
                ),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: AppSizes.fontL,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ),

              // ── APPEARANCE ───────────────────────────────────
              _SectionTitle('Appearance'),
              const SizedBox(height: AppSizes.paddingS),
              _SettingsCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          themeProvider.isDarkMode
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          color: AppColors.primary,
                          size: AppSizes.iconM,
                        ),
                        const SizedBox(width: AppSizes.paddingM),
                        Text(
                          'Dark mode',
                          style: TextStyle(
                            fontSize: AppSizes.fontM,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (_) => themeProvider.toggleTheme(),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.paddingL),

              // ── MONTHLY BUDGET ───────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionTitle('Monthly budget'),
                  TextButton.icon(
                    onPressed: () => _showAddBudgetDialog(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      textStyle: TextStyle(fontSize: AppSizes.fontS),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingS),

              // Budget list
              if (budgetProvider.budgets.isEmpty)
                _EmptyBudget(
                  onTap: () => _showAddBudgetDialog(context),
                )
              else
                ...budgetProvider.budgets
                    .where((b) => b.month == now.month && b.year == now.year)
                    .map((budget) {
                  final category =
                      CategoryExtension.fromString(budget.category);
                  final spent = spentByCategory[budget.category] ?? 0;

                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSizes.paddingS,
                    ),
                    child: GestureDetector(
                      onLongPress: () => _showDeleteDialog(
                        context,
                        budgetProvider,
                        budget,
                      ),
                      // ↑ Long press to delete
                      child: BudgetBar(
                        category: category,
                        spent: spent,
                        limit: budget.limit,
                      ),
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

  // ── ADD BUDGET DIALOG ──────────────────────────────────────
  void _showAddBudgetDialog(BuildContext context) {
    final budgetProvider = context.read<BudgetProvider>();
    final now = DateTime.now();
    Category selectedCategory = Category.food;
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // ↑ Allows the sheet to grow above the keyboard
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXL),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          // ↑ StatefulBuilder gives us setState inside
          //   a stateless modal bottom sheet
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppSizes.paddingM,
                right: AppSizes.paddingM,
                top: AppSizes.paddingL,
                bottom: MediaQuery.of(context).viewInsets.bottom +
                    AppSizes.paddingL,
                // ↑ viewInsets.bottom = keyboard height
                //   Adds padding so the sheet scrolls above keyboard
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingL),

                  Text(
                    'Set a budget',
                    style: TextStyle(
                      fontSize: AppSizes.fontL,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingM),

                  // Category selector
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: AppSizes.fontS,
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: Category.values.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final cat = Category.values[index];
                        final isSelected = cat == selectedCategory;

                        return GestureDetector(
                          onTap: () =>
                              setModalState(() => selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 64,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? cat.color
                                  : cat.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusM,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  cat.icon,
                                  color: isSelected ? Colors.white : cat.color,
                                  size: AppSizes.iconM,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cat.label,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color:
                                        isSelected ? Colors.white : cat.color,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingM),

                  // Limit amount field
                  Text(
                    'Monthly limit',
                    style: TextStyle(
                      fontSize: AppSizes.fontS,
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g. 100000',
                      suffixText: AppStrings.currency,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          width: 0.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          width: 0.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingL),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        final limit = double.tryParse(controller.text);
                        if (limit == null || limit <= 0) return;

                        await budgetProvider.setBudget(
                          category: selectedCategory.value,
                          limit: limit,
                          month: now.month,
                          year: now.year,
                        );

                        if (context.mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusM,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Save budget',
                        style: TextStyle(
                          fontSize: AppSizes.fontM,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── DELETE DIALOG ──────────────────────────────────────────
  void _showDeleteDialog(
    BuildContext context,
    BudgetProvider provider,
    dynamic budget,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete budget'),
        content: const Text(
          'Are you sure you want to delete this budget?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await provider.deleteBudget(budget);
              if (context.mounted) Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.expense,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─── HELPERS ──────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: AppSizes.fontM,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onBackground,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: child,
    );
  }
}

class _EmptyBudget extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyBudget({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 32,
              color: AppColors.primary.withOpacity(0.6),
            ),
            const SizedBox(height: AppSizes.paddingS),
            const Text(
              'Set your first budget',
              style: TextStyle(
                fontSize: AppSizes.fontS,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
