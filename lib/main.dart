import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fridge/app.dart';
import 'package:fridge/data/datasource/gemini_ingredient_image_data_source.dart';
import 'package:fridge/data/datasource/gemini_menu_data_source.dart';
import 'package:fridge/data/datasource/ingredient_local_data_source.dart';
import 'package:fridge/data/repository/image_ingredient_parsing_repository_impl.dart';
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
  final geminiMenuDataSource = GeminiMenuDataSource(apiKey: geminiApiKey);
  final menuSuggestionRepository = MenuSuggestionRepositoryImpl(
    geminiMenuDataSource,
  );

  final geminiIngredientImageDataSource = GeminiIngredientImageDataSource(
    apiKey: geminiApiKey,
  );
  final imageIngredientParsingRepository = ImageIngredientParsingRepositoryImpl(
    geminiIngredientImageDataSource,
  );

  runApp(
    FridgeApp(
      ingredientRepository: ingredientRepository,
      shelfLifeRepository: shelfLifeRepository,
      menuSuggestionRepository: menuSuggestionRepository,
      imageIngredientParsingRepository: imageIngredientParsingRepository,
    ),
  );
}

/// env.example을 asset으로 읽는다. dart:io로 프로젝트 루트 파일을 읽는
/// 방식은 기기에 설치된 앱에서는 그 경로가 기기 안 샌드박스를 가리켜
/// 동작하지 않는다 — asset 번들이 유일하게 기기까지 따라가는 경로다.
/// env.example은 항상 커밋돼 있어 파일이 없어서 빌드가 깨질 일이 없다.
Future<void> _loadEnv() async {
  await dotenv.load(fileName: 'env.example', isOptional: true);
}
