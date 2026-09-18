import 'package:fridge/core/result/result.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/domain/entity/menu_suggestion.dart';
import 'package:fridge/domain/repository/menu_suggestion_repository.dart';
import 'package:fridge/domain/usecase/sort_ingredients_by_urgency.dart';

class SuggestMenusForOneMeal {
  const SuggestMenusForOneMeal(
    this._repository, {
    this.sortByUrgency = const SortIngredientsByUrgency(),
  });

  final MenuSuggestionRepository _repository;
  final SortIngredientsByUrgency sortByUrgency;

  Future<Result<List<MenuSuggestion>>> call(
    List<Ingredient> ingredients,
    DateTime today,
  ) {
    final sorted = sortByUrgency(ingredients, today);
    return _repository.suggestForOneMeal(sorted);
  }
}
