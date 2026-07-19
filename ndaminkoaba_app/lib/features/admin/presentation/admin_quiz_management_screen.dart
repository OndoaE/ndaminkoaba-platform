import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/gradient_app_bar.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../data/content_repository.dart';
import '../domain/management_models.dart';

class AdminQuizManagementScreen extends StatefulWidget {
  const AdminQuizManagementScreen({super.key, required this.languageId, this.languageName});

  final String languageId;
  final String? languageName;

  @override
  State<AdminQuizManagementScreen> createState() => _AdminQuizManagementScreenState();
}

class _AdminQuizManagementScreenState extends State<AdminQuizManagementScreen> {
  final contentRepository = ContentRepository();
  final searchController = TextEditingController();

  bool isLoading = true;
  List<ManagedQuiz> quizzes = [];
  String? courseFilter;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final result = await contentRepository.getAllQuizzesFlat(languageId: widget.languageId);
      if (!mounted) return;
      setState(() {
        quizzes = result;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  List<String> get _courseTitles => quizzes.map((q) => q.courseTitle).toSet().toList()..sort();

  List<ManagedQuiz> get _visible {
    final query = searchController.text.trim().toLowerCase();
    return quizzes.where((q) {
      final matchesCourse = courseFilter == null || q.courseTitle == courseFilter;
      final matchesQuery = query.isEmpty || q.title.toLowerCase().contains(query);
      return matchesCourse && matchesQuery;
    }).toList();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> editQuizInfo(ManagedQuiz quiz) async {
    final titleController = TextEditingController(text: quiz.title);
    final descController = TextEditingController(text: quiz.description ?? '');
    final frenchTitleController = TextEditingController(text: quiz.frenchTitle ?? '');
    final frenchDescController = TextEditingController(text: quiz.frenchDescription ?? '');
    final scoreController = TextEditingController(text: '${quiz.passingScore}');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Quiz'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: AppSpacing.md),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: frenchTitleController,
                decoration: const InputDecoration(labelText: 'French Title (optional)'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: frenchDescController,
                decoration: const InputDecoration(labelText: 'French Description (optional)'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: scoreController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Passing Score (%)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await contentRepository.updateQuiz(
        quiz.id,
        title: titleController.text.trim(),
        description: descController.text.trim(),
        frenchTitle: frenchTitleController.text.trim(),
        frenchDescription: frenchDescController.text.trim(),
        passingScore: int.tryParse(scoreController.text.trim()),
      );
      load();
      _showMessage('Quiz updated.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not update quiz.'));
    }
  }

  Future<void> deleteQuiz(ManagedQuiz quiz) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: Text(
          'Delete "${quiz.title}" and all ${quiz.questionCount} question(s)? This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      // Full quiz + questions + choices are fetched together for the cascade.
      final full = await contentRepository.getQuizForLesson(quiz.lessonId);
      if (full != null) {
        await contentRepository.deleteQuiz(full);
      }
      load();
      _showMessage('Quiz deleted.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not delete quiz.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(title: 'Quiz Management', colors: [Color(0xFFB5312B), AppColors.primary]),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFB5312B),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Quiz', style: TextStyle(color: Colors.white)),
        onPressed: () async {
          await context.push(
            '/admin/languages/${widget.languageId}/quizzes/new',
            extra: widget.languageName,
          );
          load();
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search quizzes...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (_courseTitles.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'All Courses',
                        selected: courseFilter == null,
                        onTap: () => setState(() => courseFilter = null),
                      ),
                      ..._courseTitles.map(
                        (title) => Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.sm),
                          child: _FilterChip(
                            label: title,
                            selected: courseFilter == title,
                            onTap: () => setState(() => courseFilter = title),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: isLoading
                    ? const ShimmerListLoader()
                    : _visible.isEmpty
                        ? Center(child: Text('No quizzes found.', style: AppTypography.caption))
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: _visible.length,
                            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) {
                              final quiz = _visible[index];
                              return InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () async {
                                  await context.push(
                                    '/admin/lessons/${quiz.lessonId}/quiz',
                                    extra: quiz.lessonTitle,
                                  );
                                  load();
                                },
                                child: PremiumCard(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFB5312B).withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(Icons.quiz, color: Color(0xFFB5312B)),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(quiz.title, style: AppTypography.title),
                                            Text(
                                              '${quiz.courseTitle} › ${quiz.moduleTitle} › ${quiz.lessonTitle}',
                                              style: AppTypography.caption,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '${quiz.questionCount} questions • pass ${quiz.passingScore}%',
                                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined),
                                        onPressed: () => editQuizInfo(quiz),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                        onPressed: () => deleteQuiz(quiz),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFFB5312B),
      labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary),
    );
  }
}
