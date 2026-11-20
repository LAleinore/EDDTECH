import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/lesson_model.dart';
import '../domain/quiz_model.dart';
import '../domain/material_model.dart';

final teacherRepositoryProvider = Provider<TeacherRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return TeacherRepository(apiClient: apiClient, prefs: prefs);
});

class TeacherRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  TeacherRepository({
    required ApiClient apiClient,
    required SharedPreferences prefs,
  }) : _apiClient = apiClient,
       _prefs = prefs;

  static const String _localHistoryKey = 'local_teacher_history_v1';

  Future<LessonPlanModel> generateLesson({
    required String subject,
    required String grade,
    required String topic,
    int durationMinutes = 45,
    String difficulty = 'medium',
    String language = 'ru',
    String? learningObjectives,
  }) async {
    try {
      final res = await _apiClient.dio.post(
        '/teacher/lesson',
        data: {
          'subject': subject,
          'grade': grade,
          'topic': topic,
          'duration_minutes': durationMinutes,
          'difficulty': difficulty,
          'language': language,
          'learning_objectives': learningObjectives,
        },
      );

      final model = LessonPlanModel.fromMap(res.data);
      _saveLocalMaterial(
        MaterialItemModel(
          id: model.id ?? 'lesson-${DateTime.now().millisecondsSinceEpoch}',
          title: model.title,
          materialType: 'lesson_plan',
          subject: model.subject,
          grade: model.grade,
          topic: model.topic,
          language: model.language,
          createdAt: model.createdAt,
          content: model.toMap()['content'],
        ),
      );
      return model;
    } catch (_) {
      // Offline / Demo Mode Fallback
      final fallbackPlan = LessonPlanModel(
        id: 'lesson-demo-${DateTime.now().millisecondsSinceEpoch}',
        title: language == 'kk'
            ? "Сабақ жоспары: $topic"
            : "Поурочный план: $topic",
        subject: subject,
        grade: grade,
        topic: topic,
        durationMinutes: durationMinutes,
        difficulty: difficulty,
        language: language,
        objectives: [
          language == 'kk'
              ? "'$topic' тақырыбы бойынша негізгі ұғымдарды меңгеру"
              : "Изучить ключевые понятия по теме '$topic'",
          language == 'kk'
              ? "Практикалық есептер шығару дағдысын қалыптастыру"
              : "Сформировать навык решения практических задач по теме",
          language == 'kk'
              ? "Сыни ойлау мен талдауды дамыту"
              : "Развить критическое мышление и аналитические навыки",
        ],
        overview:
            "Структурированный урок ($durationMinutes мин) для $grade класса по предмету $subject.",
        introduction:
            "1. Организационный момент (3 мин)\n2. Мотивация и разминка (5 мин)\n3. Совместная постановка цели урока (2 мин)",
        mainBody: [
          "Теоретический блок: разбор определений и формул темы '$topic' (12 мин)",
          "Демонстрация примера решения задачи учителем (8 мин)",
          "Вопросы и интерактивное закрепление понятий (5 мин)",
        ],
        practicalTasks: [
          "Задание 1 (базовый уровень): решение упражнений в парах (7 мин)",
          "Задание 2 (продвинутый уровень): анализ нестандартного кейса (8 мин)",
        ],
        conclusion: "Рефлексия учебной деятельности, подведение итогов (5 мин)",
        homework:
            "Параграф в учебнике, решить задачи №1-3, составить вопрос для класса.",
        createdAt: DateTime.now(),
      );

      _saveLocalMaterial(
        MaterialItemModel(
          id: fallbackPlan.id!,
          title: fallbackPlan.title,
          materialType: 'lesson_plan',
          subject: subject,
          grade: grade,
          topic: topic,
          language: language,
          createdAt: fallbackPlan.createdAt,
          content: fallbackPlan.toMap()['content'],
        ),
      );
      return fallbackPlan;
    }
  }

  Future<QuizModel> generateQuiz({
    required String subject,
    required String topic,
    required String grade,
    int count = 5,
    String difficulty = 'medium',
    String questionType = 'single_choice',
    String language = 'ru',
  }) async {
    try {
      final res = await _apiClient.dio.post(
        '/teacher/quiz',
        data: {
          'subject': subject,
          'topic': topic,
          'grade': grade,
          'questions_count': count,
          'difficulty': difficulty,
          'question_type': questionType,
          'language': language,
        },
      );

      final model = QuizModel.fromMap(res.data);
      _saveLocalMaterial(
        MaterialItemModel(
          id: model.id ?? 'quiz-${DateTime.now().millisecondsSinceEpoch}',
          title: model.title,
          materialType: 'quiz',
          subject: model.subject,
          grade: model.grade,
          topic: model.topic,
          language: model.language,
          createdAt: model.createdAt,
          content: model.toMap()['content'],
        ),
      );
      return model;
    } catch (_) {
      // Offline / Demo Mode Fallback
      final questions = List.generate(count, (index) {
        final qNum = index + 1;
        return QuizQuestionModel(
          id: 'q-$qNum',
          text: language == 'kk'
              ? "$qNum-сұрақ: '$topic' бойынша негізгі қасиет қандай?"
              : "Вопрос $qNum: Какое утверждение верно для темы '$topic'?",
          type: 'single_choice',
          options: [
            QuizOptionModel(
              id: 'a',
              text: language == 'kk'
                  ? "А) Негізгі дұрыс анықтама ($topic)"
                  : "А) Фундаментальный закон темы ($topic)",
            ),
            QuizOptionModel(
              id: 'b',
              text: language == 'kk'
                  ? "В) Жанама параметр"
                  : "Б) Вторичный признак",
            ),
            QuizOptionModel(
              id: 'c',
              text: language == 'kk'
                  ? "С) Қате тұжырым"
                  : "В) Ошибочное утверждение",
            ),
            QuizOptionModel(
              id: 'd',
              text: language == 'kk'
                  ? "D) Шектелген мысал"
                  : "Г) Частный исключительный случай",
            ),
          ],
          correctOptionIds: ['a'],
          explanation:
              "Правильный ответ — вариант А, так как он выражает базовый принцип темы.",
        );
      });

      final fallbackQuiz = QuizModel(
        id: 'quiz-demo-${DateTime.now().millisecondsSinceEpoch}',
        title: language == 'kk'
            ? "Тест: $topic ($grade сынып)"
            : "Тест: $topic ($grade класс)",
        subject: subject,
        grade: grade,
        topic: topic,
        language: language,
        questions: questions,
        createdAt: DateTime.now(),
      );

      _saveLocalMaterial(
        MaterialItemModel(
          id: fallbackQuiz.id!,
          title: fallbackQuiz.title,
          materialType: 'quiz',
          subject: subject,
          grade: grade,
          topic: topic,
          language: language,
          createdAt: fallbackQuiz.createdAt,
          content: fallbackQuiz.toMap()['content'],
        ),
      );
      return fallbackQuiz;
    }
  }

  Future<Map<String, dynamic>> explainConcept({
    required String subject,
    required String topic,
    required String grade,
    String language = 'ru',
  }) async {
    try {
      final res = await _apiClient.dio.post(
        '/teacher/explain',
        data: {
          'subject': subject,
          'topic': topic,
          'grade': grade,
          'language': language,
        },
      );
      return Map<String, dynamic>.from(res.data);
    } catch (_) {
      return {
        'title': 'Объяснение темы: $topic',
        'simpleExplanation':
            'Понятное и наглядное объяснение темы $topic простыми словами с жизненными аналогиями.',
        'stepByStepGuide': [
          'Шаг 1: Рассмотрите базовую причину явления',
          'Шаг 2: Изучите цепочку взаимодействий',
          'Шаг 3: Посмотрите на практический результат',
        ],
        'practicalExamples': [
          'Пример из жизни: аналогия с движением транспорта или природным явлением.',
        ],
      };
    }
  }

  Future<List<MaterialItemModel>> getHistory() async {
    try {
      final res = await _apiClient.dio.get('/teacher/history');
      final list = (res.data as List)
          .map((m) => MaterialItemModel.fromMap(Map<String, dynamic>.from(m)))
          .toList();
      return list;
    } catch (_) {
      return _getLocalMaterials();
    }
  }

  Future<void> deleteMaterial(String id) async {
    try {
      await _apiClient.dio.delete('/teacher/materials/$id');
    } catch (_) {}
    final items = _getLocalMaterials();
    items.removeWhere((item) => item.id == id);
    final encoded = json.encode(items.map((i) => i.toMap()).toList());
    await _prefs.setString(_localHistoryKey, encoded);
  }

  void _saveLocalMaterial(MaterialItemModel item) {
    final items = _getLocalMaterials();
    items.insert(0, item);
    final encoded = json.encode(items.map((i) => i.toMap()).toList());
    _prefs.setString(_localHistoryKey, encoded);
  }

  List<MaterialItemModel> _getLocalMaterials() {
    final raw = _prefs.getString(_localHistoryKey);
    if (raw == null) return [];
    try {
      final decoded = json.decode(raw) as List;
      return decoded
          .map((m) => MaterialItemModel.fromMap(Map<String, dynamic>.from(m)))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
