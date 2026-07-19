import '../../../core/network/api_client.dart';

class NnangaChatResult {
  const NnangaChatResult({required this.response, required this.usedLocalKnowledge});

  final String response;

  /// Whether this reply was grounded in NdaMinkoaba's own vocabulary/lesson
  /// content, or answered from Nnanga's general knowledge — surfaced in the
  /// UI so learners know when to double-check against official material.
  final bool usedLocalKnowledge;
}

class NnangaHistoryTurn {
  const NnangaHistoryTurn({required this.prompt, required this.response});

  final String prompt;
  final String response;
}

class NnangaRepository {
  /// Sends a prompt to the Nnanga AI tutor (`POST /nnanga/chat`) and returns
  /// its reply. The backend always attaches the authenticated user — no
  /// userId is sent from the client. The backend also feeds in the
  /// learner's recent conversation history server-side, so multi-turn
  /// follow-ups work without the client having to resend prior messages.
  Future<NnangaChatResult> sendMessage(String prompt, {String? languageId}) async {
    final response = await ApiClient.dio.post(
      '/nnanga/chat',
      data: {
        'prompt': prompt,
        if (languageId != null) 'languageId': languageId,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final chatData = (data['data'] ?? data) as Map<String, dynamic>;

    return NnangaChatResult(
      response: chatData['response'] ?? '',
      usedLocalKnowledge: chatData['usedLocalKnowledge'] == true,
    );
  }

  /// Loads the learner's most recent conversation turns (oldest first) so
  /// the chat screen can restore continuity across app restarts instead of
  /// always starting from a blank greeting.
  Future<List<NnangaHistoryTurn>> getHistory({int limit = 20}) async {
    final response = await ApiClient.dio.get(
      '/nnanga/conversations',
      queryParameters: {'limit': limit, 'page': 1},
    );

    final data = response.data as Map<String, dynamic>;
    final body = (data['data'] ?? data) as Map<String, dynamic>;
    final items = (body['items'] as List<dynamic>?) ?? [];

    return items
        .cast<Map<String, dynamic>>()
        .map((item) => NnangaHistoryTurn(
              prompt: item['prompt'] ?? '',
              response: item['response'] ?? '',
            ))
        .toList()
        .reversed
        .toList();
  }
}
