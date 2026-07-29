/// User model representing authenticated user data
class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? passwordHash;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.passwordHash,
  });

  /// Create User from Map/JSON (Local DB response)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseInt(json['id']),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'USER',
      passwordHash: json['passwordHash'] as String? ?? json['password_hash'] as String?,
    );
  }

  /// Convert User to Map/JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      if (passwordHash != null) 'passwordHash': passwordHash,
    };
  }

  static int _parseInt(dynamic val) {
    if (val is int) return val;
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  /// Check if user is admin
  bool get isAdmin => role.toUpperCase() == 'ADMIN';

  @override
  String toString() => 'User(id: $id, name: $name, email: $email, role: $role)';
}

/// Login result wrapper for local auth operations
class LocalAuthResult {
  final bool success;
  final String message;
  final User? user;
  final String? token;

  const LocalAuthResult({
    required this.success,
    required this.message,
    this.user,
    this.token,
  });
}
