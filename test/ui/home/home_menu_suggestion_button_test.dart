import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridge/app.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/result/result.dart';
import 'package:fridge/data/repository/shelf_life_repository_impl.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/domain/entity/menu_suggestion.dart';
import 'package:fridge/domain/entity/storage_place.dart';
import 'package:fridge/domain/repository/ingredient_repository.dart';

import '../../helper/fake_menu_suggestion_repository.dart';
import '../../helper/fake_receipt_parsing_repository.dart';

class _EmptyIngredientRepository implements IngredientRepository {
  @override
  Stream<List<Ingredient>> watchAll() => Stream.value(const []);

  @override
  Future<Result<void>> save(Ingredient ingredient) async {
    return const ResultSuccess<void>(null);
  }

  @override
  Future<Result<void>> remove(String id) async {
    return const ResultSuccess<void>(null);
  }
}

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
  testWidgets('AppBar의 메뉴 추천 버튼을 누르면 메뉴 추천 화면이 열린다', (tester) async {
    final repository = _EmptyIngredientRepository();

    await tester.pumpWidget(
      FridgeApp(
        ingredientRepository: repository,
        shelfLifeRepository: const ShelfLifeRepositoryImpl(),
        menuSuggestionRepository: FakeMenuSuggestionRepository(),
        receiptParsingRepository: FakeReceiptParsingRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.restaurant_menu));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.menuSuggestionTitle), findsOneWidget);
  });

  testWidgets('재료가 없으면 추천할 수 없다는 안내를 보여준다', (tester) async {
    final repository = _EmptyIngredientRepository();

    await tester.pumpWidget(
      FridgeApp(
        ingredientRepository: repository,
        shelfLifeRepository: const ShelfLifeRepositoryImpl(),
        menuSuggestionRepository: FakeMenuSuggestionRepository(),
        receiptParsingRepository: FakeReceiptParsingRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.restaurant_menu));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.menuSuggestionEmpty), findsOneWidget);
  });

  testWidgets('재료가 있으면 추천 메뉴 카드를 보여준다', (tester) async {
    final today = DateTime.now();
    final tofu = Ingredient(
      id: 'tofu',
      name: '두부',
      amount: 1,
      unit: '모',
      storagePlace: StoragePlace.fridge,
      purchasedAt: today,
      expiresAt: today.add(const Duration(days: 3)),
    );
    const suggestion = MenuSuggestion(
      name: '두부조림',
      description: '두부로 만드는 조림',
      usedIngredientNames: ['두부'],
      steps: ['두부를 썬다', '조린다'],
    );
    final ingredientRepository = _FakeIngredientRepository([tofu]);
    final menuSuggestionRepository = FakeMenuSuggestionRepository(
      result: const ResultSuccess([suggestion]),
    );

    await tester.pumpWidget(
      FridgeApp(
        ingredientRepository: ingredientRepository,
        shelfLifeRepository: const ShelfLifeRepositoryImpl(),
        menuSuggestionRepository: menuSuggestionRepository,
        receiptParsingRepository: FakeReceiptParsingRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.restaurant_menu));
    await tester.pumpAndSettle();

    expect(find.text('두부조림'), findsOneWidget);
    expect(find.text('두부로 만드는 조림'), findsOneWidget);
  });
}
