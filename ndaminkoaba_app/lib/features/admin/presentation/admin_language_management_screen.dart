import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/navigation/app_admin_navigation.dart';
import '../../../design_system/navigation/tab_navigation.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/gradient_app_bar.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
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
        error = extractErrorMessage(e, fallback: 'Could not load languages.');
        isLoading = false;
      });
    }
  }

  Future<void> _toggleActive(AdminLanguage language) async {
    try {
      await repository.setLanguageActive(language.id, !language.isActive);
      load();
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not update language.'));
    }
  }

  Future<void> _delete(AdminLanguage language) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete language?'),
        content: Text('"${language.name}" will be permanently removed. This only works if it has no courses yet.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await repository.deleteLanguage(language.id);
      load();
      _showMessage('Language deleted.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not delete language.'));
    }
  }

  Future<void> _openAddDialog() async {
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add')),
        ],
      ),
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
      _showMessage('Language added. It starts as a draft — publish it once its content is ready.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not add language.'));
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(title: 'Languages', colors: _languageAccent),
      bottomNavigationBar: AppAdminNavigation(
        currentIndex: 2,
        onTap: (index) => handleAdminTabTap(context, index),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDialog,
        backgroundColor: _languageAccent[0],
        icon: const Icon(Icons.add),
        label: const Text('Add Language'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: isLoading
              ? const ShimmerListLoader(itemCount: 5, itemHeight: 76)
              : error != null
                  ? EmptyState(icon: Icons.error_outline, title: 'Something went wrong', message: error)
                  : languages.isEmpty
                      ? const EmptyState(
                          icon: Icons.language_outlined,
                          title: 'No languages yet',
                          message: 'Tap "Add Language" to create the first one.',
                        )
                      : ListView.separated(
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
                                          language.isActive ? 'Published' : 'Draft',
                                          style: AppTypography.caption.copyWith(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      onPressed: () => _delete(language),
                                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                      tooltip: 'Delete',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}
