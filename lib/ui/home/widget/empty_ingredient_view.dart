import 'package:flutter/material.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/theme/app_spacing.dart';

class EmptyIngredientView extends StatelessWidget {
  const EmptyIngredientView({
    this.title = AppStrings.emptyIngredients,
    this.hint = AppStrings.emptyIngredientsHint,
    super.key,
  });

  final String title;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hintStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.outline,
    );
    final hintText = hint;

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
          Text(title, style: theme.textTheme.titleMedium),
          if (hintText != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(hintText, style: hintStyle),
          ],
        ],
      ),
    );
  }
}
