import '../../../core/network/api_client.dart';
import '../domain/quiz.dart';

class QuizRepository {
  /// Returns the quiz attached to a lesson, or null if the lesson has none.
  Future<Quiz?> getQuizForLesson(String lessonId) async {
    final response = await ApiClient.dio.get(
      '/quizzes',
      queryParameters: {'lessonId': lessonId, 'limit': 1},
    );

    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];

    if ((items as List).isEmpty) return null;

    return Quiz.fromJson(items.first as Map<String, dynamic>);
  }

  Future<QuizAttemptResult> submitAttempt({
    required String userId,
    required String quizId,
    required Map<String, String> answers,
  }) async {
    final response = await ApiClient.dio.post(
      '/quiz-attempts',
      data: {
        'userId': userId,
        'quizId': quizId,
        'answers': answers.entries
            .map((e) => {'questionId': e.key, 'choiceId': e.value})
            .toList(),
      },
    );

    final data = response.data as Map<String, dynamic>;
    final attemptData = data['data'] ?? data;

    return QuizAttemptResult.fromJson(attemptData as Map<String, dynamic>);
  }
}
