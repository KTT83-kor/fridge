import 'package:equatable/equatable.dart';

class MenuSuggestion extends Equatable {
  const MenuSuggestion({
    required this.name,
    required this.description,
    required this.usedIngredientNames,
  });

  final String name;
  final String description;
  final List<String> usedIngredientNames;

  @override
  List<Object?> get props => [name, description, usedIngredientNames];
}
