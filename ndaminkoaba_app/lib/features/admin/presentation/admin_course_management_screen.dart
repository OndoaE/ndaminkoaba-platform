import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/widgets/gradient_app_bar.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../data/admin_repository.dart';
import '../data/content_repository.dart';
import '../domain/admin_models.dart';

const _levels = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'];

class AdminCourseManagementScreen extends StatefulWidget {
  const AdminCourseManagementScreen({super.key, required this.languageId, this.languageName});

  final String languageId;
  final String? languageName;

  @override
  State<AdminCourseManagementScreen> createState() => _AdminCourseManagementScreenState();
}

class _AdminCourseManagementScreenState extends State<AdminCourseManagementScreen> {
  final adminRepository = AdminRepository();
  final contentRepository = ContentRepository();
  final searchController = TextEditingController();

  bool isLoading = true;
  String? levelFilter;
  List<AdminCourse> courses = [];

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
      final result = await adminRepository.getCourses(level: levelFilter, languageId: widget.languageId);
      if (!mounted) return;
      setState(() {
        courses = result;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  List<AdminCourse> get _visibleCourses {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) return courses;
    return courses.where((c) => c.title.toLowerCase().contains(query)).toList();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> setStatus(AdminCourse course, String status) async {
    try {
      await adminRepository.setCourseStatus(course.id, status);
      load();
    } catch (_) {
      _showMessage('Could not update course status.');
    }
  }

  Future<void> setLevel(AdminCourse course, String level) async {
    try {
      await contentRepository.updateCourse(course.id, level: level);
      load();
      _showMessage('Course moved to ${level[0]}${level.substring(1).toLowerCase()}.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not update course level.'));
    }
  }

  Future<void> deleteCourse(AdminCourse course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Delete "${course.title}"? This cannot be undone.'),
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
      await contentRepository.deleteCourse(course.id);
      load();
      _showMessage('Course deleted.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(
        e,
        fallback: 'Could not delete — remove its modules first.',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(title: 'Course Management'),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Course', style: TextStyle(color: Colors.white)),
        onPressed: () async {
          await context.push(
            '/admin/languages/${widget.languageId}/courses/new',
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
                  hintText: 'Search courses...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(
                      label: 'All Levels',
                      selected: levelFilter == null,
                      onTap: () {
                        setState(() => levelFilter = null);
                        load();
                      },
                    ),
                    ..._levels.map(
                      (l) => Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.sm),
                        child: _FilterChip(
                          label: l[0] + l.substring(1).toLowerCase(),
                          selected: levelFilter == l,
                          onTap: () {
                            setState(() => levelFilter = l);
                            load();
                          },
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
                    : _visibleCourses.isEmpty
                        ? Center(child: Text('No courses found.', style: AppTypography.caption))
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: _visibleCourses.length,
                            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) {
                              final course = _visibleCourses[index];
                              return InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () async {
                                  await context.push(
                                    '/admin/languages/${widget.languageId}/courses/${course.id}',
                                    extra: widget.languageName,
                                  );
                                  load();
                                },
                                child: _CourseRow(
                                  course: course,
                                  onSetStatus: setStatus,
                                  onSetLevel: setLevel,
                                  onDelete: deleteCourse,
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
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary),
    );
  }
}

class _CourseRow extends StatelessWidget {
  const _CourseRow({
    required this.course,
    required this.onSetStatus,
    required this.onSetLevel,
    required this.onDelete,
  });

  final AdminCourse course;
  final void Function(AdminCourse, String) onSetStatus;
  final void Function(AdminCourse, String) onSetLevel;
  final void Function(AdminCourse) onDelete;

  Color _statusColor() {
    switch (course.status) {
      case 'PUBLISHED':
        return AppColors.success;
      case 'ARCHIVED':
        return AppColors.textSecondary;
      default:
        return AppColors.warning;
    }
  }

  Color _levelColor() {
    switch (course.level) {
      case 'BEGINNER':
        return const Color(0xFF0D7A4C);
      case 'INTERMEDIATE':
        return const Color(0xFF3D6BE0);
      case 'ADVANCED':
        return const Color(0xFFB5312B);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = _levelColor();

    return PremiumCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [levelColor, levelColor.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.menu_book, color: Colors.white, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title, style: AppTypography.title),
                Text(course.languageName, style: AppTypography.caption),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Chip(
                      label: Text(course.level.replaceAll('_', ' '), style: const TextStyle(fontSize: 11)),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: levelColor.withValues(alpha: 0.15),
                      labelStyle: TextStyle(color: levelColor),
                      side: BorderSide.none,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: _statusColor(), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        course.status,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: _statusColor()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                onDelete(course);
              } else if (value.startsWith('level:')) {
                onSetLevel(course, value.substring('level:'.length));
              } else {
                onSetStatus(course, value);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'PUBLISHED', child: Text('Publish')),
              const PopupMenuItem(value: 'DRAFT', child: Text('Move to Draft')),
              const PopupMenuItem(value: 'ARCHIVED', child: Text('Archive')),
              const PopupMenuDivider(),
              for (final l in _levels.where((l) => l != course.level))
                PopupMenuItem(
                  value: 'level:$l',
                  child: Text('Move to ${l[0]}${l.substring(1).toLowerCase()}'),
                ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
