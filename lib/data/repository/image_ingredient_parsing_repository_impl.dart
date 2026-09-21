import 'dart:convert';
import 'dart:typed_data';

import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/result/result.dart';
import 'package:fridge/data/datasource/gemini_ingredient_image_data_source.dart';
import 'package:fridge/domain/entity/ingredient_image_source_kind.dart';
import 'package:fridge/domain/entity/parsed_ingredient.dart';
import 'package:fridge/domain/repository/image_ingredient_parsing_repository.dart';

class ImageIngredientParsingRepositoryImpl
    implements ImageIngredientParsingRepository {
  const ImageIngredientParsingRepositoryImpl(this._dataSource);

  final GeminiIngredientImageDataSource _dataSource;

  @override
  Future<Result<List<ParsedIngredient>>> parseImage(
    Uint8List imageBytes,
    IngredientImageSourceKind sourceKind,
  ) async {
    try {
      final responseText = await _dataSource.extractIngredients(
        imageBytes,
        sourceKind,
      );
      final ingredients = _parseIngredients(responseText);
      return ResultSuccess(ingredients);
    } on GeminiApiKeyMissingException catch (error) {
      return ResultFailure(
        AppStrings.quickAddReceiptApiKeyMissing,
        cause: error,
      );
    } on GeminiRequestException catch (error) {
      return ResultFailure(_messageFor(error), cause: error);
    } on Exception catch (error) {
      return ResultFailure(AppStrings.quickAddReceiptFailed, cause: error);
    }
  }

  String _messageFor(GeminiRequestException error) {
    switch (error.statusCode) {
      case 503:
        return AppStrings.quickAddReceiptOverloaded;
      case 429:
        return AppStrings.quickAddReceiptQuotaExceeded;
      default:
        return AppStrings.quickAddReceiptFailedWithCode(error.statusCode);
    }
  }

  List<ParsedIngredient> _parseIngredients(String responseText) {
    final decoded = jsonDecode(responseText) as List<dynamic>;
    return decoded.map(_toParsedIngredient).toList();
  }

  ParsedIngredient _toParsedIngredient(dynamic json) {
    final map = json as Map<String, dynamic>;
    final name = map['name'] as String;
    final amount = map['amount'] as num?;
    final unit = map['unit'] as String?;

    return ParsedIngredient(
      rawLine: name,
      name: name,
      amount: amount?.toDouble(),
      unit: unit,
    );
  }
}
