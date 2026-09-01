import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/navigation/admin_shell.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../data/content_repository.dart';
import '../domain/admin_content_models.dart';

const _languageAccent = [Color(0xFF1B4332), Color(0xFF3E6659)];

/// Full list of every language on the platform (active and draft), reached
/// from the Global Dashboard's "Manage" link or its bottom-nav Languages
/// tab. Add/deactivate/delete happen here; tapping a row opens that
/// language's own admin dashboard.
class AdminLanguageManagementScreen extends StatefulWidget {
  const AdminLanguageManagementScreen({super.key});

  @override
  State<AdminLanguageManagementScreen> createState() => _AdminLanguageManagementScreenState();
}

class _AdminLanguageManagementScreenState extends State<AdminLanguageManagementScreen> {
  final repository = ContentRepository();
  List<AdminLanguage> languages = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final result = await repository.getLanguages();
      setState(() {
        languages = result;
        isLoading = false;
      });
    } on DioException catch (e) {
      setState(() {
        error = extractErrorMessage(e, fallback: l10n.adminLangMgmtLoadError);
        isLoading = false;
      });
    }
  }

  Future<void> _toggleActive(AdminLanguage language) async {
    final l10n = AppLocalizations.of(context);
    try {
      await repository.setLanguageActive(language.id, !language.isActive);
      load();
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminLangMgmtUpdateError));
    }
  }

  Future<void> _delete(AdminLanguage language) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.adminLangMgmtDeleteTitle),
          content: Text(l10n.adminLangMgmtDeleteBody(language.name)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.adminLangMgmtCancel)),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.adminLangMgmtDelete, style: const TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    try {
      await repository.deleteLanguage(language.id);
      load();
      _showMessage(l10n.adminLangMgmtDeletedMessage);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminLangMgmtDeleteError));
    }
  }

  Future<void> _openAddDialog() async {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final countryController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.adminLangMgmtAddTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: l10n.adminLangMgmtNameLabel),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: codeController,
                decoration: InputDecoration(labelText: l10n.adminLangMgmtCodeLabel),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: countryController,
                decoration: InputDecoration(labelText: l10n.adminLangMgmtCountryLabel),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.adminLangMgmtCancel)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.adminLangMgmtAdd)),
          ],
        );
      },
    );

    if (confirmed != true) return;
    if (nameController.text.trim().isEmpty || codeController.text.trim().isEmpty) return;

    try {
      await repository.createLanguage(
        name: nameController.text.trim(),
        code: codeController.text.trim(),
        country: countryController.text.trim(),
      );
      load();
      _showMessage(l10n.adminLangMgmtAddedMessage);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminLangMgmtAddError));
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AdminShell(
      activeNavKey: 'languages',
      title: l10n.adminLangMgmtTitle,
      subtitle: l10n.adminLangMgmtSubtitleCount(languages.length),
      actions: [
        FilledButton.icon(
          onPressed: _openAddDialog,
          style: FilledButton.styleFrom(backgroundColor: _languageAccent[0]),
          icon: const Icon(Icons.add, size: 18),
          label: Text(l10n.adminLangMgmtAddTitle),
        ),
      ],
      child: isLoading
          ? const ShimmerListLoader(itemCount: 5, itemHeight: 76)
          : error != null
              ? EmptyState(icon: Icons.error_outline, title: l10n.adminLangMgmtErrorTitle, message: error)
              : languages.isEmpty
                  ? EmptyState(
                      icon: Icons.language_outlined,
                      title: l10n.adminLangMgmtEmptyTitle,
                      message: l10n.adminLangMgmtEmptyMessage,
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: languages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                            final language = languages[index];
                            return InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => context.push(
                                '/admin/languages/${language.id}',
                                extra: language.name,
                              ),
                              child: PremiumCard(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: (language.isActive ? _languageAccent[0] : AppColors.textSecondary)
                                            .withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.language,
                                        color: language.isActive ? _languageAccent[0] : AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(language.name, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
                                          Text(
                                            '${language.code.toUpperCase()}${language.country != null && language.country!.isNotEmpty ? ' · ${language.country}' : ''}',
                                            style: AppTypography.caption,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Switch(
                                          value: language.isActive,
                                          onChanged: (_) => _toggleActive(language),
                                          activeThumbColor: _languageAccent[0],
                                        ),
                                        Text(
                                          language.isActive ? l10n.adminLangMgmtPublished : l10n.adminLangMgmtDraft,
                                          style: AppTypography.caption.copyWith(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      onPressed: () => _delete(language),
                                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                      tooltip: l10n.adminLangMgmtDelete,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
    );
  }
}
