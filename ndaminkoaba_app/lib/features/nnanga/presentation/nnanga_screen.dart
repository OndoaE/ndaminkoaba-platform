import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:record/record.dart';

import '../../../core/language/learning_language_provider.dart';
import '../../../core/network/api_error.dart';
import '../../../design_system/buttons/bouncy_icon_button.dart';
import '../../../design_system/cards/featured_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/gradients/app_gradients.dart';
import '../../../design_system/navigation/app_bottom_navigation.dart';
import '../../../design_system/navigation/tab_navigation.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/shadows/app_shadows.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/gradient_app_bar.dart';
import '../../../design_system/widgets/waveform_visualizer.dart';
import '../../../l10n/app_localizations.dart';
import '../../pronunciation/data/pronunciation_repository.dart';
import '../../pronunciation/data/wav_encoder.dart';
import '../data/nnanga_repository.dart';

const _kSampleRate = 16000;

class _ChatMessage {
  const _ChatMessage({
    required this.isUser,
    required this.text,
    this.usedLocalKnowledge,
    this.correction,
    this.translation,
    this.suggestedReplies = const [],
    this.audioUrl,
  });

  final bool isUser;
  final String text;

  /// Only set for bot replies sent live in this session (the history
  /// endpoint doesn't persist this signal) — null means "unknown", not
  /// "general knowledge", so the badge is hidden rather than shown wrong.
  final bool? usedLocalKnowledge;
  final String? correction;
  final String? translation;
  final List<String> suggestedReplies;

  /// Set when this bubble is a voice message (user's recorded audio, or
  /// theoretically a future TTS bot voice reply).
  final String? audioUrl;
}

class NnangaScreen extends ConsumerStatefulWidget {
  const NnangaScreen({super.key});

  @override
  ConsumerState<NnangaScreen> createState() => _NnangaScreenState();
}

class _NnangaScreenState extends ConsumerState<NnangaScreen> {
  final repository = NnangaRepository();
  final uploadRepository = PronunciationRepository();
  final inputController = TextEditingController();
  final scrollController = ScrollController();
  final recorder = AudioRecorder();
  final pcmBuffer = BytesBuilder();
  StreamSubscription<Uint8List>? recordingSubscription;

  final List<_ChatMessage> messages = [];
  bool _initialized = false;
  bool isLoadingHistory = true;

