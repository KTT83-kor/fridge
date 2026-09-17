import 'package:fridge/core/constant/app_strings.dart';

String formatDaysLeft(int daysLeft) {
  if (daysLeft == 0) return AppStrings.dDay;
  if (daysLeft > 0) return 'D-$daysLeft';

  final daysOverdue = -daysLeft;
  return 'D+$daysOverdue';
}
