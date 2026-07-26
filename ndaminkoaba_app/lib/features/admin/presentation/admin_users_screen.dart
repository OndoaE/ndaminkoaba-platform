import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../core/services/storage_service.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/navigation/admin_shell.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../data/admin_repository.dart';
import '../domain/admin_models.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final repository = AdminRepository();
  final searchController = TextEditingController();

  bool isLoading = true;
  List<AdminUser> users = [];
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    StorageService.getUserId().then((id) {
      if (mounted) setState(() => currentUserId = id);
    });
    load();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final result = await repository.getUsers(
        search: searchController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        users = result;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> toggleActive(AdminUser user) async {
    try {
      await repository.setUserActive(user.id, !user.isActive);
      load();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(extractErrorMessage(e, fallback: 'Could not update user.'))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not update user.')));
    }
  }

  Future<void> setRole(AdminUser user, String role) async {
    try {
      await repository.setUserRole(user.id, role);
      load();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(extractErrorMessage(e, fallback: 'Could not update role.'))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not update role.')));
    }
  }

  Future<void> deleteUser(AdminUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Permanently delete ${user.fullName}? This cannot be undone. Users with existing courses, progress, or other linked records cannot be deleted — deactivate them instead.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    try {
      await repository.deleteUser(user.id);
      load();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(extractErrorMessage(e, fallback: 'Could not delete user.'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      activeNavKey: 'users',
      title: 'Users',
      subtitle: '${users.length} total',
      actions: [
        FilledButton.icon(
          onPressed: () async {
            await context.push('/admin/users/new');
            load();
          },
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          icon: const Icon(Icons.person_add, size: 18),
          label: const Text('New User'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
            onSubmitted: (_) => load(),
            decoration: InputDecoration(
              hintText: 'Search by name or email...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (isLoading)
            const ShimmerListLoader()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) => _UserRow(
                user: users[index],
                isSelf: users[index].id == currentUserId,
                onToggleActive: toggleActive,
                onSetRole: setRole,
                onDelete: deleteUser,
              ),
            ),
        ],
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.user,
    required this.isSelf,
    required this.onToggleActive,
    required this.onSetRole,
    required this.onDelete,
  });

  final AdminUser user;
  final bool isSelf;
  final void Function(AdminUser) onToggleActive;
  final void Function(AdminUser, String) onSetRole;
  final void Function(AdminUser) onDelete;

  Color _roleColor() {
    switch (user.role) {
      case 'ADMIN':
        return AppColors.secondary;
      case 'TEACHER':
        return const Color(0xFF3D6BE0);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _roleColor();

    return PremiumCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [roleColor, roleColor.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName, style: AppTypography.title),
                Text(user.email, style: AppTypography.caption),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Chip(
                      label: Text(
                        user.role,
                        style: const TextStyle(fontSize: 11),
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: roleColor.withValues(alpha: 0.15),
                      labelStyle: TextStyle(color: roleColor),
                      side: BorderSide.none,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: user.isActive
                            ? AppColors.success
                            : AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        user.isActive ? 'Active' : 'Deactivated',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: user.isActive
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'toggle') {
                onToggleActive(user);
              } else if (value == 'delete') {
                onDelete(user);
              } else {
                onSetRole(user, value);
              }
            },
            itemBuilder: (context) => [
              if (!isSelf)
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(user.isActive ? 'Deactivate' : 'Activate'),
                ),
              if (!isSelf && user.role != 'ADMIN')
                const PopupMenuItem(
                  value: 'ADMIN',
                  child: Text('Make Administrator'),
                ),
              if (!isSelf && user.role != 'TEACHER')
                const PopupMenuItem(
                  value: 'TEACHER',
                  child: Text('Make Teacher'),
                ),
              if (!isSelf && user.role != 'LEARNER')
                const PopupMenuItem(
                  value: 'LEARNER',
                  child: Text('Make Learner'),
                ),
              if (!isSelf)
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: AppColors.error)),
                ),
              if (isSelf)
                const PopupMenuItem(
                  enabled: false,
                  child: Text('This is your account'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
