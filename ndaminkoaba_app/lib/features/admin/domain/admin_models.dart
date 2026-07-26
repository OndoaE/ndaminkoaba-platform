class RecentCertificateEntry {
  final String learnerName;
  final String courseTitle;
  final DateTime issuedAt;

  const RecentCertificateEntry({
    required this.learnerName,
    required this.courseTitle,
    required this.issuedAt,
  });

  factory RecentCertificateEntry.fromJson(Map<String, dynamic> json) {
    return RecentCertificateEntry(
      learnerName: json['learnerName'] ?? '',
      courseTitle: json['courseTitle'] ?? '',
      issuedAt: DateTime.tryParse(json['issuedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class LearnerActivityPoint {
  final DateTime date;
  final int newLearners;
  final int activeLearners;

  const LearnerActivityPoint({
    required this.date,
    required this.newLearners,
    required this.activeLearners,
  });

  factory LearnerActivityPoint.fromJson(Map<String, dynamic> json) {
    return LearnerActivityPoint(
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      newLearners: json['newLearners'] ?? 0,
      activeLearners: json['activeLearners'] ?? 0,
    );
  }
}

class AdminStats {
  final int users;
  final int languages;
  final int courses;
  final int lessons;
  final int vocabulary;
  final int quizzes;
  final int certificates;
  final int lessonsCompleted;
  final int avgCourseCompletion;
  final int vocabularyWithAudioPercent;
  final Map<String, int> usersByRole;
  final Map<String, int> coursesByLevel;
  final Map<String, int> coursesByStatus;
  final List<RecentCertificateEntry> recentCertificates;
  final List<LearnerActivityPoint> learnerActivity;
  final int aiReviewCount;
  final Map<String, int> courseCompletionByLevel;

  const AdminStats({
    required this.users,
    required this.languages,
    required this.courses,
    required this.lessons,
    required this.vocabulary,
    required this.quizzes,
    required this.certificates,
    required this.lessonsCompleted,
    required this.avgCourseCompletion,
    required this.vocabularyWithAudioPercent,
    required this.usersByRole,
    required this.coursesByLevel,
    required this.coursesByStatus,
    required this.recentCertificates,
    required this.learnerActivity,
    required this.aiReviewCount,
    required this.courseCompletionByLevel,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      users: json['users'] ?? 0,
      languages: json['languages'] ?? 0,
      courses: json['courses'] ?? 0,
      lessons: json['lessons'] ?? 0,
      vocabulary: json['vocabulary'] ?? 0,
      quizzes: json['quizzes'] ?? 0,
      certificates: json['certificates'] ?? 0,
      lessonsCompleted: json['lessonsCompleted'] ?? 0,
      avgCourseCompletion: json['avgCourseCompletion'] ?? 0,
      vocabularyWithAudioPercent: json['vocabularyWithAudioPercent'] ?? 0,
      usersByRole: Map<String, int>.from(json['usersByRole'] ?? {}),
      coursesByLevel: Map<String, int>.from(json['coursesByLevel'] ?? {}),
      coursesByStatus: Map<String, int>.from(json['coursesByStatus'] ?? {}),
      recentCertificates: ((json['recentCertificates'] ?? []) as List)
          .map((c) => RecentCertificateEntry.fromJson(c as Map<String, dynamic>))
          .toList(),
      learnerActivity: ((json['learnerActivity'] ?? []) as List)
          .map((p) => LearnerActivityPoint.fromJson(p as Map<String, dynamic>))
          .toList(),
      aiReviewCount: json['aiReviewCount'] ?? 0,
      courseCompletionByLevel: Map<String, int>.from(json['courseCompletionByLevel'] ?? {}),
    );
  }
}

class AdminUser {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final bool isActive;

  const AdminUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isActive,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: (json['role'] ?? '').toString(),
      isActive: json['isActive'] ?? true,
    );
  }
}

class AdminCourse {
  final String id;
  final String title;
  final String level;
  final String status;
  final String languageName;
  final String? reviewerId;
  final String? reviewerName;
  final int lessonsCount;

  const AdminCourse({
    required this.id,
    required this.title,
    required this.level,
    required this.status,
    required this.languageName,
    this.reviewerId,
    this.reviewerName,
    this.lessonsCount = 0,
  });

  factory AdminCourse.fromJson(Map<String, dynamic> json) {
    final language = json['language'] as Map<String, dynamic>?;
    final reviewer = json['reviewer'] as Map<String, dynamic>?;
    final modules = (json['modules'] ?? []) as List;
    final lessonsCount = modules.fold<int>(
      0,
      (sum, m) => sum + (((m as Map<String, dynamic>)['lessons'] ?? []) as List).length,
    );

    return AdminCourse(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      level: (json['level'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      languageName: language?['name'] ?? '',
      reviewerId: reviewer?['id'],
      reviewerName: reviewer?['fullName'],
      lessonsCount: lessonsCount,
    );
  }
}

class AdminCertificate {
  final String id;
  final String certificateCode;
  final String learnerName;
  final String courseTitle;
  final String level;
  final DateTime issuedAt;

  const AdminCertificate({
    required this.id,
    required this.certificateCode,
    required this.learnerName,
    required this.courseTitle,
    required this.level,
    required this.issuedAt,
  });

  factory AdminCertificate.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final course = json['course'] as Map<String, dynamic>?;

    return AdminCertificate(
      id: json['id'] ?? '',
      certificateCode: json['certificateCode'] ?? '',
      learnerName: user?['fullName'] ?? '',
      courseTitle: course?['title'] ?? '',
      level: (course?['level'] ?? '').toString(),
      issuedAt: DateTime.tryParse(json['issuedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// One row in the admin History screen — a single CREATE/UPDATE/DELETE made
/// by an admin or teacher, recorded automatically by the backend so admins
/// can see who changed what across the shared content pool.
class AuditLogEntry {
  final String id;
  final String action;
  final String entity;
  final String? summary;
  final String actorName;
  final String actorEmail;
  final String actorRole;
  final DateTime createdAt;

  const AuditLogEntry({
    required this.id,
    required this.action,
    required this.entity,
    this.summary,
    required this.actorName,
    required this.actorEmail,
    required this.actorRole,
    required this.createdAt,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;

    return AuditLogEntry(
      id: json['id'] ?? '',
      action: (json['action'] ?? '').toString(),
      entity: (json['entity'] ?? '').toString(),
      summary: json['summary'],
      actorName: user?['fullName'] ?? 'Unknown',
      actorEmail: user?['email'] ?? '',
      actorRole: (user?['role'] ?? '').toString(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
