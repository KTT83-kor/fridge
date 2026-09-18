import 'dart:convert';

import 'package:fridge/domain/entity/ingredient.dart';
import 'package:http/http.dart' as http;

class GeminiMenuDataSource {
  GeminiMenuDataSource({
    required String apiKey,
    http.Client? client,
    Duration retryDelay = const Duration(seconds: 2),
  }) : _apiKey = apiKey,
       _client = client ?? http.Client(),
       _retryDelay = retryDelay;

  static const _model = 'gemini-3.6-flash';
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';
  static const _suggestionCount = 3;

  /// 무료 티어는 요청이 몰리면 503(과부하)이나 429(쿼터 초과)를 간헐적으로
  /// 돌려준다. 몇 초 뒤 재시도하면 대부분 풀리므로 여기서 흡수한다.
  static const _maxAttempts = 3;
  static const _retryStatusCodes = {429, 503};

  final String _apiKey;
  final http.Client _client;
  final Duration _retryDelay;

  Future<String> generateMenuSuggestions(List<Ingredient> ingredients) async {
    if (_apiKey.isEmpty) throw const GeminiApiKeyMissingException();

    final uri = Uri.parse('$_endpoint?key=$_apiKey');
    final body = jsonEncode(_buildRequestBody(ingredients));

    http.Response? lastResponse;
    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      final response = await _client.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) return _extractText(response.body);

      lastResponse = response;
      final shouldRetry = _retryStatusCodes.contains(response.statusCode);
      if (!shouldRetry) break;
      if (attempt < _maxAttempts) await Future<void>.delayed(_retryDelay);
    }

    throw GeminiRequestException(
      statusCode: lastResponse!.statusCode,
      body: lastResponse.body,
    );
  }

  Map<String, dynamic> _buildRequestBody(List<Ingredient> ingredients) {
    final ingredientLines = ingredients.map(_describeIngredient).join('\n');
    final prompt =
        '아래는 냉장고에 있는 재료 목록이다. 소진 임박 순으로 정렬돼 있으니 '
        '앞쪽 재료를 우선 사용해서 한 끼 메뉴를 $_suggestionCount개 추천해라. '
        '목록에 없는 재료는 쓰지 마라.\n\n$ingredientLines';

    return {
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'responseSchema': {
          'type': 'ARRAY',
          'items': {
            'type': 'OBJECT',
            'properties': {
              'name': {'type': 'STRING'},
              'description': {'type': 'STRING'},
              'usedIngredientNames': {
                'type': 'ARRAY',
                'items': {'type': 'STRING'},
              },
            },
            'required': ['name', 'description', 'usedIngredientNames'],
          },
        },
      },
    };
  }

  String _describeIngredient(Ingredient ingredient) {
    return '- ${ingredient.name} ${ingredient.amount}${ingredient.unit}';
  }

  String _extractText(String responseBody) {
    final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
    final candidates = decoded['candidates'] as List<dynamic>;
    final firstCandidate = candidates.first as Map<String, dynamic>;
    final content = firstCandidate['content'] as Map<String, dynamic>;
    final parts = content['parts'] as List<dynamic>;
    final firstPart = parts.first as Map<String, dynamic>;
    return firstPart['text'] as String;
  }
}

class GeminiRequestException implements Exception {
  const GeminiRequestException({required this.statusCode, required this.body});

  final int statusCode;
  final String body;

  @override
  String toString() => 'GeminiRequestException($statusCode): $body';
}

class GeminiApiKeyMissingException implements Exception {
  const GeminiApiKeyMissingException();

  @override
  String toString() => 'GeminiApiKeyMissingException';
}
