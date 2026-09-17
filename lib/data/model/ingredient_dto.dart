import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/domain/entity/storage_place.dart';

class IngredientDto {
  const IngredientDto({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    required this.storagePlace,
    required this.purchasedAt,
    required this.expiresAt,
    required this.memo,
  });

  factory IngredientDto.fromJson(Map<String, dynamic> json) {
    return IngredientDto(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
      storagePlace: json['storagePlace'] as String,
      purchasedAt: json['purchasedAt'] as String,
      expiresAt: json['expiresAt'] as String,
      memo: json['memo'] as String? ?? '',
    );
  }

  factory IngredientDto.fromEntity(Ingredient ingredient) {
    return IngredientDto(
      id: ingredient.id,
      name: ingredient.name,
      amount: ingredient.amount,
      unit: ingredient.unit,
      storagePlace: ingredient.storagePlace.name,
      purchasedAt: ingredient.purchasedAt.toIso8601String(),
      expiresAt: ingredient.expiresAt.toIso8601String(),
      memo: ingredient.memo,
    );
  }

  final String id;
  final String name;
  final double amount;
  final String unit;
  final String storagePlace;
  final String purchasedAt;
  final String expiresAt;
  final String memo;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'unit': unit,
      'storagePlace': storagePlace,
      'purchasedAt': purchasedAt,
      'expiresAt': expiresAt,
      'memo': memo,
    };
  }

  Ingredient toEntity() {
    return Ingredient(
      id: id,
      name: name,
      amount: amount,
      unit: unit,
      storagePlace: StoragePlace.fromName(storagePlace),
      purchasedAt: DateTime.parse(purchasedAt),
      expiresAt: DateTime.parse(expiresAt),
      memo: memo,
    );
  }
}
