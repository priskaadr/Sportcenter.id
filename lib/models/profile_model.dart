class ProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? avatarUrl;
  final String? phone;
  final bool isVerified;

  ProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.phone,
    required this.isVerified,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      avatarUrl: json['avatar_url'],
      phone: json['phone'],
      isVerified: json['is_verified'] ?? false,
    );
  }
}