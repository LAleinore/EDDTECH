import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/ai_service.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/inclusive_material_model.dart';

final inclusiveRepositoryProvider = Provider<InclusiveRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final aiService = ref.watch(aiServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return InclusiveRepository(
    apiClient: apiClient,
    aiService: aiService,
    prefs: prefs,
  );
});

class InclusiveRepository {
  final ApiClient _apiClient;
  final AiService _aiService;
  final SharedPreferences _prefs;

  InclusiveRepository({
    required ApiClient apiClient,
    required AiService aiService,
    required SharedPreferences prefs,
  })  : _apiClient = apiClient,
        _aiService = aiService,
        _prefs = prefs;

  static const String _materialsKey = 'inclusive_saved_materials_v1';

  Future<SimplifiedResultModel> simplifyText({
    required String text,
    String targetGrade = 'elementary',
    String language = 'ru',
  }) async {
    // 1. Try Live AI simplification
    try {
      final prompt =
          'Адаптируй и упрости следующий текст для ученика ($targetGrade уровень).\n'
          'Текст: "$text"\nЯзык: ${language == 'kk' ? 'казахский' : 'русский'}\n'
          'Ответь строго валидным JSON со следующей структурой без markdown:\n'
          '{\n'
          '  "title": "Заголовок адаптированного текста",\n'
          '  "simpleExplanation": "Объяснение максимально простыми словами",\n'
          '  "summary": "Главная суть в 1-2 предложениях",\n'
          '  "stepByStepGuide": ["Шаг 1", "Шаг 2", "Шаг 3"],\n'
          '  "keyConcepts": [\n'
          '    {"term": "Термин 1", "definition": "Простое определение"},\n'
          '    {"term": "Термин 2", "definition": "Простое определение"}\n'
          '  ],\n'
          '  "practicalExamples": ["Жизненный понятный пример"]\n'
          '}';

      final aiText = await _aiService.completePrompt(
        prompt,
        systemPrompt:
            'Ты добрый и понятный педагог Inclusive AI. Твоя задача — сделать любой научный или учебный текст кристально ясным и доступным для каждого ребенка.',
        temperature: 0.5,
      );

      final dynamic parsed = AiService.parseJsonSafely(aiText);
      if (parsed is Map<String, dynamic>) {
        final concepts = (parsed['keyConcepts'] as List?)
                ?.map((c) => KeyConceptModel(
                      term: c['term']?.toString() ?? '',
                      definition: c['definition']?.toString() ?? '',
                    ))
                .toList() ??
            [];

        final result = SimplifiedResultModel(
          title: parsed['title']?.toString() ?? 'Адаптированный материал',
          simpleExplanation: parsed['simpleExplanation']?.toString() ?? '',
          summary: parsed['summary']?.toString() ?? '',
          stepByStepGuide: (parsed['stepByStepGuide'] as List?)
                  ?.map((s) => s.toString())
                  .toList() ??
              [],
          keyConcepts: concepts,
          practicalExamples: (parsed['practicalExamples'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
        );

        _saveLocalMaterial(text, result);
        return result;
      }
    } catch (_) {}

    // 2. Try Backend API
    try {
      final res = await _apiClient.dio.post(
        '/inclusive/simplify',
        data: {'text': text, 'target_grade': targetGrade, 'language': language},
      );

      final map = res.data['simplified'] as Map<String, dynamic>;
      final result = SimplifiedResultModel.fromMap(map);
      _saveLocalMaterial(text, result);
      return result;
    } catch (_) {
      // 3. Fallback
      final fallback = SimplifiedResultModel(
        title: language == 'kk'
            ? "Мәтінді қарапайым тілмен түсіндіру"
            : "Адаптированный понятный материал",
        simpleExplanation: language == 'kk'
            ? "Қарапайым сөзбен айтқанда: бұл тақырып күрделі құбылыстың өмірдегі нақты байланысын және оның қалай жұмыс істейтінін көрсетеді."
            : "Простыми словами: сложный материал объясняет логическую связь между явлениями и то, как этот принцип работает на практике.",
        summary: language == 'kk'
            ? "Басты түйін: күрделі терминдер күнделікті өмірдегі қарапайым мысалдармен ауыстырылды."
            : "Главная суть: сложные термины переведены на наглядные примеры без потери научного смысла.",
        stepByStepGuide: [
          "Шаг 1: Выделите ключевой объект изучения",
          "Шаг 2: Проследите последовательность действия правила",
          "Шаг 3: Проверьте результат на жизненном примере",
        ],
        keyConcepts: [
          KeyConceptModel(
            term: "Базовое понятие",
            definition: "Основной термин, определяющий суть явления",
          ),
          KeyConceptModel(
            term: "Практический эффект",
            definition: "То, как данное правило проявляется в реальном мире",
          ),
        ],
        practicalExamples: [
          "Наглядный пример: это работает как передача движения между шестеренками механических часов.",
        ],
      );

      _saveLocalMaterial(text, fallback);
      return fallback;
    }
  }

  Future<List<Map<String, dynamic>>> getSavedMaterials() async {
    try {
      final res = await _apiClient.dio.get('/inclusive/materials');
      return (res.data as List).map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return _getLocalMaterials();
    }
  }

  void _saveLocalMaterial(String originalText, SimplifiedResultModel result) {
    final list = _getLocalMaterials();
    list.insert(0, {
      'id': 'mat-${DateTime.now().millisecondsSinceEpoch}',
      'original': originalText,
      'title': result.title,
      'summary': result.summary,
      'simplified': result.toMap(),
      'created_at': DateTime.now().toIso8601String(),
    });
    _prefs.setString(_materialsKey, json.encode(list));
  }

  List<Map<String, dynamic>> _getLocalMaterials() {
    final raw = _prefs.getString(_materialsKey);
    if (raw == null) return [];
    try {
      final decoded = json.decode(raw) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }
}
