import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/result/result.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/domain/entity/storage_place.dart';
import 'package:fridge/domain/repository/ingredient_repository.dart';
import 'package:fridge/domain/repository/shelf_life_repository.dart';
import 'package:fridge/domain/usecase/suggest_expiry_date.dart';
import 'package:uuid/uuid.dart';

part 'add_ingredient_event.dart';
part 'add_ingredient_state.dart';

class AddIngredientBloc extends Bloc<AddIngredientEvent, AddIngredientState> {
  AddIngredientBloc({
    required IngredientRepository ingredientRepository,
    required ShelfLifeRepository shelfLifeRepository,
    required DateTime today,
    Ingredient? initial,
    Uuid uuid = const Uuid(),
  }) : _ingredientRepository = ingredientRepository,
       _shelfLifeRepository = shelfLifeRepository,
       _suggestExpiryDate = SuggestExpiryDate(shelfLifeRepository),
       super(
         _buildInitialState(today: today, initial: initial, uuid: uuid),
       ) {
    on<AddIngredientNameChanged>(_onNameChanged);
    on<AddIngredientAmountChanged>(_onAmountChanged);
    on<AddIngredientUnitChanged>(_onUnitChanged);
    on<AddIngredientStoragePlaceChanged>(_onStoragePlaceChanged);
    on<AddIngredientPurchasedAtChanged>(_onPurchasedAtChanged);
    on<AddIngredientExpiresAtChanged>(_onExpiresAtChanged);
    on<AddIngredientExpiresAtReset>(_onExpiresAtReset);
    on<AddIngredientSubmitted>(_onSubmitted);
  }

  static const _fallbackShelfLife = Duration(days: 7);

  final IngredientRepository _ingredientRepository;
  final ShelfLifeRepository _shelfLifeRepository;
  final SuggestExpiryDate _suggestExpiryDate;

  void _onNameChanged(
    AddIngredientNameChanged event,
    Emitter<AddIngredientState> emit,
  ) {
    final shelfLife = _shelfLifeRepository.findByName(event.name);
    final unit = _resolveUnit(shelfLife?.defaultUnit);
    final named = state.copyWith(
      name: event.name,
      unit: unit,
      hasShelfLifeSuggestion: shelfLife != null,
    );
    emit(_withSuggestedExpiry(named));
  }

  void _onAmountChanged(
    AddIngredientAmountChanged event,
    Emitter<AddIngredientState> emit,
  ) {
    emit(state.copyWith(amount: event.amount));
  }

  void _onUnitChanged(
    AddIngredientUnitChanged event,
    Emitter<AddIngredientState> emit,
  ) {
    emit(state.copyWith(unit: event.unit));
  }

  void _onStoragePlaceChanged(
    AddIngredientStoragePlaceChanged event,
    Emitter<AddIngredientState> emit,
  ) {
    final moved = state.copyWith(storagePlace: event.storagePlace);
    emit(_withSuggestedExpiry(moved));
  }

  void _onPurchasedAtChanged(
    AddIngredientPurchasedAtChanged event,
    Emitter<AddIngredientState> emit,
  ) {
    final purchased = _atStartOfDay(event.purchasedAt);
    final bought = state.copyWith(purchasedAt: purchased);
    emit(_withSuggestedExpiry(bought));
  }

  void _onExpiresAtChanged(
    AddIngredientExpiresAtChanged event,
    Emitter<AddIngredientState> emit,
  ) {
    emit(
      state.copyWith(
        expiresAt: _atStartOfDay(event.expiresAt),
        isExpiryManual: true,
      ),
    );
  }

  void _onExpiresAtReset(
    AddIngredientExpiresAtReset event,
    Emitter<AddIngredientState> emit,
  ) {
    final cleared = state.copyWith(isExpiryManual: false);
    emit(_withSuggestedExpiry(cleared));
  }

  Future<void> _onSubmitted(
    AddIngredientSubmitted event,
    Emitter<AddIngredientState> emit,
  ) async {
    if (!state.canSubmit) return;

    emit(state.copyWith(status: AddIngredientStatus.submitting));

    final amount = double.parse(state.amount.trim());
    final ingredient = Ingredient(
      id: state.id,
      name: state.name.trim(),
      amount: amount,
      unit: state.unit,
      storagePlace: state.storagePlace,
      purchasedAt: state.purchasedAt,
      expiresAt: state.expiresAt,
    );

    final result = await _ingredientRepository.save(ingredient);
    switch (result) {
      case ResultSuccess<void>():
        emit(state.copyWith(status: AddIngredientStatus.success));
      case ResultFailure<void>(:final message):
        emit(
          state.copyWith(
            status: AddIngredientStatus.failure,
            errorMessage: message,
          ),
        );
    }
  }

  AddIngredientState _withSuggestedExpiry(AddIngredientState next) {
    if (next.isExpiryManual) return next;

    final suggested = _suggestExpiryDate(
      name: next.name,
      storagePlace: next.storagePlace,
      purchasedAt: next.purchasedAt,
    );
    final expiresAt = suggested ?? next.purchasedAt.add(_fallbackShelfLife);
    return next.copyWith(expiresAt: expiresAt);
  }

  String _resolveUnit(String? suggestedUnit) {
    if (suggestedUnit == null) return state.unit;
    return suggestedUnit;
  }

  static DateTime _atStartOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static AddIngredientState _buildInitialState({
    required DateTime today,
    required Ingredient? initial,
    required Uuid uuid,
  }) {
    if (initial == null) {
      final purchasedAt = _atStartOfDay(today);
      return AddIngredientState(
        id: uuid.v4(),
        purchasedAt: purchasedAt,
        expiresAt: purchasedAt.add(_fallbackShelfLife),
      );
    }

    return AddIngredientState(
      id: initial.id,
      isEditing: true,
      name: initial.name,
      amount: _formatAmount(initial.amount),
      unit: initial.unit,
      storagePlace: initial.storagePlace,
      purchasedAt: initial.purchasedAt,
      expiresAt: initial.expiresAt,
      isExpiryManual: true,
    );
  }

  static String _formatAmount(double amount) {
    if (amount == amount.truncateToDouble()) {
      return amount.truncate().toString();
    }
    return amount.toString();
  }
}
