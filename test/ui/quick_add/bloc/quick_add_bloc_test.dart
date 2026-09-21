import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridge/core/result/result.dart';
import 'package:fridge/data/repository/shelf_life_repository_impl.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/domain/entity/ingredient_image_source_kind.dart';
import 'package:fridge/domain/entity/parsed_ingredient.dart';
import 'package:fridge/domain/entity/storage_place.dart';
import 'package:fridge/domain/repository/image_ingredient_parsing_repository.dart';
import 'package:fridge/domain/repository/ingredient_repository.dart';
import 'package:fridge/ui/quick_add/bloc/quick_add_bloc.dart';

class _RecordingIngredientRepository implements IngredientRepository {
  final saved = <Ingredient>[];
  Result<void> saveResult = const ResultSuccess<void>(null);

  @override
  Stream<List<Ingredient>> watchAll() => Stream.value(saved);

  @override
  Future<Result<void>> save(Ingredient ingredient) async {
    saved.add(ingredient);
    return saveResult;
  }

  @override
  Future<Result<void>> remove(String id) async {
    return const ResultSuccess<void>(null);
  }
}

class _StubImageIngredientParsingRepository
    implements ImageIngredientParsingRepository {
  Result<List<ParsedIngredient>> parseResult = const ResultSuccess([]);

  @override
  Future<Result<List<ParsedIngredient>>> parseImage(
    Uint8List imageBytes,
    IngredientImageSourceKind sourceKind,
  ) async {
    return parseResult;
  }
}

