import 'package:fridge/domain/entity/shelf_life.dart';

abstract interface class ShelfLifeRepository {
  ShelfLife? findByName(String name);

  List<ShelfLife> search(String query, {int limit});
}
