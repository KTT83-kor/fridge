import 'package:flutter_test/flutter_test.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/domain/entity/storage_place.dart';
import 'package:fridge/domain/usecase/sort_ingredients_by_urgency.dart';

void main() {
  const sortByUrgency = SortIngredientsByUrgency();
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

  group('SortIngredientsByUrgency', () {
    test('임박한 재료가 앞에 온다', () {
      final ingredients = [
        buildIngredient('양파', 10),
        buildIngredient('우유', 1),
        buildIngredient('두부', 4),
      ];

      final sorted = sortByUrgency(ingredients, today);
      final names = sorted.map((ingredient) => ingredient.name).toList();

      expect(names, ['우유', '두부', '양파']);
    });

    test('남은 날이 같으면 이름순으로 정렬한다', () {
      final ingredients = [
        buildIngredient('파프리카', 3),
        buildIngredient('계란', 3),
      ];

      final sorted = sortByUrgency(ingredients, today);
      final names = sorted.map((ingredient) => ingredient.name).toList();

      expect(names, ['계란', '파프리카']);
    });

    test('원본 리스트를 바꾸지 않는다', () {
      final ingredients = [
        buildIngredient('양파', 10),
        buildIngredient('우유', 1),
      ];

      sortByUrgency(ingredients, today);

      expect(ingredients.first.name, '양파');
    });
  });
}
