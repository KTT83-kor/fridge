import 'package:fridge/data/datasource/shelf_life_table.dart';
import 'package:fridge/domain/entity/shelf_life.dart';
import 'package:fridge/domain/repository/shelf_life_repository.dart';

class ShelfLifeRepositoryImpl implements ShelfLifeRepository {
  const ShelfLifeRepositoryImpl();

  static const defaultSearchLimit = 5;

  @override
  ShelfLife? findByName(String name) {
    final normalized = _normalize(name);
    if (normalized.isEmpty) return null;

    for (final entry in ShelfLifeTable.entries) {
      if (_normalize(entry.name) == normalized) return entry;
    }
    return null;
  }

  @override
  List<ShelfLife> search(String query, {int limit = defaultSearchLimit}) {
    final normalized = _normalize(query);
    if (normalized.isEmpty) return const [];

    final startsWith = <ShelfLife>[];
    final contains = <ShelfLife>[];
    for (final entry in ShelfLifeTable.entries) {
      final entryName = _normalize(entry.name);
      if (entryName.startsWith(normalized)) {
        startsWith.add(entry);
      } else if (entryName.contains(normalized)) {
        contains.add(entry);
      }
    }

    final matches = [...startsWith, ...contains];
    if (matches.length <= limit) return matches;
    return matches.sublist(0, limit);
  }

  String _normalize(String value) => value.replaceAll(' ', '').toLowerCase();
}
