import 'package:fridge/core/result/result.dart';
import 'package:fridge/domain/entity/ingredient.dart';

abstract interface class IngredientRepository {
  Stream<List<Ingredient>> watchAll();

  Future<Result<void>> save(Ingredient ingredient);

  Future<Result<void>> remove(String id);
}
