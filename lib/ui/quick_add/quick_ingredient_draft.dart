import 'package:equatable/equatable.dart';
import 'package:fridge/domain/entity/storage_place.dart';

class QuickIngredientDraft extends Equatable {
  const QuickIngredientDraft({
    required this.name,
    required this.amount,
    required this.unit,
    required this.storagePlace,
    required this.expiresAt,
    required this.isExpiryManual,
    required this.hasShelfLifeSuggestion,
  });

  final String name;
  final double amount;
  final String unit;
  final StoragePlace storagePlace;
  final DateTime expiresAt;
  final bool isExpiryManual;
  final bool hasShelfLifeSuggestion;

  bool get isNameValid => name.trim().isNotEmpty;

  bool get isAmountValid => amount > 0;

  bool get isValid => isNameValid && isAmountValid;

  QuickIngredientDraft copyWith({
    String? name,
    double? amount,
    String? unit,
    StoragePlace? storagePlace,
    DateTime? expiresAt,
    bool? isExpiryManual,
    bool? hasShelfLifeSuggestion,
  }) {
    return QuickIngredientDraft(
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      storagePlace: storagePlace ?? this.storagePlace,
      expiresAt: expiresAt ?? this.expiresAt,
      isExpiryManual: isExpiryManual ?? this.isExpiryManual,
      hasShelfLifeSuggestion:
          hasShelfLifeSuggestion ?? this.hasShelfLifeSuggestion,
    );
  }

  @override
  List<Object?> get props => [
    name,
    amount,
    unit,
    storagePlace,
    expiresAt,
    isExpiryManual,
    hasShelfLifeSuggestion,
  ];
}
