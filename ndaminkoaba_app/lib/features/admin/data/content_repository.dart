import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../lessons/domain/models/lesson_image.dart';
import '../domain/admin_content_models.dart';
import '../domain/management_models.dart';

class ContentRepository {
  // --- Flat management lists (all items of a type, with parent context) ---

  Future<List<ManagedModule>> getAllModulesFlat({String? languageId}) async {
    final response = await ApiClient.dio.get('/course-modules', queryParameters: {
      'limit': 200,
      if (languageId != null) 'languageId': languageId,
    });
    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];
    return (items as List)
        .map((item) => ManagedModule.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ManagedLesson>> getAllLessonsFlat({String? languageId}) async {
    final response = await ApiClient.dio.get('/lessons', queryParameters: {
      'limit': 200,
      if (languageId != null) 'languageId': languageId,
    });
    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];
    return (items as List)
        .map((item) => ManagedLesson.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ManagedQuiz>> getAllQuizzesFlat({String? languageId}) async {
    final response = await ApiClient.dio.get('/quizzes', queryParameters: {
      'limit': 200,
      if (languageId != null) 'languageId': languageId,
    });
    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];
    return (items as List)
        .map((item) => ManagedQuiz.fromJson(item as Map<String, dynamic>))
        .toList();
  }
  Future<List<AdminLanguage>> getLanguages({bool? isActive}) async {
    final response = await ApiClient.dio.get('/languages', queryParameters: {
      'limit': 100,
      if (isActive != null) 'isActive': isActive,
    });
    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];
    return (items as List)
        .map((item) => AdminLanguage.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<AdminLanguage> createLanguage({
    required String name,
    required String code,
    String? country,
  }) async {
    final response = await ApiClient.dio.post('/languages', data: {
      'name': name,
      'code': code,
      if (country != null && country.isNotEmpty) 'country': country,
    });
    final data = response.data as Map<String, dynamic>;
    return AdminLanguage.fromJson((data['data'] ?? data) as Map<String, dynamic>);
  }

  Future<void> setLanguageActive(String id, bool isActive) async {
    await ApiClient.dio.patch('/languages/$id', data: {'isActive': isActive});
  }

  Future<void> deleteLanguage(String id) async {
    await ApiClient.dio.delete('/languages/$id');
  }

  // --- Courses ---

  Future<List<AdminCourseDetail>> getAllCourses({String? languageId}) async {
    final response = await ApiClient.dio.get('/courses', queryParameters: {
      'limit': 100,
      if (languageId != null) 'languageId': languageId,
    });
    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];
    return (items as List)
        .map((item) => AdminCourseDetail.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<AdminCourseDetail> getCourse(String id) async {
    final response = await ApiClient.dio.get('/courses/$id');
    final data = response.data as Map<String, dynamic>;
    return AdminCourseDetail.fromJson((data['data'] ?? data) as Map<String, dynamic>);
  }

  Future<String> createCourse({
    required String title,
    required String description,
    String? frenchTitle,
    String? frenchDescription,
    required String level,
    required String languageId,
    int? estimatedHours,
  }) async {
    final response = await ApiClient.dio.post('/courses', data: {
      'title': title,
      'description': description,
      if (frenchTitle != null && frenchTitle.isNotEmpty) 'frenchTitle': frenchTitle,
      if (frenchDescription != null && frenchDescription.isNotEmpty)
        'frenchDescription': frenchDescription,
      'level': level,
      'languageId': languageId,
      if (estimatedHours != null) 'estimatedHours': estimatedHours,
    });
    final data = response.data as Map<String, dynamic>;
    return ((data['data'] ?? data) as Map<String, dynamic>)['id'] as String;
  }

  Future<void> updateCourse(
    String id, {
    String? title,
    String? description,
    String? frenchTitle,
    String? frenchDescription,
    String? level,
    int? estimatedHours,
  }) async {
    await ApiClient.dio.patch('/courses/$id', data: {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (frenchTitle != null) 'frenchTitle': frenchTitle,
      if (frenchDescription != null) 'frenchDescription': frenchDescription,
      if (level != null) 'level': level,
      if (estimatedHours != null) 'estimatedHours': estimatedHours,
    });
  }

  Future<void> deleteCourse(String id) async {
    await ApiClient.dio.delete('/courses/$id');
  }

  // --- Modules ---

  Future<void> createModule({
    required String courseId,
    required String title,
    required String description,
    String? frenchTitle,
    String? frenchDescription,
    required int orderNumber,
  }) async {
    await ApiClient.dio.post('/course-modules', data: {
      'courseId': courseId,
      'title': title,
      'description': description,
      if (frenchTitle != null && frenchTitle.isNotEmpty) 'frenchTitle': frenchTitle,
      if (frenchDescription != null && frenchDescription.isNotEmpty)
        'frenchDescription': frenchDescription,
      'orderNumber': orderNumber,
    });
  }

  Future<void> updateModule(
    String id, {
    String? title,
    String? description,
    String? frenchTitle,
    String? frenchDescription,
  }) async {
    await ApiClient.dio.patch('/course-modules/$id', data: {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (frenchTitle != null) 'frenchTitle': frenchTitle,
      if (frenchDescription != null) 'frenchDescription': frenchDescription,
    });
  }

  Future<void> deleteModule(String id) async {
    await ApiClient.dio.delete('/course-modules/$id');
  }

  // --- Lessons ---

  Future<String> createLesson({
    required String moduleId,
    required String title,
    required String summary,
    required String content,
    String? frenchTitle,
    String? frenchSummary,
    String? frenchContent,
    required int orderNumber,
  }) async {
    final response = await ApiClient.dio.post('/lessons', data: {
      'moduleId': moduleId,
      'title': title,
      'summary': summary,
      'content': content,
      if (frenchTitle != null && frenchTitle.isNotEmpty) 'frenchTitle': frenchTitle,
      if (frenchSummary != null && frenchSummary.isNotEmpty) 'frenchSummary': frenchSummary,
      if (frenchContent != null && frenchContent.isNotEmpty) 'frenchContent': frenchContent,
      'orderNumber': orderNumber,
    });
    final data = response.data as Map<String, dynamic>;
    return ((data['data'] ?? data) as Map<String, dynamic>)['id'] as String;
  }

  Future<void> updateLesson(
    String id, {
    String? title,
    String? summary,
    String? content,
    String? frenchTitle,
    String? frenchSummary,
    String? frenchContent,
    String? moduleId,
    int? orderNumber,
  }) async {
    await ApiClient.dio.patch('/lessons/$id', data: {
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      if (content != null) 'content': content,
      if (frenchTitle != null) 'frenchTitle': frenchTitle,
      if (frenchSummary != null) 'frenchSummary': frenchSummary,
      if (frenchContent != null) 'frenchContent': frenchContent,
      if (moduleId != null) 'moduleId': moduleId,
      if (orderNumber != null) 'orderNumber': orderNumber,
    });
  }

  Future<void> deleteLesson(String id) async {
    await ApiClient.dio.delete('/lessons/$id');
  }

  // --- Quizzes ---

  Future<AdminQuiz?> getQuizForLesson(String lessonId) async {
    final response = await ApiClient.dio.get(
      '/quizzes',
      queryParameters: {'lessonId': lessonId, 'limit': 1},
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];
    if ((items as List).isEmpty) return null;
    return AdminQuiz.fromJson(items.first as Map<String, dynamic>);
  }

  Future<String> createQuiz({
    required String lessonId,
    required String title,
    required String description,
    String? frenchTitle,
    String? frenchDescription,
    required int passingScore,
  }) async {
    final response = await ApiClient.dio.post('/quizzes', data: {
      'lessonId': lessonId,
      'title': title,
      'description': description,
      if (frenchTitle != null && frenchTitle.isNotEmpty) 'frenchTitle': frenchTitle,
      if (frenchDescription != null && frenchDescription.isNotEmpty)
        'frenchDescription': frenchDescription,
      'passingScore': passingScore,
    });
    final data = response.data as Map<String, dynamic>;
    return ((data['data'] ?? data) as Map<String, dynamic>)['id'] as String;
  }

  Future<void> updateQuiz(
    String id, {
    String? title,
    String? description,
    String? frenchTitle,
    String? frenchDescription,
    int? passingScore,
  }) async {
    await ApiClient.dio.patch('/quizzes/$id', data: {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (frenchTitle != null) 'frenchTitle': frenchTitle,
      if (frenchDescription != null) 'frenchDescription': frenchDescription,
      if (passingScore != null) 'passingScore': passingScore,
    });
  }

  /// Deletes a quiz and everything under it (choices, then questions, then
  /// the quiz itself) — required because nothing in this schema cascades.
  Future<void> deleteQuiz(AdminQuiz quiz) async {
    for (final question in quiz.questions) {
      for (final choice in question.choices) {
        await ApiClient.dio.delete('/choices/${choice.id}');
      }
      await ApiClient.dio.delete('/questions/${question.id}');
    }
    await ApiClient.dio.delete('/quizzes/${quiz.id}');
  }

  // --- Questions & choices ---

  Future<void> createQuestionWithChoices({
    required String quizId,
    required String questionText,
    String? explanation,
    String? frenchQuestionText,
    String? frenchExplanation,
    required List<({String text, String? frenchText, bool isCorrect})> choices,
  }) async {
    final response = await ApiClient.dio.post('/questions', data: {
      'quizId': quizId,
      'questionText': questionText,
      if (explanation != null && explanation.isNotEmpty) 'explanation': explanation,
      if (frenchQuestionText != null && frenchQuestionText.isNotEmpty)
        'frenchQuestionText': frenchQuestionText,
      if (frenchExplanation != null && frenchExplanation.isNotEmpty)
        'frenchExplanation': frenchExplanation,
    });
    final data = response.data as Map<String, dynamic>;
    final questionId = ((data['data'] ?? data) as Map<String, dynamic>)['id'] as String;

    for (final choice in choices) {
      await ApiClient.dio.post('/choices', data: {
        'questionId': questionId,
        'choiceText': choice.text,
        if (choice.frenchText != null && choice.frenchText!.isNotEmpty)
          'frenchChoiceText': choice.frenchText,
        'isCorrect': choice.isCorrect,
      });
    }
  }

  /// Edits an existing question in place: updates its text/explanation, and
  /// replaces its choice set entirely (simpler and safer than trying to
  /// diff old vs new choices — no attempt result references a specific
  /// Choice row, so recreating them is harmless).
  Future<void> updateQuestionWithChoices({
    required String questionId,
    required List<String> oldChoiceIds,
    required String questionText,
    String? explanation,
    String? frenchQuestionText,
    String? frenchExplanation,
    required List<({String text, String? frenchText, bool isCorrect})> choices,
  }) async {
    await ApiClient.dio.patch('/questions/$questionId', data: {
      'questionText': questionText,
      if (explanation != null && explanation.isNotEmpty) 'explanation': explanation,
      if (frenchQuestionText != null) 'frenchQuestionText': frenchQuestionText,
      if (frenchExplanation != null) 'frenchExplanation': frenchExplanation,
    });

    for (final choiceId in oldChoiceIds) {
      await ApiClient.dio.delete('/choices/$choiceId');
    }

    for (final choice in choices) {
      await ApiClient.dio.post('/choices', data: {
        'questionId': questionId,
        'choiceText': choice.text,
        if (choice.frenchText != null && choice.frenchText!.isNotEmpty)
          'frenchChoiceText': choice.frenchText,
        'isCorrect': choice.isCorrect,
      });
    }
  }

  Future<void> deleteQuestion(String questionId, List<String> choiceIds) async {
    for (final choiceId in choiceIds) {
      await ApiClient.dio.delete('/choices/$choiceId');
    }
    await ApiClient.dio.delete('/questions/$questionId');
  }

  Future<void> setChoiceCorrect(String choiceId, bool isCorrect) async {
    await ApiClient.dio.patch('/choices/$choiceId', data: {'isCorrect': isCorrect});
  }

  // --- Lesson images ---

  Future<List<LessonImage>> getLessonImages(String lessonId) async {
    final response = await ApiClient.dio.get(
      '/lesson-images',
      queryParameters: {'lessonId': lessonId, 'limit': 100},
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];
    return (items as List)
        .map((item) => LessonImage.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Uploads raw image bytes to the generic uploads endpoint and returns the
  /// relative URL (e.g. `/uploads/images/xxx.png`) to store on a LessonImage.
  Future<String> uploadImage(Uint8List bytes, String filename) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final response = await ApiClient.dio.post('/uploads/image', data: formData);
    final data = response.data as Map<String, dynamic>;
    return ((data['data'] ?? data) as Map<String, dynamic>)['url'] as String;
  }

  Future<void> createLessonImage({
    required String lessonId,
    required String imageUrl,
    required String word,
    String? caption,
    required int orderNumber,
  }) async {
    await ApiClient.dio.post('/lesson-images', data: {
      'lessonId': lessonId,
      'imageUrl': imageUrl,
      'word': word,
      if (caption != null && caption.isNotEmpty) 'caption': caption,
      'orderNumber': orderNumber,
    });
  }

  Future<void> deleteLessonImage(String id) async {
    await ApiClient.dio.delete('/lesson-images/$id');
  }
}
