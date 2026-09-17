import 'package:flutter/material.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/theme/app_spacing.dart';
import 'package:fridge/domain/entity/storage_place.dart';

class StoragePlaceSelector extends StatelessWidget {
  const StoragePlaceSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final StoragePlace selected;
  final ValueChanged<StoragePlace> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    ButtonSegment<StoragePlace> buildSegment(StoragePlace place) {
      return ButtonSegment<StoragePlace>(
        value: place,
        label: Text(place.label),
      );
    }

    final segments = StoragePlace.values.map(buildSegment).toList();

    void handleSelection(Set<StoragePlace> selection) {
      onChanged(selection.first);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.storagePlaceLabel, style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<StoragePlace>(
          segments: segments,
          selected: {selected},
          onSelectionChanged: handleSelection,
          showSelectedIcon: false,
        ),
      ],
    );
  }
}
