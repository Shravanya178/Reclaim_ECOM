enum UserRole { student, lab, admin }

class User {
  final String id;
  final String email;
  final UserRole role;
  final String? campusId;
  final String? departmentId;
  final String? fullName;
  final String? phone;
  final String? profileImageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.role,
    this.campusId,
    this.departmentId,
    this.fullName,
    this.phone,
    this.profileImageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.student,
      ),
      campusId: json['campus_id'] as String?,
      departmentId: json['department_id'] as String?,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role.name,
      'campus_id': campusId,
      'department_id': departmentId,
      'full_name': fullName,
      'phone': phone,
      'profile_image_url': profileImageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    UserRole? role,
    String? campusId,
    String? departmentId,
    String? fullName,
    String? phone,
    String? profileImageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      campusId: campusId ?? this.campusId,
      departmentId: departmentId ?? this.departmentId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, email: $email, role: $role)';
  }
}