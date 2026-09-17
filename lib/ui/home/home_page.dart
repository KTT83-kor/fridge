import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/domain/repository/ingredient_repository.dart';
import 'package:fridge/ui/add_ingredient/add_ingredient_page.dart';
import 'package:fridge/ui/home/bloc/home_bloc.dart';
import 'package:fridge/ui/home/widget/empty_ingredient_view.dart';
import 'package:fridge/ui/home/widget/ingredient_list.dart';
import 'package:fridge/ui/home/widget/load_failed_view.dart';

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
    Future<void> openAddIngredient() async {
      final messenger = ScaffoldMessenger.of(context);
      final saved = await Navigator.of(context).push(AddIngredientPage.route());
      if (saved != true) return;

      const snackBar = SnackBar(content: Text(AppStrings.ingredientSaved));
      messenger.showSnackBar(snackBar);
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appTitle)),
      body: const _HomeBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddIngredient,
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addIngredient),
      ),
    );
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

    switch (state.status) {
      case HomeStatus.initial:
      case HomeStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case HomeStatus.failure:
        return LoadFailedView(message: state.errorMessage, onRetry: reload);
      case HomeStatus.success:
        if (state.ingredients.isEmpty) {
          return const EmptyIngredientView();
        }
        return IngredientList(ingredients: state.ingredients);
    }
  }
}
