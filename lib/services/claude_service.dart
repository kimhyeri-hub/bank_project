import 'dart:convert';
import 'package:http/http.dart' as http;

class ClaudeService {
  static const _baseUrl = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-haiku-4-5-20251001';
  static const _apiVersion = '2023-06-01';

  // dart-define으로 주입: --dart-define=ANTHROPIC_API_KEY=sk-ant-...
  static const _apiKey =
      String.fromEnvironment('ANTHROPIC_API_KEY', defaultValue: '');

  static bool get isConfigured => _apiKey.isNotEmpty;

  static Future<String> complete({
    required String systemPrompt,
    required String userMessage,
    int maxTokens = 1024,
  }) async {
    if (!isConfigured) {
      throw const ClaudeException('API 키가 설정되지 않았습니다.');
    }

    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': _apiKey,
            'anthropic-version': _apiVersion,
          },
          body: jsonEncode({
            'model': _model,
            'max_tokens': maxTokens,
            'system': systemPrompt,
            'messages': [
              {'role': 'user', 'content': userMessage},
            ],
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'][0]['text'] as String;
    }

    final error = jsonDecode(response.body);
    throw ClaudeException(
      error['error']?['message'] ?? 'API 오류 (${response.statusCode})',
    );
  }
}

class ClaudeException implements Exception {
  final String message;
  const ClaudeException(this.message);

  @override
  String toString() => 'ClaudeException: $message';
}
