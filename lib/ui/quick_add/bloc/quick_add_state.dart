part of 'quick_add_bloc.dart';

enum QuickAddStatus { editing, reviewing, submitting, success, failure }

final class QuickAddState extends Equatable {
  const QuickAddState({
    this.text = '',
    this.drafts = const [],
    this.status = QuickAddStatus.editing,
    this.errorMessage = '',
  });

  final String text;
  final List<QuickIngredientDraft> drafts;
  final QuickAddStatus status;
  final String errorMessage;

  bool get canParse => text.trim().isNotEmpty;

  bool get canSubmit {
    return drafts.isNotEmpty &&
        drafts.every((draft) => draft.isValid) &&
        status != QuickAddStatus.submitting;
  }

  QuickAddState copyWith({
    String? text,
    List<QuickIngredientDraft>? drafts,
    QuickAddStatus? status,
    String? errorMessage,
  }) {
    return QuickAddState(
      text: text ?? this.text,
      drafts: drafts ?? this.drafts,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [text, drafts, status, errorMessage];
}
