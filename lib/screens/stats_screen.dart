import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/category.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late int _month;
  late int _year;
  int? _touchedIndex;
  // ↑ Index of the pie chart slice currently touched
  //   null = nothing touched

  @override
  void initState() {
    super.initState();
    _month = DateTime.now().month;
    _year = DateTime.now().year;
  }

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

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _month == now.month && _year == now.year;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final byCategory = provider.expensesByCategory(_month, _year);
    final monthly = provider.getByMonth(_month, _year);

    final totalExpense = byCategory.values.fold(0.0, (sum, v) => sum + v);

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
              // ── APP BAR ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.paddingS,
                ),
                child: Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: AppSizes.fontL,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),

              // ── MONTH NAVIGATOR ────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _previousMonth,
                    icon: const Icon(Icons.chevron_left),
                    color: AppColors.primary,
                  ),
                  Text(
                    AppFormatters.monthYear(DateTime(_year, _month)),
                    style: TextStyle(
                      fontSize: AppSizes.fontM,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: _nextMonth,
                    icon: const Icon(Icons.chevron_right),
                    color: _isCurrentMonth
                        ? AppColors.grey.withValues(alpha: 0.3)
                        : AppColors.primary,
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.paddingM),

              // ── PIE CHART ──────────────────────────────────
              if (byCategory.isEmpty)
                _EmptyStats()
              else ...[
                const _SectionTitle('Expenses by category'),
                const SizedBox(height: AppSizes.paddingM),

                // Pie chart + legend side by side
                Row(
                  children: [
                    // Pie chart
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    response == null ||
                                    response.touchedSection == null) {
                                  _touchedIndex = null;
                                  return;
                                }
                                _touchedIndex = response
                                    .touchedSection!.touchedSectionIndex;
                              });
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
                          final category =
                              CategoryExtension.fromString(entry.key);
                          final percent = totalExpense > 0
                              ? (entry.value / totalExpense * 100)
                                  .toStringAsFixed(1)
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
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
                ),

                const SizedBox(height: AppSizes.paddingL),

                // ── BAR CHART ────────────────────────────────
                const _SectionTitle('Income vs Expenses — this month'),
                const SizedBox(height: AppSizes.paddingM),

                SizedBox(
                  height: 200,
                  child: _BarChartWidget(
                    month: _month,
                    year: _year,
                    transactions: monthly,
                  ),
                ),

                const SizedBox(height: AppSizes.paddingL),

                // ── CATEGORY BREAKDOWN ───────────────────────
                const _SectionTitle('Breakdown by category'),
                const SizedBox(height: AppSizes.paddingM),

                ...byCategory.entries.map((entry) {
                  final category = CategoryExtension.fromString(entry.key);
                  final percent =
                      totalExpense > 0 ? entry.value / totalExpense : 0.0;

                  return _CategoryRow(
                    category: category,
                    amount: entry.value,
                    percent: percent,
                  );
                }),

                const SizedBox(height: 80),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Builds the pie chart slices from category data
  List<PieChartSectionData> _buildPieSections(
    Map<String, double> byCategory,
    double total,
  ) {
    final entries = byCategory.entries.toList();

    return List.generate(entries.length, (index) {
      final entry = entries[index];
      final category = CategoryExtension.fromString(entry.key);
      final percent = total > 0 ? entry.value / total * 100 : 0.0;
      final isTouched = index == _touchedIndex;

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

// ─── BAR CHART WIDGET ─────────────────────────────────────────
// Shows income vs expenses grouped by week

class _BarChartWidget extends StatelessWidget {
  final int month;
  final int year;
  final List transactions;

  const _BarChartWidget({
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

// ─── CATEGORY ROW ─────────────────────────────────────────────
// Progress bar per category in the breakdown section

class _CategoryRow extends StatelessWidget {
  final Category category;
  final double amount;
  final double percent;

  const _CategoryRow({
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
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _EmptyStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingXL),
        child: Column(
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 48,
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              'No data for this month',
              style: TextStyle(
                fontSize: AppSizes.fontM,
                color:
                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
