/// A single authoring block inside the block-based Lesson Editor. Blocks are
/// an authoring-time structure only — saving them derives into the plain
/// Lesson fields (`content`, `conversationJson`, `audioUrl`, ...) that the
/// learner-facing lesson screen already renders from; see
/// `backend-api/src/lesson-blocks/lesson-blocks.service.ts`.
class LessonBlock {
  final String id;
  final String lessonId;
  final int orderNumber;
  final String type;
  final String status;
  final String? titleLabel;
  final String? textContent;
  final String? frenchTextContent;
  final String? vocabularyId;
  final String? mediaUrl;
  final List<Map<String, dynamic>>? dialogueJson;
  final Map<String, dynamic>? exerciseJson;
  final String? quizId;

  const LessonBlock({
    required this.id,
    required this.lessonId,
    required this.orderNumber,
    required this.type,
    required this.status,
    this.titleLabel,
    this.textContent,
    this.frenchTextContent,
    this.vocabularyId,
    this.mediaUrl,
    this.dialogueJson,
    this.exerciseJson,
    this.quizId,
  });

  factory LessonBlock.fromJson(Map<String, dynamic> json) {
    return LessonBlock(
      id: json['id'] ?? '',
      lessonId: json['lessonId'] ?? '',
      orderNumber: json['orderNumber'] ?? 1,
      type: (json['type'] ?? '').toString(),
      status: (json['status'] ?? 'DRAFT').toString(),
      titleLabel: json['titleLabel'],
      textContent: json['textContent'],
      frenchTextContent: json['frenchTextContent'],
      vocabularyId: json['vocabularyId'],
      mediaUrl: json['mediaUrl'],
      dialogueJson: json['dialogueJson'] == null
          ? null
          : (json['dialogueJson'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList(),
      exerciseJson: json['exerciseJson'] == null ? null : Map<String, dynamic>.from(json['exerciseJson'] as Map),
      quizId: json['quizId'],
    );
  }
}

class LessonComment {
  final String id;
  final String text;
  final String authorName;
  final String authorRole;
  final DateTime createdAt;

  const LessonComment({
    required this.id,
    required this.text,
    required this.authorName,
    required this.authorRole,
    required this.createdAt,
  });

  factory LessonComment.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>?;
    return LessonComment(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      authorName: author?['fullName'] ?? 'Unknown',
      authorRole: (author?['role'] ?? '').toString(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// The lesson itself plus its course/module context — everything the Lesson
/// Editor's header, checklist, and review panel need beyond the block list.
class LessonDetail {
  final String id;
  final String title;
  final String? summary;
  final String content;
  final String? frenchContent;
  final String? audioUrl;
  final String? videoUrl;
  final int orderNumber;
  final String status;
  final bool generatedByAi;
  final String? reviewerId;
  final String? reviewerName;
  final String? difficulty;
  final String moduleId;
  final String courseId;
  final String courseTitle;
  final String languageId;
  final String languageName;
  final bool hasQuiz;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Lesson Info tab fields.
  final String? category;
  final int? estimatedMinutes;
  final String? coverImageUrl;
  final List<String> learningObjectives;
  final List<String> outcomes;

  const LessonDetail({
    required this.id,
    required this.title,
    this.summary,
    required this.content,
    this.frenchContent,
    this.audioUrl,
    this.videoUrl,
    required this.orderNumber,
    required this.status,
    required this.generatedByAi,
    this.reviewerId,
    this.reviewerName,
    this.difficulty,
    required this.moduleId,
    required this.courseId,
    required this.courseTitle,
    required this.languageId,
    required this.languageName,
    required this.hasQuiz,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.estimatedMinutes,
    this.coverImageUrl,
    this.learningObjectives = const [],
    this.outcomes = const [],
  });

  factory LessonDetail.fromJson(Map<String, dynamic> json) {
    final module = json['module'] as Map<String, dynamic>?;
    final course = module?['course'] as Map<String, dynamic>?;
    final reviewer = json['reviewer'] as Map<String, dynamic>?;
    final quizzes = (json['quizzes'] ?? []) as List;

    return LessonDetail(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'],
      content: json['content'] ?? '',
      frenchContent: json['frenchContent'],
      audioUrl: json['audioUrl'],
      videoUrl: json['videoUrl'],
      orderNumber: (json['orderNumber'] as num?)?.toInt() ?? 1,
      status: (json['status'] ?? 'DRAFT').toString(),
      generatedByAi: json['generatedByAi'] == true,
      reviewerId: reviewer?['id'],
      reviewerName: reviewer?['fullName'],
      difficulty: json['difficulty'] as String?,
      moduleId: json['moduleId'] ?? '',
      courseId: course?['id'] ?? '',
      courseTitle: course?['title'] ?? '',
      languageId: course?['languageId'] ?? '',
      languageName: '',
      hasQuiz: quizzes.isNotEmpty,
      createdAt: DateTime.tryParse(json['createdAt'] ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? ''),
      category: json['category'] as String?,
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt(),
      coverImageUrl: json['coverImageUrl'] as String?,
      learningObjectives:
          ((json['learningObjectives'] as List?) ?? []).whereType<String>().toList(),
      outcomes: ((json['outcomes'] as List?) ?? []).whereType<String>().toList(),
    );
  }
}
