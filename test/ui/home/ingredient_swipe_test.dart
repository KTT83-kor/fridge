import 'package:flutter_test/flutter_test.dart';
import 'package:fridge/app.dart';
import 'package:fridge/core/result/result.dart';
import 'package:fridge/data/repository/shelf_life_repository_impl.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/domain/entity/storage_place.dart';
import 'package:fridge/domain/repository/ingredient_repository.dart';

import '../../helper/fake_image_ingredient_parsing_repository.dart';
import '../../helper/fake_menu_suggestion_repository.dart';

class _InMemoryIngredientRepository implements IngredientRepository {
  _InMemoryIngredientRepository(List<Ingredient> ingredients)
    : _ingredients = [...ingredients];

  final List<Ingredient> _ingredients;
  final removedIds = <String>[];

  @override
  Stream<List<Ingredient>> watchAll() => Stream.value(_ingredients);

  @override
  Future<Result<void>> save(Ingredient ingredient) async {
    _ingredients.add(ingredient);
    return const ResultSuccess<void>(null);
  }

  @override
  Future<Result<void>> remove(String id) async {
    removedIds.add(id);
    _ingredients.removeWhere((ingredient) => ingredient.id == id);
    return const ResultSuccess<void>(null);
  }
}

void main() {
  testWidgets('재료를 밀면 삭제된다', (tester) async {
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
    final repository = _InMemoryIngredientRepository([milk]);

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

    await tester.drag(find.text('우유'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(repository.removedIds, ['milk']);
  });
}
