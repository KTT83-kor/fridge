import 'package:flutter/material.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/theme/app_spacing.dart';
import 'package:fridge/ui/quick_add/quick_ingredient_draft.dart';
import 'package:fridge/ui/quick_add/widget/quick_ingredient_tile.dart';

class QuickIngredientReviewList extends StatelessWidget {
  const QuickIngredientReviewList({
    required this.drafts,
    required this.today,
    super.key,
  });

  final List<QuickIngredientDraft> drafts;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    if (drafts.isEmpty) return const _EmptyDraftsView();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(
          AppStrings.quickAddReviewHint,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        ..._buildTiles(),
      ],
    );
  }

  List<Widget> _buildTiles() {
    return List.generate(drafts.length, _buildTile);
  }

  Widget _buildTile(int index) {
    return QuickIngredientTile(
      key: ValueKey(index),
      index: index,
      draft: drafts[index],
      today: today,
    );
  }
}

class _EmptyDraftsView extends StatelessWidget {
  const _EmptyDraftsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Text(
        AppStrings.quickAddEmpty,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
    );
  }
}
