import 'dart:convert';

enum ApplicationStatus {
  pending('pending', 'На рассмотрении'),
  approved('approved', 'Одобрено'),
  rejected('rejected', 'Отклонено');

  final String key;
  final String title;
  const ApplicationStatus(this.key, this.title);

  static ApplicationStatus fromKey(String key) {
    return ApplicationStatus.values.firstWhere(
      (s) => s.key == key,
      orElse: () => ApplicationStatus.pending,
    );
  }
}

class TeacherApplication {
  final String id;
  final String fullName;
  final String email;
  final String school;
  final String city;
  final String subject;
  final String teacherCode; // Format: TCH-XXXX-KZ
  final ApplicationStatus status;
  final DateTime appliedAt;
  final String? rejectionReason;
  final String? reviewedBy;

  const TeacherApplication({
    required this.id,
    required this.fullName,
    required this.email,
    required this.school,
    required this.city,
    required this.subject,
    required this.teacherCode,
    this.status = ApplicationStatus.pending,
    required this.appliedAt,
    this.rejectionReason,
    this.reviewedBy,
  });

  TeacherApplication copyWith({
    String? id,
    String? fullName,
    String? email,
    String? school,
    String? city,
    String? subject,
    String? teacherCode,
    ApplicationStatus? status,
    DateTime? appliedAt,
    String? rejectionReason,
    String? reviewedBy,
  }) {
    return TeacherApplication(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      school: school ?? this.school,
      city: city ?? this.city,
      subject: subject ?? this.subject,
      teacherCode: teacherCode ?? this.teacherCode,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      reviewedBy: reviewedBy ?? this.reviewedBy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'school': school,
      'city': city,
      'subject': subject,
      'teacherCode': teacherCode,
      'status': status.key,
      'appliedAt': appliedAt.toIso8601String(),
      'rejectionReason': rejectionReason,
      'reviewedBy': reviewedBy,
    };
  }

  factory TeacherApplication.fromMap(Map<String, dynamic> map) {
    return TeacherApplication(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      school: map['school'] ?? '',
      city: map['city'] ?? '',
      subject: map['subject'] ?? '',
      teacherCode: map['teacherCode'] ?? '',
      status: ApplicationStatus.fromKey(map['status'] ?? 'pending'),
      appliedAt: map['appliedAt'] != null
          ? DateTime.parse(map['appliedAt'])
          : DateTime.now(),
      rejectionReason: map['rejectionReason'],
      reviewedBy: map['reviewedBy'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TeacherApplication.fromJson(String source) =>
      TeacherApplication.fromMap(json.decode(source));
}
