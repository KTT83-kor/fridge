import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fridge/data/datasource/gemini_menu_data_source.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/domain/entity/storage_place.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final today = DateTime(2026, 9, 17);
  final milk = Ingredient(
    id: 'milk',
    name: '우유',
    amount: 2,
    unit: 'L',
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

  test('응답 본문에서 텍스트 파트를 뽑아낸다', () async {
    final suggestionsJson = jsonEncode([
      {
        'name': '우유죽',
        'description': '우유로 만드는 죽',
        'usedIngredientNames': ['우유'],
      },
    ]);
    final client = MockClient((request) async {
      final responseBody = jsonEncode(buildGeminiResponse(suggestionsJson));
      return buildJsonResponse(responseBody);
    });
    final dataSource = GeminiMenuDataSource(
      apiKey: 'test-key',
      client: client,
    );

    final result = await dataSource.generateMenuSuggestions([milk]);

    expect(result, suggestionsJson);
  });

  test('요청 본문에 재료 이름과 수량을 담는다', () async {
    late Map<String, dynamic> capturedBody;
    final client = MockClient((request) async {
      capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
      return buildJsonResponse(jsonEncode(buildGeminiResponse('[]')));
    });
    final dataSource = GeminiMenuDataSource(
      apiKey: 'test-key',
      client: client,
    );

    await dataSource.generateMenuSuggestions([milk]);

    final contents = capturedBody['contents'] as List<dynamic>;
    final firstContent = contents.first as Map<String, dynamic>;
    final parts = firstContent['parts'] as List<dynamic>;
    final promptText = (parts.first as Map<String, dynamic>)['text'] as String;

    expect(promptText, contains('우유'));
    expect(promptText, contains('2.0L'));
  });

  test('JSON 응답을 강제하는 스키마를 요청에 담는다', () async {
    late Map<String, dynamic> capturedBody;
    final client = MockClient((request) async {
      capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
      return buildJsonResponse(jsonEncode(buildGeminiResponse('[]')));
    });
    final dataSource = GeminiMenuDataSource(
      apiKey: 'test-key',
      client: client,
    );

    await dataSource.generateMenuSuggestions([milk]);

    final generationConfig =
        capturedBody['generationConfig'] as Map<String, dynamic>;
    expect(generationConfig['responseMimeType'], 'application/json');
  });

  test('API 키를 쿼리 파라미터로 담는다', () async {
    late Uri capturedUri;
    final client = MockClient((request) async {
      capturedUri = request.url;
      return buildJsonResponse(jsonEncode(buildGeminiResponse('[]')));
    });
    final dataSource = GeminiMenuDataSource(apiKey: 'my-key', client: client);

    await dataSource.generateMenuSuggestions([milk]);

    expect(capturedUri.queryParameters['key'], 'my-key');
  });

  test('재시도 대상이 아닌 오류는 바로 예외를 던진다', () async {
    var requestCount = 0;
    final client = MockClient((request) async {
      requestCount++;
      return buildJsonResponse('오류', statusCode: 400);
    });
    final dataSource = GeminiMenuDataSource(
      apiKey: 'test-key',
      client: client,
    );

    await expectLater(
      () => dataSource.generateMenuSuggestions([milk]),
      throwsA(isA<GeminiRequestException>()),
    );
    expect(requestCount, 1);
  });

  test('503은 재시도하다가 성공하면 결과를 돌려준다', () async {
    var requestCount = 0;
    final client = MockClient((request) async {
      requestCount++;
      if (requestCount < 3) return buildJsonResponse('과부하', statusCode: 503);
      return buildJsonResponse(jsonEncode(buildGeminiResponse('[]')));
    });
    final dataSource = GeminiMenuDataSource(
      apiKey: 'test-key',
      client: client,
      retryDelay: Duration.zero,
    );

    final result = await dataSource.generateMenuSuggestions([milk]);

    expect(result, '[]');
    expect(requestCount, 3);
  });

  test('429가 재시도 횟수를 넘게 계속되면 결국 예외를 던진다', () async {
    var requestCount = 0;
    final client = MockClient((request) async {
      requestCount++;
      return buildJsonResponse('쿼터 초과', statusCode: 429);
    });
    final dataSource = GeminiMenuDataSource(
      apiKey: 'test-key',
      client: client,
      retryDelay: Duration.zero,
    );

    await expectLater(
      () => dataSource.generateMenuSuggestions([milk]),
      throwsA(isA<GeminiRequestException>()),
    );
    expect(requestCount, 3);
  });

  test('API 키가 비어 있으면 요청 없이 예외를 던진다', () async {
    var requested = false;
    final client = MockClient((request) async {
      requested = true;
      return buildJsonResponse(jsonEncode(buildGeminiResponse('[]')));
    });
    final dataSource = GeminiMenuDataSource(apiKey: '', client: client);

    await expectLater(
      () => dataSource.generateMenuSuggestions([milk]),
      throwsA(isA<GeminiApiKeyMissingException>()),
    );
    expect(requested, isFalse);
  });
}
