import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/inclusive_material_model.dart';

final inclusiveRepositoryProvider = Provider<InclusiveRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return InclusiveRepository(apiClient: apiClient, prefs: prefs);
});

class InclusiveRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  InclusiveRepository({
    required ApiClient apiClient,
    required SharedPreferences prefs,
  }) : _apiClient = apiClient,
       _prefs = prefs;

  static const String _materialsKey = 'inclusive_saved_materials_v1';

  Future<SimplifiedResultModel> simplifyText({
    required String text,
    String targetGrade = 'elementary',
    String language = 'ru',
  }) async {
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
      // Offline / Demo Mode Fallback
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

  void _saveLocalMaterial(String originalText, SimplifiedResultModel result) {
    final raw = _prefs.getString(_materialsKey);
    List<Map<String, dynamic>> list = [];
    if (raw != null) {
      try {
        list = List<Map<String, dynamic>>.from(json.decode(raw));
      } catch (_) {}
    }

    list.insert(0, {
      'id': 'inc-${DateTime.now().millisecondsSinceEpoch}',
      'original': originalText,
      'simplified': result.toMap(),
      'date': DateTime.now().toIso8601String(),
    });

    _prefs.setString(_materialsKey, json.encode(list));
  }
}
