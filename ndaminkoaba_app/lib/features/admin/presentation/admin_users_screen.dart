import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/navigation/app_admin_navigation.dart';
import '../../../design_system/navigation/tab_navigation.dart';
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

  @override
  void initState() {
    super.initState();
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
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not update role.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: AppAdminNavigation(
        currentIndex: 1,
        onTap: (index) => handleAdminTabTap(context, index),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('New User', style: TextStyle(color: Colors.white)),
        onPressed: () async {
          await context.push('/admin/users/new');
          load();
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Users',
                style: AppTypography.h1.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
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
              Expanded(
                child: isLoading
                    ? const ShimmerListLoader()
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: users.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) => _UserRow(
                          user: users[index],
                          onToggleActive: toggleActive,
                          onSetRole: setRole,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.user,
    required this.onToggleActive,
    required this.onSetRole,
  });

  final AdminUser user;
  final void Function(AdminUser) onToggleActive;
  final void Function(AdminUser, String) onSetRole;

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
              } else {
                onSetRole(user, value);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle',
                child: Text(user.isActive ? 'Deactivate' : 'Activate'),
              ),
              if (user.role != 'ADMIN')
                const PopupMenuItem(
                  value: 'ADMIN',
                  child: Text('Make Administrator'),
                ),
              if (user.role != 'LEARNER')
                const PopupMenuItem(
                  value: 'LEARNER',
                  child: Text('Make Learner'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