  bool isSending = false;
  bool isRecording = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadHistory();
    }
  }

  Future<void> _loadHistory() async {
    final l10n = AppLocalizations.of(context);
    try {
      final history = await repository.getHistory();
      if (!mounted) return;
      setState(() {
        if (history.isEmpty) {
          messages.add(_ChatMessage(isUser: false, text: l10n.nnangaGreeting));
        } else {
          for (final turn in history) {
            messages.add(_ChatMessage(isUser: true, text: turn.prompt));
            messages.add(_ChatMessage(
              isUser: false,
              text: turn.response,
              usedLocalKnowledge: turn.usedLocalKnowledge,
              correction: turn.correction,
              translation: turn.translation,
              suggestedReplies: turn.suggestedReplies,
            ));
          }
        }
        isLoadingHistory = false;
      });
      _scrollToEnd();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        messages.add(_ChatMessage(isUser: false, text: l10n.nnangaGreeting));
        isLoadingHistory = false;
      });
    }
  }

  @override
  void dispose() {
    inputController.dispose();
    scrollController.dispose();
    recordingSubscription?.cancel();
    recorder.dispose();
    super.dispose();
  }

  Future<void> send({String? overrideText, String? audioUrl}) async {
    final text = overrideText ?? inputController.text.trim();
    if ((text.isEmpty && audioUrl == null) || isSending) return;

    setState(() {
      messages.add(_ChatMessage(isUser: true, text: text, audioUrl: audioUrl));
      isSending = true;
      inputController.clear();
    });
    _scrollToEnd();

    try {
      final result = await repository.sendMessage(
        audioUrl != null ? null : text,
        audioUrl: audioUrl,
        languageId: ref.read(currentLearningLanguageProvider),
      );
      if (!mounted) return;
      setState(() {
        messages.add(
          _ChatMessage(
            isUser: false,
            text: result.response,
            usedLocalKnowledge: result.usedLocalKnowledge,
            correction: result.correction,
            translation: result.translation,
            suggestedReplies: result.suggestedReplies,
          ),
        );
        isSending = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final message = extractErrorMessage(
        e,
        fallback: AppLocalizations.of(context).nnangaErrorFallback,
      );
      setState(() {
        messages.add(_ChatMessage(isUser: false, text: message));
        isSending = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        messages.add(
          _ChatMessage(
            isUser: false,
            text: AppLocalizations.of(context).commonSomethingWrong,
          ),
        );
        isSending = false;
      });
    }

    _scrollToEnd();
  }

  Future<void> _startRecording() async {
    final hasPermission = await recorder.hasPermission();
    if (!hasPermission) return;

    pcmBuffer.clear();
    setState(() => isRecording = true);

    final stream = await recorder.startStream(
      const RecordConfig(encoder: AudioEncoder.pcm16bits, sampleRate: _kSampleRate, numChannels: 1),
    );
    recordingSubscription = stream.listen((chunk) => pcmBuffer.add(chunk));
  }

  Future<void> _stopRecordingAndSend() async {
    await recorder.stop();
    await recordingSubscription?.cancel();
    recordingSubscription = null;

    if (!mounted) return;
    setState(() => isRecording = false);

    final wavBytes = wrapPcm16AsWav(pcmBuffer.toBytes(), sampleRate: _kSampleRate, numChannels: 1);
    if (wavBytes.length <= 44) return; // header-only, nothing was recorded

    try {
      final audioUrl = await uploadRepository.uploadAudio(wavBytes, 'voice_message.wav');
      await send(overrideText: '', audioUrl: audioUrl);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't send that voice message — please try again.")),
      );
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lastAssistantMessage = messages.reversed.firstWhere(
      (m) => !m.isUser,
      orElse: () => const _ChatMessage(isUser: false, text: ''),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(
        title: l10n.nnangaTitle,
        colors: const [AppColors.ai, Color(0xFF6B4CE0)],
        titleWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: Image.asset(
                'assets/icons/nnanga_ai_icon_circle.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(l10n.nnangaTitle, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 3,
        onTap: (index) => handleTabTap(context, index),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
              child: FeaturedCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.15), shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: const Icon(Icons.gps_fixed, color: AppColors.secondary, size: 18),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Practice Mode', style: AppTypography.caption.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700)),
                          Text('Free Conversation', style: AppTypography.title.copyWith(fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: isLoadingHistory
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.ai),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: messages.length + (isSending ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= messages.length) {
                          return const _TypingBubble();
                        }
                        return _MessageBubble(
                          message: messages[index],
                          onExplain: () => send(overrideText: 'Explain: ${messages[index].text}'),
                          onTranslate: () => send(overrideText: 'Translate: ${messages[index].text}'),
                        );
                      },
                    ),
            ),
            if (!isSending && lastAssistantMessage.suggestedReplies.isNotEmpty)
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  children: lastAssistantMessage.suggestedReplies
                      .map(
                        (reply) => Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: ActionChip(
                            label: Text(reply, style: const TextStyle(fontSize: 12)),
                            backgroundColor: AppColors.ai.withValues(alpha: 0.1),
                            onPressed: () => send(overrideText: reply),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            if (isRecording)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: WaveformVisualizer(animate: true, height: 28, color: AppColors.ai),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: inputController,
                      onSubmitted: (_) => send(),
                      decoration: InputDecoration(
                        hintText: l10n.nnangaInputHint,
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  BouncyIconButton(
                    icon: Icon(
                      isRecording ? Icons.stop_circle : Icons.mic_none,
                      color: isRecording ? AppColors.error : AppColors.textSecondary,
                    ),
                    onPressed: isSending ? null : (isRecording ? _stopRecordingAndSend : _startRecording),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppGradients.ai,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ai.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: BouncyIconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: isSending ? null : () => send(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.onExplain,
    required this.onTranslate,
  });

  final _ChatMessage message;
  final VoidCallback onExplain;
  final VoidCallback onTranslate;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          gradient: isUser ? AppGradients.ai : null,
          color: isUser ? null : AppColors.surface,
          borderRadius: AppRadius.medium,
          boxShadow: isUser ? null : AppShadows.soft,
        ),
        child: isUser
            ? (message.audioUrl != null
                ? WaveformVisualizer(height: 24, color: Colors.white)
                : Text(
                    message.text,
                    style: AppTypography.body.copyWith(color: Colors.white),
                  ))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MarkdownBody(
                    data: message.text,
                    styleSheet: MarkdownStyleSheet(p: AppTypography.body),
                  ),
                  if (message.usedLocalKnowledge != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _GroundingBadge(usedLocalKnowledge: message.usedLocalKnowledge!),
                  ],
                  if (message.text.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      children: [
                        _MessageActionButton(label: 'Explain', onTap: onExplain),
                        _MessageActionButton(label: 'Translate', onTap: onTranslate),
                      ],
                    ),
                  ],
                  if (message.correction != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _InlineNote(icon: Icons.spellcheck, label: 'Correction', text: message.correction!),
                  ],
                  if (message.translation != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _InlineNote(icon: Icons.translate, label: 'Translation', text: message.translation!),
                  ],
                ],
              ),
      ),
    );
  }
}

class _MessageActionButton extends StatelessWidget {
  const _MessageActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _InlineNote extends StatelessWidget {
  const _InlineNote({required this.icon, required this.label, required this.text});

  final IconData icon;
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: AppRadius.small,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.secondary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(text, style: AppTypography.caption),
          ),
        ],
      ),
    );
  }
}

class _GroundingBadge extends StatelessWidget {
  const _GroundingBadge({required this.usedLocalKnowledge});

  final bool usedLocalKnowledge;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = usedLocalKnowledge ? AppColors.success : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            usedLocalKnowledge ? Icons.verified_outlined : Icons.public,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            usedLocalKnowledge ? l10n.nnangaGroundedBadge : l10n.nnangaGeneralBadge,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.medium,
          boxShadow: AppShadows.soft,
        ),
        child: SizedBox(
          width: 40,
          height: 24,
          child: Lottie.asset(
            'assets/lottie/nnanga_thinking.json',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ai),
            ),
          ),
        ),
      ),
    );
  }
}
