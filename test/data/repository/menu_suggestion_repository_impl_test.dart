import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/result/result.dart';
import 'package:fridge/data/datasource/gemini_menu_data_source.dart';
import 'package:fridge/data/repository/menu_suggestion_repository_impl.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/domain/entity/menu_suggestion.dart';
import 'package:fridge/domain/entity/storage_place.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final today = DateTime(2026, 9, 17);
  final tofu = Ingredient(
    id: 'tofu',
    name: '두부',
    amount: 1,
    unit: '모',
    storagePlace: StoragePlace.fridge,
    purchasedAt: today,
    expiresAt: today.add(const Duration(days: 3)),
  );

  Map<String, dynamic> buildGeminiResponse(String text) {
    return {
      'candidates': [
        {
          'content': {
            'parts': [
              {'text': text},
            ],
          },
        },
      ],
    };
  }

  http.Response buildJsonResponse(String body, {int statusCode = 200}) {
    return http.Response(
      body,
      statusCode,
      headers: const {'content-type': 'application/json; charset=utf-8'},
    );
  }

  MenuSuggestionRepositoryImpl buildRepository(
    http.Client client, {
    String apiKey = 'test-key',
  }) {
    final dataSource = GeminiMenuDataSource(
      apiKey: apiKey,
      client: client,
      retryDelay: Duration.zero,
    );
    return MenuSuggestionRepositoryImpl(dataSource);
  }

  test('정상 응답을 MenuSuggestion 목록으로 바꾼다', () async {
    final suggestionsJson = jsonEncode([
      {
        'name': '두부조림',
        'description': '두부로 만드는 조림',
        'usedIngredientNames': ['두부'],
        'steps': ['두부를 썬다', '조린다'],
      },
    ]);
    final client = MockClient((request) async {
      final response = buildGeminiResponse(suggestionsJson);
      return buildJsonResponse(jsonEncode(response));
    });
    final repository = buildRepository(client);

    final result = await repository.suggestForOneMeal([tofu]);

    expect(result, isA<ResultSuccess<List<MenuSuggestion>>>());
    final success = result as ResultSuccess<List<MenuSuggestion>>;
    final suggestion = success.value.single;
    expect(suggestion.name, '두부조림');
    expect(suggestion.usedIngredientNames, ['두부']);
  });

  test('여러 메뉴를 순서대로 담는다', () async {
    final suggestionsJson = jsonEncode([
      {
        'name': '메뉴1',
        'description': '설명1',
        'usedIngredientNames': ['두부'],
        'steps': ['1단계'],
      },
      {
        'name': '메뉴2',
        'description': '설명2',
        'usedIngredientNames': ['두부'],
        'steps': ['1단계'],
      },
    ]);
    final client = MockClient((request) async {
      final response = buildGeminiResponse(suggestionsJson);
      return buildJsonResponse(jsonEncode(response));
    });
    final repository = buildRepository(client);

    final result = await repository.suggestForOneMeal([tofu]);

    final success = result as ResultSuccess<List<MenuSuggestion>>;
    expect(success.value.map((s) => s.name), ['메뉴1', '메뉴2']);
  });

  test('HTTP 오류가 나면 실패를 돌려준다', () async {
    final client = MockClient((request) async {
      return buildJsonResponse('서버 오류', statusCode: 500);
    });
    final repository = buildRepository(client);

    final result = await repository.suggestForOneMeal([tofu]);

    expect(result, isA<ResultFailure<List<MenuSuggestion>>>());
  });

  test('응답이 JSON 형식이 아니면 실패를 돌려준다', () async {
    final client = MockClient((request) async {
      return buildJsonResponse(
        jsonEncode(buildGeminiResponse('이건 JSON이 아니다')),
      );
    });
    final repository = buildRepository(client);

    final result = await repository.suggestForOneMeal([tofu]);

    expect(result, isA<ResultFailure<List<MenuSuggestion>>>());
  });

  test('API 키가 비어 있으면 전용 메시지로 실패를 돌려준다', () async {
    final client = MockClient((request) async {
      return buildJsonResponse(jsonEncode(buildGeminiResponse('[]')));
    });
    final repository = buildRepository(client, apiKey: '');

    final result = await repository.suggestForOneMeal([tofu]);

    expect(result, isA<ResultFailure<List<MenuSuggestion>>>());
    final failure = result as ResultFailure<List<MenuSuggestion>>;
    expect(failure.message, AppStrings.menuSuggestionApiKeyMissing);
  });

  test('503이면 과부하 전용 메시지로 실패를 돌려준다', () async {
    final client = MockClient((request) async {
      return buildJsonResponse('과부하', statusCode: 503);
    });
    final repository = buildRepository(client);

    final result = await repository.suggestForOneMeal([tofu]);

    final failure = result as ResultFailure<List<MenuSuggestion>>;
    expect(failure.message, AppStrings.menuSuggestionOverloaded);
  });

  test('429면 쿼터 초과 전용 메시지로 실패를 돌려준다', () async {
    final client = MockClient((request) async {
      return buildJsonResponse('쿼터 초과', statusCode: 429);
    });
    final repository = buildRepository(client);

    final result = await repository.suggestForOneMeal([tofu]);

    final failure = result as ResultFailure<List<MenuSuggestion>>;
    expect(failure.message, AppStrings.menuSuggestionQuotaExceeded);
  });

  test('그 외 오류는 상태 코드를 담은 메시지로 실패를 돌려준다', () async {
    final client = MockClient((request) async {
      return buildJsonResponse('서버 오류', statusCode: 500);
    });
    final repository = buildRepository(client);

    final result = await repository.suggestForOneMeal([tofu]);

    final failure = result as ResultFailure<List<MenuSuggestion>>;
    expect(failure.message, AppStrings.menuSuggestionFailedWithCode(500));
  });
}
