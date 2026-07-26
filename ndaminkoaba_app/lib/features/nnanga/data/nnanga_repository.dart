import '../../../core/network/api_client.dart';

class NnangaChatResult {
  const NnangaChatResult({
    required this.response,
    required this.usedLocalKnowledge,
    this.correction,
    this.translation,
    this.suggestedReplies = const [],
    this.audioUrl,
    this.audioTranscript,
  });

  final String response;

  /// Whether this reply was grounded in NdaMinkoaba's own vocabulary/lesson
  /// content, or answered from Nnanga's general knowledge — surfaced in the
  /// UI so learners know when to double-check against official material.
  final bool usedLocalKnowledge;

  /// A gentle correction of a mistake in the learner's message, if any.
  final String? correction;

  /// A translation, only present if the learner explicitly asked for one.
  final String? translation;

  /// 2-4 short follow-up messages the learner might send next.
  final List<String> suggestedReplies;

  /// Set when the learner's own message was a recorded voice message.
  final String? audioUrl;
  final String? audioTranscript;

  factory NnangaChatResult.fromJson(Map<String, dynamic> json) {
    return NnangaChatResult(
      response: json['response'] ?? '',
      usedLocalKnowledge: json['usedLocalKnowledge'] == true,
      correction: json['correction'] as String?,
      translation: json['translation'] as String?,
      suggestedReplies: (json['suggestedReplies'] as List<dynamic>? ?? [])
          .whereType<String>()
          .toList(),
      audioUrl: json['audioUrl'] as String?,
      audioTranscript: json['audioTranscript'] as String?,
    );
  }
}

class NnangaHistoryTurn {
  const NnangaHistoryTurn({
    required this.prompt,
    required this.response,
    this.usedLocalKnowledge,
    this.correction,
    this.translation,
    this.suggestedReplies = const [],
    this.audioUrl,
  });

  final String prompt;
  final String response;
  final bool? usedLocalKnowledge;
  final String? correction;
  final String? translation;
  final List<String> suggestedReplies;
  final String? audioUrl;
}

class NnangaRepository {
  /// Sends a prompt to the Nnanga AI tutor (`POST /nnanga/chat`) and returns
  /// its reply. The backend always attaches the authenticated user — no
  /// userId is sent from the client. The backend also feeds in the
  /// learner's recent conversation history server-side, so multi-turn
  /// follow-ups work without the client having to resend prior messages.
  /// Exactly one of [prompt] / [audioUrl] should be set — a voice message
  /// sends [audioUrl] (already uploaded via POST /uploads/audio) instead of
  /// typed text.
  Future<NnangaChatResult> sendMessage(
    String? prompt, {
    String? audioUrl,
    String? languageId,
  }) async {
    final response = await ApiClient.dio.post(
      '/nnanga/chat',
      data: {
        if (prompt != null) 'prompt': prompt,
        if (audioUrl != null) 'audioUrl': audioUrl,
        if (languageId != null) 'languageId': languageId,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final chatData = (data['data'] ?? data) as Map<String, dynamic>;

    return NnangaChatResult.fromJson(chatData);
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
              usedLocalKnowledge: item['usedLocalKnowledge'] as bool?,
              correction: item['correction'] as String?,
              translation: item['translation'] as String?,
              suggestedReplies: (item['suggestedReplies'] as List<dynamic>? ?? [])
                  .whereType<String>()
                  .toList(),
              audioUrl: item['audioUrl'] as String?,
            ))
        .toList()
        .reversed
        .toList();
  }
}
