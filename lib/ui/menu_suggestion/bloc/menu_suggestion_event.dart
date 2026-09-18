part of 'menu_suggestion_bloc.dart';

sealed class MenuSuggestionEvent extends Equatable {
  const MenuSuggestionEvent();

  @override
  List<Object?> get props => const [];
}

final class MenuSuggestionRequested extends MenuSuggestionEvent {
  const MenuSuggestionRequested();
}
