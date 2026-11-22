/// Represents an authenticated user returned by the PHP backend.
class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.createdAt,
  });

  /// Create a [User] from the JSON returned by profile.php / login.php.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'created_at': createdAt,
    };
  }

  @override
  String toString() => 'User(id: $id, name: $name, email: $email, role: $role)';
}
