import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/network/api_error.dart';
import '../../../design_system/buttons/primary_button.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/inputs/premium_textfield.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/gradient_app_bar.dart';
import '../data/admin_repository.dart';

const _roles = ['LEARNER', 'ADMIN'];

class AdminCreateUserScreen extends StatefulWidget {
  const AdminCreateUserScreen({super.key});

  @override
  State<AdminCreateUserScreen> createState() => _AdminCreateUserScreenState();
}

class _AdminCreateUserScreenState extends State<AdminCreateUserScreen> {
  final repository = AdminRepository();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String role = 'LEARNER';
  bool isSaving = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> submit() async {
    if (fullNameController.text.trim().isEmpty) {
      _showMessage('Enter a full name.');
      return;
    }
    if (!emailController.text.contains('@')) {
      _showMessage('Enter a valid email.');
      return;
    }
    if (passwordController.text.length < 8 ||
        !RegExp(r'[A-Za-z]').hasMatch(passwordController.text) ||
        !RegExp(r'[0-9]').hasMatch(passwordController.text)) {
      _showMessage('Password must be 8+ characters with a letter and a number.');
      return;
    }

    setState(() => isSaving = true);
    try {
      await repository.createUser(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        role: role,
      );
      if (!mounted) return;
      _showMessage('User created.');
      Navigator.pop(context);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not create user.'));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(title: 'New User'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create a new account', style: AppTypography.title),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'This creates a fully active account with the chosen role — '
                  'no email verification step, so double-check the address.',
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.lg),
                PremiumTextField(
                  label: 'Full Name',
                  controller: fullNameController,
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: AppSpacing.lg),
                PremiumTextField(
                  label: 'Email',
                  controller: emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.lg),
                PremiumTextField(
                  label: 'Temporary Password',
                  controller: passwordController,
                  prefixIcon: Icons.lock_outline,
                  obscureText: obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    ),
                    onPressed: () => setState(() => obscurePassword = !obscurePassword),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Role', style: AppTypography.caption),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: _roles
                      .map(
                        (r) => ChoiceChip(
                          label: Text(r),
                          selected: role == r,
                          onSelected: (_) => setState(() => role = r),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: role == r ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: 'Create User',
                  isLoading: isSaving,
                  onPressed: submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
