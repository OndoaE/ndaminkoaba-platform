import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../config/app_config.dart';
import '../../../core/network/api_error.dart';
import '../../../core/services/storage_service.dart';
import '../../../design_system/buttons/primary_button.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/gradients/app_gradients.dart';
import '../../../design_system/inputs/premium_textfield.dart';
import '../../../design_system/navigation/admin_shell.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/user_profile.dart';

/// Distinct admin-facing equivalent of the learner `ProfileScreen` — built
/// inside [AdminShell] (so the sidebar gives a real way back to `/admin`,
/// fixing the dead-end where admins used to land on the learner profile with
/// no navigation out) and showing account-management info relevant to an
/// administrator instead of learner stats (courses/streaks/badges).
class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final repository = ProfileRepository();
  final fullNameController = TextEditingController();
  final passwordController = TextEditingController();

  UserProfile? profile;
  bool isLoading = true;
  bool isSaving = false;
  bool isEditing = false;
  bool isUploadingAvatar = false;

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
        isLoading = false;
      });
      if (me.profileImage != null && me.profileImage!.isNotEmpty) {
        await StorageService.saveAvatarUrl(me.profileImage!);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> save() async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated.')),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(extractErrorMessage(e, fallback: 'Could not update profile.'))),
      );
    }
  }

  Future<void> pickAndUploadAvatar() async {
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
        SnackBar(content: Text(extractErrorMessage(e, fallback: 'Could not upload photo.'))),
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
    return AdminShell(
      activeNavKey: '',
      title: 'My Profile',
      subtitle: 'Manage your administrator account',
      child: isLoading
          ? const ShimmerListLoader(itemCount: 3, itemHeight: 100)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIdentityCard(),
                const SizedBox(height: AppSpacing.lg),
                _buildAccountDetailsCard(),
                if (isEditing) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _buildEditCard(),
                ],
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: 220,
                  child: OutlinedButton.icon(
                    onPressed: logout,
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: const Text('Log Out', style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildIdentityCard() {
    final avatarUrl = profile?.profileImage;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppGradients.gold,
        borderRadius: AppRadius.extraLarge,
        boxShadow: [
          BoxShadow(color: AppColors.secondary.withValues(alpha: 0.3), blurRadius: 28, offset: const Offset(0, 14)),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                  image: (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? DecorationImage(image: NetworkImage(AppConfig.resolveUrl(avatarUrl)), fit: BoxFit.cover)
                      : null,
                ),
                alignment: Alignment.center,
                child: (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? null
                    : Text(
                        (profile?.fullName.isNotEmpty ?? false) ? profile!.fullName[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: InkWell(
                  borderRadius: AppRadius.circle,
                  onTap: isUploadingAvatar ? null : pickAndUploadAvatar,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: isUploadingAvatar
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile?.fullName ?? '', style: AppTypography.h2.copyWith(color: Colors.white)),
                const SizedBox(height: 2),
                Text(profile?.email ?? '', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_outlined, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        profile?.role == 'ADMIN' ? 'Administrator' : (profile?.role ?? ''),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => isEditing = !isEditing),
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetailsCard() {
    final cert = profile;
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account Details', style: AppTypography.title.copyWith(fontSize: 16)),
          const SizedBox(height: AppSpacing.md),
          _DetailRow(label: 'Member Since', value: cert?.createdAt != null ? DateFormat.yMMMMd().format(cert!.createdAt!) : '—'),
          const Divider(height: AppSpacing.lg),
          _DetailRow(label: 'Last Login', value: cert?.lastLogin != null ? DateFormat.yMMMd().add_jm().format(cert!.lastLogin!) : 'This session'),
          const Divider(height: AppSpacing.lg),
          Row(
            children: [
              Text('Account Status', style: AppTypography.caption),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: (cert?.isActive ?? true) ? AppColors.success.withValues(alpha: 0.12) : AppColors.error.withValues(alpha: 0.12),
                  borderRadius: AppRadius.circle,
                ),
                child: Text(
                  (cert?.isActive ?? true) ? 'Active' : 'Deactivated',
                  style: TextStyle(
                    color: (cert?.isActive ?? true) ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditCard() {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit Profile', style: AppTypography.title.copyWith(fontSize: 16)),
          const SizedBox(height: AppSpacing.lg),
          PremiumTextField(
            label: 'Full Name',
            controller: fullNameController,
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: AppSpacing.lg),
          PremiumTextField(
            label: 'New Password',
            hint: 'Leave blank to keep current password',
            controller: passwordController,
            prefixIcon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(label: 'Save Changes', isLoading: isSaving, onPressed: save),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTypography.caption),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: AppTypography.title.copyWith(fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
