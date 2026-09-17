import 'package:equatable/equatable.dart';
import 'package:fridge/domain/entity/storage_place.dart';

class ShelfLife extends Equatable {
  const ShelfLife({
    required this.name,
    required this.fridgeDays,
    required this.freezerDays,
    required this.pantryDays,
    required this.defaultUnit,
  });

  final String name;
  final int fridgeDays;
  final int freezerDays;
  final int pantryDays;
  final String defaultUnit;

  int daysFor(StoragePlace storagePlace) {
    switch (storagePlace) {
      case StoragePlace.fridge:
        return fridgeDays;
      case StoragePlace.freezer:
        return freezerDays;
      case StoragePlace.pantry:
        return pantryDays;
    }
  }

  @override
  List<Object?> get props => [
    name,
    fridgeDays,
    freezerDays,
    pantryDays,
    defaultUnit,
  ];
}
