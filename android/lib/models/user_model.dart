class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? profileImageUrl;
  final String? universityId;
  final String? universityName;
  final String? phone;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.profileImageUrl,
    this.universityId,
    this.universityName,
    this.phone,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'buyer',
      profileImageUrl: json['profile_image_url'] as String?,
      universityId: json['university_id'] as String?,
      universityName: json['university_name'] as String?,
      phone: json['phone'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'profile_image_url': profileImageUrl,
      'university_id': universityId,
      'university_name': universityName,
      'phone': phone,
      'is_verified': isVerified,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? profileImageUrl,
    String? universityId,
    String? universityName,
    String? phone,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      universityId: universityId ?? this.universityId,
      universityName: universityName ?? this.universityName,
      phone: phone ?? this.phone,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isBuyer => role == 'buyer';
  bool get isSeller => role == 'seller';
  bool get isAdmin => role == 'admin';

  @override
  String toString() => 'UserModel(id: $id, email: $email, name: $name, role: $role)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
