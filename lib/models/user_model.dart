class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String role;
  final bool disabled;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.role,
    this.disabled = false,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? role,
    bool? disabled,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      disabled: disabled ?? this.disabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'role': role,
      'disabled': disabled,
    };
  }

  static UserModel fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String?,
      role: map['role'] as String? ?? 'user',
      disabled: map['disabled'] as bool? ?? false,
    );
  }
}
