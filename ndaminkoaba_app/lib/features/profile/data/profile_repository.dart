import '../../../core/network/api_client.dart';
import '../domain/user_profile.dart';

class ProfileRepository {
  Future<UserProfile> getMe() async {
    final response = await ApiClient.dio.get('/users/me');

    final data = response.data as Map<String, dynamic>;
    final userData = data['data'] ?? data;

    return UserProfile.fromJson(userData as Map<String, dynamic>);
  }

  Future<UserProfile> updateMe({String? fullName, String? password}) async {
    final response = await ApiClient.dio.patch(
      '/users/me',
      data: {
        if (fullName != null && fullName.isNotEmpty) 'fullName': fullName,
        if (password != null && password.isNotEmpty) 'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final userData = data['data'] ?? data;

    return UserProfile.fromJson(userData as Map<String, dynamic>);
  }
}
