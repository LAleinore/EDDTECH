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
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 45),
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
    double temperature = 0.7,
  }) async {
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

    throw Exception('Failed to receive response from AI service');
  }

  /// Sends a single prompt to the LLM and returns the text response.
  Future<String> completePrompt(
    String prompt, {
    String? systemPrompt,
    double temperature = 0.7,
  }) async {
    return chat(
      messages: [
        {'role': 'user', 'content': prompt},
      ],
      systemPrompt: systemPrompt,
      temperature: temperature,
    );
  }

  /// Utility to extract and parse JSON from an LLM response even if it's wrapped in Markdown fences.
  static dynamic parseJsonSafely(String raw) {
    var cleaned = raw.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    cleaned = cleaned.trim();

    return json.decode(cleaned);
  }
}
