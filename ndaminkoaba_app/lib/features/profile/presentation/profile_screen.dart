import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/storage_service.dart';
import '../../../design_system/buttons/primary_button.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/gradients/app_gradients.dart';
import '../../../design_system/inputs/premium_textfield.dart';
import '../../../design_system/navigation/app_bottom_navigation.dart';
import '../../../design_system/navigation/tab_navigation.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/gradient_hero_card.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../../courses/data/enrollment_repository.dart';
import '../../dashboard/data/dashboard_repository.dart';
import '../../dashboard/domain/dashboard_stats.dart';
import '../data/profile_repository.dart';
import '../domain/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final repository = ProfileRepository();
  final enrollmentRepository = EnrollmentRepository();
  final dashboardRepository = DashboardRepository();
  final fullNameController = TextEditingController();
  final passwordController = TextEditingController();

  UserProfile? profile;
  bool isLoading = true;
  bool isSaving = false;
  bool isEditing = false;
  int coursesEnrolled = 0;
  int certificatesEarned = 0;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final me = await repository.getMe();
      if (!mounted) return;
      setState(() {
        profile = me;
        fullNameController.text = me.fullName;
      });

      final results = await Future.wait([
        enrollmentRepository.getMyEnrollments(me.id),
        dashboardRepository.getLearnerDashboard(me.id),
      ]);

      if (!mounted) return;
      setState(() {
        coursesEnrolled = (results[0] as List).length;
        certificatesEarned = (results[1] as DashboardStats).certificates;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> save() async {
    final l10n = AppLocalizations.of(context);
    setState(() => isSaving = true);
    try {
      final updated = await repository.updateMe(
        fullName: fullNameController.text.trim(),
        password: passwordController.text.trim(),
      );
      await StorageService.saveFullName(updated.fullName);
      passwordController.clear();

      if (!mounted) return;
      setState(() {
        profile = updated;
        isSaving = false;
        isEditing = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.profileUpdatedMessage)));
    } catch (_) {
      if (!mounted) return;
      setState(() => isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.profileUpdateError)));
    }
  }

  Future<void> logout() async {
    await StorageService.logout();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 4,
        onTap: (index) => handleTabTap(context, index),
      ),
      body: SafeArea(
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: ShimmerListLoader(itemCount: 2, itemHeight: 160),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profileTitle,
                      style: AppTypography.h1.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    GradientHeroCard(
                      gradient: AppGradients.primary,
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
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
                              (profile?.fullName.isNotEmpty ?? false)
                                  ? profile!.fullName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            profile?.fullName ?? '',
                            style: AppTypography.title.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            profile?.email ?? '',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              profile?.role ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: _StatColumn(
                            value: '$coursesEnrolled',
                            label: l10n.statCoursesEnrolled,
                          ),
                        ),
                        const SizedBox(
                          height: 32,
                          child: VerticalDivider(color: AppColors.divider),
                        ),
                        Expanded(
                          child: _StatColumn(
                            value: '$certificatesEarned',
                            label: l10n.statCertificates,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    PremiumCard(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      child: Column(
                        children: [
                          _MenuRow(
                            icon: Icons.school_outlined,
                            label: l10n.myLearningTitle,
                            onTap: () => context.push('/my-learning'),
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _MenuRow(
                            icon: Icons.workspace_premium_outlined,
                            label: l10n.myCertificatesTitle,
                            onTap: () => context.push('/certificates'),
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _MenuRow(
                            icon: Icons.translate,
                            label: l10n.vocabularyTitle,
                            onTap: () => context.push('/vocabulary'),
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _MenuRow(
                            icon: Icons.language,
                            label: l10n.switchLanguageTitle,
                            onTap: () => context.push('/select-learning-language'),
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _MenuRow(
                            icon: Icons.edit_outlined,
                            label: l10n.editProfileTitle,
                            onTap: () => setState(() => isEditing = !isEditing),
                          ),
                        ],
                      ),
                    ),
                    if (isEditing) ...[
                      const SizedBox(height: AppSpacing.lg),
                      PremiumCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PremiumTextField(
                              label: l10n.fullNameLabel,
                              controller: fullNameController,
                              prefixIcon: Icons.person_outline,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            PremiumTextField(
                              label: l10n.newPasswordLabel,
                              hint: l10n.newPasswordHint,
                              controller: passwordController,
                              prefixIcon: Icons.lock_outline,
                              obscureText: true,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            PrimaryButton(
                              label: l10n.saveChangesButton,
                              isLoading: isSaving,
                              onPressed: save,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: logout,
                        icon: const Icon(Icons.logout, color: AppColors.error),
                        label: Text(
                          l10n.logOutButton,
                          style: const TextStyle(color: AppColors.error),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.lg,
                          ),
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.medium,
                          ),
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

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.h2.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTypography.caption, textAlign: TextAlign.center),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: AppRadius.small,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(label, style: AppTypography.body)),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
