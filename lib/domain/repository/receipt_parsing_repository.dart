import 'dart:typed_data';

import 'package:fridge/core/result/result.dart';
import 'package:fridge/domain/entity/parsed_ingredient.dart';

abstract interface class ReceiptParsingRepository {
  Future<Result<List<ParsedIngredient>>> parseImage(Uint8List imageBytes);
}
