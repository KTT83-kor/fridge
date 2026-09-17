import 'package:fridge/domain/entity/parsed_ingredient.dart';
import 'package:fridge/domain/entity/storage_place.dart';

class ParseIngredientLines {
  const ParseIngredientLines();

  static final _amountUnitPattern = RegExp(r'^([0-9]+(?:\.[0-9]+)?)(\D+)$');

  List<ParsedIngredient> call(String text) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty);

    return lines.map(_parseLine).toList();
  }

  ParsedIngredient _parseLine(String rawLine) {
    var tokens = rawLine.split(RegExp(r'\s+'));

    final storagePlace = _findStoragePlace(tokens.last);
    if (storagePlace != null) {
      tokens = tokens.sublist(0, tokens.length - 1);
    }

    double? amount;
    String? unit;
    if (tokens.isNotEmpty) {
      final match = _amountUnitPattern.firstMatch(tokens.last);
      if (match != null) {
        amount = double.parse(match.group(1)!);
        unit = match.group(2);
        tokens = tokens.sublist(0, tokens.length - 1);
      }
    }

    final name = tokens.join(' ').trim();

    return ParsedIngredient(
      rawLine: rawLine,
      name: name,
      amount: amount,
      unit: unit,
      storagePlace: storagePlace,
    );
  }

  StoragePlace? _findStoragePlace(String token) {
    for (final place in StoragePlace.values) {
      if (place.label == token) return place;
    }
    return null;
  }
}
