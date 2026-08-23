import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_error.dart';
import '../../../design_system/buttons/primary_button.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/gradient_app_bar.dart';
import '../../../design_system/widgets/section_title.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../syllabary/data/syllabary_repository.dart';
import '../../syllabary/domain/syllabary_models.dart';

enum _Phase { list, review }

/// Admin screen for the syllabary/literacy-chart knowledge base: an admin
/// photographs a chart (a consonant with arrows to each vowel, forming
/// syllables — see [SyllabaryExtractionResult]), an AI model extracts it,
/// and only an explicit "Approve & Import" ever writes anything — the
/// extraction step itself never touches the database.
class AdminSyllabaryManagementScreen extends StatefulWidget {
  const AdminSyllabaryManagementScreen({
    super.key,
    required this.languageId,
    this.languageName,
  });

  final String languageId;
  final String? languageName;

  @override
  State<AdminSyllabaryManagementScreen> createState() =>
      _AdminSyllabaryManagementScreenState();
}

class _AdminSyllabaryManagementScreenState
    extends State<AdminSyllabaryManagementScreen> {
  final repository = SyllabaryRepository();
  final picker = ImagePicker();

  _Phase phase = _Phase.list;
  bool isLoading = true;
  bool isExtracting = false;
  bool isImporting = false;
  List<SyllabaryEntry> entries = [];

  Uint8List? pickedImageBytes;
  String? pickedImageMimeType;
  SyllabaryExtractionResult? draft;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final result = await repository.getEntries(languageId: widget.languageId);
      if (!mounted) return;
      setState(() {
        entries = result;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Map<String, List<SyllabaryEntry>> get _grouped {
    final map = <String, List<SyllabaryEntry>>{};
    for (final e in entries) {
      map.putIfAbsent(e.letter, () => []).add(e);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
    }
    return map;
  }

  Future<void> deleteEntry(SyllabaryEntry entry) async {
    try {
      await repository.deleteEntry(entry.id);
      load();
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not delete entry.'));
    }
  }

  Future<void> deleteLetter(String letter, List<SyllabaryEntry> letterEntries) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "$letter"'),
        content: Text('Delete all ${letterEntries.length} row(s) for "$letter"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
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
      for (final e in letterEntries) {
        await repository.deleteEntry(e.id);
      }
      load();
      _showMessage('"$letter" deleted.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not delete letter.'));
    }
  }

  Future<void> pickImageSource() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    await _pickAndExtract(source);
  }

  Future<void> _pickAndExtract(ImageSource source) async {
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;

    setState(() {
      pickedImageBytes = bytes;
      pickedImageMimeType = picked.mimeType ?? _guessMimeType(picked.name);
    });
    await _runExtraction();
  }

  String _guessMimeType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<void> _runExtraction() async {
    final bytes = pickedImageBytes;
    final mimeType = pickedImageMimeType;
    if (bytes == null || mimeType == null) return;

    setState(() => isExtracting = true);
    try {
      final result = await repository.extractChart(
        imageBytes: bytes,
        mimeType: mimeType,
        languageId: widget.languageId,
      );
      if (!mounted) return;
      setState(() {
        draft = result;
        phase = _Phase.review;
        isExtracting = false;
      });
      if (result.rows.isEmpty) {
        _showMessage('No rows detected — check the notes on the review screen.');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => isExtracting = false);
      _showMessage(extractErrorMessage(e, fallback: 'Could not analyze this image.'));
    }
  }

  Future<void> reanalyze() async {
    if (pickedImageBytes == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Re-analyze?'),
        content: const Text(
          'This replaces the current draft, including any edits you made.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Re-analyze'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _runExtraction();
  }

  void cancelReview() {
    setState(() {
      phase = _Phase.list;
      draft = null;
      pickedImageBytes = null;
      pickedImageMimeType = null;
    });
  }

  Future<void> approveAndImport() async {
    final current = draft;
    if (current == null || current.rows.isEmpty) return;

    setState(() => isImporting = true);
    var succeeded = 0;
    var failed = 0;
    String? firstError;
    for (final row in current.rows) {
      try {
        await repository.createEntry(
          consonant: current.consonant,
          vowel: row.vowel,
          syllable: row.syllable,
          exampleWord: row.exampleWord,
          translation: row.translation,
          exampleSentence: row.exampleSentence,
          orderNumber: row.orderNumber,
          languageId: widget.languageId,
        );
        succeeded++;
      } on DioException catch (e) {
        failed++;
        firstError ??= extractErrorMessage(e, fallback: 'Unknown server error.');
      } catch (e) {
        failed++;
        firstError ??= e.toString();
      }
    }

    if (!mounted) return;
    setState(() {
      isImporting = false;
      phase = _Phase.list;
      draft = null;
      pickedImageBytes = null;
      pickedImageMimeType = null;
    });
    load();
    _showMessage(
      failed == 0
          ? 'Imported $succeeded row(s).'
          : 'Imported $succeeded row(s), $failed failed'
                '${firstError != null ? ' — $firstError' : ''}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(
        title: phase == _Phase.review ? 'Review Chart' : 'Syllabus Management',
        colors: const [AppColors.ai, Color(0xFF6B4CE0)],
      ),
      floatingActionButton: phase == _Phase.list && !isExtracting
          ? FloatingActionButton.extended(
              onPressed: pickImageSource,
              icon: const Icon(Icons.add_a_photo_outlined, color: Colors.white),
              label: const Text(
                'Upload Chart Photo',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.ai,
            )
          : null,
      body: SafeArea(
        child: isExtracting
            ? _buildExtractingState()
            : phase == _Phase.review
                ? _buildReviewPhase()
                : _buildListPhase(),
      ),
    );
  }

  Widget _buildExtractingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.lg),
          Text('Analyzing chart photo…', style: AppTypography.body),
        ],
      ),
    );
  }

  Widget _buildListPhase() {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: ShimmerListLoader(),
      );
    }
    final grouped = _grouped;
    if (grouped.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text(
            'No syllabary content yet. Tap "Upload Chart Photo" below — take a '
            'photo of a chart like a consonant with arrows to each vowel, and '
            'the AI will extract it for you to review before saving.',
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final letters = grouped.keys.toList()..sort();
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        120,
      ),
      children: [
        for (final letter in letters)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: PremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.ai.withValues(alpha: 0.12),
                        child: Text(
                          letter,
                          style: const TextStyle(
                            color: AppColors.ai,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          '${grouped[letter]!.length} syllable(s)',
                          style: AppTypography.title,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        tooltip: 'Delete all rows for "$letter"',
                        onPressed: () => deleteLetter(letter, grouped[letter]!),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...grouped[letter]!.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              entry.syllable,
                              style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(entry.exampleWord ?? '—', style: AppTypography.caption),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(entry.translation ?? '—', style: AppTypography.caption),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            onPressed: () => deleteEntry(entry),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildReviewPhase() {
    final current = draft;
    if (current == null) return const SizedBox.shrink();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              if (current.warnings.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.warning,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'AI extraction notes',
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ...current.warnings.map((w) => Text('• $w', style: AppTypography.caption)),
                    ],
                  ),
                ),
              PremiumCard(
                child: Row(
                  children: [
                    Text('Letter', style: AppTypography.title),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextFormField(
                        key: ValueKey('letter-${current.hashCode}'),
                        initialValue: current.consonant ?? '',
                        decoration: const InputDecoration(
                          hintText: 'e.g. L (blank = vowel-only)',
                        ),
                        onChanged: (v) =>
                            current.consonant = v.trim().isEmpty ? null : v.trim(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionTitle(title: 'Rows', subtitle: '${current.rows.length} detected'),
              const SizedBox(height: AppSpacing.md),
              if (current.rows.isEmpty)
                PremiumCard(
                  child: Text(
                    'No rows were detected. Try Re-analyze with a clearer photo, '
                    'or go back and upload a different one.',
                    style: AppTypography.caption,
                  ),
                ),
              ...current.rows.asMap().entries.map(
                (entry) => _EditableRowCard(
                  key: ValueKey(entry.value),
                  row: entry.value,
                  lowConfidence: entry.value.confidence == 'low',
                  onDelete: () => setState(() => current.rows.removeAt(entry.key)),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isImporting ? null : cancelReview,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isImporting ? null : reanalyze,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Re-analyze'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: 'Approve & Import',
                  icon: Icons.check,
                  isLoading: isImporting,
                  onPressed: current.rows.isEmpty ? null : approveAndImport,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Every field is editable inline — matching the review screen's "you can
/// fix what the AI got wrong before approving" purpose without a separate
/// edit-mode toggle. Edits write straight into the mutable [row] passed in;
/// this widget owns its own [TextEditingController]s so typing never
/// triggers a parent rebuild (only structural changes, like deleting a
/// row, do).
class _EditableRowCard extends StatefulWidget {
  const _EditableRowCard({
    super.key,
    required this.row,
    required this.lowConfidence,
    required this.onDelete,
  });

  final SyllabaryExtractionRow row;
  final bool lowConfidence;
  final VoidCallback onDelete;

  @override
  State<_EditableRowCard> createState() => _EditableRowCardState();
}

class _EditableRowCardState extends State<_EditableRowCard> {
  late final vowelController = TextEditingController(text: widget.row.vowel);
  late final syllableController = TextEditingController(text: widget.row.syllable);
  late final wordController = TextEditingController(text: widget.row.exampleWord ?? '');
  late final translationController =
      TextEditingController(text: widget.row.translation ?? '');
  late final exampleController =
      TextEditingController(text: widget.row.exampleSentence ?? '');

  @override
  void dispose() {
    vowelController.dispose();
    syllableController.dispose();
    wordController.dispose();
    translationController.dispose();
    exampleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.lowConfidence ? AppColors.warning : AppColors.divider,
          width: widget.lowConfidence ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.lowConfidence)
                const Padding(
                  padding: EdgeInsets.only(right: AppSpacing.xs),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: AppColors.warning,
                  ),
                ),
              Expanded(
                child: Text(
                  'Row ${widget.row.orderNumber + 1}',
                  style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                tooltip: 'Remove this row',
                onPressed: widget.onDelete,
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: vowelController,
                  decoration: const InputDecoration(labelText: 'Vowel', isDense: true),
                  onChanged: (v) => widget.row.vowel = v,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: syllableController,
                  decoration: const InputDecoration(labelText: 'Syllable', isDense: true),
                  onChanged: (v) => widget.row.syllable = v,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: wordController,
            decoration: const InputDecoration(labelText: 'Example word', isDense: true),
            onChanged: (v) => widget.row.exampleWord = v.isEmpty ? null : v,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: translationController,
            decoration: const InputDecoration(
              labelText: 'French translation',
              isDense: true,
            ),
            onChanged: (v) => widget.row.translation = v.isEmpty ? null : v,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: exampleController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Example sentence',
              isDense: true,
            ),
            onChanged: (v) => widget.row.exampleSentence = v.isEmpty ? null : v,
          ),
        ],
      ),
    );
  }
}
