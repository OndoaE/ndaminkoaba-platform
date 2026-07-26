import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/network/api_error.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/navigation/admin_shell.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../data/admin_repository.dart';
import '../domain/admin_models.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final repository = AdminRepository();

  List<AdminUser> allUsers = [];

  final broadcastTitleController = TextEditingController();
  final broadcastMessageController = TextEditingController();
  bool broadcastSending = false;

  final userTitleController = TextEditingController();
  final userMessageController = TextEditingController();
  AdminUser? selectedUser;
  bool userSending = false;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  @override
  void dispose() {
    broadcastTitleController.dispose();
    broadcastMessageController.dispose();
    userTitleController.dispose();
    userMessageController.dispose();
    super.dispose();
  }

  Future<void> loadUsers() async {
    try {
      final users = await repository.getUsers();
      if (!mounted) return;
      setState(() => allUsers = users);
    } catch (_) {
      // User picker degrades to empty options; broadcast still works.
    }
  }

  Future<void> sendBroadcast() async {
    final l10n = AppLocalizations.of(context);
    final title = broadcastTitleController.text.trim();
    final message = broadcastMessageController.text.trim();
    if (title.isEmpty || message.isEmpty) return;

    setState(() => broadcastSending = true);
    try {
      await repository.broadcastAnnouncement(title, message);
      if (!mounted) return;
      broadcastTitleController.clear();
      broadcastMessageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.adminBroadcastSentMessage)));
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(extractErrorMessage(e, fallback: l10n.adminCouldNotSendBroadcast))),
      );
    } finally {
      if (mounted) setState(() => broadcastSending = false);
    }
  }

  Future<void> sendToUser() async {
    final l10n = AppLocalizations.of(context);
    final user = selectedUser;
    final title = userTitleController.text.trim();
    final message = userMessageController.text.trim();
    if (user == null || title.isEmpty || message.isEmpty) return;

    setState(() => userSending = true);
    try {
      await repository.notifyUser(user.id, title, message);
      if (!mounted) return;
      userTitleController.clear();
      userMessageController.clear();
      setState(() => selectedUser = null);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.adminNotificationSentMessage)));
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(extractErrorMessage(e, fallback: l10n.adminCouldNotSendNotification))),
      );
    } finally {
      if (mounted) setState(() => userSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AdminShell(
      activeNavKey: 'notifications',
      title: l10n.adminNotificationsTitle,
      subtitle: l10n.adminNotificationsSubtitle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildBroadcastCard(l10n)),
          const SizedBox(width: AppSpacing.lg),
          Expanded(child: _buildNotifyUserCard(l10n)),
        ],
      ),
    );
  }

  Widget _buildBroadcastCard(AppLocalizations l10n) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign_outlined, color: AppColors.secondary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(l10n.adminBroadcastCardTitle, style: AppTypography.title.copyWith(fontSize: 16))),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.adminBroadcastCardDescription, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: broadcastTitleController,
            decoration: InputDecoration(labelText: l10n.adminNotificationTitleHint),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: broadcastMessageController,
            maxLines: 4,
            decoration: InputDecoration(labelText: l10n.adminNotificationMessageHint),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.secondary),
              onPressed: broadcastSending ? null : sendBroadcast,
              child: Text(broadcastSending ? l10n.adminSavingLabel : l10n.adminSendBroadcastButton),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifyUserCard(AppLocalizations l10n) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(l10n.adminNotifyUserCardTitle, style: AppTypography.title.copyWith(fontSize: 16))),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.adminNotifyUserCardDescription, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.md),
          Autocomplete<AdminUser>(
            displayStringForOption: (u) => '${u.fullName} (${u.email})',
            optionsBuilder: (textEditingValue) {
              final query = textEditingValue.text.trim().toLowerCase();
              if (query.isEmpty) return const Iterable<AdminUser>.empty();
              return allUsers.where(
                (u) => u.fullName.toLowerCase().contains(query) || u.email.toLowerCase().contains(query),
              );
            },
            onSelected: (u) => setState(() => selectedUser = u),
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: l10n.adminSearchUserHint,
                  prefixIcon: const Icon(Icons.search),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: AppRadius.small),
            child: Text(
              selectedUser == null
                  ? l10n.adminNoUserSelectedHint
                  : l10n.adminNotifyRecipientLine(selectedUser!.fullName, selectedUser!.email),
              style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: userTitleController,
            decoration: InputDecoration(labelText: l10n.adminNotificationTitleHint),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: userMessageController,
            maxLines: 4,
            decoration: InputDecoration(labelText: l10n.adminNotificationMessageHint),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: (userSending || selectedUser == null) ? null : sendToUser,
              child: Text(userSending ? l10n.adminSavingLabel : l10n.adminSendNotificationButton),
            ),
          ),
        ],
      ),
    );
  }
}
