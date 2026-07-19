import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../domain/book.dart';

class BookRepository {
  Future<List<Book>> getBooks({String? search, String? languageId}) async {
    final response = await ApiClient.dio.get('/books', queryParameters: {
      'limit': 100,
      if (search != null && search.isNotEmpty) 'search': search,
      if (languageId != null) 'languageId': languageId,
    });
    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];
    return (items as List)
        .map((item) => Book.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Book> getBook(String id) async {
    final response = await ApiClient.dio.get('/books/$id');
    final data = response.data as Map<String, dynamic>;
    return Book.fromJson((data['data'] ?? data) as Map<String, dynamic>);
  }

  /// Downloads the book's PDF/EPUB file bytes directly, so readers can pass
  /// them to in-memory viewers (e.g. `SfPdfViewer.memory`) instead of
  /// relying on a viewer package's own network fetch layer.
  Future<Uint8List> downloadBookFile(String fileUrl) async {
    final response = await Dio().get<List<int>>(
      AppConfig.resolveUrl(fileUrl),
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data!);
  }
}
