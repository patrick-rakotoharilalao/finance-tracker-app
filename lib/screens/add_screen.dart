import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/category.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/category_picker.dart';
import '../services/gemini_service.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  // ── LOCAL STATE ────────────────────────────────────────────
  String _amountString = '0';
  String _type = AppStrings.expense;
  Category _category = Category.food;
  final TextEditingController _noteController = TextEditingController();
  bool _isSaving = false;
  bool _iscategorizing = false;
  final GeminiService _gemini = GeminiService();

  // ── LIFECYCLE ──────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    // Rebuild when note field changes — to enable/disable Auto-detect button
    _noteController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _noteController.dispose();
    // ↑ Always dispose controllers to free memory
    super.dispose();
  }

  // ── COMPUTED ───────────────────────────────────────────────
  double get _amount => double.tryParse(_amountString) ?? 0;

  bool get _isValid => _amount > 0;

  // ── AI AUTO CATEGORIZATION ─────────────────────────────────
  Future<void> _autoCategorize() async {
    final note = _noteController.text.trim();
    if (note.isEmpty) return;

    setState(() => _iscategorizing = true);

    final suggested = await _gemini.categorizeTransaction(note);

    setState(() {
      _category = CategoryExtension.fromString(suggested);
      _iscategorizing = false;
    });
  }

  // ── KEYPAD LOGIC ───────────────────────────────────────────
  void _onKeyTap(String key) {
    setState(() {
      if (key == '⌫') {
        if (_amountString.length > 1) {
          _amountString = _amountString.substring(
            0,
            _amountString.length - 1,
          );
        } else {
          _amountString = '0';
        }
      } else if (key == '.') {
        if (!_amountString.contains('.')) {
          _amountString += '.';
        }
      } else {
        if (_amountString == '0') {
          _amountString = key;
        } else {
          if (_amountString.length < 10) {
            _amountString += key;
          }
        }
      }
    });
  }

  // ── SAVE ───────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_isValid || _isSaving) return;

    setState(() => _isSaving = true);

    await context.read<TransactionProvider>().addTransaction(
          amount: _amount,
          type: _type,
          category: _category.value,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          aiCategorized: _iscategorizing,
        );

    HapticFeedback.lightImpact();

    if (mounted) context.pop();
  }

  // ── BUILD ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: const Text(
          'Add Transaction',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSizes.paddingM),

                    // ── TYPE SELECTOR ───────────────────────
                    _TypeSelector(
                      selectedType: _type,
                      onChanged: (type) => setState(() => _type = type),
                    ),

                    const SizedBox(height: AppSizes.paddingL),

                    // ── AMOUNT DISPLAY ──────────────────────
                    Center(
                      child: Text(
                        AppFormatters.currency(_amount),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: _type == AppStrings.income
                              ? AppColors.income
                              : AppColors.expense,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.paddingL),

                    // ── CATEGORY HEADER + AUTO-DETECT ───────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Category',
                          style: TextStyle(
                            fontSize: AppSizes.fontS,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _noteController.text.trim().isEmpty
                              ? null
                              : _iscategorizing
                                  ? null
                                  : _autoCategorize,
                          icon: _iscategorizing
                              ? SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.leisure,
                                  ),
                                )
                              : Icon(
                                  Icons.auto_awesome,
                                  size: 14,
                                  color: _noteController.text.trim().isEmpty
                                      ? AppColors.grey
                                      : AppColors.leisure,
                                ),
                          label: Text(
                            _iscategorizing ? 'Detecting...' : 'Auto-detect',
                            style: TextStyle(
                              fontSize: AppSizes.fontXS,
                              color: _noteController.text.trim().isEmpty
                                  ? AppColors.grey
                                  : AppColors.leisure,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingS,
                              vertical: 4,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSizes.paddingS),

                    // ── CATEGORY PICKER ─────────────────────
                    Stack(
                      children: [
                        CategoryPicker(
                          selectedCategory: _category,
                          onSelected: (cat) => setState(() => _category = cat),
                        ),
                        if (_iscategorizing)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withOpacity(0.7),
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusM,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'AI is analyzing...',
                                  style: TextStyle(
                                    fontSize: AppSizes.fontXS,
                                    color: AppColors.leisure,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: AppSizes.paddingL),

                    // ── NOTE FIELD ──────────────────────────
                    TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText:
                            'Note (optional) — type to enable Auto-detect',
                        hintStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.4),
                          fontSize: AppSizes.fontXS,
                        ),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceVariant
                            .withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            width: 0.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            width: 0.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      maxLines: 1,
                    ),

                    const SizedBox(height: AppSizes.paddingL),
                  ],
                ),
              ),
            ),

            // ── KEYPAD ─────────────────────────────────────
            _Keypad(onKeyTap: _onKeyTap),

            // ── SAVE BUTTON ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isValid ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _type == AppStrings.income
                        ? AppColors.income
                        : AppColors.expense,
                    disabledBackgroundColor: AppColors.greyLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                  ),
                  child: _isSaving
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
            ),
          ],
        ),
      ),
    );
  }
}

// ─── TYPE SELECTOR ────────────────────────────────────────────

class _TypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onChanged;

  const _TypeSelector({
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          _TypeButton(
            label: 'Expense',
            isSelected: selectedType == AppStrings.expense,
            color: AppColors.expense,
            onTap: () => onChanged(AppStrings.expense),
          ),
          _TypeButton(
            label: 'Income',
            isSelected: selectedType == AppStrings.income,
            color: AppColors.income,
            onTap: () => onChanged(AppStrings.income),
          ),
        ],
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppSizes.fontS,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── KEYPAD ───────────────────────────────────────────────────

class _Keypad extends StatelessWidget {
  final ValueChanged<String> onKeyTap;

  const _Keypad({required this.onKeyTap});

  static const List<List<String>> _keys = [
    ['7', '8', '9'],
    ['4', '5', '6'],
    ['1', '2', '3'],
    ['.', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      child: Column(
        children: _keys.map((row) {
          return Row(
            children: row.map((key) {
              return Expanded(
                child: _KeyButton(
                  label: key,
                  onTap: () => onKeyTap(key),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _KeyButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: label == '⌫'
              ? AppColors.expense.withOpacity(0.1)
              : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
        child: Center(
          child: label == '⌫'
              ? const Icon(
                  Icons.backspace_outlined,
                  size: AppSizes.iconM,
                  color: AppColors.expense,
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: AppSizes.fontXL,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
        ),
      ),
    );
  }
}
