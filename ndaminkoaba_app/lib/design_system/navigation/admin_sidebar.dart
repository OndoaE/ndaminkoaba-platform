import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_config.dart';
import '../../l10n/app_localizations.dart';
import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';

class _NavItem {
  const _NavItem(this.key, this.label, this.icon, this.route);

  final String key;
  final String label;
  final IconData icon;
  final String route;
}

/// Persistent left sidebar for the admin web shell — a global nav-item list
/// when [languageId] is null, or a language-scoped one (plus a language
/// switcher pill) when it's set. Every item routes to a real, already-built
/// screen — items with no backing screen in this app (e.g. a fully separate
/// global "Content Library"/"Settings") are intentionally left out rather
/// than added as dead-end links.
class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    super.key,
    required this.activeNavKey,
    this.languageId,
    this.languageName,
    this.userName,
    this.userRole,
    this.userAvatarUrl,
  });

  final String activeNavKey;
  final String? languageId;
  final String? languageName;
  final String? userName;
  final String? userRole;
  final String? userAvatarUrl;

  List<_NavItem> _globalItems(AppLocalizations l10n) => [
    _NavItem(
      'overview',
      l10n.adminNavOverview,
      Icons.dashboard_outlined,
      '/admin',
    ),
    _NavItem(
      'languages',
      l10n.adminNavLanguages,
      Icons.language_outlined,
      '/admin/languages',
    ),
    _NavItem('users', l10n.adminNavUsers, Icons.people_outline, '/admin/users'),
    _NavItem(
      'notifications',
      l10n.adminNavNotifications,
      Icons.campaign_outlined,
      '/admin/notifications',
    ),
    _NavItem(
      'certificates',
      l10n.adminNavCertificates,
      Icons.workspace_premium_outlined,
      '/admin/certificates',
    ),
    _NavItem(
      'history',
      l10n.adminNavReportsActivity,
      Icons.bar_chart_outlined,
      '/admin/history',
    ),
  ];

  List<_NavItem> _languageItems(String id, AppLocalizations l10n) => [
    _NavItem(
      'dashboard',
      l10n.adminNavDashboard,
      Icons.dashboard_outlined,
      '/admin/languages/$id',
    ),
    _NavItem(
      'learners',
      l10n.adminNavLearners,
      Icons.people_outline,
      '/admin/users',
    ),
    _NavItem(
      'courses',
      l10n.adminNavCourses,
      Icons.menu_book_outlined,
      '/admin/languages/$id/management/courses',
    ),
    _NavItem(
      'lessons',
      l10n.adminNavLessonsContent,
      Icons.description_outlined,
      '/admin/languages/$id/management/lessons',
    ),
    _NavItem(
      'vocabulary',
      l10n.adminNavVocabulary,
      Icons.translate_outlined,
      '/admin/languages/$id/management/vocabulary',
    ),
    _NavItem(
      'assessments',
      l10n.adminNavAssessments,
      Icons.quiz_outlined,
      '/admin/languages/$id/management/quizzes',
    ),
    _NavItem(
      'ai_tutor',
      l10n.adminNavAiTutor,
      Icons.smart_toy_outlined,
      '/admin/languages/$id/knowledge',
    ),
    _NavItem(
      'bible',
      l10n.adminNavBible,
      Icons.auto_stories_outlined,
      '/admin/languages/$id/management/bible',
    ),
    _NavItem(
      'books',
      l10n.adminNavBooks,
      Icons.library_books_outlined,
      '/admin/languages/$id/management/books',
    ),
    _NavItem(
      'daily',
      l10n.adminNavDaily,
      Icons.auto_awesome_outlined,
      '/admin/languages/$id/management/daily',
    ),
    _NavItem(
      'certificates',
      l10n.adminNavCertificates,
      Icons.workspace_premium_outlined,
      '/admin/certificates',
    ),
    _NavItem(
      'reports',
      l10n.adminNavReports,
      Icons.bar_chart_outlined,
      '/admin/history',
    ),
    _NavItem(
      'settings',
      l10n.adminNavSettings,
      Icons.settings_outlined,
      '/admin/languages/$id',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = languageId != null
        ? _languageItems(languageId!, l10n)
        : _globalItems(l10n);

    return Container(
      width: 248,
      color: AppColors.primary,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/ndaminkoaba_logo.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.secondary,
                        child: Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'NdaMinkoaba Admin',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          l10n.appTagline,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (languageId != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: InkWell(
                  borderRadius: AppRadius.medium,
                  onTap: () => context.push('/admin/languages'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: AppRadius.medium,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.adminLanguageActiveSuffix(
                              languageName ?? l10n.adminLanguageFallback,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.expand_more,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                children: [
                  for (final item in items)
                    _SidebarTile(item: item, active: item.key == activeNavKey),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            if (languageId != null)
              _SidebarTile(
                item: _NavItem(
                  'back',
                  l10n.adminBackToAllLanguages,
                  Icons.arrow_back,
                  '/admin/languages',
                ),
                active: false,
              ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/admin/profile'),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        backgroundImage: (userAvatarUrl?.isNotEmpty ?? false)
                            ? NetworkImage(AppConfig.resolveUrl(userAvatarUrl!))
                            : null,
                        child: (userAvatarUrl?.isNotEmpty ?? false)
                            ? null
                            : Text(
                                (userName?.isNotEmpty ?? false)
                                    ? userName![0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              userName ?? l10n.adminRoleFallback,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              userRole ?? l10n.adminSuperAdminFallback,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({required this.item, required this.active});

  final _NavItem item;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: active ? AppColors.secondary : Colors.transparent,
        borderRadius: AppRadius.medium,
        child: InkWell(
          borderRadius: AppRadius.medium,
          onTap: () => context.go(item.route),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(item.icon, color: Colors.white, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body.copyWith(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
