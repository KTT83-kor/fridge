import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/ui/add_ingredient/add_ingredient_page.dart';
import 'package:fridge/ui/home/bloc/home_bloc.dart';
import 'package:fridge/ui/home/widget/empty_ingredient_view.dart';
import 'package:fridge/ui/home/widget/ingredient_list.dart';

class UrgentIngredientsPage extends StatelessWidget {
  const UrgentIngredientsPage({required this.homeBloc, super.key});

  final HomeBloc homeBloc;

  static Route<void> route({required HomeBloc homeBloc}) {
    return MaterialPageRoute<void>(
      builder: (context) => UrgentIngredientsPage(homeBloc: homeBloc),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: homeBloc,
      child: const _UrgentIngredientsView(),
    );
  }
}

class _UrgentIngredientsView extends StatelessWidget {
  const _UrgentIngredientsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.urgentIngredientsTitle),
      ),
      body: const _UrgentIngredientsBody(),
    );
  }
}

class _UrgentIngredientsBody extends StatelessWidget {
  const _UrgentIngredientsBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(builder: _buildBody);
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    Future<void> openEditIngredient(Ingredient ingredient) async {
      final messenger = ScaffoldMessenger.of(context);
      final saved = await Navigator.of(
        context,
      ).push(AddIngredientPage.route(initial: ingredient));
      if (saved != true) return;

      const snackBar = SnackBar(content: Text(AppStrings.ingredientUpdated));
      messenger.showSnackBar(snackBar);
    }

    final urgentIngredients = state.urgentIngredientsFrom(DateTime.now());
    if (urgentIngredients.isEmpty) {
      return const EmptyIngredientView(
        title: AppStrings.urgentIngredientsEmpty,
        hint: null,
      );
    }

    return IngredientList(
      ingredients: urgentIngredients,
      onTileTapped: openEditIngredient,
    );
  }
}
