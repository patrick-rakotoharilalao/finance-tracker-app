import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? linkLabel;
  final String? link;
  const SectionHeader(
      {super.key, required this.title, this.linkLabel, this.link});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        if (linkLabel != null && link != null)
          TextButton(
            onPressed: () => context.go(link!),
            child: Text(
              linkLabel!,
              style: const TextStyle(
                fontSize: AppSizes.fontS,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}
