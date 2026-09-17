import 'package:flutter_test/flutter_test.dart';
import 'package:fridge/core/result/result.dart';
import 'package:fridge/data/datasource/ingredient_local_data_source.dart';
import 'package:fridge/data/repository/ingredient_repository_impl.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/domain/entity/storage_place.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final today = DateTime(2026, 9, 17);

  Ingredient buildIngredient(String id, String name) {
    return Ingredient(
      id: id,
      name: name,
      amount: 1,
      unit: '개',
      storagePlace: StoragePlace.fridge,
      purchasedAt: today,
      expiresAt: today.add(const Duration(days: 3)),
    );
  }

  Future<IngredientRepositoryImpl> buildRepository() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    return IngredientRepositoryImpl(IngredientLocalDataSource(preferences));
  }

  test('저장소가 비어 있어도 첫 재료를 저장한다', () async {
    final repository = await buildRepository();

    final result = await repository.save(buildIngredient('milk', '우유'));

    expect(result, isA<ResultSuccess<void>>());
    expect(await repository.watchAll().first, hasLength(1));
  });

  test('저장한 재료를 다시 읽는다', () async {
    final repository = await buildRepository();
    await repository.save(buildIngredient('milk', '우유'));

    final stored = await repository.watchAll().first;

    expect(stored.single.name, '우유');
    expect(stored.single.expiresAt, DateTime(2026, 9, 20));
  });

  test('같은 id로 저장하면 덮어쓴다', () async {
    final repository = await buildRepository();
    await repository.save(buildIngredient('milk', '우유'));
    await repository.save(buildIngredient('milk', '저지방우유'));

    final stored = await repository.watchAll().first;

    expect(stored, hasLength(1));
    expect(stored.single.name, '저지방우유');
  });

  test('재료를 지운다', () async {
    final repository = await buildRepository();
    await repository.save(buildIngredient('milk', '우유'));
    await repository.save(buildIngredient('tofu', '두부'));

    await repository.remove('milk');
    final stored = await repository.watchAll().first;

    expect(stored.single.name, '두부');
  });

  test('저장하면 스트림으로 바뀐 목록을 흘려보낸다', () async {
    final repository = await buildRepository();
    final emitted = <List<Ingredient>>[];
    final subscription = repository.watchAll().listen(emitted.add);
    await Future<void>.delayed(Duration.zero);

    await repository.save(buildIngredient('milk', '우유'));
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(emitted.first, isEmpty);
    expect(emitted.last.single.name, '우유');
  });
}
