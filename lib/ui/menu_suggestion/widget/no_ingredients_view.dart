import 'package:flutter/material.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/theme/app_spacing.dart';

class NoIngredientsView extends StatelessWidget {
  const NoIngredientsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          Text(
            AppStrings.menuSuggestionEmpty,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
