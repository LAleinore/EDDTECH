import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/anonymous_message_model.dart';

final anonymousChatProvider =
    StateNotifierProvider<AnonymousChatNotifier, List<AnonymousMessageModel>>((
      ref,
    ) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return AnonymousChatNotifier(prefs);
    });

class AnonymousChatNotifier extends StateNotifier<List<AnonymousMessageModel>> {
  final SharedPreferences _prefs;
  static const String _storageKey = 'anonymous_teacher_messages_v2';

  AnonymousChatNotifier(this._prefs) : super(_loadInitial(_prefs));

  static List<AnonymousMessageModel> _loadInitial(SharedPreferences prefs) {
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw) as List;
        return decoded
            .map((e) => AnonymousMessageModel.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      } catch (_) {}
    }
    return _demoMessages;
  }

  static final List<AnonymousMessageModel> _demoMessages = [
    AnonymousMessageModel(
      id: 'anon-001',
      studentAlias: 'Ученик #214',
      category: 'Сложность с темой',
      content:
          'Здравствуйте! Мне очень трудно даются логарифмы и тригонометрия в 10 классе. На уроке стесняюсь спросить перед всеми. Можно ли разобрать типичные ошибки в заданиях БЖБ?',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      teacherReply:
          'Здравствуй! Не переживай, тригонометрия часто вызывает вопросы в начале. Я подготовила пошаговую памятку с формулами приведения и обязательно выделю 15 минут консультации после уроков. Держись, всё получится!',
      teacherName: 'Айгүл Серікқызы (Учитель математики)',
      repliedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    AnonymousMessageModel(
      id: 'anon-002',
      studentAlias: 'Ученик #589',
      category: 'Перегрузка заданиями',
      content:
          'У нас на этой неделе совпали 3 больших СОР-а подряд: по физике, химии и геометрии. Мы физически не успеваем всё выучить качественнно, очень высокий уровень стресса.',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      teacherReply: null,
    ),
  ];

  Future<void> _persist() async {
    final encoded = json.encode(state.map((m) => m.toMap()).toList());
    await _prefs.setString(_storageKey, encoded);
  }

  Future<void> reload() async {
    try {
      await _prefs.reload();
      state = _loadInitial(_prefs);
    } catch (_) {}
  }

  Future<void> sendStudentMessage({
    required String category,
    required String content,
    String? customAlias,
  }) async {
    final newMsg = AnonymousMessageModel(
      id: 'anon-${DateTime.now().millisecondsSinceEpoch}',
      studentAlias: customAlias ??
          'Ученик #${(DateTime.now().millisecondsSinceEpoch % 900 + 100)}',
      category: category,
      content: content.trim(),
      timestamp: DateTime.now(),
    );

    state = [newMsg, ...state];
    await _persist();
  }

  Future<void> replyTeacherMessage({
    required String messageId,
    required String reply,
    required String teacherName,
  }) async {
    state = [
      for (final m in state)
        if (m.id == messageId)
          m.copyWith(
            teacherReply: reply.trim(),
            teacherName: teacherName,
            repliedAt: DateTime.now(),
          )
        else
          m,
    ];
    await _persist();
  }
}
