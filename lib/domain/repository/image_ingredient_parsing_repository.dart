import 'dart:typed_data';

import 'package:fridge/core/result/result.dart';
import 'package:fridge/domain/entity/ingredient_image_source_kind.dart';
import 'package:fridge/domain/entity/parsed_ingredient.dart';

abstract interface class ImageIngredientParsingRepository {
  Future<Result<List<ParsedIngredient>>> parseImage(
    Uint8List imageBytes,
    IngredientImageSourceKind sourceKind,
  );
}
