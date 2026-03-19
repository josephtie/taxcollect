class User {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final bool enabled;
  final List<String> roles;
  final DateTime? createdTimestamp;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.enabled,
    required this.roles,
    this.createdTimestamp,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      enabled: json['enabled'] ?? false,
      roles: List<String>.from(json['realmRoles'] ?? []),
      createdTimestamp: json['createdTimestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['createdTimestamp'] * 1000)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'enabled': enabled,
      'realmRoles': roles,
      'createdTimestamp': (createdTimestamp?.millisecondsSinceEpoch ?? 0) ~/ 1000,
    };
  }

  String get fullName => '$firstName $lastName';
  
  bool hasRole(String role) {
    return roles.contains(role);
  }
  
  bool hasAnyRole(List<String> roles) {
    return roles.any((role) => this.roles.contains(role));
  }

  // Permission getters
  bool get isAgent => hasRole('agent') || hasRole('agent_collecteur');
  bool get isSupervisor => hasRole('supervisor') || hasRole('admin');
  bool get isAdmin => hasRole('admin') || hasRole('super_admin');

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    bool? enabled,
    List<String>? roles,
    DateTime? createdTimestamp,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      enabled: enabled ?? this.enabled,
      roles: roles ?? this.roles,
      createdTimestamp: createdTimestamp ?? this.createdTimestamp,
    );
  }
}
