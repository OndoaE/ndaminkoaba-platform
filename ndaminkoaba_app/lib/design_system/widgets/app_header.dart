import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale/locale_provider.dart';
import '../../features/notifications/data/notifications_repository.dart';
import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';
import 'notifications_sheet.dart';

/// Consistent header used across every learner screen: circular logo (and
/// an optional back button on pushed screens), title + subtitle, a
/// notification bell with a real unread-count dot, and a language pill.
/// Home/Practice (bottom-nav tab roots) additionally show a profile avatar
/// shortcut.
class AppHeader extends ConsumerStatefulWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.showAvatar = false,
    this.trailing,
  });

  final String title;
  final String? subtitle;

  /// When set, a back chevron is shown alongside the logo (pushed screens).
  final VoidCallback? onBack;

  /// Shows a profile-shortcut avatar next to the bell (tab-root screens).
  final bool showAvatar;

  /// Extra action shown right after the title (e.g. a bookmark toggle on
  /// the lesson screen), before the bell/avatar/locale controls.
  final Widget? trailing;

  @override
  ConsumerState<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends ConsumerState<AppHeader> {
  final notificationsRepository = NotificationsRepository();
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
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

    return Row(
      children: [
        if (widget.onBack != null) ...[
          InkWell(
            borderRadius: AppRadius.circle,
            onTap: widget.onBack,
            child: const Padding(
              padding: EdgeInsets.only(right: AppSpacing.sm),
              child: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
          ),
        ],
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/images/ndaminkoaba_logo.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(Icons.school, color: Colors.white, size: 20),
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
                widget.title,
                style: AppTypography.title.copyWith(fontWeight: FontWeight.w800),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.subtitle != null)
                Text(
                  widget.subtitle!,
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        if (widget.trailing != null) ...[
          widget.trailing!,
          const SizedBox(width: AppSpacing.xs),
        ],
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
        if (widget.showAvatar) ...[
          const SizedBox(width: AppSpacing.xs),
          InkWell(
            borderRadius: AppRadius.circle,
            onTap: () => context.push('/profile'),
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ),
        ],
        const SizedBox(width: AppSpacing.xs),
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
      ],
    );
  }
}
