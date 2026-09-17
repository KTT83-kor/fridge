import 'package:flutter/material.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/theme/app_spacing.dart';

class EmptyIngredientView extends StatelessWidget {
  const EmptyIngredientView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hintStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.outline,
    );

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.kitchen_outlined,
            size: AppSpacing.xl * 2,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(AppStrings.emptyIngredients, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(AppStrings.emptyIngredientsHint, style: hintStyle),
        ],
      ),
    );
  }
}
