import 'package:finance_tracker/widgets/keypad.dart';
import 'package:finance_tracker/widgets/save_button.dart';
import 'package:finance_tracker/widgets/type_selector.dart';
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
  String _amountString = '0';
  String _type = AppStrings.expense;
  Category _category = Category.food;
  final TextEditingController _noteController = TextEditingController();
  bool _isSaving = false;
  bool _iscategorizing = false;
  final GeminiService _gemini = GeminiService();

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

  double get _amount => double.tryParse(_amountString) ?? 0;

  bool get _isValid => _amount > 0;

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

                    // ── TYPE SELECTOR 
                    TypeSelector(
                      selectedType: _type,
                      onChanged: (type) => setState(() => _type = type),
                    ),

                    const SizedBox(height: AppSizes.paddingL),

                    // ── AMOUNT DISPLAY
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
                              ? const SizedBox(
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
                                    .withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusM,
                                ),
                              ),
                              child: const Center(
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
                              .withValues(alpha: 0.4),
                          fontSize: AppSizes.fontXS,
                        ),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.3),
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
            Keypad(onKeyTap: _onKeyTap),

            // ── SAVE BUTTON ─────────────────────────────────
            SaveButton(isValid: _isValid, isSaving: _isSaving, type: _type, onSave: _save)
          ],
        ),
      ),
    );
  }
}
