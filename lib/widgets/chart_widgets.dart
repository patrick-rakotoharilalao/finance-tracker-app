import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/category.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class PieChartStat extends StatelessWidget {
  final int? touchedIndex;
  final Map<String, double> byCategory;
  final double totalExpense;
  final ValueChanged<int?> onTouchedIndexChanged;
  const PieChartStat(
      {super.key,
      required this.touchedIndex,
      required this.byCategory,
      required this.totalExpense,
      required this.onTouchedIndexChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Pie chart
        SizedBox(
          width: 180,
          height: 180,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  if (!event.isInterestedForInteractions ||
                      response == null ||
                      response.touchedSection == null) {
                    // _touchedIndex = null;
                    onTouchedIndexChanged(null);
                    return;
                  }
                  onTouchedIndexChanged(
                      response.touchedSection!.touchedSectionIndex);
                },
              ),
              sectionsSpace: 2,
              centerSpaceRadius: 48,
              // ↑ Creates the donut hole in the middle
              sections: _buildPieSections(
                byCategory,
                totalExpense,
              ),
            ),
          ),
        ),

        const SizedBox(width: AppSizes.paddingM),

        // Legend
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: byCategory.entries.map((entry) {
              final category = CategoryExtension.fromString(entry.key);
              final percent = totalExpense > 0
                  ? (entry.value / totalExpense * 100).toStringAsFixed(1)
                  : '0';

              return Padding(
                padding: const EdgeInsets.only(
                  bottom: AppSizes.paddingS,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: category.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category.label,
                        style: TextStyle(
                          fontSize: AppSizes.fontXS,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: TextStyle(
                        fontSize: AppSizes.fontXS,
                        fontWeight: FontWeight.w600,
                        color: category.color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections(
    Map<String, double> byCategory,
    double total,
  ) {
    final entries = byCategory.entries.toList();

    return List.generate(entries.length, (index) {
      final entry = entries[index];
      final category = CategoryExtension.fromString(entry.key);
      final percent = total > 0 ? entry.value / total * 100 : 0.0;
      final isTouched = index == touchedIndex;

      return PieChartSectionData(
        value: entry.value,
        color: category.color,
        radius: isTouched ? 60 : 50,
        // ↑ Touched slice grows slightly
        showTitle: isTouched,
        title: '${percent.toStringAsFixed(1)}%',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );
    });
  }
}

class BarChartWidget extends StatelessWidget {
  final int month;
  final int year;
  final List transactions;

  const BarChartWidget({
    super.key,
    required this.month,
    required this.year,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    // Group transactions into 4 weeks
    final List<double> weeklyIncome = [0, 0, 0, 0];
    final List<double> weeklyExpenses = [0, 0, 0, 0];

    for (final t in transactions) {
      // Week index 0-3 based on day of month
      final weekIndex = ((t.date.day - 1) / 7).floor().clamp(0, 3);
      if (t.isIncome) {
        weeklyIncome[weekIndex] += t.amount;
      } else {
        weeklyExpenses[weekIndex] += t.amount;
      }
    }

    final maxY =
        [...weeklyIncome, ...weeklyExpenses].reduce((a, b) => a > b ? a : b);
    // ↑ Find the highest value to set the chart's Y axis

    return BarChart(
      BarChartData(
        maxY: maxY * 1.2,
        // ↑ Add 20% space above the tallest bar
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const labels = ['W1', 'W2', 'W3', 'W4'];
                return Text(
                  labels[value.toInt()],
                  style: TextStyle(
                    fontSize: AppSizes.fontXS,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context).colorScheme.outlineVariant,
            strokeWidth: 0.5,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(4, (weekIndex) {
          return BarChartGroupData(
            x: weekIndex,
            barRods: [
              // Income bar
              BarChartRodData(
                toY: weeklyIncome[weekIndex],
                color: AppColors.income,
                width: 12,
                borderRadius: BorderRadius.circular(4),
              ),
              // Expense bar
              BarChartRodData(
                toY: weeklyExpenses[weekIndex],
                color: AppColors.expense,
                width: 12,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class CategoryRow extends StatelessWidget {
  final Category category;
  final double amount;
  final double percent;

  const CategoryRow({
    super.key,
    required this.category,
    required this.amount,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: Column(
        children: [
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
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                AppFormatters.currency(amount),
                style: TextStyle(
                  fontSize: AppSizes.fontS,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              // ↑ Value between 0.0 and 1.0
              backgroundColor: category.color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(category.color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
