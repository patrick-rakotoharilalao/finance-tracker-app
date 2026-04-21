import 'package:finance_tracker/widgets/ai_widgets.dart';
import 'package:finance_tracker/widgets/empty_state.dart';
import 'package:finance_tracker/widgets/greeting_bar.dart';
import 'package:finance_tracker/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/streak_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/gemini_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GeminiService _gemini = GeminiService();
  String _insight = '';
  bool _loadingInsight = false;

  @override
  void initState() {
    super.initState();
    // Load insight after first frame — data might not be ready yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInsight();
      context.read<StreakProvider>().markDailyUsage();
    });
  }

  Future<void> _loadInsight() async {
    final provider = context.read<TransactionProvider>();
    final now = DateTime.now();

    if (provider.monthlyExpenses == 0) return;

    setState(() => _loadingInsight = true);

    final insight = await _gemini.generateMonthlyInsight(
      totalIncome: provider.monthlyIncome,
      totalExpenses: provider.monthlyExpenses,
      expensesByCategory: provider.expensesByCategory(now.month, now.year),
      month: AppFormatters.monthYear(now),
    );

    setState(() {
      _insight = insight;
      _loadingInsight = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final streakProvider = context.watch<StreakProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const GreetingBar(),

            // ── CONTENT
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    margin: const EdgeInsets.only(top: AppSizes.paddingS),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingM,
                      vertical: AppSizes.paddingS,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          size: AppSizes.iconS,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: AppSizes.paddingS),
                        Text(
                          '${streakProvider.streakDays} day${streakProvider.streakDays > 1 ? 's' : ''} in a row',
                          style: TextStyle(
                            fontSize: AppSizes.fontS,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingM),

                  // Balance card
                  BalanceCard(
                    totalBalance: provider.totalBalance,
                    monthlyIncome: provider.monthlyIncome,
                    monthlyExpenses: provider.monthlyExpenses,
                  ),

                  // ── AI INSIGHT CARD
                  if (_loadingInsight || _insight.isNotEmpty)
                    AiInsightCard(
                        loadingInsight: _loadingInsight, insight: _insight),

                  const SizedBox(height: AppSizes.paddingL),

                  // Recent transactions header
                  const SectionHeader(
                      title: 'Recent Transactions',
                      linkLabel: 'See All',
                      link: '/history'),

                  const SizedBox(height: AppSizes.paddingS),

                  // Transaction list — last 5 only
                  if (provider.transactions.isEmpty)
                    const EmptyState()
                  else
                    ...provider.transactions
                        .take(5)
                        .toList()
                        .asMap()
                        .entries
                        .map(
                          (entry) => TransactionCard(
                            key: Key('home_${entry.value.id}'),
                            transaction: entry.value,
                            index: entry.key,
                            onDelete: () =>
                                provider.deleteTransaction(entry.value),
                          ),
                        ),

                  // Bottom padding so FAB doesn't cover last item
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
