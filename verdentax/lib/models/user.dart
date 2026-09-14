import '../config/app_config.dart';

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
      // Un payload JWT Keycloak porte l'identifiant dans `sub` et le login dans
      // `preferred_username` ; une réponse /api/users utilise `id` / `username`.
      id: json['id'] ?? json['sub'] ?? '',
      username: json['username'] ?? json['preferred_username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? json['given_name'] ?? '',
      lastName: json['lastName'] ?? json['family_name'] ?? '',
      enabled: json['enabled'] ?? true,
      roles: _rolesFromJson(json),
      createdTimestamp: json['createdTimestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdTimestamp'] * 1000)
          : null,
    );
  }

  /// Extrait les rôles quelle que soit la source :
  /// - `realm_access.roles` / `resource_access['tax-backend'].roles` (payload JWT Keycloak)
  /// - `realmRoles` / `roles` (réponse d'API ou cache local sérialisé)
  static List<String> _rolesFromJson(Map<String, dynamic> json) {
    final roles = <String>{};

    void addAll(dynamic value) {
      if (value is List) {
        roles.addAll(value.map((e) => e.toString()));
      }
    }

    addAll(json['realmRoles']);
    addAll(json['roles']);

    final realmAccess = json['realm_access'];
    if (realmAccess is Map) addAll(realmAccess['roles']);

    final resourceAccess = json['resource_access'];
    if (resourceAccess is Map) {
      final backend = resourceAccess['tax-backend'];
      if (backend is Map) addAll(backend['roles']);
    }

    // Les rôles techniques Keycloak ne portent aucune sémantique métier.
    roles.removeWhere((r) =>
        r.startsWith('default-roles') ||
        r == 'offline_access' ||
        r == 'uma_authorization');

    return roles.toList();
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

  // Permission getters — les rôles du realm Keycloak sont en MAJUSCULES
  // (voir AppConfig.role* et realm-mairie.json).
  bool get isAgent => hasRole(AppConfig.roleAgent);
  bool get isSupervisor =>
      hasRole(AppConfig.roleSuperviseur) || hasRole(AppConfig.roleAdministrateur);
  bool get isAdmin => hasRole(AppConfig.roleAdministrateur);
  bool get isTresor => hasRole(AppConfig.roleTresorPublic);
  bool get isResponsableQuartier => hasRole(AppConfig.roleResponsableQuartier);

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
