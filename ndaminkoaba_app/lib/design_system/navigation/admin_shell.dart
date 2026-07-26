import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_config.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/services/storage_service.dart';
import '../../l10n/app_localizations.dart';
import '../../features/notifications/data/notifications_repository.dart';
import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';
import '../widgets/notifications_sheet.dart';
import 'admin_sidebar.dart';

/// Desktop-only web-admin shell — persistent left sidebar + top bar +
/// content area — replacing the old bottom-nav-bar admin chrome to match the
/// mockups' wide desktop layout. Admin tooling doesn't need the learner
/// app's mobile responsiveness, so narrow widths get an explicit
/// "use a wider screen" message rather than a squeezed layout.
class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({
    super.key,
    required this.activeNavKey,
    required this.title,
    this.subtitle,
    this.breadcrumbs,
    this.languageId,
    this.languageName,
    this.actions,
    required this.child,
  });

  final String activeNavKey;
  final String title;
  final String? subtitle;
  final List<String>? breadcrumbs;
  final String? languageId;
  final String? languageName;
  final List<Widget>? actions;
  final Widget child;

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  final notificationsRepository = NotificationsRepository();

  String? userName;
  String? userRole;
  String? avatarUrl;
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadUnreadCount();
  }

  Future<void> _loadUser() async {
    final name = await StorageService.getFullName();
    final role = await StorageService.getRole();
    final avatar = await StorageService.getAvatarUrl();
    if (!mounted) return;
    setState(() {
      userName = name;
      userRole = role;
      avatarUrl = avatar;
    });
  }

  Future<void> _openProfile() async {
    await context.push('/admin/profile');
    _loadUser();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final unread = await notificationsRepository.getMy(isRead: false);
      if (!mounted) return;
      setState(() => unreadCount = unread.length);
    } catch (_) {
      // Silently skip — the bell just shows with no badge.
    }
  }

  Future<void> _openNotifications() async {
    await NotificationsSheet.show(context);
    _loadUnreadCount();
  }

  void _toggleLocale() {
    final current = ref.read(localeProvider).languageCode;
    setAppLocale(ref, Locale(current == 'en' ? 'fr' : 'en'));
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider).languageCode;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 900) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.desktop_windows_outlined, size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.adminNeedsWiderScreen,
                      textAlign: TextAlign.center,
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.adminResizeBrowserMessage,
                      textAlign: TextAlign.center,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            );
          }

          return Row(
            children: [
              AdminSidebar(
                activeNavKey: widget.activeNavKey,
                languageId: widget.languageId,
                languageName: widget.languageName,
                userName: userName,
                userRole: userRole,
                userAvatarUrl: avatarUrl,
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        border: Border(bottom: BorderSide(color: AppColors.divider)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.breadcrumbs != null && widget.breadcrumbs!.isNotEmpty)
                                  Text(widget.breadcrumbs!.join(' / '), style: AppTypography.caption),
                                Text(widget.title, style: AppTypography.h2),
                                if (widget.subtitle != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(widget.subtitle!, style: AppTypography.caption),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          InkWell(
                            borderRadius: AppRadius.circle,
                            onTap: _openNotifications,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                                  if (unreadCount > 0)
                                    Positioned(
                                      right: -1,
                                      top: -1,
                                      child: Container(
                                        width: 9,
                                        height: 9,
                                        decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          InkWell(
                            borderRadius: AppRadius.circle,
                            onTap: _toggleLocale,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.divider),
                                borderRadius: AppRadius.circle,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    locale.toUpperCase(),
                                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12),
                                  ),
                                  const Icon(Icons.expand_more, size: 16, color: AppColors.primary),
                                ],
                              ),
                            ),
                          ),
                          if (widget.actions != null) ...[
                            const SizedBox(width: AppSpacing.md),
                            ...widget.actions!,
                          ],
                          const SizedBox(width: AppSpacing.md),
                          InkWell(
                            borderRadius: AppRadius.circle,
                            onTap: _openProfile,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primary,
                              backgroundImage: (avatarUrl?.isNotEmpty ?? false)
                                  ? NetworkImage(AppConfig.resolveUrl(avatarUrl!))
                                  : null,
                              child: (avatarUrl?.isNotEmpty ?? false)
                                  ? null
                                  : Text(
                                      (userName?.isNotEmpty ?? false) ? userName![0].toUpperCase() : '?',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: widget.child,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
