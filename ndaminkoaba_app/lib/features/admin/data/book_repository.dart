import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../domain/book_models.dart';

class BookRepository {
  Future<List<AdminBook>> getBooks({String? search, String? languageId}) async {
    final response = await ApiClient.dio.get('/books', queryParameters: {
      'limit': 100,
      if (search != null && search.isNotEmpty) 'search': search,
      if (languageId != null) 'languageId': languageId,
    });
    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];
    return (items as List)
        .map((item) => AdminBook.fromJson(item as Map<String, dynamic>))
        .toList();
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

  Future<void> createBook({
    required String title,
    required String languageId,
    String? author,
    String? description,
    String? coverUrl,
    required String fileUrl,
    required String fileType,
  }) async {
    await ApiClient.dio.post('/books', data: {
      'title': title,
      'languageId': languageId,
      if (author != null && author.isNotEmpty) 'author': author,
      if (description != null && description.isNotEmpty) 'description': description,
      if (coverUrl != null) 'coverUrl': coverUrl,
      'fileUrl': fileUrl,
      'fileType': fileType,
    });
  }

  Future<void> updateBook(
    String id, {
    required String title,
    String? author,
    String? description,
    String? coverUrl,
  }) async {
    await ApiClient.dio.patch('/books/$id', data: {
      'title': title,
      'author': author,
      'description': description,
      'coverUrl': coverUrl,
    });
  }

  Future<void> deleteBook(String id) async {
    await ApiClient.dio.delete('/books/$id');
  }
}
