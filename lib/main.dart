import 'package:flutter/material.dart';
import 'package:fridge/app.dart';
import 'package:fridge/data/datasource/ingredient_local_data_source.dart';
import 'package:fridge/data/repository/ingredient_repository_impl.dart';
import 'package:fridge/data/repository/shelf_life_repository_impl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ko_KR');

  final preferences = await SharedPreferences.getInstance();
  final localDataSource = IngredientLocalDataSource(preferences);
  final ingredientRepository = IngredientRepositoryImpl(localDataSource);
  const shelfLifeRepository = ShelfLifeRepositoryImpl();

  runApp(
    FridgeApp(
      ingredientRepository: ingredientRepository,
      shelfLifeRepository: shelfLifeRepository,
    ),
  );
}
