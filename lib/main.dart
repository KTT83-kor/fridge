import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fridge/app.dart';
import 'package:fridge/data/datasource/gemini_menu_data_source.dart';
import 'package:fridge/data/datasource/ingredient_local_data_source.dart';
import 'package:fridge/data/repository/ingredient_repository_impl.dart';
import 'package:fridge/data/repository/menu_suggestion_repository_impl.dart';
import 'package:fridge/data/repository/shelf_life_repository_impl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ko_KR');
  await _loadEnv();

  final preferences = await SharedPreferences.getInstance();
  final localDataSource = IngredientLocalDataSource(preferences);
  final ingredientRepository = IngredientRepositoryImpl(localDataSource);
  const shelfLifeRepository = ShelfLifeRepositoryImpl();

  final geminiApiKey = dotenv.maybeGet('GEMINI_API_KEY') ?? '';
  final geminiDataSource = GeminiMenuDataSource(apiKey: geminiApiKey);
  final menuSuggestionRepository = MenuSuggestionRepositoryImpl(
    geminiDataSource,
  );

  runApp(
    FridgeApp(
      ingredientRepository: ingredientRepository,
      shelfLifeRepository: shelfLifeRepository,
      menuSuggestionRepository: menuSuggestionRepository,
    ),
  );
}

/// 태블릿 개발 환경의 프로젝트 루트에 있는 .env 파일을 읽는다.
/// 배포용 asset이 아니라 dart:io로 직접 읽어서, .env가 아직 없어도
/// 빌드 자체는 막히지 않는다.
Future<void> _loadEnv() async {
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    dotenv.loadFromString(isOptional: true);
    return;
  }

  final envString = await envFile.readAsString();
  dotenv.loadFromString(envString: envString, isOptional: true);
}
