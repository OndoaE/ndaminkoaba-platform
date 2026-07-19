import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';

class _Section {
  const _Section(this.title, this.subtitle, this.icon, this.color, this.routeSuffix);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  /// Appended to `/admin/languages/:languageId` to build the full route.
  final String routeSuffix;
}

const _sections = [
  _Section('Course Management', 'Create, edit, publish and delete courses',
      Icons.menu_book, AppColors.primary, '/management/courses'),
  _Section('Module Management', 'Organize each course into modules',
      Icons.view_module, Color(0xFF0D7A4C), '/management/modules'),
  _Section('Lesson Management', 'Author lesson content, in order',
      Icons.play_lesson, Color(0xFF3D6BE0), '/management/lessons'),
  _Section('Vocabulary Management', "Nnanga's knowledge base",
      Icons.translate, AppColors.ai, '/management/vocabulary'),
  _Section('Quiz Management', 'Quizzes, questions and answer keys',
      Icons.quiz, Color(0xFFB5312B), '/management/quizzes'),
  _Section('Bible Management', 'Upload USFM chapters and whole books',
      Icons.auto_stories, Color(0xFF8B3A3A), '/management/bible'),
  _Section('Daily Content Management', 'Daily Word and Daily Verse pools',
      Icons.auto_awesome, Color(0xFFC77B2E), '/management/daily'),
  _Section('Book Management', 'Upload PDF and EPUB books for learners',
      Icons.local_library, Color(0xFF5D4037), '/management/books'),
];

/// The 8 content-management sections for one language, reached from that
/// language's dashboard. Unchanged from the original single-language
/// version — just every route now carries [languageId].
class AdminContentHubScreen extends StatelessWidget {
  const AdminContentHubScreen({super.key, required this.languageId, this.languageName});

  final String languageId;
  final String? languageName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(languageName != null ? '$languageName Content' : 'Content Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Content Management',
                style: AppTypography.h1.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Manage every piece of learning content for this language.',
                style: AppTypography.caption,
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: ListView.separated(
                  itemCount: _sections.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final section = _sections[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => context.push(
                        '/admin/languages/$languageId${section.routeSuffix}',
                        extra: languageName,
                      ),
                      child: PremiumCard(
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [section.color, section.color.withValues(alpha: 0.7)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(section.icon, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(section.title, style: AppTypography.title),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(section.subtitle, style: AppTypography.caption),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
