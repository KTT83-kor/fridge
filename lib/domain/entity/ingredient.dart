import 'package:equatable/equatable.dart';
import 'package:fridge/domain/entity/freshness.dart';
import 'package:fridge/domain/entity/storage_place.dart';

class Ingredient extends Equatable {
  const Ingredient({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    required this.storagePlace,
    required this.purchasedAt,
    required this.expiresAt,
    this.memo = '',
  });

  final String id;
  final String name;
  final double amount;
  final String unit;
  final StoragePlace storagePlace;
  final DateTime purchasedAt;
  final DateTime expiresAt;
  final String memo;

  int daysLeftFrom(DateTime today) {
    final from = DateTime(today.year, today.month, today.day);
    final until = DateTime(expiresAt.year, expiresAt.month, expiresAt.day);
    return until.difference(from).inDays;
  }

  Freshness freshnessFrom(DateTime today) {
    return Freshness.fromDaysLeft(daysLeftFrom(today));
  }

  Ingredient copyWith({
    String? name,
    double? amount,
    String? unit,
    StoragePlace? storagePlace,
    DateTime? purchasedAt,
    DateTime? expiresAt,
    String? memo,
  }) {
    return Ingredient(
      id: id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      storagePlace: storagePlace ?? this.storagePlace,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      memo: memo ?? this.memo,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    amount,
    unit,
    storagePlace,
    purchasedAt,
    expiresAt,
    memo,
  ];
}
