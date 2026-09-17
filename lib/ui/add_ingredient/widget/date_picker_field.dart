import 'package:flutter/material.dart';
import 'package:fridge/core/theme/app_spacing.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatelessWidget {
  const DatePickerField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.helperText = '',
    this.helperColor,
    super.key,
  });

  static const _firstYearOffset = 5;
  static const _lastYearOffset = 5;

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final String helperText;
  final Color? helperColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatted = DateFormat('yyyy.MM.dd (E)', 'ko_KR').format(value);

    Future<void> pickDate() async {
      final firstDate = DateTime(value.year - _firstYearOffset);
      final lastDate = DateTime(value.year + _lastYearOffset, 12, 31);
      final picked = await showDatePicker(
        context: context,
        initialDate: value,
        firstDate: firstDate,
        lastDate: lastDate,
      );
      if (picked == null) return;
      onChanged(picked);
    }

    final helperStyle = theme.textTheme.bodySmall?.copyWith(
      color: helperColor ?? theme.colorScheme.outline,
    );

    return InkWell(
      onTap: pickDate,
      borderRadius: BorderRadius.circular(AppSpacing.xs),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(formatted, style: theme.textTheme.bodyLarge),
            if (helperText.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(helperText, style: helperStyle),
            ],
          ],
        ),
      ),
    );
  }
}
