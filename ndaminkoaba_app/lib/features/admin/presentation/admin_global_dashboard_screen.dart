import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../core/services/storage_service.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/gradients/app_gradients.dart';
import '../../../design_system/navigation/app_admin_navigation.dart';
import '../../../design_system/navigation/tab_navigation.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/gradient_hero_card.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../data/admin_repository.dart';
import '../data/content_repository.dart';
import '../domain/admin_content_models.dart';
import '../domain/admin_models.dart';

/// The admin's landing screen — platform-wide, language-agnostic overview.
/// Every piece of learning content lives inside a specific language's own
/// dashboard (see [AdminLanguageDashboardScreen]); this screen is just the
/// index of which languages exist and the handful of truly global actions
/// (users, certificates, announcements, audit history).
class AdminGlobalDashboardScreen extends StatefulWidget {
  const AdminGlobalDashboardScreen({super.key});

  @override
  State<AdminGlobalDashboardScreen> createState() => _AdminGlobalDashboardScreenState();
}

class _AdminGlobalDashboardScreenState extends State<AdminGlobalDashboardScreen> {
  final adminRepository = AdminRepository();
  final contentRepository = ContentRepository();

  bool isLoading = true;
  AdminStats? stats;
  List<AdminLanguage> languages = [];
  String fullName = '';

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final results = await Future.wait([
        adminRepository.getStats(),
        contentRepository.getLanguages(),
        StorageService.getFullName(),
      ]);
      if (!mounted) return;
      setState(() {
        stats = results[0] as AdminStats;
        languages = results[1] as List<AdminLanguage>;
        fullName = (results[2] as String?) ?? 'Administrator';
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> logout() async {
    await StorageService.logout();
    if (!mounted) return;
    context.go('/login');
  }

  Future<void> _openAddLanguageDialog() async {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final countryController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name (e.g. Bassa)'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: 'Code (e.g. bas)'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: countryController,
              decoration: const InputDecoration(labelText: 'Country (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (nameController.text.trim().isEmpty || codeController.text.trim().isEmpty) return;

    try {
      await contentRepository.createLanguage(
        name: nameController.text.trim(),
        code: codeController.text.trim(),
        country: countryController.text.trim(),
      );
      load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Language added. It starts inactive — publish it once its content is ready.')),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(extractErrorMessage(e, fallback: 'Could not add language.'))),
      );
    }
  }

  Future<void> _openBroadcastDialog() async {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Broadcast Announcement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sends a notification to every learner on the platform.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (titleController.text.trim().isEmpty || messageController.text.trim().isEmpty) return;

    try {
      await adminRepository.broadcastAnnouncement(
        titleController.text.trim(),
        messageController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement sent to all learners.')),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(extractErrorMessage(e, fallback: 'Could not send announcement.'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: AppAdminNavigation(
        currentIndex: 0,
        onTap: (index) => handleAdminTabTap(context, index),
      ),
      body: SafeArea(
        child: isLoading
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: const ShimmerListLoader(itemCount: 5, itemHeight: 100),
              )
            : RefreshIndicator(
                onRefresh: load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroBanner(fullName: fullName, onLogout: logout),
                      const SizedBox(height: AppSpacing.xl),
                      Text('Quick Actions', style: AppTypography.title),
                      const SizedBox(height: AppSpacing.md),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 2.4,
                        children: [
                          _QuickAction(
                            icon: Icons.add_circle_outline,
                            label: 'Add Language',
                            color: AppColors.primary,
                            onTap: _openAddLanguageDialog,
                          ),
                          _QuickAction(
                            icon: Icons.person_add_outlined,
                            label: 'New User',
                            color: AppColors.secondary,
                            onTap: () async {
                              await context.push('/admin/users/new');
                              load();
                            },
                          ),
                          _QuickAction(
                            icon: Icons.campaign_outlined,
                            label: 'Announce',
                            color: AppColors.warning,
                            onTap: _openBroadcastDialog,
                          ),
                          _QuickAction(
                            icon: Icons.history,
                            label: 'History',
                            color: const Color(0xFF4B5FBD),
                            onTap: () => context.push('/admin/history'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text('Platform Stats', style: AppTypography.title),
                      const SizedBox(height: AppSpacing.md),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.72,
                        children: [
                          _StatCard(
                            icon: Icons.language,
                            label: 'Languages',
                            value: '${languages.length}',
                            color: AppColors.primary,
                          ),
                          _StatCard(
                            icon: Icons.people,
                            label: 'Users',
                            value: '${stats?.users ?? 0}',
                            color: AppColors.secondary,
                          ),
                          _StatCard(
                            icon: Icons.menu_book,
                            label: 'Courses',
                            value: '${stats?.courses ?? 0}',
                            color: const Color(0xFF0D7A4C),
                          ),
                          _StatCard(
                            icon: Icons.workspace_premium,
                            label: 'Certificates',
                            value: '${stats?.certificates ?? 0}',
                            color: AppColors.warning,
                          ),
                        ],
                      ),
                      if (stats != null && stats!.usersByRole.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xl),
                        Text('Users by Role', style: AppTypography.title),
                        const SizedBox(height: AppSpacing.md),
                        PremiumCard(
                          child: _RoleBreakdown(data: stats!.usersByRole),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Languages', style: AppTypography.title),
                          TextButton.icon(
                            onPressed: () => context.push('/admin/languages'),
                            icon: const Icon(Icons.settings_outlined, size: 18),
                            label: const Text('Manage'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (languages.isEmpty)
                        PremiumCard(
                          child: Text(
                            'No languages yet — add one to get started.',
                            style: AppTypography.caption,
                          ),
                        )
                      else
                        ...languages.map(
                          (language) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: InkWell(
                              borderRadius: AppRadius.large,
                              onTap: () => context.push(
                                '/admin/languages/${language.id}',
                                extra: language.name,
                              ),
                              child: PremiumCard(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: (language.isActive ? AppColors.primary : AppColors.textSecondary)
                                            .withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.language,
                                        color: language.isActive ? AppColors.primary : AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(language.name, style: AppTypography.title),
                                          Text(
                                            language.isActive ? 'Published to learners' : 'Draft — hidden from learners',
                                            style: AppTypography.caption,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.fullName, required this.onLogout});

  final String fullName;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'A';

    return GradientHeroCard(
      gradient: AppGradients.primary,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $fullName',
                  style: AppTypography.h2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Global overview — every language on NdaMinkoaba',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onLogout,
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Log out',
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: PremiumCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.title.copyWith(fontSize: 15),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.color = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.sm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTypography.h2, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(
            label,
            style: AppTypography.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _RoleBreakdown extends StatelessWidget {
  const _RoleBreakdown({required this.data});

  final Map<String, int> data;

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0, (a, b) => a + b);

    return Column(
      children: data.entries.map((entry) {
        final ratio = total == 0 ? 0.0 : entry.value / total;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                child: Text(entry.key, style: AppTypography.caption),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 12,
                    backgroundColor: AppColors.divider,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.secondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('${entry.value}', style: AppTypography.caption),
            ],
          ),
        );
      }).toList(),
    );
  }
}
