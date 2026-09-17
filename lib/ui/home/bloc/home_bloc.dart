import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/result/result.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/domain/repository/ingredient_repository.dart';
import 'package:fridge/domain/usecase/sort_ingredients_by_urgency.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required IngredientRepository repository,
    SortIngredientsByUrgency sortByUrgency = const SortIngredientsByUrgency(),
  }) : _repository = repository,
       _sortByUrgency = sortByUrgency,
       super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeIngredientRemoved>(_onIngredientRemoved);
  }

  final IngredientRepository _repository;
  final SortIngredientsByUrgency _sortByUrgency;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    await emit.forEach<List<Ingredient>>(
      _repository.watchAll(),
      onData: _toLoadedState,
      onError: _toLoadFailedState,
    );
  }

  Future<void> _onIngredientRemoved(
    HomeIngredientRemoved event,
    Emitter<HomeState> emit,
  ) async {
    final result = await _repository.remove(event.id);
    switch (result) {
      case ResultSuccess<void>():
        return;
      case ResultFailure<void>(:final message):
        emit(state.copyWith(errorMessage: message));
    }
  }

  HomeState _toLoadedState(List<Ingredient> ingredients) {
    final sorted = _sortByUrgency(ingredients, DateTime.now());
    return state.copyWith(
      status: HomeStatus.success,
      ingredients: sorted,
      errorMessage: '',
    );
  }

  HomeState _toLoadFailedState(Object error, StackTrace stackTrace) {
    return state.copyWith(
      status: HomeStatus.failure,
      errorMessage: AppStrings.loadIngredientsFailed,
    );
  }
}
