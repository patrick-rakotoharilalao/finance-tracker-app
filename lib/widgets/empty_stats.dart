import 'package:flutter/material.dart';
import '../utils/constants.dart';

class EmptyStats extends StatelessWidget {
  const EmptyStats({super.key});
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
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              'No data for this month',
              style: TextStyle(
                fontSize: AppSizes.fontM,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
