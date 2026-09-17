import 'package:flutter/material.dart';
import 'package:fridge/core/theme/app_colors.dart';
import 'package:fridge/domain/entity/freshness.dart';

extension FreshnessColor on Freshness {
  Color resolveColor(ColorScheme colorScheme) {
    switch (this) {
      case Freshness.expired:
        return colorScheme.error;
      case Freshness.urgent:
        return AppColors.urgent;
      case Freshness.soon:
        return AppColors.soon;
      case Freshness.fresh:
        return colorScheme.primary;
    }
  }
}
