import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../config/app_config.dart';
import '../../../core/network/api_error.dart';
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
import '../../../design_system/widgets/app_header.dart';
import '../../../design_system/widgets/gradient_hero_card.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../../badges/data/badges_repository.dart';
import '../../badges/domain/badge_entry.dart';
import '../../courses/data/enrollment_repository.dart';
import '../../dashboard/data/dashboard_repository.dart';
import '../../dashboard/domain/dashboard_stats.dart';
import '../../streaks/data/streaks_repository.dart';
import '../../streaks/domain/streak_stats.dart';
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
  final streaksRepository = StreaksRepository();
  final badgesRepository = BadgesRepository();
  final fullNameController = TextEditingController();
  final passwordController = TextEditingController();

  UserProfile? profile;
  bool isLoading = true;
  bool isSaving = false;
  bool isEditing = false;
  bool isUploadingAvatar = false;
  int coursesEnrolled = 0;
  int certificatesEarned = 0;
  int longestStreak = 0;
  int badgesEarned = 0;

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
        streaksRepository.getMe(),
        badgesRepository.getBadges(),
      ]);

      if (!mounted) return;
      setState(() {
        coursesEnrolled = (results[0] as List).length;
        certificatesEarned = (results[1] as DashboardStats).certificates;
        longestStreak = (results[2] as StreakStats).longestStreak;
        badgesEarned = (results[3] as List<BadgeEntry>).where((b) => b.earned).length;
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

  Future<void> pickAndUploadAvatar() async {
    final l10n = AppLocalizations.of(context);
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (picked == null) return;
    if (!mounted) return;
    final Uint8List bytes = await picked.readAsBytes();
    setState(() => isUploadingAvatar = true);
    try {
      final url = await repository.uploadAvatar(bytes, picked.name);
      final updated = await repository.updateMe(profileImage: url);
      await StorageService.saveAvatarUrl(url);
      if (!mounted) return;
      setState(() {
        profile = updated;
        isUploadingAvatar = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => isUploadingAvatar = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(extractErrorMessage(e, fallback: l10n.couldNotUploadPhotoError))),
      );
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
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xl,
                  AppSpacing.xl,
                  AppSpacing.giant,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppHeader(title: l10n.profileTitle, showAvatar: false),
                    const SizedBox(height: AppSpacing.xl),
                    GradientHeroCard(
                      gradient: AppGradients.primary,
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
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
                                  image: (profile?.profileImage?.isNotEmpty ?? false)
                                      ? DecorationImage(
                                          image: NetworkImage(AppConfig.resolveUrl(profile!.profileImage!)),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: (profile?.profileImage?.isNotEmpty ?? false)
                                    ? null
                                    : Text(
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
                              Positioned(
                                right: -2,
                                bottom: -2,
                                child: InkWell(
                                  borderRadius: AppRadius.circle,
                                  onTap: isUploadingAvatar ? null : pickAndUploadAvatar,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    alignment: Alignment.center,
                                    child: isUploadingAvatar
                                        ? const SizedBox(
                                            width: 10,
                                            height: 10,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                          )
                                        : Tooltip(
                                            message: l10n.uploadPhotoTooltip,
                                            child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                                          ),
                                  ),
                                ),
                              ),
                            ],
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
                        const SizedBox(
                          height: 32,
                          child: VerticalDivider(color: AppColors.divider),
                        ),
                        Expanded(
                          child: _StatColumn(
                            value: '$longestStreak',
                            label: 'Best Streak',
                          ),
                        ),
                        const SizedBox(
                          height: 32,
                          child: VerticalDivider(color: AppColors.divider),
                        ),
                        Expanded(
                          child: _StatColumn(
                            value: '$badgesEarned',
                            label: 'Badges',
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
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, style: AppTypography.caption, maxLines: 1, textAlign: TextAlign.center),
        ),
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
