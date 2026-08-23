import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../domain/book_models.dart';

class BookRepository {
  Future<List<AdminBook>> getBooks({String? search, String? languageId, String? category}) async {
    final response = await ApiClient.dio.get('/books', queryParameters: {
      'limit': 100,
      if (search != null && search.isNotEmpty) 'search': search,
      if (languageId != null) 'languageId': languageId,
      if (category != null) 'category': category,
    });
    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];
    return (items as List)
        .map((item) => AdminBook.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<AdminBook> getBook(String id) async {
    final response = await ApiClient.dio.get('/books/$id');
    final data = response.data as Map<String, dynamic>;
    return AdminBook.fromJson((data['data'] ?? data) as Map<String, dynamic>);
  }

  /// Uploads a book's PDF/EPUB file and returns its stored URL + detected
  /// file type ("pdf"/"epub"), ready to hand to [createBook]/[updateBook].
  Future<({String url, String fileType})> uploadBookFile(
    Uint8List bytes,
    String filename,
  ) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final response = await ApiClient.dio.post('/uploads/document', data: formData);
    final data = response.data as Map<String, dynamic>;
    final body = (data['data'] ?? data) as Map<String, dynamic>;
    final url = body['url'] as String;
    final fileType = url.toLowerCase().endsWith('.epub') ? 'epub' : 'pdf';
    return (url: url, fileType: fileType);
  }

  Future<String> uploadCoverImage(Uint8List bytes, String filename) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final response = await ApiClient.dio.post('/uploads/image', data: formData);
    final data = response.data as Map<String, dynamic>;
    return ((data['data'] ?? data) as Map<String, dynamic>)['url'] as String;
  }

  Future<String> createBook({
    required String title,
    required String languageId,
    String? author,
    String? description,
    String? coverUrl,
    String? fileUrl,
    String? fileType,
  }) async {
    final response = await ApiClient.dio.post('/books', data: {
      'title': title,
      'languageId': languageId,
      if (author != null && author.isNotEmpty) 'author': author,
      if (description != null && description.isNotEmpty) 'description': description,
      if (coverUrl != null) 'coverUrl': coverUrl,
      if (fileUrl != null) 'fileUrl': fileUrl,
      if (fileType != null) 'fileType': fileType,
    });
    final data = response.data as Map<String, dynamic>;
    final body = (data['data'] ?? data) as Map<String, dynamic>;
    return body['id'] as String;
  }

  Future<void> updateBook(
    String id, {
    String? title,
    String? author,
    String? description,
    String? coverUrl,
    String? fileUrl,
    String? fileType,
    String? category,
    String? level,
    int? readingTimeMinutes,
    int? recommendedAge,
    bool? hasImages,
    int? pageCount,
  }) async {
    await ApiClient.dio.patch('/books/$id', data: {
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (description != null) 'description': description,
      if (coverUrl != null) 'coverUrl': coverUrl,
      if (fileUrl != null) 'fileUrl': fileUrl,
      if (fileType != null) 'fileType': fileType,
      if (category != null) 'category': category,
      if (level != null) 'level': level,
      if (readingTimeMinutes != null) 'readingTimeMinutes': readingTimeMinutes,
      if (recommendedAge != null) 'recommendedAge': recommendedAge,
      if (hasImages != null) 'hasImages': hasImages,
      if (pageCount != null) 'pageCount': pageCount,
    });
  }

  Future<void> deleteBook(String id) async {
    await ApiClient.dio.delete('/books/$id');
  }

  // ---------- Pages (admin-authored illustrated content) ----------

  Future<List<AdminBookPage>> getPages(String bookId) async {
    final response = await ApiClient.dio.get('/book-pages', queryParameters: {'bookId': bookId});
    final data = response.data as Map<String, dynamic>;
    final items = (data['data'] ?? data) as List;
    return items.map((e) => AdminBookPage.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createPage({
    required String bookId,
    required int orderNumber,
    required String ewondoText,
    String? illustrationUrl,
    String? frenchText,
    String? audioUrl,
  }) async {
    await ApiClient.dio.post('/book-pages', data: {
      'bookId': bookId,
      'orderNumber': orderNumber,
      'ewondoText': ewondoText,
      if (illustrationUrl != null && illustrationUrl.isNotEmpty) 'illustrationUrl': illustrationUrl,
      if (frenchText != null && frenchText.isNotEmpty) 'frenchText': frenchText,
      if (audioUrl != null && audioUrl.isNotEmpty) 'audioUrl': audioUrl,
    });
  }

  Future<void> updatePage(
    String id, {
    String? ewondoText,
    String? illustrationUrl,
    String? frenchText,
    String? audioUrl,
  }) async {
    await ApiClient.dio.patch('/book-pages/$id', data: {
      if (ewondoText != null) 'ewondoText': ewondoText,
      if (illustrationUrl != null) 'illustrationUrl': illustrationUrl,
      if (frenchText != null) 'frenchText': frenchText,
      if (audioUrl != null) 'audioUrl': audioUrl,
    });
  }

  Future<void> deletePage(String id) async {
    await ApiClient.dio.delete('/book-pages/$id');
  }

  Future<void> reorderPages(String bookId, List<String> orderedIds) async {
    await ApiClient.dio.patch('/book-pages/reorder', data: {
      'bookId': bookId,
      'orderedIds': orderedIds,
    });
  }
}
