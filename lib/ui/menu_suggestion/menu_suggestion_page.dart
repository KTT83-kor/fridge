import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/theme/app_spacing.dart';
import 'package:fridge/domain/entity/menu_suggestion.dart';
import 'package:fridge/domain/repository/ingredient_repository.dart';
import 'package:fridge/domain/repository/menu_suggestion_repository.dart';
import 'package:fridge/ui/home/widget/load_failed_view.dart';
import 'package:fridge/ui/menu_suggestion/bloc/menu_suggestion_bloc.dart';
import 'package:fridge/ui/menu_suggestion/widget/menu_suggestion_card.dart';
import 'package:fridge/ui/menu_suggestion/widget/no_ingredients_view.dart';

class MenuSuggestionPage extends StatelessWidget {
  const MenuSuggestionPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (context) => const MenuSuggestionPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: _createBloc,
      child: const _MenuSuggestionView(),
    );
  }

  MenuSuggestionBloc _createBloc(BuildContext context) {
    return MenuSuggestionBloc(
      ingredientRepository: context.read<IngredientRepository>(),
      menuSuggestionRepository: context.read<MenuSuggestionRepository>(),
    );
  }
}

class _MenuSuggestionView extends StatelessWidget {
  const _MenuSuggestionView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.menuSuggestionTitle)),
      body: const _MenuSuggestionBody(),
    );
  }
}

class _MenuSuggestionBody extends StatelessWidget {
  const _MenuSuggestionBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuSuggestionBloc, MenuSuggestionState>(
      builder: _buildByStatus,
    );
  }

  Widget _buildByStatus(BuildContext context, MenuSuggestionState state) {
    void retry() {
      context.read<MenuSuggestionBloc>().add(const MenuSuggestionRequested());
    }

    switch (state.status) {
      case MenuSuggestionStatus.loading:
        return const _LoadingView();
      case MenuSuggestionStatus.noIngredients:
        return const NoIngredientsView();
      case MenuSuggestionStatus.failure:
        return LoadFailedView(message: state.errorMessage, onRetry: retry);
      case MenuSuggestionStatus.success:
        return _SuggestionList(
          suggestions: state.suggestions,
          onRetry: retry,
        );
    }
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppStrings.menuSuggestionLoading,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({required this.suggestions, required this.onRetry});

  final List<MenuSuggestion> suggestions;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        ..._buildCards(),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton(
          onPressed: onRetry,
          child: const Text(AppStrings.menuSuggestionRetry),
        ),
      ],
    );
  }

  List<Widget> _buildCards() {
    return suggestions.map(_buildCard).toList();
  }

  Widget _buildCard(MenuSuggestion suggestion) {
    return MenuSuggestionCard(suggestion: suggestion);
  }
}
