import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/result/result.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/domain/entity/parsed_ingredient.dart';
import 'package:fridge/domain/entity/storage_place.dart';
import 'package:fridge/domain/repository/ingredient_repository.dart';
import 'package:fridge/domain/repository/shelf_life_repository.dart';
import 'package:fridge/domain/usecase/parse_ingredient_lines.dart';
import 'package:fridge/domain/usecase/suggest_expiry_date.dart';
import 'package:fridge/ui/quick_add/quick_ingredient_draft.dart';
import 'package:uuid/uuid.dart';

part 'quick_add_event.dart';
part 'quick_add_state.dart';

class QuickAddBloc extends Bloc<QuickAddEvent, QuickAddState> {
  QuickAddBloc({
    required IngredientRepository ingredientRepository,
    required ShelfLifeRepository shelfLifeRepository,
    required DateTime today,
    ParseIngredientLines parseLines = const ParseIngredientLines(),
    Uuid uuid = const Uuid(),
  }) : _ingredientRepository = ingredientRepository,
       _shelfLifeRepository = shelfLifeRepository,
       _suggestExpiryDate = SuggestExpiryDate(shelfLifeRepository),
       _parseLines = parseLines,
       _today = _atStartOfDay(today),
       _uuid = uuid,
       super(const QuickAddState()) {
    on<QuickAddTextChanged>(_onTextChanged);
    on<QuickAddParsed>(_onParsed);
    on<QuickAddDraftNameChanged>(_onDraftNameChanged);
    on<QuickAddDraftAmountChanged>(_onDraftAmountChanged);
    on<QuickAddDraftUnitChanged>(_onDraftUnitChanged);
    on<QuickAddDraftStoragePlaceChanged>(_onDraftStoragePlaceChanged);
    on<QuickAddDraftRemoved>(_onDraftRemoved);
    on<QuickAddBackToEditing>(_onBackToEditing);
    on<QuickAddSubmitted>(_onSubmitted);
  }

  static const _fallbackShelfLife = Duration(days: 7);
  static const _defaultAmount = 1.0;

  final IngredientRepository _ingredientRepository;
  final ShelfLifeRepository _shelfLifeRepository;
  final SuggestExpiryDate _suggestExpiryDate;
  final ParseIngredientLines _parseLines;
  final DateTime _today;
  final Uuid _uuid;

  void _onTextChanged(QuickAddTextChanged event, Emitter<QuickAddState> emit) {
    emit(state.copyWith(text: event.text));
  }

  void _onParsed(QuickAddParsed event, Emitter<QuickAddState> emit) {
    final parsedLines = _parseLines(state.text);
    final drafts = parsedLines.map(_toDraft).toList();
    emit(state.copyWith(drafts: drafts, status: QuickAddStatus.reviewing));
  }

  void _onDraftNameChanged(
    QuickAddDraftNameChanged event,
    Emitter<QuickAddState> emit,
  ) {
    QuickIngredientDraft renamed(QuickIngredientDraft draft) {
      return draft.copyWith(name: event.name);
    }

    _updateDraft(emit, event.index, renamed);
  }

  void _onDraftAmountChanged(
    QuickAddDraftAmountChanged event,
    Emitter<QuickAddState> emit,
  ) {
    QuickIngredientDraft withAmount(QuickIngredientDraft draft) {
      return draft.copyWith(amount: event.amount);
    }

    _updateDraft(emit, event.index, withAmount);
  }

  void _onDraftUnitChanged(
    QuickAddDraftUnitChanged event,
    Emitter<QuickAddState> emit,
  ) {
    QuickIngredientDraft withUnit(QuickIngredientDraft draft) {
      return draft.copyWith(unit: event.unit);
    }

    _updateDraft(emit, event.index, withUnit);
  }

  void _onDraftStoragePlaceChanged(
    QuickAddDraftStoragePlaceChanged event,
    Emitter<QuickAddState> emit,
  ) {
    QuickIngredientDraft moved(QuickIngredientDraft draft) {
      final withStoragePlace = draft.copyWith(
        storagePlace: event.storagePlace,
      );
      return _withSuggestedExpiry(withStoragePlace);
    }

    _updateDraft(emit, event.index, moved);
  }

  void _onDraftRemoved(
    QuickAddDraftRemoved event,
    Emitter<QuickAddState> emit,
  ) {
    final drafts = [...state.drafts]..removeAt(event.index);
    emit(state.copyWith(drafts: drafts));
  }

  void _onBackToEditing(
    QuickAddBackToEditing event,
    Emitter<QuickAddState> emit,
  ) {
    emit(const QuickAddState());
  }

  Future<void> _onSubmitted(
    QuickAddSubmitted event,
    Emitter<QuickAddState> emit,
  ) async {
    if (!state.canSubmit) return;

    emit(state.copyWith(status: QuickAddStatus.submitting));

    for (final draft in state.drafts) {
      final ingredient = Ingredient(
        id: _uuid.v4(),
        name: draft.name.trim(),
        amount: draft.amount,
        unit: draft.unit,
        storagePlace: draft.storagePlace,
        purchasedAt: _today,
        expiresAt: draft.expiresAt,
      );

      final result = await _ingredientRepository.save(ingredient);
      if (result case ResultFailure<void>(:final message)) {
        emit(
          state.copyWith(status: QuickAddStatus.failure, errorMessage: message),
        );
        return;
      }
    }

    emit(state.copyWith(status: QuickAddStatus.success));
  }

  void _updateDraft(
    Emitter<QuickAddState> emit,
    int index,
    QuickIngredientDraft Function(QuickIngredientDraft draft) update,
  ) {
    final drafts = [...state.drafts];
    drafts[index] = update(drafts[index]);
    emit(state.copyWith(drafts: drafts));
  }

  QuickIngredientDraft _toDraft(ParsedIngredient parsed) {
    final storagePlace = parsed.storagePlace ?? StoragePlace.fridge;
    final amount = parsed.amount ?? _defaultAmount;
    final shelfLife = _shelfLifeRepository.findByName(parsed.name);
    final shelfLifeUnit = shelfLife?.defaultUnit;
    final unit = parsed.unit ?? shelfLifeUnit ?? AppStrings.defaultUnit;

    final draft = QuickIngredientDraft(
      name: parsed.name,
      amount: amount,
      unit: unit,
      storagePlace: storagePlace,
      expiresAt: _today.add(_fallbackShelfLife),
      isExpiryManual: false,
      hasShelfLifeSuggestion: false,
    );

    return _withSuggestedExpiry(draft);
  }

  QuickIngredientDraft _withSuggestedExpiry(QuickIngredientDraft draft) {
    if (draft.isExpiryManual) return draft;

    final suggested = _suggestExpiryDate(
      name: draft.name,
      storagePlace: draft.storagePlace,
      purchasedAt: _today,
    );
    if (suggested == null) {
      return draft.copyWith(
        expiresAt: _today.add(_fallbackShelfLife),
        hasShelfLifeSuggestion: false,
      );
    }

    return draft.copyWith(expiresAt: suggested, hasShelfLifeSuggestion: true);
  }

  static DateTime _atStartOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
}
