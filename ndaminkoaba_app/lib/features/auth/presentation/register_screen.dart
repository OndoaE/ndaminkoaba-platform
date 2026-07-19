import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../design_system/buttons/google_sign_in_button.dart';
import '../../../design_system/buttons/oauth_button.dart';
import '../../../design_system/buttons/primary_button.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/inputs/premium_textfield.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/logo_header.dart';
import '../../../design_system/widgets/or_divider.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_service.dart';
import 'post_login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final authService = AuthService();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;
  OAuthProvider? oauthLoading;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    final l10n = AppLocalizations.of(context);
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showMessage(l10n.registerFillAllFieldsError);
      return;
    }

    if (password != confirmPassword) {
      showMessage(l10n.passwordsDoNotMatchError);
      return;
    }

    if (password.length < 8 ||
        !RegExp(r'[A-Za-z]').hasMatch(password) ||
        !RegExp(r'[0-9]').hasMatch(password)) {
      showMessage(l10n.passwordTooWeakError);
      return;
    }

    setState(() => isLoading = true);

    try {
      await authService.register(
        fullName: fullName,
        email: email,
        password: password,
      );

      if (!mounted) return;

      showMessage(l10n.registerSuccessMessage);
      context.go('/login');
    } on DioException catch (e) {
      if (!mounted) return;
      showMessage(extractErrorMessage(e, fallback: l10n.registerFailedError));
    } catch (_) {
      if (!mounted) return;
      showMessage(l10n.commonSomethingWrong);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // Facebook only — Google sign-in is fully handled by GoogleSignInButton,
  // since its web flow can't be driven from an awaited Future the way this
  // method drives Facebook's (see google_sign_in_button.dart).
  Future<void> registerWithFacebook() async {
    final l10n = AppLocalizations.of(context);
    setState(() => oauthLoading = OAuthProvider.facebook);

    try {
      final result = await authService.loginWithFacebook();
      await saveLoginSession(result);

      if (!mounted) return;
      await navigateAfterLogin(context, result, showMessage: showMessage);
    } on OAuthCancelledException {
      // Learner backed out of the picker — nothing to show.
    } on OAuthNotConfiguredException catch (e) {
      showMessage(l10n.commonOAuthNotConfigured(e.provider));
    } on DioException catch (e) {
      if (!mounted) return;
      showMessage(
        extractErrorMessage(e, fallback: l10n.oauthSignInFailedError),
      );
    } catch (e, stack) {
      if (!mounted) return;
      debugPrint('Facebook sign-in failed: $e\n$stack');
      showMessage('${l10n.commonSomethingWrong} ($e)');
    } finally {
      if (mounted) {
        setState(() => oauthLoading = null);
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFEAD9), AppColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  children: [
                    LogoHeader(
                      title: l10n.appTitle,
                      subtitle: l10n.appTagline,
                      imagePath: 'assets/images/ndaminkoaba_logo.png',
                      size: 120,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    PremiumCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.createAccountTitle,
                            style: AppTypography.h2,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.registerSubtitle,
                            style: AppTypography.caption,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          PremiumTextField(
                            label: l10n.fullNameLabel,
                            hint: l10n.fullNameHint,
                            controller: fullNameController,
                            prefixIcon: Icons.person_outline,
                            keyboardType: TextInputType.name,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          PremiumTextField(
                            label: l10n.emailLabel,
                            hint: l10n.emailHint,
                            controller: emailController,
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          PremiumTextField(
                            label: l10n.passwordLabel,
                            hint: l10n.passwordHint,
                            controller: passwordController,
                            prefixIcon: Icons.lock_outline,
                            obscureText: obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          PremiumTextField(
                            label: l10n.confirmPasswordLabel,
                            hint: l10n.confirmPasswordHint,
                            controller: confirmPasswordController,
                            prefixIcon: Icons.lock_outline,
                            obscureText: obscureConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscureConfirmPassword =
                                      !obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          PrimaryButton(
                            label: l10n.registerButtonLabel,
                            isLoading: isLoading,
                            onPressed: register,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          const OrDivider(),
                          const SizedBox(height: AppSpacing.lg),
                          GoogleSignInButton(
                            isLoading: oauthLoading == OAuthProvider.google,
                            onLoadingChanged: (loading) => setState(
                              () => oauthLoading =
                                  loading ? OAuthProvider.google : null,
                            ),
                            onIdToken: handleGoogleIdToken,
                            onCancelled: () {},
                            onError: handleGoogleError,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          OAuthButton(
                            provider: OAuthProvider.facebook,
                            isLoading: oauthLoading == OAuthProvider.facebook,
                            onPressed: registerWithFacebook,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  l10n.alreadyHaveAccountPrompt,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go('/login'),
                                child: Text(l10n.loginLinkLabel),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
