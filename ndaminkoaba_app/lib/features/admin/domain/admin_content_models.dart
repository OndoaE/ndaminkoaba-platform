class AdminLanguage {
  final String id;
  final String name;
  final String code;
  final String? country;
  final bool isActive;

  // Only populated when the list was fetched with includeStats: true (see
  // ContentRepository.getLanguages) — null otherwise.
  final int? courseCount;
  final int? learnerCount;
  final int? avgProgress;

  const AdminLanguage({
    required this.id,
    required this.name,
    required this.code,
    this.country,
    required this.isActive,
    this.courseCount,
    this.learnerCount,
    this.avgProgress,
  });

  factory AdminLanguage.fromJson(Map<String, dynamic> json) {
    return AdminLanguage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      country: json['country'],
      isActive: json['isActive'] ?? true,
      courseCount: json['courseCount'],
      learnerCount: json['learnerCount'],
      avgProgress: json['avgProgress'],
    );
  }
}

class AdminLesson {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String? frenchTitle;
  final String? frenchSummary;
  final String? frenchContent;
  final int orderNumber;
  final String moduleId;

  const AdminLesson({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    this.frenchTitle,
    this.frenchSummary,
    this.frenchContent,
    required this.orderNumber,
    required this.moduleId,
  });

  factory AdminLesson.fromJson(Map<String, dynamic> json) {
    return AdminLesson(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      content: json['content'] ?? '',
      frenchTitle: json['frenchTitle'],
      frenchSummary: json['frenchSummary'],
      frenchContent: json['frenchContent'],
      orderNumber: json['orderNumber'] ?? 1,
      moduleId: json['moduleId'] ?? '',
    );
  }
}

class AdminModule {
  final String id;
  final String title;
  final String description;
  final String? frenchTitle;
  final String? frenchDescription;
  final int orderNumber;
  final String courseId;
  final List<AdminLesson> lessons;

  const AdminModule({
    required this.id,
    required this.title,
    required this.description,
    this.frenchTitle,
    this.frenchDescription,
    required this.orderNumber,
    required this.courseId,
    required this.lessons,
  });

  factory AdminModule.fromJson(Map<String, dynamic> json) {
    return AdminModule(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      frenchTitle: json['frenchTitle'],
      frenchDescription: json['frenchDescription'],
      orderNumber: json['orderNumber'] ?? 1,
      courseId: json['courseId'] ?? '',
      lessons: ((json['lessons'] ?? []) as List)
          .map((l) => AdminLesson.fromJson(l as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber)),
    );
  }
}

class AdminCourseDetail {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String? frenchTitle;
  final String? frenchDescription;
  final String level;
  final String status;
  final int? estimatedHours;
  final String languageId;
  final String category;
  final List<String> tags;
  final List<String> learningObjectives;
  final List<String> supportLanguageCodes;
  final String? thumbnailUrl;
  final String visibility;
  final String enrollmentMode;
  final bool issueCertificate;
  final DateTime? publicationDate;
  final String? teacherId;
  final String? teacherName;
  final String? reviewerId;
  final String? reviewerName;
  final String? prerequisiteCourseId;
  final List<AdminModule> modules;

  const AdminCourseDetail({
    required this.id,
    required this.title,
    this.subtitle = '',
    required this.description,
    this.frenchTitle,
    this.frenchDescription,
    required this.level,
    required this.status,
    required this.estimatedHours,
    required this.languageId,
    this.category = '',
    this.tags = const [],
    this.learningObjectives = const [],
    this.supportLanguageCodes = const [],
    this.thumbnailUrl,
    this.visibility = 'PUBLIC',
    this.enrollmentMode = 'OPEN',
    this.issueCertificate = true,
    this.publicationDate,
    this.teacherId,
    this.teacherName,
    this.reviewerId,
    this.reviewerName,
    this.prerequisiteCourseId,
    required this.modules,
  });

  factory AdminCourseDetail.fromJson(Map<String, dynamic> json) {
    final teacher = json['teacher'] as Map<String, dynamic>?;
    final reviewer = json['reviewer'] as Map<String, dynamic>?;

    return AdminCourseDetail(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      description: json['description'] ?? '',
      frenchTitle: json['frenchTitle'],
      frenchDescription: json['frenchDescription'],
      level: (json['level'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      estimatedHours: json['estimatedHours'],
      languageId: json['languageId'] ?? '',
      category: json['category'] ?? '',
      tags: ((json['tags'] ?? []) as List).map((t) => t.toString()).toList(),
      learningObjectives:
          ((json['learningObjectives'] ?? []) as List).map((t) => t.toString()).toList(),
      supportLanguageCodes:
          ((json['supportLanguageCodes'] ?? []) as List).map((t) => t.toString()).toList(),
      thumbnailUrl: json['thumbnailUrl'],
      visibility: (json['visibility'] ?? 'PUBLIC').toString(),
      enrollmentMode: (json['enrollmentMode'] ?? 'OPEN').toString(),
      issueCertificate: json['issueCertificate'] ?? true,
      publicationDate:
          json['publicationDate'] == null ? null : DateTime.tryParse(json['publicationDate']),
      teacherId: teacher?['id'],
      teacherName: teacher?['fullName'],
      reviewerId: reviewer?['id'],
      reviewerName: reviewer?['fullName'],
      prerequisiteCourseId: json['prerequisiteCourseId'],
      modules: ((json['modules'] ?? []) as List)
          .map((m) => AdminModule.fromJson(m as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber)),
    );
  }
}

class AdminChoice {
  final String id;
  final String choiceText;
  final String? frenchChoiceText;
  final bool isCorrect;

  const AdminChoice({
    required this.id,
    required this.choiceText,
    this.frenchChoiceText,
    required this.isCorrect,
  });

  factory AdminChoice.fromJson(Map<String, dynamic> json) {
    return AdminChoice(
      id: json['id'] ?? '',
      choiceText: json['choiceText'] ?? '',
      frenchChoiceText: json['frenchChoiceText'],
      isCorrect: json['isCorrect'] == true,
    );
  }
}

class AdminQuestion {
  final String id;
  final String questionText;
  final String? explanation;
  final String? frenchQuestionText;
  final String? frenchExplanation;
  final List<AdminChoice> choices;

  const AdminQuestion({
    required this.id,
    required this.questionText,
    this.explanation,
    this.frenchQuestionText,
    this.frenchExplanation,
    required this.choices,
  });

  factory AdminQuestion.fromJson(Map<String, dynamic> json) {
    return AdminQuestion(
      id: json['id'] ?? '',
      questionText: json['questionText'] ?? '',
      explanation: json['explanation'],
      frenchQuestionText: json['frenchQuestionText'],
      frenchExplanation: json['frenchExplanation'],
      choices: ((json['choices'] ?? []) as List)
          .map((c) => AdminChoice.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AdminQuiz {
  final String id;
  final String title;
  final String? description;
  final String? frenchTitle;
  final String? frenchDescription;
  final int passingScore;
  final List<AdminQuestion> questions;

  const AdminQuiz({
    required this.id,
    required this.title,
    this.description,
    this.frenchTitle,
    this.frenchDescription,
    required this.passingScore,
    required this.questions,
  });

  factory AdminQuiz.fromJson(Map<String, dynamic> json) {
    return AdminQuiz(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      frenchTitle: json['frenchTitle'],
      frenchDescription: json['frenchDescription'],
      passingScore: json['passingScore'] ?? 80,
      questions: ((json['questions'] ?? []) as List)
          .map((q) => AdminQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}
