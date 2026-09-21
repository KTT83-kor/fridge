import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/domain/repository/ingredient_repository.dart';
import 'package:fridge/ui/add_ingredient/add_ingredient_page.dart';
import 'package:fridge/ui/home/bloc/home_bloc.dart';
import 'package:fridge/ui/home/urgent_ingredients_page.dart';
import 'package:fridge/ui/home/widget/empty_ingredient_view.dart';
import 'package:fridge/ui/home/widget/ingredient_list.dart';
import 'package:fridge/ui/home/widget/load_failed_view.dart';
import 'package:fridge/ui/home/widget/urgent_banner.dart';
import 'package:fridge/ui/menu_suggestion/menu_suggestion_page.dart';
import 'package:fridge/ui/quick_add/quick_add_page.dart';

enum _AddIngredientAction { quickAdd, oneByOne }

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: _createBloc, child: const _HomeView());
  }

  HomeBloc _createBloc(BuildContext context) {
    final repository = context.read<IngredientRepository>();
    return HomeBloc(repository: repository)..add(const HomeStarted());
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    Future<void> openQuickAdd() async {
      final messenger = ScaffoldMessenger.of(context);
      final saved = await Navigator.of(context).push(QuickAddPage.route());
      if (saved != true) return;

      const snackBar = SnackBar(content: Text(AppStrings.ingredientSaved));
      messenger.showSnackBar(snackBar);
    }

    Future<void> openAddIngredient() async {
      final messenger = ScaffoldMessenger.of(context);
      final saved = await Navigator.of(context).push(AddIngredientPage.route());
      if (saved != true) return;

      const snackBar = SnackBar(content: Text(AppStrings.ingredientSaved));
      messenger.showSnackBar(snackBar);
    }

    void handleAction(_AddIngredientAction action) {
      switch (action) {
        case _AddIngredientAction.quickAdd:
          unawaited(openQuickAdd());
        case _AddIngredientAction.oneByOne:
          unawaited(openAddIngredient());
      }
    }

    void openMenuSuggestion() {
      unawaited(Navigator.of(context).push(MenuSuggestionPage.route()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appTitle),
        actions: [
          IconButton(
            onPressed: openMenuSuggestion,
            icon: const Icon(Icons.restaurant_menu),
            tooltip: AppStrings.menuSuggestionTitle,
          ),
        ],
      ),
      body: const _HomeBody(),
      floatingActionButton: PopupMenuButton<_AddIngredientAction>(
        onSelected: handleAction,
        itemBuilder: _buildMenuItems,
        child: const FloatingActionButton.extended(
          onPressed: null,
          icon: Icon(Icons.add),
          label: Text(AppStrings.addIngredient),
        ),
      ),
    );
  }

  List<PopupMenuEntry<_AddIngredientAction>> _buildMenuItems(
    BuildContext context,
  ) {
    return const [
      PopupMenuItem(
        value: _AddIngredientAction.quickAdd,
        child: Text(AppStrings.quickAddTitle),
      ),
      PopupMenuItem(
        value: _AddIngredientAction.oneByOne,
        child: Text(AppStrings.addIngredientOneByOne),
      ),
    ];
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listenWhen: _hasNewErrorMessage,
      listener: _showErrorSnackBar,
      builder: _buildByStatus,
    );
  }

  bool _hasNewErrorMessage(HomeState previous, HomeState current) {
    return current.errorMessage.isNotEmpty &&
        previous.errorMessage != current.errorMessage &&
        current.status != HomeStatus.failure;
  }

  void _showErrorSnackBar(BuildContext context, HomeState state) {
    final snackBar = SnackBar(content: Text(state.errorMessage));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _buildByStatus(BuildContext context, HomeState state) {
    void reload() {
      context.read<HomeBloc>().add(const HomeStarted());
    }

    Future<void> openEditIngredient(Ingredient ingredient) async {
      final messenger = ScaffoldMessenger.of(context);
      final saved = await Navigator.of(
        context,
      ).push(AddIngredientPage.route(initial: ingredient));
      if (saved != true) return;

      const snackBar = SnackBar(content: Text(AppStrings.ingredientUpdated));
      messenger.showSnackBar(snackBar);
    }

    void openUrgentIngredients() {
      final homeBloc = context.read<HomeBloc>();
      final route = UrgentIngredientsPage.route(homeBloc: homeBloc);
      unawaited(Navigator.of(context).push(route));
    }

    switch (state.status) {
      case HomeStatus.initial:
      case HomeStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case HomeStatus.failure:
        return LoadFailedView(message: state.errorMessage, onRetry: reload);
      case HomeStatus.success:
        final urgentIngredients = state.urgentIngredientsFrom(DateTime.now());
        final banner = urgentIngredients.isEmpty
            ? null
            : UrgentBanner(
                count: urgentIngredients.length,
                onTap: openUrgentIngredients,
              );

        if (state.ingredients.isEmpty) {
          return Column(
            children: [
              ?banner,
              const Expanded(child: EmptyIngredientView()),
            ],
          );
        }
        return Column(
          children: [
            ?banner,
            Expanded(
              child: IngredientList(
                ingredients: state.ingredients,
                onTileTapped: openEditIngredient,
              ),
            ),
          ],
        );
    }
  }
}
