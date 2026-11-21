import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/ai_service.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/chat_message_model.dart';
import '../domain/mood_model.dart';

final mindcareRepositoryProvider = Provider<MindcareRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final aiService = ref.watch(aiServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return MindcareRepository(
    apiClient: apiClient,
    aiService: aiService,
    prefs: prefs,
  );
});

class MindcareRepository {
  final ApiClient _apiClient;
  final AiService _aiService;
  final SharedPreferences _prefs;

  MindcareRepository({
    required ApiClient apiClient,
    required AiService aiService,
    required SharedPreferences prefs,
  })  : _apiClient = apiClient,
        _aiService = aiService,
        _prefs = prefs;

  static const String _chatHistoryKey = 'mindcare_chat_history_v1';
  static const String _moodHistoryKey = 'mindcare_mood_history_v1';

  // Safety filter keywords
  static final List<String> _crisisKeywords = [
    'суицид',
    'убить себя',
    'покончить с собой',
    'самоубийств',
    'порезать вены',
    'не хочу жить',
    'хочу умереть',
    'өзіме қол салу',
    'өлгім келеді',
    'suicide',
    'kill myself',
    'want to die',
    'self-harm',
  ];

  static bool checkCrisis(String text) {
    final lower = text.toLowerCase();
    for (final kw in _crisisKeywords) {
      if (lower.contains(kw)) return true;
    }
    return false;
  }

