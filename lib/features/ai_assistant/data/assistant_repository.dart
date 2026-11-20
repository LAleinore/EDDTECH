import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/user_model.dart';
import '../../mindcare/data/mindcare_repository.dart';
import '../../mindcare/domain/chat_message_model.dart';

final assistantRepositoryProvider = Provider<AssistantRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AssistantRepository(apiClient: apiClient);
});

class AssistantRepository {
  final ApiClient _apiClient;

  AssistantRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ChatMessageModel> sendMessage({
    required String message,
    required List<ChatMessageModel> history,
    required UserRole role,
    String language = 'ru',
  }) async {
    // Client-side instant deterministic crisis guardrail
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
      return _buildLocalFallback(
        message: message,
        role: role,
        language: language,
      );
    }
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
          '1. Сначала выделим главную мысль.\n'
          '2. Разделим объяснение на 3 коротких шага.\n'
          '3. Подберём понятный пример из повседневной жизни.\n\n'
          'Нажми на иконку динамика, чтобы прослушать ответ вслух.';
      suggestedRoute = '/inclusive/simplifier';
    } else {
      if (lower.contains('днк') || lower.contains('рнк')) {
        reply =
            'Главные отличия ДНК и РНК:\n'
            '• ДНК — двойная спираль, РНК — одна цепочка.\n'
            '• Сахар: дезоксирибоза (ДНК) vs рибоза (РНК).\n'
            '• Основания: тимин в ДНК заменён на урацил в РНК.\n'
            '• Функция: ДНК хранит генетический код, РНК участвует в синтезе белка.';
      } else {
        reply =
            'Структурированный план по запросу «$message»:\n'
            '1. Изучите базовые определения и ключевую идею.\n'
            '2. Разберите 2–3 практических примера.\n'
            '3. Закрепите материал методом активного повторения (пересказ своими словами).';
      }
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
