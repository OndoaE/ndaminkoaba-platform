import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/language/learning_language_provider.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/gradient_app_bar.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../data/syllabary_repository.dart';

/// Alphabet grid — each tile is a letter with a syllabary chart behind it
/// (see [SyllabaryChartScreen]). Reached from the Learn Hub.
class SyllabaryAlphabetScreen extends ConsumerStatefulWidget {
  const SyllabaryAlphabetScreen({super.key});

  @override
  ConsumerState<SyllabaryAlphabetScreen> createState() =>
      _SyllabaryAlphabetScreenState();
}

class _SyllabaryAlphabetScreenState
    extends ConsumerState<SyllabaryAlphabetScreen> {
  final repository = SyllabaryRepository();
  bool isLoading = true;
  bool hasError = false;
  List<String> letters = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    final languageId = ref.read(currentLearningLanguageProvider);
    if (languageId == null) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      return;
    }

    try {
      final result = await repository.getLetters(languageId);
      if (!mounted) return;
      setState(() {
        letters = result;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(title: 'Alphabet'),
      body: SafeArea(
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: ShimmerListLoader(),
              )
            : (hasError || letters.isEmpty)
                ? const EmptyState(
                    icon: Icons.grid_view_outlined,
                    title: 'Nothing here yet',
                    message:
                        "The syllabary chart for this language hasn't been added yet.",
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1,
                    ),
                    itemCount: letters.length,
                    itemBuilder: (context, index) {
                      final letter = letters[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => context.push('/syllabary/$letter'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.divider),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            letter,
                            style: AppTypography.h1.copyWith(color: AppColors.primary),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
