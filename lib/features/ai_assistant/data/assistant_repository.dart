import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/ai_service.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/user_model.dart';
import '../../mindcare/data/mindcare_repository.dart';
import '../../mindcare/domain/chat_message_model.dart';

final assistantRepositoryProvider = Provider<AssistantRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final aiService = ref.watch(aiServiceProvider);
  return AssistantRepository(apiClient: apiClient, aiService: aiService);
});

class AssistantRepository {
  final ApiClient _apiClient;
  final AiService _aiService;

  AssistantRepository({
    required ApiClient apiClient,
    required AiService aiService,
  })  : _apiClient = apiClient,
        _aiService = aiService;

  Future<ChatMessageModel> sendMessage({
    required String message,
    required List<ChatMessageModel> history,
    required UserRole role,
    String language = 'ru',
  }) async {
    // 1. Client-side instant deterministic crisis guardrail
    if (MindcareRepository.checkCrisis(message)) {
      return ChatMessageModel(
        id: 'safety-${DateTime.now().millisecondsSinceEpoch}',
        role: 'assistant',
        content:
            'Я чувствую, насколько вам сейчас тяжело, и очень ценю, что вы поделились этим. Ваша жизнь и безопасность — самое главное.\n\nПожалуйста, прямо сейчас обратитесь к близкому человеку или позвоните по бесплатной круглосуточной линии помощи:\n\n📞 Единая служба экстренной помощи: 112\n📞 Национальная линия доверия: 150 (бесплатно, анонимно)',
        isCrisis: true,
        emergencyHelpline: '150 или 112',
        timestamp: DateTime.now(),
      );
    }

    // 2. First attempt live AI generation via AiService
    try {
      final systemPrompt = _buildSystemPrompt(role, language);
      final messages = _formatHistory(history, message);

      final reply = await _aiService.chat(
        messages: messages,
        systemPrompt: systemPrompt,
        temperature: 0.7,
      );

      final route = _detectSuggestedRoute(reply, role);

      return ChatMessageModel(
        id: 'assistant-${DateTime.now().millisecondsSinceEpoch}',
        role: 'assistant',
        content: reply,
        isCrisis: false,
        suggestedTechnique: route,
        timestamp: DateTime.now(),
      );
    } catch (_) {
      // 3. Fallback attempt: if backend API server is available, try it
      try {
        final res = await _apiClient.dio.post(
          '/assistant/chat',
          data: {
            'message': message,
            'history': history
                .map((h) => {'role': h.role, 'content': h.content})
                .toList(),
            'role': role.key,
            'language': language,
          },
        );

        return ChatMessageModel(
          id: 'assistant-${DateTime.now().millisecondsSinceEpoch}',
          role: 'assistant',
          content: res.data['reply'] ?? '',
          isCrisis: res.data['isCrisis'] ?? false,
          emergencyHelpline: res.data['emergencyHelpline'],
          suggestedTechnique: res.data['suggestedRoute'],
          timestamp: DateTime.now(),
        );
      } catch (_) {
        // 4. Offline fallback if device has no internet connection
        return _buildLocalFallback(
          message: message,
          role: role,
          language: language,
        );
      }
    }
  }

  String _buildSystemPrompt(UserRole role, String language) {
    if (role == UserRole.teacher) {
      return 'Ты — Daryn Ustaz AI, продвинутый методический ассистент и наставник для преподавателей Казахстана. '
          'Твоя задача: помогать учителям с поурочными планами (ҚМЖ), критериями оценивания и дескрипторами, '
          'заданиями БЖБ/ТЖБ, интерактивными педагогическими методиками, практическими заданиями и тестами. '
          'Отвечай профессионально, педагогически структурированно, понятно и по существу, адаптируя ответ под предмет и класс. '
          'Язык ответа: ${language == 'kk' ? 'казахский' : 'русский'} (или язык запроса учителя).';
    } else if (role == UserRole.learner) {
      return 'Ты — EduMind Inclusive AI, заботливый и понятный образовательный помощник для учащихся, в том числе с особыми потребностями. '
          'Твоя цель: объяснять любые сложные школьные или научные темы простыми словами, наглядными аналогиями из жизни, '
          'короткими шагами и без перегруженных терминов. Будь очень доброжелательным, поддерживающим и терпеливым. '
          'Язык ответа: ${language == 'kk' ? 'казахский' : 'русский'}.';
    } else {
      return 'Ты — EduMind AI, умный, гибкий и живой персональный AI-репетитор для школьников и студентов (Казахстан). '
          'Твоя задача: помогать разбираться в любых учебных предметах (математика, алгебра, геометрия, физика, химия, биология, информатика, Python/C++, история, литература, языки). '
          'ПРАВИЛА: '
          '1. НЕ используй заученные шаблонные фразы. Отвечай прямо на конкретный вопрос учащегося. '
          '2. Давай пошаговые решения, математические формулы, примеры кода с комментариями, когда это уместно. '
          '3. Пиши живо, доброжелательно, понятно и структурированно. '
          '4. Отвечай на языке запроса (русский или казахский).';
    }
  }

