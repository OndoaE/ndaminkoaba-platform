class LoginResponse {
  final String accessToken;
  final String id;
  final String fullName;
  final String email;
  final String role;
  final bool isFirstLogin;

  LoginResponse({
    required this.accessToken,
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isFirstLogin,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return LoginResponse(
      accessToken: data['accessToken'],
      id: data['user']['id'],
      fullName: data['user']['fullName'],
      email: data['user']['email'],
      role: data['user']['role'],
      isFirstLogin: data['isFirstLogin'] == true,
    );
  }
}