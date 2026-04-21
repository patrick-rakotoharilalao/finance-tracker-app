import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AiInsightCard extends StatelessWidget {
  final bool loadingInsight;
  final String insight;
  const AiInsightCard(
      {super.key, required this.loadingInsight, required this.insight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSizes.paddingM,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: AppColors.leisure.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
            color: AppColors.leisure.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: loadingInsight
            ? const Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.leisure,
                    ),
                  ),
                  SizedBox(width: 10),
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
                  const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: AppColors.leisure,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight,
                      style: TextStyle(
                        fontSize: AppSizes.fontS,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
