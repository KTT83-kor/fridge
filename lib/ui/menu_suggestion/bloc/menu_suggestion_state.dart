part of 'menu_suggestion_bloc.dart';

enum MenuSuggestionStatus { loading, noIngredients, success, failure }

final class MenuSuggestionState extends Equatable {
  const MenuSuggestionState({
    this.status = MenuSuggestionStatus.loading,
    this.suggestions = const [],
    this.errorMessage = '',
  });

  final MenuSuggestionStatus status;
  final List<MenuSuggestion> suggestions;
  final String errorMessage;

  MenuSuggestionState copyWith({
    MenuSuggestionStatus? status,
    List<MenuSuggestion>? suggestions,
    String? errorMessage,
  }) {
    return MenuSuggestionState(
      status: status ?? this.status,
      suggestions: suggestions ?? this.suggestions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, suggestions, errorMessage];
}
