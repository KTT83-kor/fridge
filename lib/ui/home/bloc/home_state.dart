part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, failure }

final class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.ingredients = const [],
    this.errorMessage = '',
  });

  final HomeStatus status;
  final List<Ingredient> ingredients;
  final String errorMessage;

  HomeState copyWith({
    HomeStatus? status,
    List<Ingredient>? ingredients,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      ingredients: ingredients ?? this.ingredients,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, ingredients, errorMessage];
}