  List<Map<String, String>> _formatHistory(
    List<ChatMessageModel> history,
    String currentMessage,
  ) {
    final list = <Map<String, String>>[];
    // Take up to 10 recent messages for conversational context
    final recent = history.length > 10
        ? history.sublist(history.length - 10)
        : history;

    for (final m in recent) {
      if (m.role == 'user' || m.role == 'assistant') {
        if (!m.isCrisis && m.content.isNotEmpty) {
          list.add({'role': m.role, 'content': m.content});
        }
      }
    }

    if (list.isEmpty || list.last['content'] != currentMessage) {
      list.add({'role': 'user', 'content': currentMessage});
    }

    return list;
  }

  String? _detectSuggestedRoute(String reply, UserRole role) {
    final lower = reply.toLowerCase();
    if (role == UserRole.teacher) {
      if (lower.contains('тест') || lower.contains('бжб') || lower.contains('тжб')) {
        return '/teacher/quiz-generator';
      }
      if (lower.contains('қмж') || lower.contains('поурочн') || lower.contains('план урок')) {
        return '/teacher/lesson-generator';
      }
    } else if (role == UserRole.learner) {
      if (lower.contains('упрощ') || lower.contains('простыми словами')) {
        return '/inclusive/simplifier';
      }
    }
    return null;
  }

  ChatMessageModel _buildLocalFallback({
    required String message,
    required UserRole role,
    required String language,
  }) {
    final lower = message.toLowerCase();
    String reply;
    String? suggestedRoute;

    if (role == UserRole.teacher) {
      if (lower.contains('критери') || lower.contains('тест') || lower.contains('оценив')) {
        reply =
            'Для объективного оценивания проекта используйте 4 критерия (10 баллов):\n'
            '1. Глубина понимания темы (0–3 балла)\n'
            '2. Практическое применение (0–3 балла)\n'
            '3. Структура и презентация (0–2 балла)\n'
            '4. Выводы и самостоятельность (0–2 балла)\n\n'
            'Вы также можете создать автоматический тест в модуле «Конструктор тестов».';
        suggestedRoute = '/teacher/quiz-generator';
      } else {
        reply =
            'Педагогическая идея по запросу «$message»:\n'
            '• Разминка (5 мин): проблемный вопрос из жизни.\n'
            '• Практикум в парах (10 мин): мини-исследование с наглядными примерами.\n'
            '• Рефлексия (5 мин): 2 контрольных вопроса.\n\n'
            'Откройте «Генератор уроков» Daryn Ustaz, чтобы получить полный конспект занятия.';
        suggestedRoute = '/teacher/lesson-generator';
      }
    } else if (role == UserRole.learner) {
      reply =
          'Давай разберём «$message» простыми словами:\n'
          '1. Сначала выделим главную мысль темы.\n'
          '2. Разделим объяснение на 3 понятных шага.\n'
          '3. Закрепим на примере из повседневной жизни.\n\n'
          'Нажми на иконку динамика, чтобы прослушать ответ вслух.';
      suggestedRoute = '/inclusive/simplifier';
    } else {
      reply =
          'Ответ на запрос «$message»:\n\n'
          '1. Ключевая концепция: суть состоит в понимании основных принципов и взаимосвязей.\n'
          '2. Практический алгоритм: разбейте задачу на подшаги и проверьте граничные условия.\n'
          '3. Рекомендация: повторите материал через решение 2–3 аналогичных задач.';
    }

    return ChatMessageModel(
      id: 'assistant-local-${DateTime.now().millisecondsSinceEpoch}',
      role: 'assistant',
      content: reply,
      isCrisis: false,
      suggestedTechnique: suggestedRoute,
      timestamp: DateTime.now(),
    );
  }
}
