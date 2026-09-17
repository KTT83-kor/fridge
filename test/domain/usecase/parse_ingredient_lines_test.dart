import 'package:flutter_test/flutter_test.dart';
import 'package:fridge/domain/entity/storage_place.dart';
import 'package:fridge/domain/usecase/parse_ingredient_lines.dart';

void main() {
  const parseLines = ParseIngredientLines();

  group('ParseIngredientLines', () {
    test('줄바꿈으로 여러 재료를 나눈다', () {
      final result = parseLines('우유 2L\n두부 1모');

      expect(result, hasLength(2));
      expect(result[0].name, '우유');
      expect(result[1].name, '두부');
    });

    test('빈 줄은 건너뛴다', () {
      final result = parseLines('우유 2L\n\n\n두부 1모');

      expect(result, hasLength(2));
    });

    test('이름, 수량, 단위, 보관 장소를 모두 읽는다', () {
      final result = parseLines('돼지고기 300g 냉동').single;

      expect(result.name, '돼지고기');
      expect(result.amount, 300);
      expect(result.unit, 'g');
      expect(result.storagePlace, StoragePlace.freezer);
    });

    test('보관 장소를 안 쓰면 null이다', () {
      final result = parseLines('우유 2L').single;

      expect(result.storagePlace, isNull);
    });

    test('수량 단위를 안 쓰면 이름만 읽고 수량은 1로 본다', () {
      final result = parseLines('우유').single;

      expect(result.name, '우유');
      expect(result.amount, isNull);
    });

    test('소수 수량을 읽는다', () {
      final result = parseLines('우유 1.5L').single;

      expect(result.amount, 1.5);
      expect(result.unit, 'L');
    });

    test('여러 단어 이름을 합쳐서 읽는다', () {
      final result = parseLines('방울 토마토 200g').single;

      expect(result.name, '방울 토마토');
      expect(result.amount, 200);
    });

    test('인식하지 못한 조각은 이름에 남고 수량은 비운다', () {
      final result = parseLines('계란 한판').single;

      expect(result.name, '계란 한판');
      expect(result.amount, isNull);
      expect(result.unit, isNull);
    });

    test('줄 앞뒤 공백을 정리한다', () {
      final result = parseLines('  우유 2L  ').single;

      expect(result.name, '우유');
    });

    test('원본 줄을 그대로 보관한다', () {
      final result = parseLines('돼지고기 300g 냉동').single;

      expect(result.rawLine, '돼지고기 300g 냉동');
    });
  });
}
