import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../data/admin_repository.dart';
import '../domain/admin_models.dart';

/// A single language's admin dashboard — structurally the same screen every
/// language gets (stats, quick actions, content hub), just scoped to
/// [languageId]. Reached by tapping a language card on the Global Dashboard
/// or the Languages management list. A brand-new, empty language lands here
/// with zero special-casing: the same Quick Actions the admin already knows
/// from every other language, just building against an empty content set.
class AdminLanguageDashboardScreen extends StatefulWidget {
  const AdminLanguageDashboardScreen({
    super.key,
    required this.languageId,
    this.languageName,
  });

  final String languageId;
  final String? languageName;

  @override
  State<AdminLanguageDashboardScreen> createState() => _AdminLanguageDashboardScreenState();
}

class _AdminLanguageDashboardScreenState extends State<AdminLanguageDashboardScreen> {
  final repository = AdminRepository();

  bool isLoading = true;
  AdminStats? stats;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final result = await repository.getStats(languageId: widget.languageId);
      if (!mounted) return;
      setState(() {
        stats = result;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.languageName ?? 'Language';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('$title Admin'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: isLoading
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: const ShimmerListLoader(itemCount: 5, itemHeight: 100),
              )
            : RefreshIndicator(
                onRefresh: load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quick Actions', style: AppTypography.title),
                      const SizedBox(height: AppSpacing.md),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 2.4,
                        children: [
                          _QuickAction(
                            icon: Icons.folder_open_outlined,
                            label: 'Content Hub',
                            color: AppColors.primary,
                            onTap: () => context.push(
                              '/admin/languages/${widget.languageId}/courses',
                              extra: widget.languageName,
                            ),
                          ),
                          _QuickAction(
                            icon: Icons.add_circle_outline,
                            label: 'New Course',
                            color: const Color(0xFF0D7A4C),
                            onTap: () async {
                              await context.push('/admin/languages/${widget.languageId}/courses/new');
                              load();
                            },
                          ),
                          _QuickAction(
                            icon: Icons.play_lesson_outlined,
                            label: 'New Lesson',
                            color: const Color(0xFF3D6BE0),
                            onTap: () async {
                              await context.push('/admin/languages/${widget.languageId}/lessons/new');
                              load();
                            },
                          ),
                          _QuickAction(
                            icon: Icons.quiz_outlined,
                            label: 'New Quiz',
                            color: AppColors.secondary,
                            onTap: () async {
                              await context.push('/admin/languages/${widget.languageId}/quizzes/new');
                              load();
                            },
                          ),
                          _QuickAction(
                            icon: Icons.psychology_outlined,
                            label: 'Train the AI',
                            color: AppColors.ai,
                            onTap: () async {
                              await context.push('/admin/languages/${widget.languageId}/knowledge');
                              load();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text('$title Stats', style: AppTypography.title),
                      const SizedBox(height: AppSpacing.md),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.72,
                        children: [
                          _StatCard(
                            icon: Icons.menu_book,
                            label: 'Courses',
                            value: '${stats?.courses ?? 0}',
                            color: AppColors.primary,
                          ),
                          _StatCard(
                            icon: Icons.play_lesson,
                            label: 'Lessons',
                            value: '${stats?.lessons ?? 0}',
                            color: const Color(0xFF0D7A4C),
                          ),
                          _StatCard(
                            icon: Icons.translate,
                            label: 'Vocabulary',
                            value: '${stats?.vocabulary ?? 0}',
                            color: AppColors.ai,
                          ),
                          _StatCard(
                            icon: Icons.quiz,
                            label: 'Quizzes',
                            value: '${stats?.quizzes ?? 0}',
                            color: const Color(0xFF3D6BE0),
                          ),
                          _StatCard(
                            icon: Icons.workspace_premium,
                            label: 'Certificates',
                            value: '${stats?.certificates ?? 0}',
                            color: AppColors.warning,
                          ),
                        ],
                      ),
                      if (stats != null && stats!.coursesByLevel.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xl),
                        Text('Courses by Level', style: AppTypography.title),
                        const SizedBox(height: AppSpacing.md),
                        PremiumCard(
                          child: _LevelBarChart(data: stats!.coursesByLevel),
                        ),
                      ],
                      if (stats != null && stats!.recentCertificates.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xl),
                        Text('Recent Certificates', style: AppTypography.title),
                        const SizedBox(height: AppSpacing.md),
                        ...stats!.recentCertificates.map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: PremiumCard(
                              child: Row(
                                children: [
                                  const Icon(Icons.workspace_premium, color: AppColors.secondary),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${c.learnerName} completed ${c.courseTitle}'),
                                        Text(
                                          DateFormat.yMMMd().format(c.issuedAt),
                                          style: AppTypography.caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: PremiumCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.title.copyWith(fontSize: 15),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.color = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.sm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTypography.h2, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(
            label,
            style: AppTypography.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _LevelBarChart extends StatelessWidget {
  const _LevelBarChart({required this.data});

  final Map<String, int> data;

  static const _order = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'];

  @override
  Widget build(BuildContext context) {
    final maxValue = data.values.isEmpty
        ? 1.0
        : data.values.reduce((a, b) => a > b ? a : b).toDouble();

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue + 1,
          barTouchData: BarTouchData(enabled: false),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= _order.length) {
                    return const SizedBox.shrink();
                  }
                  final label = _order[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      label[0] + label.substring(1, 3).toLowerCase(),
                      style: AppTypography.caption,
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(_order.length, (index) {
            final value = (data[_order[index]] ?? 0).toDouble();
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value,
                  color: AppColors.primary,
                  width: 32,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
