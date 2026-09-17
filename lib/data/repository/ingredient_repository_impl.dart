import 'dart:async';

import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/result/result.dart';
import 'package:fridge/data/datasource/ingredient_local_data_source.dart';
import 'package:fridge/data/model/ingredient_dto.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/domain/repository/ingredient_repository.dart';

class IngredientRepositoryImpl implements IngredientRepository {
  IngredientRepositoryImpl(this._localDataSource);

  final IngredientLocalDataSource _localDataSource;
  final _changes = StreamController<List<Ingredient>>.broadcast();

  @override
  Stream<List<Ingredient>> watchAll() async* {
    yield _readIngredients();
    yield* _changes.stream;
  }

  @override
  Future<Result<void>> save(Ingredient ingredient) async {
    try {
      final stored = _localDataSource.readAll()
        ..removeWhere((dto) => dto.id == ingredient.id)
        ..add(IngredientDto.fromEntity(ingredient));
      await _localDataSource.writeAll(stored);
      _changes.add(_readIngredients());
      return const ResultSuccess<void>(null);
    } on Exception catch (error) {
      return ResultFailure<void>(
        AppStrings.saveIngredientFailed,
        cause: error,
      );
    }
  }

  @override
  Future<Result<void>> remove(String id) async {
    try {
      final stored = _localDataSource.readAll()
        ..removeWhere((dto) => dto.id == id);
      await _localDataSource.writeAll(stored);
      _changes.add(_readIngredients());
      return const ResultSuccess<void>(null);
    } on Exception catch (error) {
      return ResultFailure<void>(
        AppStrings.removeIngredientFailed,
        cause: error,
      );
    }
  }

  Future<void> dispose() => _changes.close();

  List<Ingredient> _readIngredients() {
    final dtos = _localDataSource.readAll();
    return dtos.map((dto) => dto.toEntity()).toList();
  }
}
