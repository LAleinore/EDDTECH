class MaterialItemModel {
  final String id;
  final String title;
  final String materialType; // lesson_plan, quiz, concept_explanation
  final String subject;
  final String grade;
  final String topic;
  final String language;
  final DateTime createdAt;
  final Map<String, dynamic> content;

  MaterialItemModel({
    required this.id,
    required this.title,
    required this.materialType,
    required this.subject,
    required this.grade,
    required this.topic,
    required this.language,
    required this.createdAt,
    required this.content,
  });

  factory MaterialItemModel.fromMap(Map<String, dynamic> map) {
    return MaterialItemModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      materialType:
          map['materialType'] ?? map['material_type'] ?? 'lesson_plan',
      subject: map['subject'] ?? '',
      grade: map['grade'] ?? '',
      topic: map['topic'] ?? '',
      language: map['language'] ?? 'ru',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : (map['created_at'] != null
                ? DateTime.parse(map['created_at'])
                : DateTime.now()),
      content: Map<String, dynamic>.from(map['content'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'materialType': materialType,
    'subject': subject,
    'grade': grade,
    'topic': topic,
    'language': language,
    'createdAt': createdAt.toIso8601String(),
    'content': content,
  };
}
