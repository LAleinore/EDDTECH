import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

class AiService {
  final Dio _dio;

  AiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 25),
                receiveTimeout: const Duration(seconds: 35),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

  static const String _primaryEndpoint =
      'https://text.pollinations.ai/openai/chat/completions';

  /// Sends a conversational multi-turn chat request to the LLM.
  Future<String> chat({
    required List<Map<String, String>> messages,
    String? systemPrompt,
    double temperature = 0.6,
  }) async {
    // 1. Try Primary POST Endpoint
    try {
      final formattedMessages = <Map<String, String>>[];

      if (systemPrompt != null && systemPrompt.trim().isNotEmpty) {
        formattedMessages.add({
          'role': 'system',
          'content': systemPrompt.trim(),
        });
      }

      formattedMessages.addAll(messages);

      final payload = {
        'model': 'openai',
        'messages': formattedMessages,
        'temperature': temperature,
      };

      final response = await _dio.post(
        _primaryEndpoint,
        data: payload,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('choices')) {
          final choices = data['choices'] as List;
          if (choices.isNotEmpty) {
            final choice = choices.first;
            final message = choice['message'];
            if (message is Map && message.containsKey('content')) {
              final content = message['content']?.toString().trim() ?? '';
              if (content.isNotEmpty) {
                return content;
              }
            }
          }
        } else if (data is String && data.trim().isNotEmpty) {
          return data.trim();
        }
      }
    } catch (_) {}

    // 2. Secondary High-Resilience GET Endpoint (bypasses CORS preflight issues)
    try {
      final lastUserMessage = messages.lastWhere(
        (m) => m['role'] == 'user',
        orElse: () => {'content': ''},
      )['content'] ?? '';

      final fullPrompt = systemPrompt != null && systemPrompt.isNotEmpty
          ? '$systemPrompt\n\nВопрос пользователя: $lastUserMessage'
          : lastUserMessage;

      final encoded = Uri.encodeComponent(fullPrompt);
      final fallbackUrl =
          'https://text.pollinations.ai/$encoded?model=openai&json=true';

      final fallbackRes = await _dio.get(
        fallbackUrl,
        options: Options(responseType: ResponseType.plain),
      );

      if (fallbackRes.statusCode == 200 && fallbackRes.data != null) {
        final raw = fallbackRes.data.toString().trim();
        if (raw.isNotEmpty) {
          return raw;
        }
      }
    } catch (_) {}

    throw Exception('Failed to receive response from AI service');
  }

  /// Sends a single prompt to the LLM and returns the text response.
  Future<String> completePrompt(
    String prompt, {
    String? systemPrompt,
    double temperature = 0.6,
  }) async {
    return chat(
      messages: [
        {'role': 'user', 'content': prompt},
      ],
      systemPrompt: systemPrompt,
      temperature: temperature,
    );
  }

  /// Robust JSON extraction: handles markdown fences, preambles, and extracts outermost JSON object or array.
  static dynamic parseJsonSafely(String raw) {
    var cleaned = raw.trim();

    // 1. Remove markdown fences if present
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    cleaned = cleaned.trim();

    // 2. Attempt direct JSON decode
    try {
      return json.decode(cleaned);
    } catch (_) {}

    // 3. Extract outermost { ... }
    final startBrace = cleaned.indexOf('{');
    final endBrace = cleaned.lastIndexOf('}');
    if (startBrace != -1 && endBrace != -1 && endBrace > startBrace) {
      try {
        final sub = cleaned.substring(startBrace, endBrace + 1);
        return json.decode(sub);
      } catch (_) {}
    }

    // 4. Extract outermost [ ... ]
    final startBracket = cleaned.indexOf('[');
    final endBracket = cleaned.lastIndexOf(']');
    if (startBracket != -1 && endBracket != -1 && endBracket > startBracket) {
      try {
        final sub = cleaned.substring(startBracket, endBracket + 1);
        return json.decode(sub);
      } catch (_) {}
    }

    return null;
  }
}
