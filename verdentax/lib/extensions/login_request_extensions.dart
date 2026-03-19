import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Extensions pour aligner LoginRequest avec les autres services
extension LoginRequestExtensions on LoginRequest {
  
  /// Valider la requête de connexion
  ValidationResult validate() {
    final errors = <String>[];
    
    // Validation du username
    if (username.trim().isEmpty) {
      errors.add('Le nom d\'utilisateur est requis');
    } else if (username.trim().length < 3) {
      errors.add('Le nom d\'utilisateur doit contenir au moins 3 caractères');
    } else if (!RegExp(r'^[a-zA-Z0-9_@.-]+$').hasMatch(username)) {
      errors.add('Le nom d\'utilisateur contient des caractères invalides');
    }
    
    // Validation du password
    if (password.isEmpty) {
      errors.add('Le mot de passe est requis');
    } else if (password.length < 6) {
      errors.add('Le mot de passe doit contenir au moins 6 caractères');
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
  
  /// Vérifier la force du mot de passe
  PasswordStrength getPasswordStrength() {
    if (password.length < 6) return PasswordStrength.veryWeak;
    
    int score = 0;
    
    // Longueur
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    
    // Complexité
    if (password.contains(RegExp(r'[a-z]'))) score++; // Minuscules
    if (password.contains(RegExp(r'[A-Z]'))) score++; // Majuscules
    if (password.contains(RegExp(r'[0-9]'))) score++; // Chiffres
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++; // Symboles
    
    switch (score) {
      case 0:
      case 1:
        return PasswordStrength.veryWeak;
      case 2:
        return PasswordStrength.weak;
      case 3:
        return PasswordStrength.medium;
      case 4:
        return PasswordStrength.strong;
      case 5:
      case 6:
        return PasswordStrength.veryStrong;
      default:
        return PasswordStrength.veryWeak;
    }
  }
  
  /// Obtenir des suggestions pour améliorer le mot de passe
  List<String> getPasswordSuggestions() {
    final suggestions = <String>[];
    final strength = getPasswordStrength();
    
    if (strength.index < PasswordStrength.medium.index) {
      if (password.length < 8) {
        suggestions.add('Utilisez au moins 8 caractères');
      }
      if (!password.contains(RegExp(r'[a-z]'))) {
        suggestions.add('Ajoutez des lettres minuscules');
      }
      if (!password.contains(RegExp(r'[A-Z]'))) {
        suggestions.add('Ajoutez des lettres majuscules');
      }
      if (!password.contains(RegExp(r'[0-9]'))) {
        suggestions.add('Ajoutez des chiffres');
      }
      if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        suggestions.add('Ajoutez des caractères spéciaux');
      }
    }
    
    return suggestions;
  }
  
  /// Créer une requête d'authentification pour l'API
  Map<String, dynamic> toApiRequest() {
    return {
      'username': username.trim(),
      'password': password,
      'grant_type': 'password',
      'client_id': 'verdentax-app',
      'scope': 'openid profile email',
    };
  }
  
  /// Créer une requête d'authentification Keycloak
  Map<String, dynamic> toKeycloakRequest() {
    return {
      'username': username.trim(),
      'password': password,
      'grant_type': 'password',
      'client_id': 'verdentax-frontend',
    };
  }
  
  /// Vérifier si c'est une tentative d'authentification admin
  bool get isAdminAttempt {
    return username.toLowerCase().contains('admin') ||
           username.toLowerCase().contains('administrator');
  }
  
  /// Vérifier si c'est une tentative d'authentification agent
  bool get isAgentAttempt {
    return username.toLowerCase().contains('agent') ||
           username.toLowerCase().contains('collecteur');
  }
  
  /// Obtenir le type d'utilisateur probable basé sur le username
  UserType? getProbableUserType() {
    final lowerUsername = username.toLowerCase();
    
    if (lowerUsername.contains('admin') || lowerUsername.contains('administrator')) {
      return UserType.admin;
    } else if (lowerUsername.contains('supervisor') || lowerUsername.contains('manager')) {
      return UserType.supervisor;
    } else if (lowerUsername.contains('agent') || lowerUsername.contains('collecteur')) {
      return UserType.agent;
    } else if (lowerUsername.contains('contribuable') || lowerUsername.contains('taxpayer')) {
      return UserType.contribuable;
    }
    
    return null;
  }
  
  /// Créer un hash du mot de passe pour le stockage local
  Future<String> hashPassword() async {
    // Utiliser un algorithme de hashage sécurisé
    // Pour l'instant, simulation simple
    final bytes = utf8.encode('${password}verdentax_salt_2024');
    final hash = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return hash;
  }
  
  /// Vérifier si le mot de passe correspond au hash
  Future<bool> verifyPassword(String hashedPassword) async {
    final computedHash = await hashPassword();
    return computedHash == hashedPassword;
  }
  
  /// Obtenir des métadonnées sur la requête
  LoginRequestMetadata getMetadata() {
    return LoginRequestMetadata(
      username: username,
      usernameLength: username.length,
      passwordLength: password.length,
      passwordStrength: getPasswordStrength(),
      probableUserType: getProbableUserType(),
      isAdminAttempt: isAdminAttempt,
      isAgentAttempt: isAgentAttempt,
      timestamp: DateTime.now(),
    );
  }
  
  /// Créer une requête de réinitialisation de mot de passe
  Map<String, dynamic> createPasswordResetRequest() {
    return {
      'username': username.trim(),
      'action': 'reset_password',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
  
  /// Créer une requête de vérification de compte
  Map<String, dynamic> createAccountVerificationRequest() {
    return {
      'username': username.trim(),
      'action': 'verify_account',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Résultat de validation
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({
    required this.isValid,
    required this.errors,
  });

  String get errorMessage => errors.join('\n');
}

/// Force du mot de passe
enum PasswordStrength {
  veryWeak('Très faible', Color(0xFFFF0000)),
  weak('Faible', Color(0xFFFFA500)),
  medium('Moyen', Color(0xFFFFFF00)),
  strong('Fort', Color(0xFF90EE90)),
  veryStrong('Très fort', Color(0xFF00FF00));

  const PasswordStrength(this.label, this.color);
  final String label;
  final Color color;
}

/// Types d'utilisateurs
enum UserType {
  admin('Administrateur'),
  supervisor('Superviseur'),
  agent('Agent'),
  contribuable('Contribuable'),
  guest('Invité');

  const UserType(this.label);
  final String label;
}

/// Métadonnées de la requête de connexion
class LoginRequestMetadata {
  final String username;
  final int usernameLength;
  final int passwordLength;
  final PasswordStrength passwordStrength;
  final UserType? probableUserType;
  final bool isAdminAttempt;
  final bool isAgentAttempt;
  final DateTime timestamp;

  LoginRequestMetadata({
    required this.username,
    required this.usernameLength,
    required this.passwordLength,
    required this.passwordStrength,
    this.probableUserType,
    required this.isAdminAttempt,
    required this.isAgentAttempt,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'usernameLength': usernameLength,
      'passwordLength': passwordLength,
      'passwordStrength': passwordStrength.name,
      'probableUserType': probableUserType?.name,
      'isAdminAttempt': isAdminAttempt,
      'isAgentAttempt': isAgentAttempt,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LoginRequestMetadata.fromJson(Map<String, dynamic> json) {
    return LoginRequestMetadata(
      username: json['username'],
      usernameLength: json['usernameLength'],
      passwordLength: json['passwordLength'],
      passwordStrength: PasswordStrength.values.firstWhere(
        (e) => e.name == json['passwordStrength'],
        orElse: () => PasswordStrength.veryWeak,
      ),
      probableUserType: json['probableUserType'] != null
          ? UserType.values.firstWhere(
              (e) => e.name == json['probableUserType'],
              orElse: () => UserType.guest,
            )
          : null,
      isAdminAttempt: json['isAdminAttempt'],
      isAgentAttempt: json['isAgentAttempt'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// Extensions pour le service d'authentification avec LoginRequest
extension AuthServiceLoginExtensions on AuthService {
  
  /// Valider et traiter une requête de connexion
  Future<LoginResult> validateAndLogin(LoginRequest loginRequest) async {
    try {
      // Valider la requête
      final validation = loginRequest.validate();
      if (!validation.isValid) {
        return LoginResult(
          success: false,
          error: validation.errorMessage,
          requiresTwoFactor: false,
          metadata: loginRequest.getMetadata(),
        );
      }
      
      // Vérifier la force du mot de passe
      final passwordStrength = loginRequest.getPasswordStrength();
      if (passwordStrength.index < PasswordStrength.weak.index) {
        return LoginResult(
          success: false,
          error: 'Le mot de passe est trop faible. Veuillez choisir un mot de passe plus sécurisé.',
          requiresTwoFactor: false,
          metadata: loginRequest.getMetadata(),
        );
      }
      
      // Obtenir les métadonnées
      final metadata = loginRequest.getMetadata();
      
      // Tenter la connexion
      final success = await login(
        loginRequest.username.trim(),
        loginRequest.password,
      );
      
      return LoginResult(
        success: success,
        error: success ? null : errorMessage,
        requiresTwoFactor: false, // À implémenter si nécessaire
        metadata: metadata,
      );
    } catch (e) {
      return LoginResult(
        success: false,
        error: 'Erreur lors de la connexion: $e',
        requiresTwoFactor: false,
        metadata: loginRequest.getMetadata(),
      );
    }
  }
  
  /// Créer une session avec métadonnées
  Future<void> createSessionWithMetadata(
    LoginRequest loginRequest,
    User user,
  ) async {
    try {
      final metadata = loginRequest.getMetadata();
      
      // Logger la connexion
      debugPrint('Session created for user ${user.username} with metadata: ${metadata.toJson()}');
    } catch (e) {
      debugPrint('Error creating session with metadata: $e');
    }
  }
  
  /// Vérifier si une connexion nécessite une authentification à deux facteurs
  bool requiresTwoFactor(LoginRequest loginRequest) {
    // Logique pour déterminer si 2FA est nécessaire
    final metadata = loginRequest.getMetadata();
    
    // Admin et superviseur nécessitent 2FA
    if (metadata.isAdminAttempt) return true;
    
    // Connexion depuis un nouvel appareil/IP nécessite 2FA
    // (À implémenter avec la détection d'appareil)
    
    // Tentatives multiples nécessitent 2FA
    if (loginAttempts > 2) return true;
    
    return false;
  }
}

/// Résultat de connexion
class LoginResult {
  final bool success;
  final String? error;
  final bool requiresTwoFactor;
  final LoginRequestMetadata metadata;

  LoginResult({
    required this.success,
    this.error,
    required this.requiresTwoFactor,
    required this.metadata,
  });
}
