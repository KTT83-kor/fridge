import 'package:fridge/core/constant/app_strings.dart';

enum StoragePlace {
  fridge(AppStrings.storageFridge),
  freezer(AppStrings.storageFreezer),
  pantry(AppStrings.storagePantry);

  const StoragePlace(this.label);

  final String label;

  static StoragePlace fromName(String name) {
    return StoragePlace.values.firstWhere(
      (place) => place.name == name,
      orElse: () => StoragePlace.fridge,
    );
  }
}
