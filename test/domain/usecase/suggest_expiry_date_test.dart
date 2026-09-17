import 'package:flutter_test/flutter_test.dart';
import 'package:fridge/data/repository/shelf_life_repository_impl.dart';
import 'package:fridge/domain/entity/storage_place.dart';
import 'package:fridge/domain/usecase/suggest_expiry_date.dart';

void main() {
  const suggestExpiryDate = SuggestExpiryDate(ShelfLifeRepositoryImpl());
  final purchasedAt = DateTime(2026, 9, 17);

  group('SuggestExpiryDate', () {
    test('표에 있는 재료는 보관 일수를 더한 날짜를 준다', () {
      final expiresAt = suggestExpiryDate(
        name: '우유',
        storagePlace: StoragePlace.fridge,
        purchasedAt: purchasedAt,
      );

      expect(expiresAt, DateTime(2026, 9, 24));
    });

    test('냉동이면 더 먼 날짜를 준다', () {
      final frozen = suggestExpiryDate(
        name: '돼지고기',
        storagePlace: StoragePlace.freezer,
        purchasedAt: purchasedAt,
      );

      expect(frozen, DateTime(2027, 1, 15));
    });

    test('표에 없는 재료는 null을 준다', () {
      final expiresAt = suggestExpiryDate(
        name: '트러플',
        storagePlace: StoragePlace.fridge,
        purchasedAt: purchasedAt,
      );

      expect(expiresAt, isNull);
    });

    test('산 날짜의 시각은 버리고 자정으로 맞춘다', () {
      final expiresAt = suggestExpiryDate(
        name: '우유',
        storagePlace: StoragePlace.fridge,
        purchasedAt: DateTime(2026, 9, 17, 22, 30),
      );

      expect(expiresAt, DateTime(2026, 9, 24));
    });
  });
}
