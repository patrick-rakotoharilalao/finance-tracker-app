import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_card.dart';
import '../services/gemini_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GeminiService _gemini = GeminiService();
  String _insight             = '';
  bool _loadingInsight        = false;

  @override
  void initState() {
    super.initState();
    // Load insight after first frame — data might not be ready yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInsight();
    });
  }

  Future<void> _loadInsight() async {
    final provider = context.read<TransactionProvider>();
    final now      = DateTime.now();

    if (provider.monthlyExpenses == 0) return;

    setState(() => _loadingInsight = true);

    final insight = await _gemini.generateMonthlyInsight(
      totalIncome:        provider.monthlyIncome,
      totalExpenses:      provider.monthlyExpenses,
      expensesByCategory: provider.expensesByCategory(now.month, now.year),
      month:              AppFormatters.monthYear(now),
    );

    setState(() {
      _insight        = insight;
      _loadingInsight = false;
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 18) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final now      = DateTime.now();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [

            // ── APP BAR ──────────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(),
                    style: TextStyle(
                      fontSize: AppSizes.fontS,
                      color: Theme.of(context).colorScheme.onSurface
                          .withValues(alpha: 0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    AppFormatters.monthYear(now),
                    style: TextStyle(
                      fontSize: AppSizes.fontL,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // ── CONTENT ──────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // Balance card
                  BalanceCard(
                    totalBalance:    provider.totalBalance,
                    monthlyIncome:   provider.monthlyIncome,
                    monthlyExpenses: provider.monthlyExpenses,
                  ),

                  // ── AI INSIGHT CARD ───────────────────────
                  if (_loadingInsight || _insight.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppSizes.paddingM,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.leisure.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          border: Border.all(
                            color: AppColors.leisure.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: _loadingInsight
                            ? Row(
                                children: [
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.leisure,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Generating insight...',
                                    style: TextStyle(
                                      fontSize: AppSizes.fontXS,
                                      color: AppColors.leisure,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 16,
                                    color: AppColors.leisure,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _insight,
                                      style: TextStyle(
                                        fontSize: AppSizes.fontS,
                                        color: Theme.of(context)
                                            .colorScheme.onSurface,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                  const SizedBox(height: AppSizes.paddingL),

                  // Recent transactions header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: AppSizes.fontM,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/history'),
                        child: const Text(
                          'See all',
                          style: TextStyle(
                            fontSize: AppSizes.fontS,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.paddingS),

                  // Transaction list — last 5 only
                  if (provider.transactions.isEmpty)
                    _EmptyState()
                  else
                    ...provider.transactions
                        .take(5)
                        .map((t) => TransactionCard(
                              transaction: t,
                              onDelete: () => provider.deleteTransaction(t),
                            )),

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

// ─── EMPTY STATE ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingXL),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              'No transactions yet',
              style: TextStyle(
                fontSize: AppSizes.fontM,
                color: Theme.of(context).colorScheme.onSurface
                    .withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              'Tap + to add your first transaction',
              style: TextStyle(
                fontSize: AppSizes.fontS,
                color: Theme.of(context).colorScheme.onSurface
                    .withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}