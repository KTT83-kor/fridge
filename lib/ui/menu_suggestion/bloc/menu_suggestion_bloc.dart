import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fridge/core/result/result.dart';
import 'package:fridge/domain/entity/menu_suggestion.dart';
import 'package:fridge/domain/repository/ingredient_repository.dart';
import 'package:fridge/domain/repository/menu_suggestion_repository.dart';
import 'package:fridge/domain/usecase/suggest_menus_for_one_meal.dart';

part 'menu_suggestion_event.dart';
part 'menu_suggestion_state.dart';

class MenuSuggestionBloc
    extends Bloc<MenuSuggestionEvent, MenuSuggestionState> {
  MenuSuggestionBloc({
    required IngredientRepository ingredientRepository,
    required MenuSuggestionRepository menuSuggestionRepository,
    DateTime? today,
  }) : _ingredientRepository = ingredientRepository,
       _suggestMenus = SuggestMenusForOneMeal(menuSuggestionRepository),
       _today = today ?? DateTime.now(),
       super(const MenuSuggestionState()) {
    on<MenuSuggestionRequested>(_onRequested);
    add(const MenuSuggestionRequested());
  }

  final IngredientRepository _ingredientRepository;
  final SuggestMenusForOneMeal _suggestMenus;
  final DateTime _today;

  Future<void> _onRequested(
    MenuSuggestionRequested event,
    Emitter<MenuSuggestionState> emit,
  ) async {
    emit(state.copyWith(status: MenuSuggestionStatus.loading));

    final ingredients = await _ingredientRepository.watchAll().first;
    if (ingredients.isEmpty) {
      emit(state.copyWith(status: MenuSuggestionStatus.noIngredients));
      return;
    }

    final result = await _suggestMenus(ingredients, _today);
    switch (result) {
      case ResultSuccess<List<MenuSuggestion>>(:final value):
        emit(
          state.copyWith(
            status: MenuSuggestionStatus.success,
            suggestions: value,
          ),
        );
      case ResultFailure<List<MenuSuggestion>>(:final message):
        emit(
          state.copyWith(
            status: MenuSuggestionStatus.failure,
            errorMessage: message,
          ),
        );
    }
  }
}
