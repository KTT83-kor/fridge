import 'package:flutter_test/flutter_test.dart';
import 'package:fridge/data/datasource/shelf_life_table.dart';
import 'package:fridge/data/repository/shelf_life_repository_impl.dart';
import 'package:fridge/domain/entity/storage_place.dart';

void main() {
  const repository = ShelfLifeRepositoryImpl();

  group('ShelfLifeTable', () {
    test('보관기간 표는 100종이다', () {
      expect(ShelfLifeTable.entries, hasLength(100));
    });

    test('이름이 겹치는 항목이 없다', () {
      final names = ShelfLifeTable.entries.map((entry) => entry.name).toSet();

      expect(names, hasLength(ShelfLifeTable.entries.length));
    });

    test('모든 항목의 보관 일수는 1일 이상이다', () {
      for (final entry in ShelfLifeTable.entries) {
        expect(entry.fridgeDays, greaterThan(0), reason: entry.name);
        expect(entry.freezerDays, greaterThan(0), reason: entry.name);
        expect(entry.pantryDays, greaterThan(0), reason: entry.name);
      }
    });
  });

  group('findByName', () {
    test('이름이 정확히 같으면 찾는다', () {
      final found = repository.findByName('우유');

      expect(found?.name, '우유');
      expect(found?.fridgeDays, 7);
    });

    test('앞뒤 공백과 사이 공백을 무시한다', () {
      final found = repository.findByName(' 닭 가슴살 ');

      expect(found?.name, '닭가슴살');
    });

    test('표에 없으면 null을 준다', () {
      expect(repository.findByName('트러플'), isNull);
    });

    test('빈 문자열이면 null을 준다', () {
      expect(repository.findByName('   '), isNull);
    });
  });

  group('search', () {
    test('앞에서부터 일치하는 항목을 먼저 준다', () {
      final found = repository.search('닭');
      final names = found.map((entry) => entry.name).toList();

      expect(names.first, startsWith('닭'));
    });

    test('limit보다 많이 주지 않는다', () {
      final found = repository.search('고', limit: 3);

      expect(found.length, lessThanOrEqualTo(3));
    });

    test('빈 문자열이면 빈 목록을 준다', () {
      expect(repository.search(''), isEmpty);
    });
  });

  group('daysFor', () {
    test('보관 장소마다 다른 일수를 준다', () {
      final pork = repository.findByName('돼지고기');

      expect(pork?.daysFor(StoragePlace.fridge), 3);
      expect(pork?.daysFor(StoragePlace.freezer), 120);
      expect(pork?.daysFor(StoragePlace.pantry), 1);
    });
  });
}
