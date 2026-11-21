import 'dart:convert';

class AnonymousMessageModel {
  final String id;
  final String studentAlias;
  final String category;
  final String content;
  final DateTime timestamp;
  final String? teacherReply;
  final String? teacherName;
  final DateTime? repliedAt;

  const AnonymousMessageModel({
    required this.id,
    required this.studentAlias,
    required this.category,
    required this.content,
    required this.timestamp,
    this.teacherReply,
    this.teacherName,
    this.repliedAt,
  });

  bool get isReplied => teacherReply != null && teacherReply!.isNotEmpty;

  AnonymousMessageModel copyWith({
    String? id,
    String? studentAlias,
    String? category,
    String? content,
    DateTime? timestamp,
    String? teacherReply,
    String? teacherName,
    DateTime? repliedAt,
  }) {
    return AnonymousMessageModel(
      id: id ?? this.id,
      studentAlias: studentAlias ?? this.studentAlias,
      category: category ?? this.category,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      teacherReply: teacherReply ?? this.teacherReply,
      teacherName: teacherName ?? this.teacherName,
      repliedAt: repliedAt ?? this.repliedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentAlias': studentAlias,
      'category': category,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'teacherReply': teacherReply,
      'teacherName': teacherName,
      'repliedAt': repliedAt?.toIso8601String(),
    };
  }

  factory AnonymousMessageModel.fromMap(Map<String, dynamic> map) {
    return AnonymousMessageModel(
      id: map['id'] ?? '',
      studentAlias: map['studentAlias'] ?? 'Анонимный ученик',
      category: map['category'] ?? 'Общий вопрос',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      teacherReply: map['teacherReply'],
      teacherName: map['teacherName'],
      repliedAt: map['repliedAt'] != null
          ? DateTime.parse(map['repliedAt'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AnonymousMessageModel.fromJson(String source) =>
      AnonymousMessageModel.fromMap(json.decode(source));
}
