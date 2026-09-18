import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/theme/app_theme.dart';
import 'package:fridge/domain/repository/ingredient_repository.dart';
import 'package:fridge/domain/repository/menu_suggestion_repository.dart';
import 'package:fridge/domain/repository/receipt_parsing_repository.dart';
import 'package:fridge/domain/repository/shelf_life_repository.dart';
import 'package:fridge/ui/home/home_page.dart';

class FridgeApp extends StatelessWidget {
  const FridgeApp({
    required this.ingredientRepository,
    required this.shelfLifeRepository,
    required this.menuSuggestionRepository,
    required this.receiptParsingRepository,
    super.key,
  });

  final IngredientRepository ingredientRepository;
  final ShelfLifeRepository shelfLifeRepository;
  final MenuSuggestionRepository menuSuggestionRepository;
  final ReceiptParsingRepository receiptParsingRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IngredientRepository>.value(
          value: ingredientRepository,
        ),
        RepositoryProvider<ShelfLifeRepository>.value(
          value: shelfLifeRepository,
        ),
        RepositoryProvider<MenuSuggestionRepository>.value(
          value: menuSuggestionRepository,
        ),
        RepositoryProvider<ReceiptParsingRepository>.value(
          value: receiptParsingRepository,
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appTitle,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ko', 'KR')],
        home: const HomePage(),
      ),
    );
  }
}
