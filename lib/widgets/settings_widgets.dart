import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/budget.dart';
import '../models/category.dart';
import '../providers/budget_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import 'budget_bar.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
      child: Text(
        'Settings',
        style: TextStyle(
          fontSize: AppSizes.fontL,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class SettingsSectionTitle extends StatelessWidget {
  final String title;

  const SettingsSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: AppSizes.fontM,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  final Widget child;

  const SettingsCard({super.key, required this.child});

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

class AppearanceTile extends StatelessWidget {
  const AppearanceTile({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return SettingsCard(
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
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class BudgetSectionHeader extends StatelessWidget {
  final VoidCallback onAdd;

  const BudgetSectionHeader({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SettingsSectionTitle('Monthly budget'),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: const TextStyle(fontSize: AppSizes.fontS),
          ),
        ),
      ],
    );
  }
}

class EmptyBudgetCard extends StatelessWidget {
  final VoidCallback onTap;

  const EmptyBudgetCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 32,
              color: AppColors.primary.withValues(alpha: 0.6),
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

class BudgetListItem extends StatelessWidget {
  final Budget budget;
  final double spent;
  final Future<void> Function() onDelete;

  const BudgetListItem({
    super.key,
    required this.budget,
    required this.spent,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final category = CategoryExtension.fromString(budget.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
      child: GestureDetector(
        onLongPress: () => showDeleteBudgetDialog(context, onDelete),
        child: BudgetBar(
          category: category,
          spent: spent,
          limit: budget.limit,
        ),
      ),
    );
  }
}

Future<void> showAddBudgetSheet(BuildContext context) async {
  final budgetProvider = context.read<BudgetProvider>();
  final now = DateTime.now();
  var selectedCategory = Category.food;
  final controller = TextEditingController();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusXL),
      ),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: AppSizes.paddingM,
              right: AppSizes.paddingM,
              top: AppSizes.paddingL,
              bottom: MediaQuery.of(context).viewInsets.bottom +
                  AppSizes.paddingL,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
                Text(
                  'Category',
                  style: TextStyle(
                    fontSize: AppSizes.fontS,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
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
                      final category = Category.values[index];
                      final isSelected = category == selectedCategory;

                      return GestureDetector(
                        onTap: () =>
                            setModalState(() => selectedCategory = category),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 64,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? category.color
                                : category.color.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusM),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                category.icon,
                                color: isSelected
                                    ? Colors.white
                                    : category.color,
                                size: AppSizes.iconM,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category.label,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isSelected
                                      ? Colors.white
                                      : category.color,
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
                Text(
                  'Monthly limit',
                  style: TextStyle(
                    fontSize: AppSizes.fontS,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
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
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
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

Future<void> showDeleteBudgetDialog(
  BuildContext context,
  Future<void> Function() onDelete,
) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete budget'),
      content: const Text('Are you sure you want to delete this budget?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await onDelete();
            if (context.mounted) Navigator.pop(context);
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.expense),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
