import 'dart:convert';

import 'package:fridge/data/model/ingredient_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IngredientLocalDataSource {
  const IngredientLocalDataSource(this._preferences);

  static const _storageKey = 'ingredients';

  final SharedPreferences _preferences;

  List<IngredientDto> readAll() {
    final raw = _preferences.getString(_storageKey);
    if (raw == null) return const [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    final dtos = decoded
        .map((item) => IngredientDto.fromJson(item as Map<String, dynamic>))
        .toList();
    return dtos;
  }

  Future<void> writeAll(List<IngredientDto> dtos) {
    final jsonList = dtos.map((dto) => dto.toJson()).toList();
    final encoded = jsonEncode(jsonList);
    return _preferences.setString(_storageKey, encoded);
  }
}
