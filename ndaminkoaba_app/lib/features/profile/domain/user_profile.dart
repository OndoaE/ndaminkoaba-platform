class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final bool isActive;
  final String? profileImage;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.isActive = true,
    this.profileImage,
    this.createdAt,
    this.lastLogin,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: (json['role'] ?? '').toString(),
      isActive: json['isActive'] ?? true,
      profileImage: json['profileImage'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? ''),
      lastLogin: json['lastLogin'] == null ? null : DateTime.tryParse(json['lastLogin']),
    );
  }
}
