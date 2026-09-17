import 'package:flutter/material.dart';
import 'package:fridge/app.dart';
import 'package:fridge/data/datasource/ingredient_local_data_source.dart';
import 'package:fridge/data/repository/ingredient_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final localDataSource = IngredientLocalDataSource(preferences);
  final ingredientRepository = IngredientRepositoryImpl(localDataSource);

  runApp(FridgeApp(ingredientRepository: ingredientRepository));
}
