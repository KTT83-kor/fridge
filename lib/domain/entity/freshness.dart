import 'package:fridge/core/constant/app_strings.dart';

enum Freshness {
  expired(AppStrings.freshnessExpired),
  urgent(AppStrings.freshnessUrgent),
  soon(AppStrings.freshnessSoon),
  fresh(AppStrings.freshnessFresh);

  const Freshness(this.label);

  final String label;

  static const urgentThresholdDays = 1;
  static const soonThresholdDays = 3;

  static Freshness fromDaysLeft(int daysLeft) {
    if (daysLeft < 0) return Freshness.expired;
    if (daysLeft <= urgentThresholdDays) return Freshness.urgent;
    if (daysLeft <= soonThresholdDays) return Freshness.soon;
    return Freshness.fresh;
  }
}
