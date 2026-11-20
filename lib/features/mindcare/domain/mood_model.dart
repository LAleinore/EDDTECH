class MoodModel {
  final String id;
  final int score; // 1 to 5
  final String moodState; // terrible, bad, neutral, good, excellent
  final List<String> emotions;
  final String note;
  final DateTime createdAt;

  MoodModel({
    required this.id,
    required this.score,
    required this.moodState,
    required this.emotions,
    required this.note,
    required this.createdAt,
  });

  factory MoodModel.fromMap(Map<String, dynamic> map) {
    return MoodModel(
      id: map['id'] ?? '',
      score: map['score'] ?? 3,
      moodState: map['moodState'] ?? map['mood_state'] ?? 'neutral',
      emotions: List<String>.from(map['emotions'] ?? []),
      note: map['note'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : (map['created_at'] != null
                ? DateTime.parse(map['created_at'])
                : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'score': score,
    'moodState': moodState,
    'emotions': emotions,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
  };
}
