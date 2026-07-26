import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../domain/user_profile.dart';

class ProfileRepository {
  Future<UserProfile> getMe() async {
    final response = await ApiClient.dio.get('/users/me');

    final data = response.data as Map<String, dynamic>;
    final userData = data['data'] ?? data;

    return UserProfile.fromJson(userData as Map<String, dynamic>);
  }

  Future<UserProfile> updateMe({
    String? fullName,
    String? password,
    String? profileImage,
  }) async {
    final response = await ApiClient.dio.patch(
      '/users/me',
      data: {
        if (fullName != null && fullName.isNotEmpty) 'fullName': fullName,
        if (password != null && password.isNotEmpty) 'password': password,
        if (profileImage != null && profileImage.isNotEmpty) 'profileImage': profileImage,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final userData = data['data'] ?? data;

    return UserProfile.fromJson(userData as Map<String, dynamic>);
  }

  /// Uploads a picked image via the shared `/uploads/image` endpoint and
  /// returns its relative URL (e.g. `/uploads/images/xxx.png`) — the caller
  /// still needs to persist it onto the user via [updateMe].
  Future<String> uploadAvatar(Uint8List bytes, String filename) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final response = await ApiClient.dio.post('/uploads/image', data: formData);
    final data = response.data as Map<String, dynamic>;
    return ((data['data'] ?? data) as Map<String, dynamic>)['url'] as String;
  }
}
