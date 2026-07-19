class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: (json['role'] ?? '').toString(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? ''),
    );
  }
}
