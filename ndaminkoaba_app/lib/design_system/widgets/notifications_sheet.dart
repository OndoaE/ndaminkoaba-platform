import 'package:flutter/material.dart';

import '../../features/notifications/data/notifications_repository.dart';
import '../../features/notifications/domain/notification_entry.dart';
import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';

/// Opened from the bell icon in [AppHeader]. Shows the learner's recent
/// notifications (real data from `GET /notifications`) and marks one as
/// read when tapped.
class NotificationsSheet extends StatefulWidget {
  const NotificationsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationsSheet(),
    );
  }

  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  final repository = NotificationsRepository();
  bool isLoading = true;
  List<NotificationEntry> notifications = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final items = await repository.getMy();
      if (!mounted) return;
      setState(() {
        notifications = items;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> _markRead(NotificationEntry entry) async {
    if (entry.isRead) return;
    try {
      await repository.markAsRead(entry.id);
      load();
    } catch (_) {
      // Best-effort.
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            )),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text('Notifications', style: AppTypography.title),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : notifications.isEmpty
                      ? Center(
                          child: Text('No notifications yet.', style: AppTypography.caption),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final entry = notifications[index];
                            return InkWell(
                              borderRadius: AppRadius.medium,
                              onTap: () => _markRead(entry),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: entry.isRead ? AppColors.surface : AppColors.secondary.withValues(alpha: 0.1),
                                  borderRadius: AppRadius.medium,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!entry.isRead)
                                      Container(
                                        margin: const EdgeInsets.only(top: 6, right: AppSpacing.sm),
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.secondary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(entry.title, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
                                          const SizedBox(height: 2),
                                          Text(entry.message, style: AppTypography.caption),
                                        ],
                                      ),
                                    ),
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
    );
  }
}
