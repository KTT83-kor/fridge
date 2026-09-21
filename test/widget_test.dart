import 'package:flutter_test/flutter_test.dart';
import 'package:fridge/app.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/result/result.dart';
import 'package:fridge/data/repository/shelf_life_repository_impl.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/domain/entity/storage_place.dart';
import 'package:fridge/domain/repository/ingredient_repository.dart';

import 'helper/fake_image_ingredient_parsing_repository.dart';
import 'helper/fake_menu_suggestion_repository.dart';

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

void main() {
  testWidgets('재료가 없으면 빈 상태 안내를 보여준다', (tester) async {
    final repository = _FakeIngredientRepository(const []);

    await tester.pumpWidget(
      FridgeApp(
        ingredientRepository: repository,
        shelfLifeRepository: const ShelfLifeRepositoryImpl(),
        menuSuggestionRepository: FakeMenuSuggestionRepository(),
        imageIngredientParsingRepository:
            FakeImageIngredientParsingRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.emptyIngredients), findsOneWidget);
  });

  testWidgets('재료가 있으면 이름과 남은 기한을 보여준다', (tester) async {
    final today = DateTime.now();
    final milk = Ingredient(
      id: 'milk',
      name: '우유',
      amount: 1,
      unit: 'L',
      storagePlace: StoragePlace.fridge,
      purchasedAt: today,
      expiresAt: today.add(const Duration(days: 2)),
    );
    final repository = _FakeIngredientRepository([milk]);

    await tester.pumpWidget(
      FridgeApp(
        ingredientRepository: repository,
        shelfLifeRepository: const ShelfLifeRepositoryImpl(),
        menuSuggestionRepository: FakeMenuSuggestionRepository(),
        imageIngredientParsingRepository:
            FakeImageIngredientParsingRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('우유'), findsOneWidget);
    expect(find.text('D-2'), findsOneWidget);
  });
}
