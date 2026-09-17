import 'package:equatable/equatable.dart';
import 'package:fridge/domain/entity/storage_place.dart';

class ParsedIngredient extends Equatable {
  const ParsedIngredient({
    required this.rawLine,
    required this.name,
    this.amount,
    this.unit,
    this.storagePlace,
  });

  final String rawLine;
  final String name;
  final double? amount;
  final String? unit;
  final StoragePlace? storagePlace;

  bool get isRecognized => name.isNotEmpty;

  bool get hasAmount => amount != null;

  @override
  List<Object?> get props => [rawLine, name, amount, unit, storagePlace];
}
