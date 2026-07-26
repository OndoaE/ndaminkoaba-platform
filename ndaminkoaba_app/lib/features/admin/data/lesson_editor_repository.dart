import '../../../core/network/api_client.dart';
import '../domain/lesson_editor_models.dart';

/// Backs the block-based Lesson Editor: the lesson itself, its blocks
/// (`lesson-blocks` module), its comment thread (`lesson-comments` module),
/// and the Nnanga authoring assistant (`ai/lesson-assist`).
class LessonEditorRepository {
  Future<LessonDetail> getLesson(String lessonId) async {
    final response = await ApiClient.dio.get('/lessons/$lessonId');
    final data = response.data as Map<String, dynamic>;
    return LessonDetail.fromJson((data['data'] ?? data) as Map<String, dynamic>);
  }

  Future<List<LessonBlock>> getBlocks(String lessonId) async {
    final response = await ApiClient.dio.get('/lessons/$lessonId/blocks');
    final data = response.data as Map<String, dynamic>;
    final items = (data['data'] ?? data) as List;
    return items.map((item) => LessonBlock.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> createBlock({
    required String lessonId,
    required int orderNumber,
    required String type,
    String? titleLabel,
    String? textContent,
    String? frenchTextContent,
    String? vocabularyId,
    String? mediaUrl,
    List<Map<String, dynamic>>? dialogueJson,
    Map<String, dynamic>? exerciseJson,
    String? quizId,
  }) async {
    await ApiClient.dio.post('/lesson-blocks', data: {
      'lessonId': lessonId,
      'orderNumber': orderNumber,
      'type': type,
      if (titleLabel != null && titleLabel.isNotEmpty) 'titleLabel': titleLabel,
      if (textContent != null && textContent.isNotEmpty) 'textContent': textContent,
      if (frenchTextContent != null && frenchTextContent.isNotEmpty) 'frenchTextContent': frenchTextContent,
      if (vocabularyId != null && vocabularyId.isNotEmpty) 'vocabularyId': vocabularyId,
      if (mediaUrl != null && mediaUrl.isNotEmpty) 'mediaUrl': mediaUrl,
      if (dialogueJson != null) 'dialogueJson': dialogueJson,
      if (exerciseJson != null) 'exerciseJson': exerciseJson,
      if (quizId != null && quizId.isNotEmpty) 'quizId': quizId,
    });
  }

  Future<void> updateBlock(
    String id, {
    String? titleLabel,
    String? textContent,
    String? frenchTextContent,
    String? vocabularyId,
    String? mediaUrl,
    List<Map<String, dynamic>>? dialogueJson,
    Map<String, dynamic>? exerciseJson,
    String? quizId,
  }) async {
    await ApiClient.dio.patch('/lesson-blocks/$id', data: {
      if (titleLabel != null) 'titleLabel': titleLabel,
      if (textContent != null) 'textContent': textContent,
      if (frenchTextContent != null) 'frenchTextContent': frenchTextContent,
      if (vocabularyId != null) 'vocabularyId': vocabularyId,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      if (dialogueJson != null) 'dialogueJson': dialogueJson,
      if (exerciseJson != null) 'exerciseJson': exerciseJson,
      if (quizId != null) 'quizId': quizId,
    });
  }

  Future<void> deleteBlock(String id) async {
    await ApiClient.dio.delete('/lesson-blocks/$id');
  }

  Future<void> reorderBlocks(String lessonId, List<String> orderedIds) async {
    await ApiClient.dio.patch('/lesson-blocks/reorder', data: {
      'lessonId': lessonId,
      'orderedIds': orderedIds,
    });
  }

  Future<List<LessonComment>> getComments(String lessonId) async {
    final response = await ApiClient.dio.get('/lessons/$lessonId/comments');
    final data = response.data as Map<String, dynamic>;
    final items = (data['data'] ?? data) as List;
    return items.map((item) => LessonComment.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> postComment(String lessonId, String text) async {
    await ApiClient.dio.post('/lessons/$lessonId/comments', data: {'text': text});
  }

  Future<void> deleteComment(String id) async {
    await ApiClient.dio.delete('/lesson-comments/$id');
  }

  /// Calls the Nnanga authoring assistant. [action] is one of
  /// GENERATE_EXAMPLES / CREATE_QUIZ / SIMPLIFY_CONTENT / CHECK_TRANSLATIONS.
  Future<({String suggestion, List<Map<String, dynamic>>? quizDraft})> lessonAssist({
    required String action,
    required String lessonContent,
    String? frenchContent,
    String? instruction,
  }) async {
    final response = await ApiClient.dio.post('/ai/lesson-assist', data: {
      'action': action,
      'lessonContent': lessonContent,
      if (frenchContent != null && frenchContent.isNotEmpty) 'frenchContent': frenchContent,
      if (instruction != null && instruction.isNotEmpty) 'instruction': instruction,
    });
    final data = response.data as Map<String, dynamic>;
    final body = (data['data'] ?? data) as Map<String, dynamic>;
    return (
      suggestion: (body['suggestion'] ?? '') as String,
      quizDraft: body['quizDraft'] == null
          ? null
          : (body['quizDraft'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList(),
    );
  }
}
