import 'dart:convert';

/// Represents a user role in the system
class Role {
  final String id;
  final String name;
  final String route; // Navigation route for this role (e.g., '/admin', '/client')

  Role({
    required this.id,
    required this.name,
    required this.route,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      route: json['route'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'route': route,
    };
  }
}

/// Represents a user in the system
/// Supports both authenticated users and anonymous (guest) users
class User {
  final String id;
  final String name;
  final String lastname;
  final String email;
  final String phone;
  final String? cedula;
  final String? image;
  final String sessionToken;
  final String? notificationToken;
  final List<Role> roles;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.name,
    required this.lastname,
    required this.email,
    required this.phone,
    this.cedula,
    this.image,
    required this.sessionToken,
    this.notificationToken,
    this.roles = const [],
    this.lastLogin,
  });

  /// Helper to check if user is anonymous (guest mode)
  bool get isAnonymous => id.isEmpty || sessionToken.isEmpty;
  
  /// Helper to check if user is authenticated
  bool get isAuthenticated => !isAnonymous;

  /// Helper to get user's full name
  String get fullName => '$name $lastname'.trim();

  /// Helper to check if user has admin role
  bool get isAdmin => roles.any((role) => role.name.toLowerCase() == 'admin' || role.name.toLowerCase() == 'administrador');

  /// Creates an anonymous (guest) user
  factory User.anonymous() {
    return User(
      id: '',
      name: 'Invitado',
      lastname: '',
      email: '',
      phone: '',
      sessionToken: '',
      roles: [],
    );
  }

  /// Creates a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    // Parse roles
    List<Role> rolesList = [];
    if (json['roles'] != null) {
      if (json['roles'] is List) {
        rolesList = (json['roles'] as List)
            .map((roleJson) => Role.fromJson(roleJson))
            .toList();
      }
    }

    // Parse lastLogin
    DateTime? lastLoginDate;
    if (json['last_login'] != null) {
      if (json['last_login'] is String) {
        lastLoginDate = DateTime.tryParse(json['last_login']);
      } else if (json['last_login'] is int) {
        lastLoginDate = DateTime.fromMillisecondsSinceEpoch(json['last_login']);
      }
    }

    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      lastname: json['lastname'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      cedula: json['cedula']?.toString(),
      image: json['image'],
      sessionToken: json['session_token'] ?? '',
      notificationToken: json['notification_token'],
      roles: rolesList,
      lastLogin: lastLoginDate,
    );
  }

  /// Converts User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastname': lastname,
      'email': email,
      'phone': phone,
      'cedula': cedula,
      'image': image,
      'session_token': sessionToken,
      'notification_token': notificationToken,
      'roles': roles.map((role) => role.toJson()).toList(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  /// Creates a copy of this User with updated fields
  User copyWith({
    String? id,
    String? name,
    String? lastname,
    String? email,
    String? phone,
    String? cedula,
    String? image,
    String? sessionToken,
    String? notificationToken,
    List<Role>? roles,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      cedula: cedula ?? this.cedula,
      image: image ?? this.image,
      sessionToken: sessionToken ?? this.sessionToken,
      notificationToken: notificationToken ?? this.notificationToken,
      roles: roles ?? this.roles,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

/// Helper functions for User serialization
String userToJson(User user) => json.encode(user.toJson());
User userFromJson(String str) => User.fromJson(json.decode(str));
