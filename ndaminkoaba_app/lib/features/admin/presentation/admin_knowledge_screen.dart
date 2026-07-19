import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/gradient_app_bar.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../data/knowledge_repository.dart';
import '../domain/knowledge_models.dart';

class AdminKnowledgeScreen extends StatelessWidget {
  const AdminKnowledgeScreen({super.key, required this.languageId, this.languageName});

  final String languageId;
  final String? languageName;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: GradientAppBar(
          title: 'Train the AI',
          colors: const [AppColors.ai, Color(0xFF6B4CE0)],
          actions: [
            IconButton(
              icon: const Icon(Icons.translate),
              tooltip: 'Manage vocabulary',
              onPressed: () => context.push(
                '/admin/languages/$languageId/management/vocabulary',
                extra: languageName,
              ),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Test Nnanga'),
              Tab(text: 'Learner Questions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _TestNnangaTab(languageId: languageId, languageName: languageName),
            const _RecentQuestionsTab(),
          ],
        ),
      ),
    );
  }
}

class _TestNnangaTab extends StatefulWidget {
  const _TestNnangaTab({required this.languageId, this.languageName});

  final String languageId;
  final String? languageName;

  @override
  State<_TestNnangaTab> createState() => _TestNnangaTabState();
}

class _TestNnangaTabState extends State<_TestNnangaTab> {
  final repository = KnowledgeRepository();
  final promptController = TextEditingController();
  bool isSending = false;
  NnangaTestResult? result;

  @override
  void dispose() {
    promptController.dispose();
    super.dispose();
  }

  Future<void> test() async {
    final prompt = promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() => isSending = true);
    try {
      final testResult = await repository.testNnanga(prompt, languageId: widget.languageId);
      if (!mounted) return;
      setState(() {
        result = testResult;
        isSending = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ask Nnanga a question exactly like a learner would, and see whether '
            'it found an answer in the knowledge base.',
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: promptController,
                  onSubmitted: (_) => test(),
                  decoration: InputDecoration(
                    hintText: 'e.g. What does Mbolo mean?',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              CircleAvatar(
                backgroundColor: AppColors.ai,
                child: IconButton(
                  icon: isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: isSending ? null : test,
                ),
              ),
            ],
          ),
          if (result != null) ...[
            const SizedBox(height: AppSpacing.xl),
            PremiumCard(
              color: result!.usedLocalKnowledge ? AppColors.success : AppColors.warning,
              child: Row(
                children: [
                  Icon(
                    result!.usedLocalKnowledge ? Icons.check_circle : Icons.warning_amber,
                    color: Colors.white,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      result!.usedLocalKnowledge
                          ? 'Answered from the knowledge base'
                          : 'No local knowledge found — Nnanga could not answer well',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nnanga\'s reply', style: AppTypography.caption),
                  const SizedBox(height: AppSpacing.sm),
                  Text(result!.response),
                  if (result!.matchedKeywords.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text('Matched keywords', style: AppTypography.caption),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: result!.matchedKeywords
                          .map((k) => Chip(label: Text(k, style: const TextStyle(fontSize: 11))))
                          .toList(),
                    ),
                  ],
                  if (!result!.usedLocalKnowledge) ...[
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: () => context.push(
                        '/admin/languages/${widget.languageId}/management/vocabulary',
                        extra: widget.languageName,
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Add knowledge for this'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentQuestionsTab extends StatefulWidget {
  const _RecentQuestionsTab();

  @override
  State<_RecentQuestionsTab> createState() => _RecentQuestionsTabState();
}

class _RecentQuestionsTabState extends State<_RecentQuestionsTab> {
  final repository = KnowledgeRepository();
  bool isLoading = true;
  List<NnangaConversation> conversations = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final result = await repository.getRecentConversations();
      if (!mounted) return;
      setState(() {
        conversations = result;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: ShimmerListLoader(itemCount: 3, itemHeight: 110),
      );
    }

    if (conversations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            'No learners have asked Nnanga anything yet.',
            style: AppTypography.caption,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: conversations.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final convo = conversations[index];
        return PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(convo.learnerName, style: AppTypography.title),
                  ),
                  Text(
                    DateFormat.MMMd().add_jm().format(convo.createdAt),
                    style: AppTypography.caption,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('"${convo.prompt}"', style: const TextStyle(fontStyle: FontStyle.italic)),
              const SizedBox(height: AppSpacing.sm),
              Text(convo.response, maxLines: 3, overflow: TextOverflow.ellipsis),
            ],
          ),
        );
      },
    );
  }
}
