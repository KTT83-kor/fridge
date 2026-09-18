import 'package:flutter/material.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/theme/app_spacing.dart';
import 'package:fridge/domain/entity/menu_suggestion.dart';

class MenuSuggestionCard extends StatelessWidget {
  const MenuSuggestionCard({required this.suggestion, super.key});

  final MenuSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usedIngredients = suggestion.usedIngredientNames.join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(suggestion.name, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(suggestion.description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${AppStrings.menuSuggestionUsedIngredients}: $usedIngredients',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
