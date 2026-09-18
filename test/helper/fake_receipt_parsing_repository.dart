import 'dart:typed_data';

import 'package:fridge/core/result/result.dart';
import 'package:fridge/domain/entity/parsed_ingredient.dart';
import 'package:fridge/domain/repository/receipt_parsing_repository.dart';

class FakeReceiptParsingRepository implements ReceiptParsingRepository {
  FakeReceiptParsingRepository({
    Result<List<ParsedIngredient>> result = const ResultSuccess([]),
  }) : _result = result;

  final Result<List<ParsedIngredient>> _result;

  @override
  Future<Result<List<ParsedIngredient>>> parseImage(
    Uint8List imageBytes,
  ) async {
    return _result;
  }
}
