import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/theme/app_theme.dart';
import 'package:fridge/domain/repository/ingredient_repository.dart';
import 'package:fridge/ui/home/home_page.dart';

class FridgeApp extends StatelessWidget {
  const FridgeApp({required this.ingredientRepository, super.key});

  final IngredientRepository ingredientRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<IngredientRepository>.value(
      value: ingredientRepository,
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
