import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/language/learning_language_provider.dart';
import '../../../core/network/api_error.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/gradients/app_gradients.dart';
import '../../../design_system/navigation/app_bottom_navigation.dart';
import '../../../design_system/navigation/tab_navigation.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/shadows/app_shadows.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/gradient_app_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../data/nnanga_repository.dart';

class _ChatMessage {
  const _ChatMessage({required this.isUser, required this.text, this.usedLocalKnowledge});

  final bool isUser;
  final String text;

  /// Only set for bot replies sent live in this session (the history
  /// endpoint doesn't persist this signal) — null means "unknown", not
  /// "general knowledge", so the badge is hidden rather than shown wrong.
  final bool? usedLocalKnowledge;
}

class NnangaScreen extends ConsumerStatefulWidget {
  const NnangaScreen({super.key});

  @override
  ConsumerState<NnangaScreen> createState() => _NnangaScreenState();
}

class _NnangaScreenState extends ConsumerState<NnangaScreen> {
  final repository = NnangaRepository();
  final inputController = TextEditingController();
  final scrollController = ScrollController();

  final List<_ChatMessage> messages = [];
  bool _initialized = false;
  bool isLoadingHistory = true;

  bool isSending = false;

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
            messages.add(_ChatMessage(isUser: false, text: turn.response));
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
    super.dispose();
  }

  Future<void> send() async {
    final text = inputController.text.trim();
    if (text.isEmpty || isSending) return;

    setState(() {
      messages.add(_ChatMessage(isUser: true, text: text));
      isSending = true;
      inputController.clear();
    });
    _scrollToEnd();

    try {
      final result = await repository.sendMessage(
        text,
        languageId: ref.read(currentLearningLanguageProvider),
      );
      if (!mounted) return;
      setState(() {
        messages.add(
          _ChatMessage(
            isUser: false,
            text: result.response,
            usedLocalKnowledge: result.usedLocalKnowledge,
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
                        return _MessageBubble(message: messages[index]);
                      },
                    ),
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
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: isSending ? null : send,
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
  const _MessageBubble({required this.message});

  final _ChatMessage message;

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
            ? Text(
                message.text,
                style: AppTypography.body.copyWith(color: Colors.white),
              )
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
                ],
              ),
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
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ai),
        ),
      ),
    );
  }
}
