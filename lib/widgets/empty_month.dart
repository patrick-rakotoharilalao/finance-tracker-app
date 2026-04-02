import 'package:flutter/material.dart';
import '../utils/constants.dart';

class EmptyMonth extends StatelessWidget {
  const EmptyMonth({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 48,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            'No transactions this month',
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
    );
  }
}
