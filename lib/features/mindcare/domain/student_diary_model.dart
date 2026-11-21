import 'dart:convert';

class StudentDiaryEntryModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final int moodScore; // 1 to 5
  final DateTime createdAt;

  const StudentDiaryEntryModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.moodScore,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'moodScore': moodScore,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StudentDiaryEntryModel.fromMap(Map<String, dynamic> map) {
    return StudentDiaryEntryModel(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Запись в дневнике',
      content: map['content'] ?? '',
      category: map['category'] ?? 'Мысли',
      moodScore: map['moodScore'] ?? 4,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory StudentDiaryEntryModel.fromJson(String source) =>
      StudentDiaryEntryModel.fromMap(json.decode(source));
}
