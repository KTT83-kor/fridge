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
    super.key,
  });

  final Ingredient ingredient;
  final DateTime today;
  final VoidCallback onRemoved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysLeft = ingredient.daysLeftFrom(today);
    final freshness = ingredient.freshnessFrom(today);
    final freshnessColor = freshness.resolveColor(theme.colorScheme);
    final amountLabel = NumberFormat.decimalPattern().format(ingredient.amount);
    final subtitle =
        '$amountLabel${ingredient.unit} · ${ingredient.storagePlace.label}';

    return ListTile(
      leading: _DDayBadge(daysLeft: daysLeft, color: freshnessColor),
      title: Text(ingredient.name),
      subtitle: Text(subtitle),
      trailing: IconButton(
        onPressed: onRemoved,
        icon: const Icon(Icons.close),
        tooltip: AppStrings.removeIngredient,
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
