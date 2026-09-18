import 'package:fridge/core/result/result.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/domain/entity/menu_suggestion.dart';
import 'package:fridge/domain/repository/menu_suggestion_repository.dart';

class FakeMenuSuggestionRepository implements MenuSuggestionRepository {
  FakeMenuSuggestionRepository({
    Result<List<MenuSuggestion>> result = const ResultSuccess([]),
  }) : _result = result;

  final Result<List<MenuSuggestion>> _result;

  @override
  Future<Result<List<MenuSuggestion>>> suggestForOneMeal(
    List<Ingredient> ingredients,
  ) async {
    return _result;
  }
}
