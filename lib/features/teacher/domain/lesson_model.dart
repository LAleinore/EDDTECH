class LessonPlanModel {
  final String? id;
  final String title;
  final String subject;
  final String grade;
  final String topic;
  final int durationMinutes;
  final String difficulty;
  final String language;
  final List<String> objectives;
  final String overview;
  final String introduction;
  final List<String> mainBody;
  final List<String> practicalTasks;
  final String conclusion;
  final String homework;
  final DateTime createdAt;

  LessonPlanModel({
    this.id,
    required this.title,
    required this.subject,
    required this.grade,
    required this.topic,
    required this.durationMinutes,
    required this.difficulty,
    required this.language,
    required this.objectives,
    required this.overview,
    required this.introduction,
    required this.mainBody,
    required this.practicalTasks,
    required this.conclusion,
    required this.homework,
    required this.createdAt,
  });

  factory LessonPlanModel.fromMap(Map<String, dynamic> map) {
    final content = map['content'] as Map<String, dynamic>? ?? {};
    return LessonPlanModel(
      id: map['id'],
      title: content['title'] ?? map['title'] ?? 'Поурочный план',
      subject: map['subject'] ?? '',
      grade: map['grade'] ?? '',
      topic: map['topic'] ?? '',
      durationMinutes: map['duration_minutes'] ?? 45,
      difficulty: map['difficulty'] ?? 'medium',
      language: map['language'] ?? 'ru',
      objectives: List<String>.from(content['objectives'] ?? []),
      overview: content['overview'] ?? '',
      introduction: content['introduction'] ?? '',
      mainBody: List<String>.from(content['main_body'] ?? []),
      practicalTasks: List<String>.from(content['practical_tasks'] ?? []),
      conclusion: content['conclusion'] ?? '',
      homework: content['homework'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'grade': grade,
      'topic': topic,
      'duration_minutes': durationMinutes,
      'difficulty': difficulty,
      'language': language,
      'content': {
        'title': title,
        'objectives': objectives,
        'overview': overview,
        'introduction': introduction,
        'main_body': mainBody,
        'practical_tasks': practicalTasks,
        'conclusion': conclusion,
        'homework': homework,
      },
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
