import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/student_diary_model.dart';

final studentDiaryProvider =
    StateNotifierProvider<StudentDiaryNotifier, List<StudentDiaryEntryModel>>((
      ref,
    ) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return StudentDiaryNotifier(prefs);
    });

class StudentDiaryNotifier extends StateNotifier<List<StudentDiaryEntryModel>> {
  final SharedPreferences _prefs;
  static const String _storageKey = 'student_personal_diary_v2';

  StudentDiaryNotifier(this._prefs) : super(_loadInitial(_prefs));

  static List<StudentDiaryEntryModel> _loadInitial(SharedPreferences prefs) {
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw) as List;
        return decoded
            .map((e) => StudentDiaryEntryModel.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      } catch (_) {}
    }
    return _defaultEntries;
  }

  static final List<StudentDiaryEntryModel> _defaultEntries = [
    StudentDiaryEntryModel(
      id: 'diary-001',
      title: 'Сложный день перед контрольной по физике',
      content:
          'Сегодня целый день переживал из-за формул динамики Ньютона. Кажется, что не успеваю всё запомнить. Но вечером сел, разложил задачи по шагам и стало немного спокойнее.',
      category: 'Учеба',
      moodScore: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    StudentDiaryEntryModel(
      id: 'diary-002',
      title: 'Удалось решить проект на Python!',
      content:
          'Наконец-то разобрался с вложенными списками и словарями. Написал рабочий скрипт для расчета баллов. Очень горжусь собой!',
      category: 'Победа дня',
      moodScore: 5,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  Future<void> _persist() async {
    final encoded = json.encode(state.map((e) => e.toMap()).toList());
    await _prefs.setString(_storageKey, encoded);
  }

  Future<void> reload() async {
    try {
      await _prefs.reload();
      state = _loadInitial(_prefs);
    } catch (_) {}
  }

  Future<void> addEntry({
    required String title,
    required String content,
    required String category,
    required int moodScore,
  }) async {
    final newEntry = StudentDiaryEntryModel(
      id: 'entry-${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim().isEmpty ? 'Мысли дня' : title.trim(),
      content: content.trim(),
      category: category,
      moodScore: moodScore,
      createdAt: DateTime.now(),
    );

    state = [newEntry, ...state];
    await _persist();
  }

  Future<void> deleteEntry(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _persist();
  }
}
