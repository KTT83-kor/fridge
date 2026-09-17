import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridge/app.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/result/result.dart';
import 'package:fridge/data/repository/shelf_life_repository_impl.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/domain/repository/ingredient_repository.dart';

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

void main() {
  testWidgets('FAB을 누르면 담기 방식을 고르는 메뉴가 뜬다', (tester) async {
    final repository = _EmptyIngredientRepository();

    await tester.pumpWidget(
      FridgeApp(
        ingredientRepository: repository,
        shelfLifeRepository: const ShelfLifeRepositoryImpl(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.quickAddTitle), findsOneWidget);
    expect(find.text(AppStrings.addIngredientOneByOne), findsOneWidget);
  });

  testWidgets('빠른 입력을 고르면 빠른 입력 화면이 열린다', (tester) async {
    final repository = _EmptyIngredientRepository();

    await tester.pumpWidget(
      FridgeApp(
        ingredientRepository: repository,
        shelfLifeRepository: const ShelfLifeRepositoryImpl(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.quickAddTitle));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.quickAddHint), findsOneWidget);
  });

  testWidgets('하나씩 담기를 고르면 재료 담기 화면이 열린다', (tester) async {
    final repository = _EmptyIngredientRepository();

    await tester.pumpWidget(
      FridgeApp(
        ingredientRepository: repository,
        shelfLifeRepository: const ShelfLifeRepositoryImpl(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.addIngredientOneByOne));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.addIngredientTitle), findsOneWidget);
  });
}
