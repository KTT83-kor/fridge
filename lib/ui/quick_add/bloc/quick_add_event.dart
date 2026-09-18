part of 'quick_add_bloc.dart';

sealed class QuickAddEvent extends Equatable {
  const QuickAddEvent();

  @override
  List<Object?> get props => const [];
}

final class QuickAddTextChanged extends QuickAddEvent {
  const QuickAddTextChanged(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

final class QuickAddParsed extends QuickAddEvent {
  const QuickAddParsed();
}

final class QuickAddReceiptImagePicked extends QuickAddEvent {
  const QuickAddReceiptImagePicked(this.imageBytes);

  final Uint8List imageBytes;

  @override
  List<Object?> get props => [imageBytes];
}

final class QuickAddReceiptParsed extends QuickAddEvent {
  const QuickAddReceiptParsed(this.result);

  final Result<List<ParsedIngredient>> result;

  @override
  List<Object?> get props => [result];
}

final class QuickAddDraftNameChanged extends QuickAddEvent {
  const QuickAddDraftNameChanged(this.index, this.name);

  final int index;
  final String name;

  @override
  List<Object?> get props => [index, name];
}

final class QuickAddDraftAmountChanged extends QuickAddEvent {
  const QuickAddDraftAmountChanged(this.index, this.amount);

  final int index;
  final double amount;

  @override
  List<Object?> get props => [index, amount];
}

final class QuickAddDraftUnitChanged extends QuickAddEvent {
  const QuickAddDraftUnitChanged(this.index, this.unit);

  final int index;
  final String unit;

  @override
  List<Object?> get props => [index, unit];
}

final class QuickAddDraftStoragePlaceChanged extends QuickAddEvent {
  const QuickAddDraftStoragePlaceChanged(this.index, this.storagePlace);

  final int index;
  final StoragePlace storagePlace;

  @override
  List<Object?> get props => [index, storagePlace];
}

final class QuickAddDraftRemoved extends QuickAddEvent {
  const QuickAddDraftRemoved(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

final class QuickAddBackToEditing extends QuickAddEvent {
  const QuickAddBackToEditing();
}

final class QuickAddSubmitted extends QuickAddEvent {
  const QuickAddSubmitted();
}
