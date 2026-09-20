import 'package:flutter_test/flutter_test.dart';
import 'package:fridge/core/result/result.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/domain/entity/menu_suggestion.dart';
import 'package:fridge/domain/entity/storage_place.dart';
import 'package:fridge/domain/repository/menu_suggestion_repository.dart';
import 'package:fridge/domain/usecase/suggest_menus_for_one_meal.dart';

class _RecordingMenuSuggestionRepository implements MenuSuggestionRepository {
  List<Ingredient>? receivedIngredients;
  Result<List<MenuSuggestion>> result = const ResultSuccess([]);

  @override
  Future<Result<List<MenuSuggestion>>> suggestForOneMeal(
    List<Ingredient> ingredients,
  ) async {
    receivedIngredients = ingredients;
    return result;
  }
}

void main() {
  final today = DateTime(2026, 9, 17);
  late _RecordingMenuSuggestionRepository repository;

  Ingredient buildIngredient(String name, int daysLeft) {
    return Ingredient(
      id: name,
      name: name,
      amount: 1,
      unit: '개',
      storagePlace: StoragePlace.fridge,
      purchasedAt: today,
      expiresAt: today.add(Duration(days: daysLeft)),
    );
  }

  setUp(() {
    repository = _RecordingMenuSuggestionRepository();
  });

  test('임박한 재료 순으로 정렬해서 리포지토리에 넘긴다', () async {
    final usecase = SuggestMenusForOneMeal(repository);
    final ingredients = [
      buildIngredient('양파', 10),
      buildIngredient('우유', 1),
      buildIngredient('두부', 4),
    ];

    await usecase(ingredients, today);

    final receivedNames = repository.receivedIngredients!
        .map((ingredient) => ingredient.name)
        .toList();
    expect(receivedNames, ['우유', '두부', '양파']);
  });

  test('리포지토리의 결과를 그대로 돌려준다', () async {
    const suggestion = MenuSuggestion(
      name: '두부조림',
      description: '두부와 양파로 만드는 조림',
      usedIngredientNames: ['두부', '양파'],
      steps: ['두부와 양파를 썬다', '양념을 넣고 조린다'],
    );
    repository.result = const ResultSuccess([suggestion]);
    final usecase = SuggestMenusForOneMeal(repository);

    final result = await usecase([buildIngredient('두부', 3)], today);

    expect(result, isA<ResultSuccess<List<MenuSuggestion>>>());
    final success = result as ResultSuccess<List<MenuSuggestion>>;
    expect(success.value.single.name, '두부조림');
  });
}
