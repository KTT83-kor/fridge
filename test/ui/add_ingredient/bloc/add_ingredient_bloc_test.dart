import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridge/core/result/result.dart';
import 'package:fridge/data/repository/shelf_life_repository_impl.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/domain/entity/storage_place.dart';
import 'package:fridge/domain/repository/ingredient_repository.dart';
import 'package:fridge/ui/add_ingredient/bloc/add_ingredient_bloc.dart';

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

void main() {
  final today = DateTime(2026, 9, 17);
  late _RecordingIngredientRepository ingredientRepository;

  AddIngredientBloc buildBloc() {
    return AddIngredientBloc(
      ingredientRepository: ingredientRepository,
      shelfLifeRepository: const ShelfLifeRepositoryImpl(),
      today: today,
    );
  }

  setUp(() {
    ingredientRepository = _RecordingIngredientRepository();
  });

  group('보관기간 자동 채우기', () {
    blocTest<AddIngredientBloc, AddIngredientState>(
      '표에 있는 이름을 넣으면 기한이 자동으로 채워진다',
      build: buildBloc,
      act: (bloc) => bloc.add(const AddIngredientNameChanged('우유')),
      verify: (bloc) {
        expect(bloc.state.expiresAt, DateTime(2026, 9, 20));
        expect(bloc.state.hasShelfLifeSuggestion, isTrue);
      },
    );

    blocTest<AddIngredientBloc, AddIngredientState>(
      '표에 있는 이름은 기본 단위도 채운다',
      build: buildBloc,
      act: (bloc) => bloc.add(const AddIngredientNameChanged('계란')),
      verify: (bloc) {
        expect(bloc.state.unit, '개');
      },
    );

    blocTest<AddIngredientBloc, AddIngredientState>(
      '표에 없는 이름은 기본 7일로 채운다',
      build: buildBloc,
      act: (bloc) => bloc.add(const AddIngredientNameChanged('트러플')),
      verify: (bloc) {
        expect(bloc.state.expiresAt, DateTime(2026, 9, 24));
        expect(bloc.state.hasShelfLifeSuggestion, isFalse);
      },
    );

    blocTest<AddIngredientBloc, AddIngredientState>(
      '보관 장소를 바꾸면 기한을 다시 계산한다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const AddIngredientNameChanged('돼지고기'))
        ..add(const AddIngredientStoragePlaceChanged(StoragePlace.freezer)),
      verify: (bloc) {
        expect(bloc.state.expiresAt, DateTime(2027, 2, 14));
      },
    );

    blocTest<AddIngredientBloc, AddIngredientState>(
      '산 날짜를 바꾸면 기한을 다시 계산한다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const AddIngredientNameChanged('우유'))
        ..add(AddIngredientPurchasedAtChanged(DateTime(2026, 9, 20))),
      verify: (bloc) {
        expect(bloc.state.expiresAt, DateTime(2026, 9, 23));
      },
    );
  });

  group('손으로 고친 기한', () {
    blocTest<AddIngredientBloc, AddIngredientState>(
      '직접 고른 날짜가 그대로 남는다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const AddIngredientNameChanged('우유'))
        ..add(AddIngredientExpiresAtChanged(DateTime(2026, 10, 2))),
      verify: (bloc) {
        expect(bloc.state.expiresAt, DateTime(2026, 10, 2));
        expect(bloc.state.isExpiryManual, isTrue);
      },
    );

    blocTest<AddIngredientBloc, AddIngredientState>(
      '직접 고른 뒤에는 보관 장소를 바꿔도 덮어쓰지 않는다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const AddIngredientNameChanged('돼지고기'))
        ..add(AddIngredientExpiresAtChanged(DateTime(2026, 10, 2)))
        ..add(const AddIngredientStoragePlaceChanged(StoragePlace.freezer)),
      verify: (bloc) {
        expect(bloc.state.expiresAt, DateTime(2026, 10, 2));
      },
    );

    blocTest<AddIngredientBloc, AddIngredientState>(
      '직접 고른 뒤에는 이름을 바꿔도 덮어쓰지 않는다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const AddIngredientNameChanged('우유'))
        ..add(AddIngredientExpiresAtChanged(DateTime(2026, 10, 2)))
        ..add(const AddIngredientNameChanged('두부')),
      verify: (bloc) {
        expect(bloc.state.expiresAt, DateTime(2026, 10, 2));
      },
    );

    blocTest<AddIngredientBloc, AddIngredientState>(
      '되돌리면 표 기준으로 다시 채운다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const AddIngredientNameChanged('우유'))
        ..add(AddIngredientExpiresAtChanged(DateTime(2026, 10, 2)))
        ..add(const AddIngredientExpiresAtReset()),
      verify: (bloc) {
        expect(bloc.state.expiresAt, DateTime(2026, 9, 20));
        expect(bloc.state.isExpiryManual, isFalse);
      },
    );
  });

  group('저장 가능 조건', () {
    blocTest<AddIngredientBloc, AddIngredientState>(
      '이름만 있으면 저장할 수 없다',
      build: buildBloc,
      act: (bloc) => bloc.add(const AddIngredientNameChanged('우유')),
      verify: (bloc) {
        expect(bloc.state.canSubmit, isFalse);
      },
    );

    blocTest<AddIngredientBloc, AddIngredientState>(
      '이름과 수량이 모두 있으면 저장할 수 있다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const AddIngredientNameChanged('우유'))
        ..add(const AddIngredientAmountChanged('1')),
      verify: (bloc) {
        expect(bloc.state.canSubmit, isTrue);
      },
    );

    blocTest<AddIngredientBloc, AddIngredientState>(
      '수량이 0이면 저장할 수 없다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const AddIngredientNameChanged('우유'))
        ..add(const AddIngredientAmountChanged('0')),
      verify: (bloc) {
        expect(bloc.state.canSubmit, isFalse);
      },
    );

    blocTest<AddIngredientBloc, AddIngredientState>(
      '수량이 숫자가 아니면 저장할 수 없다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const AddIngredientNameChanged('우유'))
        ..add(const AddIngredientAmountChanged('한개')),
      verify: (bloc) {
        expect(bloc.state.canSubmit, isFalse);
      },
    );

    blocTest<AddIngredientBloc, AddIngredientState>(
      '이름이 공백뿐이면 저장할 수 없다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const AddIngredientNameChanged('   '))
        ..add(const AddIngredientAmountChanged('1')),
      verify: (bloc) {
        expect(bloc.state.canSubmit, isFalse);
      },
    );
  });

  group('저장', () {
    blocTest<AddIngredientBloc, AddIngredientState>(
      '저장하면 재료가 저장소에 들어가고 성공 상태가 된다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const AddIngredientNameChanged('우유'))
        ..add(const AddIngredientAmountChanged('2'))
        ..add(const AddIngredientSubmitted()),
      verify: (bloc) {
        expect(bloc.state.status, AddIngredientStatus.success);

        final saved = ingredientRepository.saved.single;
        expect(saved.name, '우유');
        expect(saved.amount, 2);
        expect(saved.unit, 'mL');
        expect(saved.expiresAt, DateTime(2026, 9, 20));
      },
    );

    blocTest<AddIngredientBloc, AddIngredientState>(
      '이름 앞뒤 공백은 잘라서 저장한다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const AddIngredientNameChanged(' 두부 '))
        ..add(const AddIngredientAmountChanged('1'))
        ..add(const AddIngredientSubmitted()),
      verify: (bloc) {
        expect(ingredientRepository.saved.single.name, '두부');
      },
    );

    blocTest<AddIngredientBloc, AddIngredientState>(
      '수량이 없으면 저장하지 않는다',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const AddIngredientNameChanged('우유'))
        ..add(const AddIngredientSubmitted()),
      verify: (bloc) {
        expect(ingredientRepository.saved, isEmpty);
      },
    );

    blocTest<AddIngredientBloc, AddIngredientState>(
      '저장에 실패하면 실패 상태와 메시지를 남긴다',
      build: () {
        ingredientRepository.saveResult = const ResultFailure<void>('저장 실패');
        return buildBloc();
      },
      act: (bloc) => bloc
        ..add(const AddIngredientNameChanged('우유'))
        ..add(const AddIngredientAmountChanged('1'))
        ..add(const AddIngredientSubmitted()),
      verify: (bloc) {
        expect(bloc.state.status, AddIngredientStatus.failure);
        expect(bloc.state.errorMessage, '저장 실패');
      },
    );
  });
}
