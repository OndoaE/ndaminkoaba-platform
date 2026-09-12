import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/locale_provider.dart';
import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../spacing/app_spacing.dart';

/// Shared top section for the Login and Signup screens — the app
/// logo/wordmark pinned top-left, and a language pill pinned top-right.
class AuthHeader extends ConsumerWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.tagline,
    this.large = false,
  });

  final bool large;
  final String title;
  final String tagline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider).languageCode;
    final expanded = large && MediaQuery.sizeOf(context).width >= 650;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: Image.asset(
            'assets/images/ndaminkoaba_logo.png',
            width: expanded ? 80 : 48,
            height: expanded ? 80 : 48,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.school, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  maxLines: 1,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: expanded ? 28 : 22,
                  ),
                ),
              ),
              Text(
                tagline,
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: expanded ? 15 : 12,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          borderRadius: AppRadius.circle,
          onTap: () => setAppLocale(ref, Locale(locale == 'en' ? 'fr' : 'en')),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.divider),
              borderRadius: AppRadius.circle,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  locale.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const Icon(
                  Icons.expand_more,
                  size: 18,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
