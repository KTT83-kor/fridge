import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fridge/core/theme/app_spacing.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/ui/home/bloc/home_bloc.dart';
import 'package:fridge/ui/home/widget/ingredient_tile.dart';

class IngredientList extends StatelessWidget {
  const IngredientList({required this.ingredients, super.key});

  final List<Ingredient> ingredients;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: ingredients.length,
      separatorBuilder: _buildSeparator,
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        void removeIngredient() {
          context.read<HomeBloc>().add(HomeIngredientRemoved(ingredient.id));
        }

        return IngredientTile(
          ingredient: ingredient,
          today: today,
          onRemoved: removeIngredient,
        );
      },
    );
  }

  Widget _buildSeparator(BuildContext context, int index) {
    return const Divider(height: 1);
  }
}
