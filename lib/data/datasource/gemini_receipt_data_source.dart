import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class GeminiReceiptDataSource {
  GeminiReceiptDataSource({
    required String apiKey,
    http.Client? client,
    Duration retryDelay = const Duration(seconds: 2),
  }) : _apiKey = apiKey,
       _client = client ?? http.Client(),
       _retryDelay = retryDelay;

  static const _model = 'gemini-3.6-flash';
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  /// 무료 티어는 요청이 몰리면 503(과부하)이나 429(쿼터 초과)를 간헐적으로
  /// 돌려준다. 몇 초 뒤 재시도하면 대부분 풀리므로 여기서 흡수한다.
  static const _maxAttempts = 3;
  static const _retryStatusCodes = {429, 503};

  static const _prompt =
      '이 영수증 사진에서 식재료로 보이는 상품명만 뽑아라. 상품명은 영수증에 '
      '적힌 표현을 최대한 살리되 규격·용량 표기(예: 1L, 500g)가 있으면 '
      'amount와 unit으로 분리해라. 봉투값·할인·부가세 같은 비상품 항목은 '
      '제외해라.';

  final String _apiKey;
  final http.Client _client;
  final Duration _retryDelay;

  Future<String> extractIngredients(Uint8List imageBytes) async {
    if (_apiKey.isEmpty) throw const GeminiApiKeyMissingException();

    final uri = Uri.parse('$_endpoint?key=$_apiKey');
    final body = jsonEncode(_buildRequestBody(imageBytes));

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

  Map<String, dynamic> _buildRequestBody(Uint8List imageBytes) {
    return {
      'contents': [
        {
          'parts': [
            {'text': _prompt},
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Encode(imageBytes),
              },
            },
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
              'amount': {'type': 'NUMBER'},
              'unit': {'type': 'STRING'},
            },
            'required': ['name'],
          },
        },
      },
    };
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
