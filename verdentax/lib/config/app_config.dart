import 'package:flutter/foundation.dart';

class AppConfig {
  // Application Info
  static const String appName = 'VerdenTax';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Digitalisation des Taxes Communales';
  
  // API Configuration
  static const String baseUrl = 'http://192.168.1.4:9090';
  static const String apiUrl = '$baseUrl/api';
  static const String authUrl = '$baseUrl/auth';
  
  // Keycloak Configuration
  static const String keycloakUrl = 'http://192.168.1.4:8080';
  static const String keycloakRealm = 'mairie';
  static const String clientId = 'tax-backend';
  static const String redirectUrl = 'verdentax://callback';
  
  // Authentication Configuration
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String lastLoginKey = 'last_login_time';
  static const String loginAttemptsKey = 'login_attempts';
  static const String lockoutEndKey = 'lockout_end_time';
  
  // Timeouts (in seconds)
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
  static const int sendTimeout = 30;
  
  // Session Management
  static const int sessionTimeoutHours = 24;
  static const int maxLoginAttempts = 3;
  static const Duration lockoutDuration = Duration(minutes: 15);
  
  // Security
  static const int minPasswordLength = 6;
  static const int minUsernameLength = 3;
  static const bool enableBiometricAuth = true;
  
  // UI Configuration
  static const String primaryColor = '#1976D2';
  static const String secondaryColor = '#FFC107';
  static const String successColor = '#4CAF50';
  static const String warningColor = '#FF9800';
  static const String errorColor = '#F44336';
  static const String backgroundColor = '#F5F5F5';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // File Upload
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];
  
  // Location Configuration
  static const double defaultLatitude = 14.6937; // Abidjan
  static const double defaultLongitude = -17.4441;
  static const double defaultZoom = 15.0;
  static const double locationAccuracyThreshold = 100.0; // meters
  
  // Offline Configuration
  static const Duration syncInterval = Duration(minutes: 5);
  static const int maxOfflineTransactions = 100;
  static const Duration offlineDataRetention = Duration(days: 30);
  
  // QR Code Configuration
  static const int qrCodeSize = 200;
  static const String qrCodePrefix = 'VTX';
  
  // Print Configuration
  static const String receiptPaperSize = '58mm'; // Thermal printer
  static const int receiptCopies = 1;
  
  // Cache Configuration
  static const Duration imageCacheDuration = Duration(hours: 24);
  static const Duration dataCacheDuration = Duration(minutes: 30);
  
  // Debug Configuration
  static const bool isDebugMode = true;
  static const bool enableLogging = true;
  static const LogLevel logLevel = LogLevel.debug;
  
  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableLocationServices = true;
  static const bool enableQRCodeScanning = true;
  static const bool enableBiometricLogin = true;
  static const bool enablePushNotifications = false;
  static const bool enableAnalytics = false;
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';
  static const String debugRolesEndpoint = '/auth/api/debug/roles';
  
  static const String usersEndpoint = '/api/users';
  static const String transactionsEndpoint = '/api/transactions';
  static const String clotureCaisseEndpoint = '/api/cloture-caisse';
  
  static const String contribuablesEndpoint = '/api/taxcollect/contribuable';
  static const String agentsEndpoint = '/api/taxcollect/agent';
  static const String zonesEndpoint = '/api/taxcollect/zonecollect';
  static const String taxesEndpoint = '/api/taxcollect/taxe';
  static const String cartesEndpoint = '/api/taxcollect/carte';
  static const String communesEndpoint = '/api/taxcollect/commune';
  static const String quartiersEndpoint = '/api/taxcollect/quartier';
  
  // Error Messages
  static const String networkError = 'Erreur de connexion réseau';
  static const String serverError = 'Erreur serveur';
  static const String authError = 'Erreur d\'authentification';
  static const String loginSuccess = 'Connexion réussie';
  static const String logoutSuccess = 'Déconnexion réussie';
  static const String loading = 'Chargement...';
  static const String authenticating = 'Authentification...';
  static const String syncing = 'Synchronisation...';
  static const String noDataFound = 'Aucune donnée trouvée';
  static const String operationSuccess = 'Opération réussie';
  static const String operationFailed = 'Opération échouée';
  
  // Validation Messages
  static const String fieldRequired = 'Ce champ est obligatoire';
  static const String emailInvalid = 'Email invalide';
  static const String phoneInvalid = 'Numéro de téléphone invalide';
  static const String amountInvalid = 'Montant invalide';
  static const String passwordTooShort = 'Le mot de passe doit contenir au moins ${minPasswordLength} caractères';
  static const String usernameTooShort = 'Le nom d\'utilisateur doit contenir au moins ${minUsernameLength} caractères';
  
  // User Roles
  static const String roleAgent = 'AGENT';
  static const String roleSuperviseur = 'SUPERVISEUR';
  static const String roleAdministrateur = 'ADMINISTRATEUR';
  static const String roleTresorPublic = 'TRESOR_PUBLIC';
  
  // Transaction Status
  static const String statusEnAttente = 'EN_ATTENTE';
  static const String statusValidee = 'VALIDEE';
  static const String statusAnnulee = 'ANNULEE';
  static const String statusSynchronisee = 'SYNCHRONISEE';
  static const String statusEnErreur = 'EN_ERREUR';
  
  // Payment Methods
  static const String paiementEspece = 'ESPECE';
  static const String paiementMobileMoney = 'MOBILE_MONEY';
  static const String paiementQRCode = 'QR_CODE';
  
  // Cloture Status
  static const String clotureEnCours = 'EN_COURS';
  static const String clotureSoumise = 'SOUMISE';
  static const String clotureValidee = 'VALIDEE';
  static const String clotureRejetee = 'REJETEE';
  static const String clotureDeposee = 'DEPOSEE';
  
  // Biometric Authentication
  static const String biometricReason = 'Authentification biométrique requise';
  static const String biometricNotAvailable = 'L\'authentification biométrique n\'est pas disponible';
  static const String biometricFailed = 'Échec de l\'authentification biométrique';
  
  // Permissions
  static const List<String> requiredPermissions = [
    'camera',
    'location',
    'storage',
    'phone',
  ];
  
  // App Links
  static const String privacyPolicyUrl = 'https://verdentax.com/privacy';
  static const String termsOfServiceUrl = 'https://verdentax.com/terms';
  static const String supportEmail = 'support@verdentax.com';
  static const String supportPhone = '+225 00 00 00 00';
}

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

enum Environment {
  development,
  staging,
  production,
}

extension AppConfigExtension on AppConfig {
  static bool get isDebugMode => kDebugMode;
  static bool get isProduction => !isDebugMode;
  static String get currentEnvironment => isDebugMode ? 'Development' : 'Production';
  static int get sessionTimeoutHours => 24;
  static Duration get sessionTimeout => Duration(hours: sessionTimeoutHours);
  
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[0-9]{10,15}$').hasMatch(phone);
  }
  
  static bool isValidAmount(String amount) {
    return RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(amount) && 
           double.tryParse(amount) != null && 
           double.parse(amount) > 0;
  }
}
