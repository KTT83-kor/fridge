part of 'add_ingredient_bloc.dart';

enum AddIngredientStatus { editing, submitting, success, failure }

final class AddIngredientState extends Equatable {
  const AddIngredientState({
    required this.purchasedAt,
    required this.expiresAt,
    this.name = '',
    this.amount = '',
    this.unit = AppStrings.defaultUnit,
    this.storagePlace = StoragePlace.fridge,
    this.isExpiryManual = false,
    this.hasShelfLifeSuggestion = false,
    this.status = AddIngredientStatus.editing,
    this.errorMessage = '',
  });

  final String name;
  final String amount;
  final String unit;
  final StoragePlace storagePlace;
  final DateTime purchasedAt;
  final DateTime expiresAt;
  final bool isExpiryManual;
  final bool hasShelfLifeSuggestion;
  final AddIngredientStatus status;
  final String errorMessage;

  bool get isNameValid => name.trim().isNotEmpty;

  bool get isAmountValid {
    final parsed = double.tryParse(amount.trim());
    if (parsed == null) return false;
    return parsed > 0;
  }

  bool get canSubmit {
    return isNameValid &&
        isAmountValid &&
        status != AddIngredientStatus.submitting;
  }

  AddIngredientState copyWith({
    String? name,
    String? amount,
    String? unit,
    StoragePlace? storagePlace,
    DateTime? purchasedAt,
    DateTime? expiresAt,
    bool? isExpiryManual,
    bool? hasShelfLifeSuggestion,
    AddIngredientStatus? status,
    String? errorMessage,
  }) {
    return AddIngredientState(
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      storagePlace: storagePlace ?? this.storagePlace,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isExpiryManual: isExpiryManual ?? this.isExpiryManual,
      hasShelfLifeSuggestion:
          hasShelfLifeSuggestion ?? this.hasShelfLifeSuggestion,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    name,
    amount,
    unit,
    storagePlace,
    purchasedAt,
    expiresAt,
    isExpiryManual,
    hasShelfLifeSuggestion,
    status,
    errorMessage,
  ];
}