void main() {
  final today = DateTime(2026, 9, 17);
  late _RecordingIngredientRepository ingredientRepository;
  late _StubImageIngredientParsingRepository imageIngredientParsingRepository;

  QuickAddBloc buildBloc() {
    return QuickAddBloc(
      ingredientRepository: ingredientRepository,
      shelfLifeRepository: const ShelfLifeRepositoryImpl(),
      imageIngredientParsingRepository: imageIngredientParsingRepository,
      today: today,
    );
  }

  setUp(() {
    ingredientRepository = _RecordingIngredientRepository();
    imageIngredientParsingRepository =
        _StubImageIngredientParsingRepository();
  });

  group('파싱', () {
    blocTest<QuickAddBloc, QuickAddState>(
      '여러 줄을 파싱해서 항목 목록을 만든다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const QuickAddTextChanged('우유 2L\n두부 1모'))
        ..add(const QuickAddParsed()),
      verify: (bloc) {
        expect(bloc.state.drafts, hasLength(2));
        expect(bloc.state.status, QuickAddStatus.reviewing);
      },
    );

    blocTest<QuickAddBloc, QuickAddState>(
      '수량을 안 쓰면 1로 본다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const QuickAddTextChanged('우유'))
        ..add(const QuickAddParsed()),
      verify: (bloc) {
        expect(bloc.state.drafts.single.amount, 1);
      },
    );

    blocTest<QuickAddBloc, QuickAddState>(
      '입력한 단위를 표보다 우선한다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const QuickAddTextChanged('우유 2개'))
        ..add(const QuickAddParsed()),
      verify: (bloc) {
        expect(bloc.state.drafts.single.unit, '개');
      },
    );

    blocTest<QuickAddBloc, QuickAddState>(
      '단위를 안 쓰면 표의 기본 단위를 쓴다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const QuickAddTextChanged('우유'))
        ..add(const QuickAddParsed()),
      verify: (bloc) {
        expect(bloc.state.drafts.single.unit, 'mL');
      },
    );

    blocTest<QuickAddBloc, QuickAddState>(
      '표에 있는 이름은 기한을 자동으로 채운다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const QuickAddTextChanged('돼지고기 300g 냉동'))
        ..add(const QuickAddParsed()),
      verify: (bloc) {
        final draft = bloc.state.drafts.single;
        expect(draft.storagePlace, StoragePlace.freezer);
        expect(draft.expiresAt, DateTime(2027, 2, 14));
        expect(draft.hasShelfLifeSuggestion, isTrue);
      },
    );

    blocTest<QuickAddBloc, QuickAddState>(
      '보관 장소를 안 쓰면 냉장으로 본다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const QuickAddTextChanged('우유 2L'))
        ..add(const QuickAddParsed()),
      verify: (bloc) {
        expect(bloc.state.drafts.single.storagePlace, StoragePlace.fridge);
      },
    );

    blocTest<QuickAddBloc, QuickAddState>(
      '인식하지 못한 조각은 이름에 남고 수량은 1, 기한은 기본값이다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const QuickAddTextChanged('계란 한판'))
        ..add(const QuickAddParsed()),
      verify: (bloc) {
        final draft = bloc.state.drafts.single;
        expect(draft.name, '계란 한판');
        expect(draft.amount, 1);
        expect(draft.hasShelfLifeSuggestion, isFalse);
        expect(draft.expiresAt, DateTime(2026, 9, 24));
      },
    );
  });

  group('미리보기 수정', () {
    blocTest<QuickAddBloc, QuickAddState>(
      '보관 장소를 바꾸면 기한을 다시 계산한다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const QuickAddTextChanged('돼지고기 300g'))
        ..add(const QuickAddParsed())
        ..add(
          const QuickAddDraftStoragePlaceChanged(0, StoragePlace.freezer),
        ),
      verify: (bloc) {
        expect(bloc.state.drafts.single.expiresAt, DateTime(2027, 2, 14));
      },
    );

    blocTest<QuickAddBloc, QuickAddState>(
      '이름을 고칠 수 있다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const QuickAddTextChanged('계란 한판'))
        ..add(const QuickAddParsed())
        ..add(const QuickAddDraftNameChanged(0, '계란')),
      verify: (bloc) {
        expect(bloc.state.drafts.single.name, '계란');
      },
    );

    blocTest<QuickAddBloc, QuickAddState>(
      '항목을 뺄 수 있다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const QuickAddTextChanged('우유 2L\n두부 1모'))
        ..add(const QuickAddParsed())
        ..add(const QuickAddDraftRemoved(0)),
      verify: (bloc) {
        expect(bloc.state.drafts.single.name, '두부');
      },
    );
  });

  group('저장 가능 조건', () {
    blocTest<QuickAddBloc, QuickAddState>(
      '항목이 하나도 없으면 저장할 수 없다',
      build: buildBloc,
      verify: (bloc) {
        expect(bloc.state.canSubmit, isFalse);
      },
    );

    blocTest<QuickAddBloc, QuickAddState>(
      '수량이 0인 항목이 있으면 저장할 수 없다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const QuickAddTextChanged('우유 2L'))
        ..add(const QuickAddParsed())
        ..add(const QuickAddDraftAmountChanged(0, 0)),
      verify: (bloc) {
        expect(bloc.state.canSubmit, isFalse);
      },
    );

    blocTest<QuickAddBloc, QuickAddState>(
      '모든 항목이 유효하면 저장할 수 있다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const QuickAddTextChanged('우유 2L\n두부 1모'))
        ..add(const QuickAddParsed()),
      verify: (bloc) {
        expect(bloc.state.canSubmit, isTrue);
      },
    );
  });

  group('저장', () {
    blocTest<QuickAddBloc, QuickAddState>(
      '모든 항목을 저장소에 담고 성공 상태가 된다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const QuickAddTextChanged('우유 2L\n두부 1모'))
        ..add(const QuickAddParsed())
        ..add(const QuickAddSubmitted()),
      verify: (bloc) {
        expect(bloc.state.status, QuickAddStatus.success);
        expect(ingredientRepository.saved, hasLength(2));
        expect(ingredientRepository.saved[0].name, '우유');
        expect(ingredientRepository.saved[1].name, '두부');
      },
    );

    blocTest<QuickAddBloc, QuickAddState>(
      '저장에 실패하면 실패 상태와 메시지를 남긴다',
      build: () {
        ingredientRepository.saveResult = const ResultFailure<void>('저장 실패');
        return buildBloc();
      },
      act: (bloc) => bloc
        ..add(const QuickAddTextChanged('우유 2L'))
        ..add(const QuickAddParsed())
        ..add(const QuickAddSubmitted()),
      verify: (bloc) {
        expect(bloc.state.status, QuickAddStatus.failure);
        expect(bloc.state.errorMessage, '저장 실패');
      },
    );
  });
}
