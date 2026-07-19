import '../../../core/network/api_client.dart';
import '../domain/language.dart';

class LanguageRepository {
  Future<List<Language>> getLanguages({bool? isActive}) async {
    final response = await ApiClient.dio.get('/languages', queryParameters: {
      'limit': 100,
      if (isActive != null) 'isActive': isActive,
    });
    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];
    return (items as List)
        .map((item) => Language.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Language> getLanguage(String id) async {
    final response = await ApiClient.dio.get('/languages/$id');
    final data = response.data as Map<String, dynamic>;
    return Language.fromJson((data['data'] ?? data) as Map<String, dynamic>);
  }
}
