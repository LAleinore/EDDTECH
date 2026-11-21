import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/ai_service.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/lesson_model.dart';
import '../domain/quiz_model.dart';
import '../domain/material_model.dart';

final teacherRepositoryProvider = Provider<TeacherRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final aiService = ref.watch(aiServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return TeacherRepository(
    apiClient: apiClient,
    aiService: aiService,
    prefs: prefs,
  );
});

class TeacherRepository {
  final ApiClient _apiClient;
  final AiService _aiService;
  final SharedPreferences _prefs;

  TeacherRepository({
    required ApiClient apiClient,
    required AiService aiService,
    required SharedPreferences prefs,
  })  : _apiClient = apiClient,
        _aiService = aiService,
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
    // 1. Try Live AI Generation
    try {
      final prompt =
          'Составь поурочный план (ҚМЖ) урока.\n'
          'Предмет: $subject\nКласс: $grade\nТема: $topic\nДлительность: $durationMinutes минут\n'
          'Сложность: $difficulty\nЯзык: ${language == 'kk' ? 'казахский' : 'русский'}\n'
          '${learningObjectives != null && learningObjectives.isNotEmpty ? "Цели обучения: $learningObjectives\n" : ""}'
          'Ответь ТОЛЬКО валидным JSON со следующей структурой без пояснительного текста:\n'
          '{\n'
          '  "title": "string",\n'
          '  "objectives": ["string", "string", "string"],\n'
          '  "overview": "string",\n'
          '  "introduction": "string",\n'
          '  "mainBody": ["string", "string", "string"],\n'
          '  "practicalTasks": ["string", "string"],\n'
          '  "conclusion": "string",\n'
          '  "homework": "string"\n'
          '}';

      final aiText = await _aiService.completePrompt(
        prompt,
        systemPrompt:
            'Ты методический эксперт Daryn Ustaz по составлению поурочных планов для учителей Казахстана. Отвечай строго валидным JSON.',
        temperature: 0.5,
      );

      final dynamic parsed = AiService.parseJsonSafely(aiText);
      if (parsed is Map<String, dynamic>) {
        final plan = LessonPlanModel(
          id: 'lesson-${DateTime.now().millisecondsSinceEpoch}',
          title: parsed['title']?.toString() ?? 'Поурочный план: $topic',
          subject: subject,
          grade: grade,
          topic: topic,
          durationMinutes: durationMinutes,
          difficulty: difficulty,
          language: language,
          objectives: (parsed['objectives'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              ['Изучить тему $topic'],
          overview: parsed['overview']?.toString() ??
              'Урок по теме $topic ($grade класс)',
          introduction: parsed['introduction']?.toString() ??
              'Организационный момент и мотивация',
          mainBody: (parsed['mainBody'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              ['Объяснение материала'],
          practicalTasks: (parsed['practicalTasks'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              ['Практическое задание'],
          conclusion: parsed['conclusion']?.toString() ?? 'Подведение итогов',
          homework: parsed['homework']?.toString() ?? 'Домашнее задание',
          createdAt: DateTime.now(),
        );

        _saveLocalMaterial(
          MaterialItemModel(
            id: plan.id!,
            title: plan.title,
            materialType: 'lesson_plan',
            subject: subject,
            grade: grade,
            topic: topic,
            language: language,
            createdAt: plan.createdAt,
            content: plan.toMap()['content'],
          ),
        );
        return plan;
      }
    } catch (_) {}

    // 2. Try Backend API if available
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
      // 3. Fallback Plan
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
    // 1. Try Live AI Generation
    try {
      final prompt =
          'Составь тест из $count вопросов с 4 вариантами ответов (1 правильный).\n'
          'Предмет: $subject\nТема: $topic\nКласс: $grade\nСложность: $difficulty\n'
          'Язык: ${language == 'kk' ? 'казахский' : 'русский'}\n'
          'Ответь ТОЛЬКО валидным JSON массивом вопросов без разметки markdown:\n'
          '[\n'
          '  {\n'
          '    "text": "Текст вопроса",\n'
          '    "options": [\n'
          '      {"id": "a", "text": "Вариант А"},\n'
          '      {"id": "b", "text": "Вариант Б"},\n'
          '      {"id": "c", "text": "Вариант В"},\n'
          '      {"id": "d", "text": "Вариант Г"}\n'
          '    ],\n'
          '    "correctOptionIds": ["a"],\n'
          '    "explanation": "Объяснение правильного ответа"\n'
          '  }\n'
          ']';

      final aiText = await _aiService.completePrompt(
        prompt,
        systemPrompt:
            'Ты составитель тестов БЖБ/ТЖБ и суммативных заданий для школ Казахстана. Отвечай исключительно валидным JSON списком.',
        temperature: 0.6,
      );

      final dynamic parsed = AiService.parseJsonSafely(aiText);
      if (parsed is List) {
        final questions = <QuizQuestionModel>[];
        for (var i = 0; i < parsed.length; i++) {
          final q = parsed[i];
          if (q is Map<String, dynamic>) {
            final opts = (q['options'] as List?)
                    ?.map((o) => QuizOptionModel(
                          id: o['id']?.toString() ?? 'a',
                          text: o['text']?.toString() ?? '',
                        ))
                    .toList() ??
                [];
            questions.add(
              QuizQuestionModel(
                id: 'q-${i + 1}',
                text: q['text']?.toString() ?? 'Вопрос ${i + 1}',
                type: 'single_choice',
                options: opts,
                correctOptionIds: (q['correctOptionIds'] as List?)
                        ?.map((c) => c.toString())
                        .toList() ??
                    ['a'],
                explanation: q['explanation']?.toString() ?? '',
              ),
            );
          }
        }

        if (questions.isNotEmpty) {
          final liveQuiz = QuizModel(
            id: 'quiz-${DateTime.now().millisecondsSinceEpoch}',
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
              id: liveQuiz.id!,
              title: liveQuiz.title,
              materialType: 'quiz',
              subject: subject,
              grade: grade,
              topic: topic,
              language: language,
              createdAt: liveQuiz.createdAt,
              content: liveQuiz.toMap()['content'],
            ),
          );
          return liveQuiz;
        }
      }
    } catch (_) {}

    // 2. Try Backend API
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
      // 3. Fallback Quiz
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
      final prompt =
          'Объясни педагогическую концепцию темы "$topic" для $grade класса по предмету $subject.\n'
          'Дай краткий пошаговый разбор и пример из жизни.';
      final reply = await _aiService.completePrompt(
        prompt,
        systemPrompt: 'Ты опытный учитель-методист Daryn Ustaz.',
      );
      return {
        'title': 'Объяснение темы: $topic',
        'simpleExplanation': reply,
        'stepByStepGuide': [
          'Шаг 1: Актуализация опорных знаний',
          'Шаг 2: Введение ключевой идеи с визуализацией',
          'Шаг 3: Практическое закрепление в парах',
        ],
        'practicalExamples': [
          'Практический пример по теме $topic для учащихся $grade класса.',
        ],
      };
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
