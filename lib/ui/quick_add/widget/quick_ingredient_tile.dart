import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/formatter/d_day_formatter.dart';
import 'package:fridge/core/theme/app_spacing.dart';
import 'package:fridge/core/theme/freshness_color.dart';
import 'package:fridge/domain/entity/freshness.dart';
import 'package:fridge/domain/entity/storage_place.dart';
import 'package:fridge/ui/add_ingredient/widget/storage_place_selector.dart';
import 'package:fridge/ui/quick_add/bloc/quick_add_bloc.dart';
import 'package:fridge/ui/quick_add/quick_ingredient_draft.dart';
import 'package:intl/intl.dart';

class QuickIngredientTile extends StatefulWidget {
  const QuickIngredientTile({
    required this.index,
    required this.draft,
    required this.today,
    super.key,
  });

  final int index;
  final QuickIngredientDraft draft;
  final DateTime today;

  @override
  State<QuickIngredientTile> createState() => _QuickIngredientTileState();
}

class _QuickIngredientTileState extends State<QuickIngredientTile> {
  static const _amountFlex = 2;

  late final _nameController = TextEditingController(text: widget.draft.name);
  late final _amountController = TextEditingController(
    text: NumberFormat.decimalPattern().format(widget.draft.amount),
  );
  late final _unitController = TextEditingController(text: widget.draft.unit);

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.read<QuickAddBloc>();
    final draft = widget.draft;
    final index = widget.index;

    void changeName(String name) {
      bloc.add(QuickAddDraftNameChanged(index, name));
    }

    void changeAmount(String amount) {
      final parsed = double.tryParse(amount.trim());
      if (parsed == null) return;
      bloc.add(QuickAddDraftAmountChanged(index, parsed));
    }

    void changeUnit(String unit) {
      bloc.add(QuickAddDraftUnitChanged(index, unit));
    }

    void changeStoragePlace(StoragePlace storagePlace) {
      bloc.add(QuickAddDraftStoragePlaceChanged(index, storagePlace));
    }

    void remove() {
      bloc.add(QuickAddDraftRemoved(index));
    }

    final daysLeft = draft.expiresAt.difference(widget.today).inDays;
    final freshness = Freshness.fromDaysLeft(daysLeft);
    final freshnessColor = freshness.resolveColor(theme.colorScheme);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    onChanged: changeName,
                    decoration: const InputDecoration(
                      labelText: AppStrings.ingredientName,
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: remove,
                  icon: const Icon(Icons.close),
                  tooltip: AppStrings.removeIngredient,
                ),
              ],
            ),
            if (!draft.isAmountValid) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppStrings.quickAddUnrecognizedAmount,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: _amountFlex,
                  child: TextField(
                    controller: _amountController,
                    onChanged: changeAmount,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: AppStrings.ingredientAmount,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _unitController,
                    onChanged: changeUnit,
                    decoration: const InputDecoration(
                      labelText: AppStrings.ingredientUnit,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            StoragePlaceSelector(
              selected: draft.storagePlace,
              onChanged: changeStoragePlace,
            ),
            const SizedBox(height: AppSpacing.sm),
            _ExpiryPreview(daysLeft: daysLeft, color: freshnessColor),
          ],
        ),
      ),
    );
  }
}

class _ExpiryPreview extends StatelessWidget {
  const _ExpiryPreview({required this.daysLeft, required this.color});

  final int daysLeft;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = formatDaysLeft(daysLeft);
    final labelStyle = theme.textTheme.labelMedium?.copyWith(
      color: color,
      fontWeight: FontWeight.bold,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Text(label, style: labelStyle),
    );
  }
}
