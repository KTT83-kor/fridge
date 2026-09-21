import 'dart:typed_data';

import 'package:fridge/core/result/result.dart';
import 'package:fridge/domain/entity/ingredient_image_source_kind.dart';
import 'package:fridge/domain/entity/parsed_ingredient.dart';
import 'package:fridge/domain/repository/image_ingredient_parsing_repository.dart';

class FakeImageIngredientParsingRepository
    implements ImageIngredientParsingRepository {
  FakeImageIngredientParsingRepository({
    Result<List<ParsedIngredient>> result = const ResultSuccess([]),
  }) : _result = result;

  final Result<List<ParsedIngredient>> _result;

  @override
  Future<Result<List<ParsedIngredient>>> parseImage(
    Uint8List imageBytes,
    IngredientImageSourceKind sourceKind,
  ) async {
    return _result;
  }
}
