import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SaveButton extends StatelessWidget {
  final bool isValid;
  final bool isSaving;
  final String type;
  final VoidCallback onSave;

  const SaveButton(
      {super.key,
      required this.isValid,
      required this.isSaving,
      required this.type,
      required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: isValid && !isSaving ? onSave : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: type == AppStrings.income
                ? AppColors.income
                : AppColors.expense,
            disabledBackgroundColor: AppColors.greyLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
          ),
          child: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: AppSizes.fontM,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