  Future<ChatMessageModel> sendMessage({
    required String message,
    required List<ChatMessageModel> history,
    String language = 'ru',
  }) async {
    // 1. Client-side instant deterministic safety check
    if (checkCrisis(message)) {
      return ChatMessageModel(
        id: 'safety-${DateTime.now().millisecondsSinceEpoch}',
        role: 'assistant',
        content:
            'Я чувствую, насколько вам сейчас тяжело, и очень ценю, что вы поделились этим. Ваша жизнь и безопасность — самое главное.\n\nБудучи AI-ассистентом эмоциональной поддержки, я не могу заменить специалистов кризисной помощи. Пожалуйста, прямо сейчас позвоните по бесплатной круглосуточной линии помощи:\n\n📞 Единая служба экстренной помощи: 112\n📞 Национальная линия доверия: 150 (бесплатно, анонимно)',
        isCrisis: true,
        emergencyHelpline: '150 или 112',
        timestamp: DateTime.now(),
      );
    }

    // 2. Live intelligent empathetic response via AiService
    try {
      const systemPrompt =
          'Ты — MindCare AI, чуткий, внимательный и теплый ассистент психологической поддержки для учащихся и учителей. '
          'Твои принципы: '
          '1. Выслушивай без критики и оценивания, проявляй искреннее человеческое сочувствие и валидируй эмоции. '
          '2. Не сыпь сухими заученными фразами. Отвечай индивидуально на то, что человек рассказал. '
          '3. Если собеседник испытывает тревогу, страх перед контрольной, экзаменом или эмоциональное выгорание, мягко предложи практическое упражнение: глубокое дыхание 4-7-8 или технику заземления 5-4-3-2-1. '
          '4. Ты не ставишь диагнозы, но даешь безопасное пространство для выражения чувств.';

      final formattedHistory = <Map<String, String>>[];
      final recent = history.length > 8
          ? history.sublist(history.length - 8)
          : history;

      for (final m in recent) {
        if (m.role == 'user' || m.role == 'assistant') {
          if (!m.isCrisis && m.content.isNotEmpty) {
            formattedHistory.add({'role': m.role, 'content': m.content});
          }
        }
      }

      if (formattedHistory.isEmpty || formattedHistory.last['content'] != message) {
        formattedHistory.add({'role': 'user', 'content': message});
      }

      final reply = await _aiService.chat(
        messages: formattedHistory,
        systemPrompt: systemPrompt,
        temperature: 0.75,
      );

      String? technique;
      final lower = '$message $reply'.toLowerCase();
      if (lower.contains('тревог') ||
          lower.contains('стресс') ||
          lower.contains('дыхан') ||
          lower.contains('паник') ||
          lower.contains('экзамен')) {
        technique = 'Дыхание 4-7-8';
      }

      return ChatMessageModel(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        role: 'assistant',
        content: reply,
        isCrisis: false,
        suggestedTechnique: technique,
        timestamp: DateTime.now(),
      );
    } catch (_) {
      // 3. Fallback to API client if present
      try {
        final res = await _apiClient.dio.post(
          '/mindcare/chat',
          data: {
            'message': message,
            'history': history
                .map((h) => {'role': h.role, 'content': h.content})
                .toList(),
            'language': language,
          },
        );

        return ChatMessageModel(
          id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
          role: 'assistant',
          content: res.data['reply'] ?? '',
          isCrisis: res.data['isCrisis'] ?? false,
          emergencyHelpline: res.data['emergencyHelpline'],
          suggestedTechnique: res.data['suggestedTechnique'],
          timestamp: DateTime.now(),
        );
      } catch (_) {
        // 4. Offline Fallback
        String reply =
            "Спасибо, что поделились своими переживаниями. Проговаривать эмоции — важный шаг к равновесию. Как я могу поддержать вас прямо сейчас?";
        String? technique;

        final lower = message.toLowerCase();
        if (lower.contains('тревог') ||
            lower.contains('стресс') ||
            lower.contains('экзамен') ||
            lower.contains('қобалжу')) {
          reply =
              "Волноваться перед важными событиями или учебой — совершенно естественно. Позвольте себе сделать глубокий вдох. Хотите выполнить короткую дыхательную практику 4-7-8 вместе?";
          technique = "Дыхание 4-7-8";
        }

        return ChatMessageModel(
          id: 'msg-local-${DateTime.now().millisecondsSinceEpoch}',
          role: 'assistant',
          content: reply,
          isCrisis: false,
          suggestedTechnique: technique,
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<MoodModel> saveMoodEntry({
    required int score,
    required String moodState,
    required List<String> emotions,
    String note = '',
  }) async {
    final newEntry = MoodModel(
      id: 'mood-${DateTime.now().millisecondsSinceEpoch}',
      score: score,
      moodState: moodState,
      emotions: emotions,
      note: note,
      createdAt: DateTime.now(),
    );

    try {
      await _apiClient.dio.post(
        '/mindcare/mood',
        data: {
          'score': score,
          'moodState': moodState,
          'emotions': emotions,
          'note': note,
        },
      );
    } catch (_) {}

    _saveLocalMood(newEntry);
    return newEntry;
  }

  Future<List<MoodModel>> getMoodEntries() async {
    try {
      final res = await _apiClient.dio.get('/mindcare/mood');
      final list = (res.data as List)
          .map((m) => MoodModel.fromMap(Map<String, dynamic>.from(m)))
          .toList();
      return list;
    } catch (_) {
      return _getLocalMoods();
    }
  }

  void _saveLocalMood(MoodModel entry) {
    final list = _getLocalMoods();
    list.insert(0, entry);
    final encoded = json.encode(list.map((m) => m.toMap()).toList());
    _prefs.setString(_moodHistoryKey, encoded);
  }

  List<MoodModel> _getLocalMoods() {
    final raw = _prefs.getString(_moodHistoryKey);
    if (raw == null) {
      return [
        MoodModel(
          id: 'demo-mood-1',
          score: 4,
          moodState: 'good',
          emotions: ['Спокойствие', 'Продуктивность'],
          note: 'Успешно завершил подготовку к уроку',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        MoodModel(
          id: 'demo-mood-2',
          score: 5,
          moodState: 'excellent',
          emotions: ['Радость', 'Вдохновение'],
          note: 'Отличный учебный день!',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        MoodModel(
          id: 'demo-mood-3',
          score: 3,
          moodState: 'neutral',
          emotions: ['Усталость'],
          note: 'Много задач, нужен отдых',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];
    }
    try {
      final decoded = json.decode(raw) as List;
      return decoded
          .map((m) => MoodModel.fromMap(Map<String, dynamic>.from(m)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clearAllData() async {
    try {
      await _apiClient.dio.delete('/mindcare/data');
    } catch (_) {}
    await _prefs.remove(_chatHistoryKey);
    await _prefs.remove(_moodHistoryKey);
  }
}
