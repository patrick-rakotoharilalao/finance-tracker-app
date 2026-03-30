import 'package:finance_tracker/utils/constants.dart';
import 'package:flutter/material.dart';
import '../services/insight_service.dart';
import '../utils/formatters.dart';

class GreetingBar extends StatelessWidget {
  const GreetingBar({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            InsightService.greeting(),
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
    );
  }
}
