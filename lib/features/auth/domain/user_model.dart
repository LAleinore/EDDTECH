import 'dart:convert';

enum UserRole {
  teacher('teacher', 'Преподаватель'),
  student('student', 'Студент'),
  learner('learner', 'Инклюзивный ученик'),
  admin('admin', 'Администратор');

  final String key;
  final String title;
  const UserRole(this.key, this.title);

  static UserRole fromKey(String key) {
    return UserRole.values.firstWhere(
      (r) => r.key == key,
      orElse: () => UserRole.student,
    );
  }
}

class UserAccessibilitySettings {
  final double fontScale;
  final bool highContrast;
  final bool reduceMotion;
  final bool voiceEnabled;
  final bool simplifiedUI;
  final bool largeButtons;

  const UserAccessibilitySettings({
    this.fontScale = 1.0,
    this.highContrast = false,
    this.reduceMotion = false,
    this.voiceEnabled = false,
    this.simplifiedUI = false,
    this.largeButtons = false,
  });

  UserAccessibilitySettings copyWith({
    double? fontScale,
    bool? highContrast,
    bool? reduceMotion,
    bool? voiceEnabled,
    bool? simplifiedUI,
    bool? largeButtons,
  }) {
    return UserAccessibilitySettings(
      fontScale: fontScale ?? this.fontScale,
      highContrast: highContrast ?? this.highContrast,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      simplifiedUI: simplifiedUI ?? this.simplifiedUI,
      largeButtons: largeButtons ?? this.largeButtons,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fontScale': fontScale,
      'highContrast': highContrast,
      'reduceMotion': reduceMotion,
      'voiceEnabled': voiceEnabled,
      'simplifiedUI': simplifiedUI,
      'largeButtons': largeButtons,
    };
  }

  factory UserAccessibilitySettings.fromMap(Map<String, dynamic> map) {
    return UserAccessibilitySettings(
      fontScale: (map['fontScale'] as num?)?.toDouble() ?? 1.0,
      highContrast: map['highContrast'] as bool? ?? false,
      reduceMotion: map['reduceMotion'] as bool? ?? false,
      voiceEnabled: map['voiceEnabled'] as bool? ?? false,
      simplifiedUI: map['simplifiedUI'] as bool? ?? false,
      largeButtons: map['largeButtons'] as bool? ?? false,
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String avatarUrl;
  final String language;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final UserAccessibilitySettings accessibility;
  final bool isDemo;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl = '',
    this.language = 'ru',
    required this.createdAt,
    this.lastLoginAt,
    this.accessibility = const UserAccessibilitySettings(),
    this.isDemo = false,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? avatarUrl,
    String? language,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    UserAccessibilitySettings? accessibility,
    bool? isDemo,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      accessibility: accessibility ?? this.accessibility,
      isDemo: isDemo ?? this.isDemo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.key,
      'avatarUrl': avatarUrl,
      'language': language,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'accessibility': accessibility.toMap(),
      'isDemo': isDemo,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.fromKey(map['role'] ?? 'student'),
      avatarUrl: map['avatarUrl'] ?? '',
      language: map['language'] ?? 'ru',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.parse(map['lastLoginAt'])
          : null,
      accessibility: map['accessibility'] != null
          ? UserAccessibilitySettings.fromMap(
              Map<String, dynamic>.from(map['accessibility']),
            )
          : const UserAccessibilitySettings(),
      isDemo: map['isDemo'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));
}
