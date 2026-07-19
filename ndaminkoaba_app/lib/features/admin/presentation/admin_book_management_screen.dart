import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_error.dart';
import '../../../config/app_config.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/gradient_app_bar.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../data/book_repository.dart';
import '../domain/book_models.dart';

const _bookAccent = [Color(0xFF5D4037), Color(0xFF8D6E63)];

class AdminBookManagementScreen extends StatefulWidget {
  const AdminBookManagementScreen({super.key, required this.languageId, this.languageName});

  final String languageId;
  final String? languageName;

  @override
  State<AdminBookManagementScreen> createState() => _AdminBookManagementScreenState();
}

class _AdminBookManagementScreenState extends State<AdminBookManagementScreen> {
  final repository = BookRepository();
  final searchController = TextEditingController();
  List<AdminBook> books = [];
  bool isLoading = true;
  String? error;

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
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final result = await repository.getBooks(
        search: searchController.text.trim(),
        languageId: widget.languageId,
      );
      setState(() {
        books = result;
        isLoading = false;
      });
    } on DioException catch (e) {
      setState(() {
        error = extractErrorMessage(e, fallback: 'Could not load books.');
        isLoading = false;
      });
    }
  }

  Future<void> addBook() async {
    final result = await showDialog<_BookFormResult>(
      context: context,
      builder: (context) => const _BookFormDialog(),
    );
    if (result == null) return;

    try {
      String? coverUrl;
      if (result.coverBytes != null) {
        coverUrl = await repository.uploadCoverImage(result.coverBytes!, result.coverFilename!);
      }

      final uploaded = await repository.uploadBookFile(result.fileBytes!, result.fileFilename!);

      await repository.createBook(
        title: result.title,
        languageId: widget.languageId,
        author: result.author,
        description: result.description,
        coverUrl: coverUrl,
        fileUrl: uploaded.url,
        fileType: uploaded.fileType,
      );
      load();
      _showMessage('Book added.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not add book.'));
    }
  }

  Future<void> editBook(AdminBook book) async {
    final result = await showDialog<_BookFormResult>(
      context: context,
      builder: (context) => _BookFormDialog(existing: book),
    );
    if (result == null) return;

    try {
      String? coverUrl = book.coverUrl;
      if (result.coverBytes != null) {
        coverUrl = await repository.uploadCoverImage(result.coverBytes!, result.coverFilename!);
      }

      await repository.updateBook(
        book.id,
        title: result.title,
        author: result.author,
        description: result.description,
        coverUrl: coverUrl,
      );
      load();
      _showMessage('Book updated.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not update book.'));
    }
  }

  Future<void> deleteBook(AdminBook book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete book?'),
        content: Text('"${book.title}" will be removed for every learner.'),
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
      await repository.deleteBook(book.id);
      load();
      _showMessage('Book deleted.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not delete book.'));
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
      appBar: const GradientAppBar(title: 'Book Management', colors: _bookAccent),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addBook,
        backgroundColor: _bookAccent[0],
        icon: const Icon(Icons.add),
        label: const Text('Add Book'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'Search books',
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (_) => load(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: isLoading
                    ? const ShimmerListLoader(itemCount: 5, itemHeight: 88)
                    : error != null
                        ? EmptyState(icon: Icons.error_outline, title: 'Something went wrong', message: error)
                        : books.isEmpty
                            ? const EmptyState(
                                icon: Icons.menu_book_outlined,
                                title: 'No books yet',
                                message: 'Tap "Add Book" to upload the first one.',
                              )
                            : ListView.separated(
                                itemCount: books.length,
                                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                                itemBuilder: (context, index) {
                                  final book = books[index];
                                  return PremiumCard(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    child: Row(
                                      children: [
                                        _BookCover(book: book),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                book.title,
                                                style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (book.author != null && book.author!.isNotEmpty)
                                                Text(
                                                  book.author!,
                                                  style: AppTypography.caption,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              const SizedBox(height: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: _bookAccent[0].withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  book.fileType.toUpperCase(),
                                                  style: AppTypography.caption.copyWith(
                                                    color: _bookAccent[0],
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'edit') editBook(book);
                                            if (value == 'delete') deleteBook(book);
                                          },
                                          itemBuilder: (context) => const [
                                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                                            PopupMenuItem(value: 'delete', child: Text('Delete')),
                                          ],
                                        ),
                                      ],
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

class _BookCover extends StatelessWidget {
  const _BookCover({required this.book});

  final AdminBook book;

  @override
  Widget build(BuildContext context) {
    final isPdf = book.fileType == 'pdf';

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: book.coverUrl != null
          ? Image.network(
              AppConfig.resolveUrl(book.coverUrl!),
              width: 48,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => _fallbackIcon(isPdf),
            )
          : SizedBox(width: 48, height: 64, child: _fallbackIcon(isPdf)),
    );
  }

  Widget _fallbackIcon(bool isPdf) {
    return Container(
      color: _bookAccent[0].withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: Icon(
        isPdf ? Icons.picture_as_pdf_outlined : Icons.menu_book_outlined,
        color: _bookAccent[0],
      ),
    );
  }
}

class _BookFormResult {
  const _BookFormResult({
    required this.title,
    this.author,
    this.description,
    this.coverBytes,
    this.coverFilename,
    this.fileBytes,
    this.fileFilename,
  });

  final String title;
  final String? author;
  final String? description;
  final Uint8List? coverBytes;
  final String? coverFilename;
  final Uint8List? fileBytes;
  final String? fileFilename;
}

/// Add or edit a book. In "edit" mode ([existing] non-null) the underlying
/// PDF/EPUB file can't be swapped — only metadata and the cover — since
/// re-uploading just to fix a typo in the title is unnecessary complexity;
/// delete and re-add if the file itself needs to change.
class _BookFormDialog extends StatefulWidget {
  const _BookFormDialog({this.existing});

  final AdminBook? existing;

  @override
  State<_BookFormDialog> createState() => _BookFormDialogState();
}

class _BookFormDialogState extends State<_BookFormDialog> {
  late final titleController = TextEditingController(text: widget.existing?.title ?? '');
  late final authorController = TextEditingController(text: widget.existing?.author ?? '');
  late final descriptionController = TextEditingController(text: widget.existing?.description ?? '');

  Uint8List? coverBytes;
  String? coverFilename;
  Uint8List? fileBytes;
  String? fileFilename;

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  bool get isEditing => widget.existing != null;

  Future<void> pickCover() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      coverBytes = bytes;
      coverFilename = picked.name;
    });
  }

  Future<void> pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'epub'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.first;
    if (picked.bytes == null) return;
    setState(() {
      fileBytes = picked.bytes;
      fileFilename = picked.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Edit Book' : 'Add Book'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(labelText: 'Author (optional)'),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                minLines: 2,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
              ),
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: pickCover,
                icon: const Icon(Icons.image_outlined),
                label: Text(
                  coverFilename ?? (isEditing ? 'Replace cover image (optional)' : 'Cover image (optional)'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isEditing) ...[
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: Text(
                    fileFilename ?? 'PDF or EPUB file',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final title = titleController.text.trim();
            if (title.isEmpty) return;
            if (!isEditing && fileBytes == null) return;

            Navigator.pop(
              context,
              _BookFormResult(
                title: title,
                author: authorController.text.trim(),
                description: descriptionController.text.trim(),
                coverBytes: coverBytes,
                coverFilename: coverFilename,
                fileBytes: fileBytes,
                fileFilename: fileFilename,
              ),
            );
          },
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
