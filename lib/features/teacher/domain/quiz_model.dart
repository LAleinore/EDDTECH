class QuizOptionModel {
  final String id;
  final String text;

  QuizOptionModel({required this.id, required this.text});

  factory QuizOptionModel.fromMap(Map<String, dynamic> map) {
    return QuizOptionModel(id: map['id'] ?? '', text: map['text'] ?? '');
  }

  Map<String, dynamic> toMap() => {'id': id, 'text': text};
}

class QuizQuestionModel {
  final String id;
  final String text;
  final String type; // single_choice, multiple_choice, open_question
  final List<QuizOptionModel> options;
  final List<String> correctOptionIds;
  final String? sampleAnswer;
  final String explanation;

  QuizQuestionModel({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
    required this.correctOptionIds,
    this.sampleAnswer,
    required this.explanation,
  });

  factory QuizQuestionModel.fromMap(Map<String, dynamic> map) {
    return QuizQuestionModel(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      type: map['type'] ?? 'single_choice',
      options: (map['options'] as List? ?? [])
          .map((o) => QuizOptionModel.fromMap(Map<String, dynamic>.from(o)))
          .toList(),
      correctOptionIds: List<String>.from(map['correct_option_ids'] ?? []),
      sampleAnswer: map['sample_answer'],
      explanation: map['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'text': text,
    'type': type,
    'options': options.map((o) => o.toMap()).toList(),
    'correct_option_ids': correctOptionIds,
    'sample_answer': sampleAnswer,
    'explanation': explanation,
  };
}

class QuizModel {
  final String? id;
  final String title;
  final String subject;
  final String grade;
  final String topic;
  final String language;
  final List<QuizQuestionModel> questions;
  final DateTime createdAt;

  QuizModel({
    this.id,
    required this.title,
    required this.subject,
    required this.grade,
    required this.topic,
    required this.language,
    required this.questions,
    required this.createdAt,
  });

  factory QuizModel.fromMap(Map<String, dynamic> map) {
    final content = map['content'] as Map<String, dynamic>? ?? {};
    final qList = (content['questions'] as List? ?? [])
        .map((q) => QuizQuestionModel.fromMap(Map<String, dynamic>.from(q)))
        .toList();

    return QuizModel(
      id: map['id'],
      title: content['title'] ?? map['title'] ?? 'Интерактивный тест',
      subject: map['subject'] ?? '',
      grade: map['grade'] ?? '',
      topic: map['topic'] ?? '',
      language: map['language'] ?? 'ru',
      questions: qList,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'subject': subject,
    'grade': grade,
    'topic': topic,
    'language': language,
    'content': {
      'title': title,
      'questions': questions.map((q) => q.toMap()).toList(),
    },
    'createdAt': createdAt.toIso8601String(),
  };
}
