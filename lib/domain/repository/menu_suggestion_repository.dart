import 'package:fridge/core/result/result.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/domain/entity/menu_suggestion.dart';

abstract interface class MenuSuggestionRepository {
  Future<Result<List<MenuSuggestion>>> suggestForOneMeal(
    List<Ingredient> ingredients,
  );
}
