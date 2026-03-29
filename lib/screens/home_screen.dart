import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the provider — rebuilds when data changes
    // Like useStore() in Pinia but reactive
    final provider = context.watch<TransactionProvider>();
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        // ↑ SafeArea avoids the phone's notch and status bar
        child: CustomScrollView(
          // ↑ CustomScrollView lets us mix different
          //   scrollable widgets (SliverAppBar, SliverList...)
          slivers: [
            // ── APP BAR ──────────────────────────────────────
            SliverAppBar(
              floating: true,
              // ↑ App bar reappears when scrolling up
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
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
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
                    totalBalance: provider.totalBalance,
                    monthlyIncome: provider.monthlyIncome,
                    monthlyExpenses: provider.monthlyExpenses,
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
                        // ↑ Shows only the 5 most recent transactions
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

  // Returns a greeting based on the current hour
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 18) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }
}

// ─── EMPTY STATE ─────────────────────────────────────────────
// Shown when there are no transactions yet

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
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              'No transactions yet',
              style: TextStyle(
                fontSize: AppSizes.fontM,
                color:
                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              'Tap + to add your first transaction',
              style: TextStyle(
                fontSize: AppSizes.fontS,
                color:
                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
