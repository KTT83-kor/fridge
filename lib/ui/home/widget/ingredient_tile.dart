import 'package:flutter/material.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/formatter/d_day_formatter.dart';
import 'package:fridge/core/theme/app_spacing.dart';
import 'package:fridge/core/theme/freshness_color.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:intl/intl.dart';

class IngredientTile extends StatelessWidget {
  const IngredientTile({
    required this.ingredient,
    required this.today,
    required this.onRemoved,
    required this.onTap,
    super.key,
  });

  final Ingredient ingredient;
  final DateTime today;
  final VoidCallback onRemoved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysLeft = ingredient.daysLeftFrom(today);
    final freshness = ingredient.freshnessFrom(today);
    final freshnessColor = freshness.resolveColor(theme.colorScheme);
    final amountLabel = NumberFormat.decimalPattern().format(ingredient.amount);
    final subtitle =
        '$amountLabel${ingredient.unit} · ${ingredient.storagePlace.label}';

    void handleDismissed(DismissDirection direction) {
      onRemoved();
    }

    return Dismissible(
      key: ValueKey(ingredient.id),
      background: const _RemoveBackground(alignment: Alignment.centerLeft),
      secondaryBackground: const _RemoveBackground(
        alignment: Alignment.centerRight,
      ),
      onDismissed: handleDismissed,
      child: ListTile(
        onTap: onTap,
        leading: _DDayBadge(daysLeft: daysLeft, color: freshnessColor),
        title: Text(ingredient.name),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class _RemoveBackground extends StatelessWidget {
  const _RemoveBackground({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.errorContainer,
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.delete_outline,
                color: colorScheme.onErrorContainer,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppStrings.removeIngredient,
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DDayBadge extends StatelessWidget {
  const _DDayBadge({required this.daysLeft, required this.color});

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
      width: AppSpacing.xl * 1.5,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Text(label, style: labelStyle),
    );
  }
}
