import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/storage_service.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/widgets/logo_header.dart';
import '../../../l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    decideDestination();
  }

  Future<void> decideDestination() async {
    final results = await Future.wait([
      StorageService.getToken(),
      StorageService.getRole(),
      StorageService.getLanguageCode(),
      Future<void>.delayed(const Duration(seconds: 2)),
    ]);

    if (!mounted) return;

    final token = results[0] as String?;
    final role = results[1] as String?;
    final languageCode = results[2] as String?;

    if (languageCode == null) {
      context.go('/language-select');
      return;
    }

    if (token != null && token.isNotEmpty) {
      if (role == 'ADMIN') {
        context.go('/admin');
        return;
      }
      final learningLanguageId = await StorageService.getLearningLanguageId();
      if (!mounted) return;
      if (learningLanguageId == null) {
        context.go('/select-learning-language');
      } else {
        context.go('/continue-learning', extra: learningLanguageId);
      }
    } else {
      context.go('/login');
    }
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LogoHeader(
                title: l10n.appTitle,
                subtitle: l10n.appTagline,
                imagePath: 'assets/images/ndaminkoaba_logo.png',
                size: 140,
              ),
              const SizedBox(height: AppSpacing.xxl),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
