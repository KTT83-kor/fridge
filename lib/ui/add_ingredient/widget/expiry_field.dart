import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/theme/app_spacing.dart';
import 'package:fridge/core/theme/freshness_color.dart';
import 'package:fridge/domain/entity/freshness.dart';
import 'package:fridge/ui/add_ingredient/bloc/add_ingredient_bloc.dart';
import 'package:fridge/ui/add_ingredient/widget/date_picker_field.dart';

class ExpiryField extends StatelessWidget {
  const ExpiryField({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddIngredientBloc, AddIngredientState>(
      builder: _buildField,
    );
  }

  Widget _buildField(BuildContext context, AddIngredientState state) {
    final theme = Theme.of(context);
    final bloc = context.read<AddIngredientBloc>();

    void changeExpiresAt(DateTime expiresAt) {
      bloc.add(AddIngredientExpiresAtChanged(expiresAt));
    }

    void resetExpiresAt() {
      bloc.add(const AddIngredientExpiresAtReset());
    }

    final daysLeft = state.expiresAt.difference(state.purchasedAt).inDays;
    final freshness = Freshness.fromDaysLeft(daysLeft);
    final helperText = _resolveHelperText(state);
    final helperColor = _resolveHelperColor(state, theme.colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DatePickerField(
          label: AppStrings.expiresAtLabel,
          value: state.expiresAt,
          onChanged: changeExpiresAt,
          helperText: helperText,
          helperColor: helperColor,
        ),
        if (state.isExpiryManual && state.hasShelfLifeSuggestion) ...[
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: resetExpiresAt,
              icon: const Icon(Icons.restart_alt),
              label: const Text(AppStrings.expiryResetToTable),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xs),
        _RemainingDaysLabel(
          daysLeft: daysLeft,
          color: freshness.resolveColor(theme.colorScheme),
        ),
      ],
    );
  }

  String _resolveHelperText(AddIngredientState state) {
    if (state.isExpiryManual) return AppStrings.expiryManual;
    if (state.hasShelfLifeSuggestion) return AppStrings.expiryFromTable;
    return AppStrings.expiryFromDefault;
  }

  Color _resolveHelperColor(AddIngredientState state, ColorScheme colorScheme) {
    if (state.isExpiryManual) return colorScheme.outline;
    if (state.hasShelfLifeSuggestion) return colorScheme.primary;
    return colorScheme.outline;
  }
}

class _RemainingDaysLabel extends StatelessWidget {
  const _RemainingDaysLabel({required this.daysLeft, required this.color});

  final int daysLeft;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: color,
      fontWeight: FontWeight.bold,
    );

    final label = AppStrings.daysFromPurchase(daysLeft);
    return Text(label, style: labelStyle);
  }
}
