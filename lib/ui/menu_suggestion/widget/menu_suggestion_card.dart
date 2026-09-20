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
            const SizedBox(height: AppSpacing.sm),
            _RecipeSteps(steps: suggestion.steps),
          ],
        ),
      ),
    );
  }
}

class _RecipeSteps extends StatefulWidget {
  const _RecipeSteps({required this.steps});

  final List<String> steps;

  @override
  State<_RecipeSteps> createState() => _RecipeStepsState();
}

class _RecipeStepsState extends State<_RecipeSteps> {
  var _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    void toggleExpanded() {
      setState(() {
        _isExpanded = !_isExpanded;
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: toggleExpanded,
          icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
          label: const Text(AppStrings.menuSuggestionRecipe),
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
        ),
        if (_isExpanded) _buildStepList(context),
      ],
    );
  }

  Widget _buildStepList(BuildContext context) {
    final theme = Theme.of(context);
    final stepTexts = List.generate(widget.steps.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: Text(
          '${index + 1}. ${widget.steps[index]}',
          style: theme.textTheme.bodyMedium,
        ),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: stepTexts,
    );
  }
}
