import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/config/ai_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exception.dart';

class AiRepository {
  AiRepository()
      : _dio = Dio(
          BaseOptions(
            baseUrl: AiConfig.baseUrl,
            connectTimeout: AiConfig.softTimeout,
            receiveTimeout: AiConfig.softTimeout,
            headers: {
              'Authorization': 'Bearer ${AiConfig.apiKey}',
              'Content-Type': 'application/json',
              if (AiConfig.httpReferer.isNotEmpty) 'HTTP-Referer': AiConfig.httpReferer,
              if (AiConfig.appName.isNotEmpty) 'X-Title': AiConfig.appName,
            },
          ),
        );

  final Dio _dio;

  bool get isConfigured =>
      AiConfig.baseUrl.isNotEmpty && AiConfig.model.isNotEmpty && AiConfig.apiKey.isNotEmpty;

  Future<List<Map<String, String>>> generateCards({
    required String topic,
    required int count,
    required String language,
    required String difficulty,
  }) async {
    if (!isConfigured) {
      throw ApiException(message: 'AI is not configured');
    }

    final cappedCount = count.clamp(AppConstants.minAiCards, AppConstants.maxAiCards);
    final prompt = '''
Ты — помощник по созданию обучающих флеш-карточек в стиле Anki.
Нужно сгенерировать $cappedCount карточек по теме "$topic" на языке "$language" с уровнем сложности "$difficulty".

Формат ответа — строго JSON-массив без лишнего текста:
[
  {"question": "...", "answer": "..."},
  ...
]
''';

    final response = await _dio.post<Map<String, dynamic>>(
      '/chat/completions',
      data: {
        'model': AiConfig.model,
        'max_tokens': AiConfig.maxOutputTokens,
        'temperature': 0.7,
        'messages': [
          {
            'role': 'system',
            'content': 'Ты создаёшь карточки вопрос-ответ для приложения флеш-карточек.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
      },
    );

    final data = response.data;
    if (data == null) throw ApiException(message: 'Empty AI response');
    final choices = data['choices'];
    if (choices is! List || choices.isEmpty) {
      throw ApiException(message: 'Invalid AI response');
    }
    final content = choices.first['message']?['content'] as String? ?? '';
    if (content.isEmpty) {
      throw ApiException(message: 'Empty AI content');
    }

    return _parseCardsFromContent(content);
  }

  Future<List<Map<String, String>>> generateFromText({
    required String text,
    required int count,
    String language = 'ru',
  }) async {
    if (!isConfigured) {
      throw ApiException(message: 'AI is not configured');
    }

    final cappedCount = count.clamp(AppConstants.minAiCards, AppConstants.maxAiCards);
    final normalizedText = _normalizeText(text);
    if (normalizedText.isEmpty) {
      throw ApiException(message: 'Empty text');
    }

    final prompt = '''
У тебя есть исходный учебный текст. Выбери самые важные термины/понятия и факты и создай $cappedCount обучающих флеш-карточек (вопрос-ответ) на "$language".
Если в тексте есть термины без явного определения, сформулируй вопрос так, чтобы ответ можно было вывести из контекста (кратко, без выдуманных фактов).
Карточки должны быть атомарными, без воды, без повторов.

Ответь строго JSON-массивом:
[
  {"question": "...", "answer": "..."},
  ...
]

Вот текст:
$normalizedText
''';

    final response = await _dio.post<Map<String, dynamic>>(
      '/chat/completions',
      data: {
        'model': AiConfig.model,
        'max_tokens': AiConfig.maxOutputTokens,
        'temperature': 0.4,
        'messages': [
          {
            'role': 'system',
            'content': 'Ты выделяешь главное из текста и превращаешь в карточки вопрос-ответ.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
      },
    );

    final data = response.data;
    if (data == null) throw ApiException(message: 'Empty AI response');
    final choices = data['choices'];
    if (choices is! List || choices.isEmpty) {
      throw ApiException(message: 'Invalid AI response');
    }
    final content = choices.first['message']?['content'] as String? ?? '';
    if (content.isEmpty) {
      throw ApiException(message: 'Empty AI content');
    }

    return _parseCardsFromContent(content);
  }

  String _normalizeText(String text) {
    // Guard against huge prompts. Keep enough context to produce decent cards.
    const maxChars = 12000;
    const marker = '\n\n[...текст сокращён...]\n\n';
    final trimmed = text.trim().replaceAll('\r\n', '\n');
    if (trimmed.length <= maxChars) return trimmed;

    const available = maxChars - marker.length;
    // Prefer keeping more from the beginning but still preserve some tail context.
    final headChars = (available * 2 / 3).floor().clamp(0, available);
    final tailChars = (available - headChars).clamp(0, available);
    final head = trimmed.substring(0, headChars);
    final tail = trimmed.substring(trimmed.length - tailChars);
    return '$head$marker$tail';
  }

  List<Map<String, String>> _parseCardsFromContent(String content) {
    try {
      final jsonText = _extractJson(content);
      final decoded = jsonDecode(jsonText);
      if (decoded is! List) {
        throw ApiException(message: 'AI JSON is not a list');
      }
      final result = <Map<String, String>>[];
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          final question = '${item['question'] ?? ''}'.trim();
          final answer = '${item['answer'] ?? ''}'.trim();
          if (question.isNotEmpty && answer.isNotEmpty) {
            result.add({'question': question, 'answer': answer});
          }
        }
      }
      return result;
    } catch (_) {
      throw ApiException(message: 'Failed to parse AI response');
    }
  }

  String _extractJson(String content) {
    final start = content.indexOf('[');
    final end = content.lastIndexOf(']');
    if (start == -1 || end == -1 || end <= start) {
      return content;
    }
    return content.substring(start, end + 1);
  }
}
