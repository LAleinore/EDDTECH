class ChatMessageModel {
  final String id;
  final String role; // user, assistant, system
  final String content;
  final bool isCrisis;
  final String? emergencyHelpline;
  final String? suggestedTechnique;
  final DateTime timestamp;

  ChatMessageModel({
    required this.id,
    required this.role,
    required this.content,
    this.isCrisis = false,
    this.emergencyHelpline,
    this.suggestedTechnique,
    required this.timestamp,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id'] ?? '',
      role: map['role'] ?? 'assistant',
      content: map['content'] ?? '',
      isCrisis: map['isCrisis'] ?? map['is_crisis'] ?? false,
      emergencyHelpline: map['emergencyHelpline'] ?? map['emergency_helpline'],
      suggestedTechnique:
          map['suggestedTechnique'] ?? map['suggested_technique'],
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'role': role,
    'content': content,
    'isCrisis': isCrisis,
    'emergencyHelpline': emergencyHelpline,
    'suggestedTechnique': suggestedTechnique,
    'timestamp': timestamp.toIso8601String(),
  };
}
