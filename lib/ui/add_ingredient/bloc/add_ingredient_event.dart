part of 'add_ingredient_bloc.dart';

sealed class AddIngredientEvent extends Equatable {
  const AddIngredientEvent();

  @override
  List<Object?> get props => const [];
}

final class AddIngredientNameChanged extends AddIngredientEvent {
  const AddIngredientNameChanged(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

final class AddIngredientAmountChanged extends AddIngredientEvent {
  const AddIngredientAmountChanged(this.amount);

  final String amount;

  @override
  List<Object?> get props => [amount];
}

final class AddIngredientUnitChanged extends AddIngredientEvent {
  const AddIngredientUnitChanged(this.unit);

  final String unit;

  @override
  List<Object?> get props => [unit];
}

final class AddIngredientStoragePlaceChanged extends AddIngredientEvent {
  const AddIngredientStoragePlaceChanged(this.storagePlace);

  final StoragePlace storagePlace;

  @override
  List<Object?> get props => [storagePlace];
}

final class AddIngredientPurchasedAtChanged extends AddIngredientEvent {
  const AddIngredientPurchasedAtChanged(this.purchasedAt);

  final DateTime purchasedAt;

  @override
  List<Object?> get props => [purchasedAt];
}

final class AddIngredientExpiresAtChanged extends AddIngredientEvent {
  const AddIngredientExpiresAtChanged(this.expiresAt);

  final DateTime expiresAt;

  @override
  List<Object?> get props => [expiresAt];
}

final class AddIngredientExpiresAtReset extends AddIngredientEvent {
  const AddIngredientExpiresAtReset();
}

final class AddIngredientSubmitted extends AddIngredientEvent {
  const AddIngredientSubmitted();
}
