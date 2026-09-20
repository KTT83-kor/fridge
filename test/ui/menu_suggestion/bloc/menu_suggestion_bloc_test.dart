import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridge/core/result/result.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/domain/entity/menu_suggestion.dart';
import 'package:fridge/domain/entity/storage_place.dart';
import 'package:fridge/domain/repository/ingredient_repository.dart';
import 'package:fridge/domain/repository/menu_suggestion_repository.dart';
import 'package:fridge/ui/menu_suggestion/bloc/menu_suggestion_bloc.dart';

class _FakeIngredientRepository implements IngredientRepository {
  _FakeIngredientRepository(this._ingredients);

  final List<Ingredient> _ingredients;

  @override
  Stream<List<Ingredient>> watchAll() => Stream.value(_ingredients);

  @override
  Future<Result<void>> save(Ingredient ingredient) async {
    return const ResultSuccess<void>(null);
  }

  @override
  Future<Result<void>> remove(String id) async {
    return const ResultSuccess<void>(null);
  }
}

class _FakeMenuSuggestionRepository implements MenuSuggestionRepository {
  _FakeMenuSuggestionRepository(this._result);

  final Result<List<MenuSuggestion>> _result;
  List<Ingredient>? receivedIngredients;

  @override
  Future<Result<List<MenuSuggestion>>> suggestForOneMeal(
    List<Ingredient> ingredients,
  ) async {
    receivedIngredients = ingredients;
    return _result;
  }
}

void main() {
  final today = DateTime(2026, 9, 17);

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

  blocTest<MenuSuggestionBloc, MenuSuggestionState>(
    '재료가 없으면 재료 없음 상태가 된다',
    build: () {
      final ingredientRepository = _FakeIngredientRepository(const []);
      final menuSuggestionRepository = _FakeMenuSuggestionRepository(
        const ResultSuccess([]),
      );
      return MenuSuggestionBloc(
        ingredientRepository: ingredientRepository,
        menuSuggestionRepository: menuSuggestionRepository,
        today: today,
      );
    },
    wait: const Duration(milliseconds: 10),
    verify: (bloc) {
      expect(bloc.state.status, MenuSuggestionStatus.noIngredients);
    },
  );

  test('재료가 있으면 임박한 순으로 정렬해서 추천 저장소에 넘긴다', () async {
    final ingredientRepository = _FakeIngredientRepository([
      buildIngredient('양파', 10),
      buildIngredient('우유', 1),
    ]);
    final menuSuggestionRepository = _FakeMenuSuggestionRepository(
      const ResultSuccess([]),
    );
    final bloc = MenuSuggestionBloc(
      ingredientRepository: ingredientRepository,
      menuSuggestionRepository: menuSuggestionRepository,
      today: today,
    );

    await Future<void>.delayed(const Duration(milliseconds: 10));

    final receivedNames = menuSuggestionRepository.receivedIngredients!
        .map((ingredient) => ingredient.name)
        .toList();
    expect(receivedNames, ['우유', '양파']);

    await bloc.close();
  });

  blocTest<MenuSuggestionBloc, MenuSuggestionState>(
    '추천에 성공하면 성공 상태로 목록을 담는다',
    build: () {
      const suggestion = MenuSuggestion(
        name: '두부조림',
        description: '두부와 양파로 만드는 조림',
        usedIngredientNames: ['두부', '양파'],
        steps: ['두부와 양파를 썬다', '양념을 넣고 조린다'],
      );
      final ingredientRepository = _FakeIngredientRepository([
        buildIngredient('두부', 3),
      ]);
      final menuSuggestionRepository = _FakeMenuSuggestionRepository(
        const ResultSuccess([suggestion]),
      );
      return MenuSuggestionBloc(
        ingredientRepository: ingredientRepository,
        menuSuggestionRepository: menuSuggestionRepository,
        today: today,
      );
    },
    wait: const Duration(milliseconds: 10),
    verify: (bloc) {
      expect(bloc.state.status, MenuSuggestionStatus.success);
      expect(bloc.state.suggestions.single.name, '두부조림');
    },
  );

  blocTest<MenuSuggestionBloc, MenuSuggestionState>(
    '추천에 실패하면 실패 상태와 메시지를 남긴다',
    build: () {
      final ingredientRepository = _FakeIngredientRepository([
        buildIngredient('두부', 3),
      ]);
      final menuSuggestionRepository = _FakeMenuSuggestionRepository(
        const ResultFailure('메뉴를 추천받지 못했습니다'),
      );
      return MenuSuggestionBloc(
        ingredientRepository: ingredientRepository,
        menuSuggestionRepository: menuSuggestionRepository,
        today: today,
      );
    },
    wait: const Duration(milliseconds: 10),
    verify: (bloc) {
      expect(bloc.state.status, MenuSuggestionStatus.failure);
      expect(bloc.state.errorMessage, '메뉴를 추천받지 못했습니다');
    },
  );

  blocTest<MenuSuggestionBloc, MenuSuggestionState>(
    '다시 요청하면 로딩 상태를 거쳐 새로 추천한다',
    build: () {
      final ingredientRepository = _FakeIngredientRepository([
        buildIngredient('두부', 3),
      ]);
      final menuSuggestionRepository = _FakeMenuSuggestionRepository(
        const ResultSuccess([]),
      );
      return MenuSuggestionBloc(
        ingredientRepository: ingredientRepository,
        menuSuggestionRepository: menuSuggestionRepository,
        today: today,
      );
    },
    wait: const Duration(milliseconds: 10),
    act: (bloc) => bloc.add(const MenuSuggestionRequested()),
    expect: () => [
      const MenuSuggestionState(),
      const MenuSuggestionState(status: MenuSuggestionStatus.success),
    ],
  );
}
