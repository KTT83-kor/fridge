import 'package:fridge/domain/entity/ingredient.dart';

class SortIngredientsByUrgency {
  const SortIngredientsByUrgency();

  List<Ingredient> call(List<Ingredient> ingredients, DateTime today) {
    int compareByUrgency(Ingredient left, Ingredient right) {
      final leftDaysLeft = left.daysLeftFrom(today);
      final rightDaysLeft = right.daysLeftFrom(today);
      final byDaysLeft = leftDaysLeft.compareTo(rightDaysLeft);
      if (byDaysLeft != 0) return byDaysLeft;
      return left.name.compareTo(right.name);
    }

    return [...ingredients]..sort(compareByUrgency);
  }
}
