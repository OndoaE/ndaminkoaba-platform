import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../design_system/buttons/bouncy_icon_button.dart';
import '../../../design_system/buttons/google_sign_in_button.dart';
import '../../../design_system/buttons/primary_button.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/inputs/underline_field.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/widgets/auth_header.dart';
import '../../../design_system/widgets/or_divider.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_service.dart';
import 'post_login.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final authService = AuthService();

  bool obscurePassword = true;
  bool rememberMe = false;
  bool isLoading = false;
  bool googleLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final l10n = AppLocalizations.of(context);
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage(l10n.loginEmptyFieldsError);
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await authService.login(email: email, password: password);
      await saveLoginSession(result);

      if (!mounted) return;
      await navigateAfterLogin(context, result, showMessage: showMessage);
    } on DioException catch (e) {
      if (!mounted) return;
      showMessage(
        extractErrorMessage(
          e,
          fallback: AppLocalizations.of(context).loginFailedError,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      showMessage(AppLocalizations.of(context).commonSomethingWrong);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> handleGoogleIdToken(String idToken) async {
    final l10n = AppLocalizations.of(context);

    try {
      final result = await authService.exchangeGoogleIdToken(idToken);
      await saveLoginSession(result);

      if (!mounted) return;
      await navigateAfterLogin(context, result, showMessage: showMessage);
    } on DioException catch (e) {
      if (!mounted) return;
      showMessage(
        extractErrorMessage(e, fallback: l10n.oauthSignInFailedError),
      );
    } catch (e, stack) {
      if (!mounted) return;
      debugPrint('Google idToken exchange failed: $e\n$stack');
      showMessage('${l10n.commonSomethingWrong} ($e)');
    }
  }

  void handleGoogleError(Object error) {
    final l10n = AppLocalizations.of(context);
    debugPrint('Google sign-in failed: $error');

    if (error is OAuthNotConfiguredException) {
      showMessage(l10n.commonOAuthNotConfigured(error.provider));
    } else {
      showMessage('${l10n.commonSomethingWrong} ($error)');
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthHeader(title: l10n.appTitle, tagline: l10n.appTagline),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.loginButtonLabel,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  UnderlineField(
                    icon: Icons.email_outlined,
                    hint: l10n.emailLabel,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  UnderlineField(
                    icon: Icons.lock_outline,
                    hint: l10n.passwordLabel,
                    controller: passwordController,
                    obscureText: obscurePassword,
                    suffixIcon: BouncyIconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: rememberMe,
                          onChanged: (value) => setState(() => rememberMe = value ?? false),
                          side: const BorderSide(color: AppColors.secondary),
                          activeColor: AppColors.secondary,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(l10n.rememberMeLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const Spacer(),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => showMessage(l10n.comingSoonMessage),
                        child: Text(
                          l10n.forgotPasswordLabel,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    label: l10n.loginButtonLabel.toUpperCase(),
                    isLoading: isLoading,
                    onPressed: login,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const OrDivider(showLines: false),
                  const SizedBox(height: AppSpacing.lg),
                  GoogleSignInButton(
                    isLoading: googleLoading,
                    onLoadingChanged: (loading) => setState(
                      () => googleLoading = loading,
                    ),
                    onIdToken: handleGoogleIdToken,
                    onCancelled: () {},
                    onError: handleGoogleError,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(l10n.noAccountPrompt, style: const TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: Text(
                            l10n.registerLinkLabel,
                            style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
