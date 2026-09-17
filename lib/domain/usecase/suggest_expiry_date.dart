import 'package:fridge/domain/entity/storage_place.dart';
import 'package:fridge/domain/repository/shelf_life_repository.dart';

class SuggestExpiryDate {
  const SuggestExpiryDate(this._shelfLifeRepository);

  final ShelfLifeRepository _shelfLifeRepository;

  DateTime? call({
    required String name,
    required StoragePlace storagePlace,
    required DateTime purchasedAt,
  }) {
    final shelfLife = _shelfLifeRepository.findByName(name);
    if (shelfLife == null) return null;

    final days = shelfLife.daysFor(storagePlace);
    final purchasedDate = DateTime(
      purchasedAt.year,
      purchasedAt.month,
      purchasedAt.day,
    );
    return purchasedDate.add(Duration(days: days));
  }
}
