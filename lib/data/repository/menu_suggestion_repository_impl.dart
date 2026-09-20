import 'dart:convert';

import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/result/result.dart';
import 'package:fridge/data/datasource/gemini_menu_data_source.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/domain/entity/menu_suggestion.dart';
import 'package:fridge/domain/repository/menu_suggestion_repository.dart';

class MenuSuggestionRepositoryImpl implements MenuSuggestionRepository {
  const MenuSuggestionRepositoryImpl(this._dataSource);

  final GeminiMenuDataSource _dataSource;

  @override
  Future<Result<List<MenuSuggestion>>> suggestForOneMeal(
    List<Ingredient> ingredients,
  ) async {
    try {
      final responseText = await _dataSource.generateMenuSuggestions(
        ingredients,
      );
      final suggestions = _parseSuggestions(responseText);
      return ResultSuccess(suggestions);
    } on GeminiApiKeyMissingException catch (error) {
      return ResultFailure(
        AppStrings.menuSuggestionApiKeyMissing,
        cause: error,
      );
    } on GeminiRequestException catch (error) {
      return ResultFailure(_messageFor(error), cause: error);
    } on Exception catch (error) {
      return ResultFailure(AppStrings.menuSuggestionFailed, cause: error);
    }
  }

  String _messageFor(GeminiRequestException error) {
    switch (error.statusCode) {
      case 503:
        return AppStrings.menuSuggestionOverloaded;
      case 429:
        return AppStrings.menuSuggestionQuotaExceeded;
      default:
        return AppStrings.menuSuggestionFailedWithCode(error.statusCode);
    }
  }

  List<MenuSuggestion> _parseSuggestions(String responseText) {
    final decoded = jsonDecode(responseText) as List<dynamic>;
    return decoded.map(_toSuggestion).toList();
  }

  MenuSuggestion _toSuggestion(dynamic json) {
    final map = json as Map<String, dynamic>;
    final usedIngredientNames = (map['usedIngredientNames'] as List<dynamic>)
        .map((name) => name as String)
        .toList();
    final steps = (map['steps'] as List<dynamic>)
        .map((step) => step as String)
        .toList();

    return MenuSuggestion(
      name: map['name'] as String,
      description: map['description'] as String,
      usedIngredientNames: usedIngredientNames,
      steps: steps,
    );
  }
}
