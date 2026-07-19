import '../../../core/network/api_client.dart';
import '../domain/certificate.dart';

class CertificateRepository {
  Future<List<Certificate>> getMyCertificates() async {
    final response = await ApiClient.dio.get(
      '/certificates',
      queryParameters: {'limit': 100},
    );

    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];

    return (items as List)
        .map((item) => Certificate.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Issues a certificate for the given course. The backend re-validates
  /// that every lesson is completed and every quiz passed before issuing —
  /// this call fails with a 400 if the learner isn't actually eligible yet.
  Future<Certificate> claim({
    required String userId,
    required String courseId,
  }) async {
    final response = await ApiClient.dio.post(
      '/certificates',
      data: {'userId': userId, 'courseId': courseId},
    );

    final data = response.data as Map<String, dynamic>;
    final certData = data['data'] ?? data;

    return Certificate.fromJson(certData as Map<String, dynamic>);
  }

  Future<Certificate> generatePdf(String certificateId) async {
    final response = await ApiClient.dio.post(
      '/certificates/$certificateId/generate-pdf',
    );

    final data = response.data as Map<String, dynamic>;
    final certData = data['data'] ?? data;

    return Certificate.fromJson(certData as Map<String, dynamic>);
  }
}
