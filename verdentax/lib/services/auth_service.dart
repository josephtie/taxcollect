import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../config/config.dart';
import '../models/models.dart';

class AuthService with ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final Logger _logger = Logger();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final Dio _dio = Dio();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  String? _token;
  DateTime? _lastLoginTime;
  int _loginAttempts = 0;
  bool _isLocked = false;
  DateTime? _lockoutEndTime;
  bool _isOffline = false;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  String? get token => _token;
  DateTime? get lastLoginTime => _lastLoginTime;
  int get loginAttempts => _loginAttempts;
  bool get isLocked => _isLocked;
  DateTime? get lockoutEndTime => _lockoutEndTime;
  bool get isOffline => _isOffline;

  bool get canUseBiometrics => _currentUser != null && AppConfig.enableBiometricLogin;
  bool get isSessionExpired {
    if (_lastLoginTime == null) return true;
    final sessionDuration = DateTime.now().difference(_lastLoginTime!);
    return sessionDuration.inHours >= AppConfig.sessionTimeoutHours;
  }

  // Initialize the service
  Future<void> initialize() async {
    try {
      _logger.i('Initializing AuthService...');
      
      // Configure Dio for backend communication
      _dio.options = BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: Duration(seconds: AppConfig.connectionTimeout),
        receiveTimeout: Duration(seconds: AppConfig.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': '${AppConfig.appName}/${AppConfig.appVersion}',
        },
      );

      // Check for existing session
      await _checkExistingSession();
      
      // Check lockout status
      await _checkLockoutStatus();
      
      // Check connectivity
      await _checkConnectivity();
      
      _logger.i('AuthService initialized successfully');
    } catch (e) {
      _logger.e('Error initializing AuthService: $e');
      _setError('Erreur lors de l\'initialisation du service d\'authentification');
    }
  }

  // Check connectivity
  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      _isOffline = connectivityResult == ConnectivityResult.none;
      
      // Listen for connectivity changes
      Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
        final result = results.first;
        _isOffline = result == ConnectivityResult.none;
        _logger.i('Connectivity changed. Offline: $_isOffline');
        notifyListeners();
      });
    } catch (e) {
      _logger.e('Error checking connectivity: $e');
      _isOffline = true; // Assume offline if we can't check
    }
  }

  // Check existing session
  Future<void> _checkExistingSession() async {
    try {
      final storedToken = await _secureStorage.read(key: AppConfig.authTokenKey);
      final storedUserData = await _secureStorage.read(key: AppConfig.userDataKey);
      final storedLoginTime = await _secureStorage.read(key: AppConfig.lastLoginKey);

      if (storedToken != null && storedUserData != null) {
        final userData = jsonDecode(storedUserData);
        _currentUser = User.fromJson(userData);
        _token = storedToken;
        
        if (storedLoginTime != null) {
          _lastLoginTime = DateTime.parse(storedLoginTime);
        }

        // Check if session is still valid
        if (!isSessionExpired) {
          _isAuthenticated = true;
          _dio.options.headers['Authorization'] = 'Bearer $token';
          _logger.i('Existing session restored for user: ${_currentUser!.username}');
        } else {
          await logout(); // Session expired, logout
        }
      }
    } catch (e) {
      _logger.e('Error checking existing session: $e');
      await logout(); // Clear any corrupted data
    }
  }

  // Check lockout status
  Future<void> _checkLockoutStatus() async {
    try {
      final lockoutTimeStr = await _secureStorage.read(key: AppConfig.lockoutEndKey);
      final attemptsStr = await _secureStorage.read(key: AppConfig.loginAttemptsKey);

      if (lockoutTimeStr != null) {
        final lockoutTime = DateTime.parse(lockoutTimeStr);
        if (DateTime.now().isBefore(lockoutTime)) {
          _isLocked = true;
          _lockoutEndTime = lockoutTime;
        } else {
          // Lockout period expired, reset attempts
          await _resetLoginAttempts();
        }
      }

      if (attemptsStr != null) {
        _loginAttempts = int.parse(attemptsStr);
      }
    } catch (e) {
      _logger.e('Error checking lockout status: $e');
    }
  }

  // Login with username and password
  Future<bool> login(String username, String password) async {
    if (_isLocked) {
      _setError('Compte temporairement bloqué. Réessayez plus tard.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      _logger.i('Attempting login for user: $username (Offline: $_isOffline)');

      bool success = false;
      
      if (_isOffline) {
        // Offline mode: Try cached authentication
        success = await _loginOffline(username, password);
      } else {
        // Online mode: Call backend login endpoint
        success = await _loginViaBackend(username, password);
      }

      if (success) {
        await _resetLoginAttempts();
        _logger.i('Login successful for user: $username');
        notifyListeners();
        return true;
      }
    } catch (e) {
      _logger.e('Login error: $e');
      await _handleLoginFailure();
      _setError(AppConfig.authError);
    } finally {
      _setLoading(false);
    }
    
    return false;
  }

  // Login via backend (online)
  Future<bool> _loginViaBackend(String username, String password) async {
    try {
      // Test de connexion au backend
      _logger.i('Tentative de connexion à: ${AppConfig.baseUrl}${AppConfig.loginEndpoint}');
      _logger.i('Username envoyé: "$username"');
      _logger.i('Password envoyé: "${password.isNotEmpty ? "***" : "EMPTY"}"');
      
      // Le backend attend application/x-www-form-urlencoded
      final formData = FormData.fromMap({
        'username': username,
        'password': password,
      });
      
      _logger.i('FormData créé: ${formData.fields}');
      
      final response = await _dio.post(
        AppConfig.loginEndpoint,
        data: formData,
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );
      
      _logger.i('Réponse du backend: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Store token (backend returns Keycloak token)
        _token = data['access_token'];
        await _secureStorage.write(key: AppConfig.authTokenKey, value: _token!);

        // Extract user info from token or backend response
        Map<String, dynamic> userData;
        if (data.containsKey('user')) {
          // Backend provides user info separately
          userData = data['user'];
        } else {
          // Decode JWT token to get user info
          userData = _decodeJwtToken(_token!);
        }
        
        _currentUser = User.fromJson(userData);
        
        // Store user data
        await _secureStorage.write(
          key: AppConfig.userDataKey,
          value: jsonEncode(_currentUser!.toJson()),
        );

        // Store login time
        _lastLoginTime = DateTime.now();
        await _secureStorage.write(
          key: AppConfig.lastLoginKey,
          value: _lastLoginTime!.toIso8601String(),
        );

        // Configure Dio with token
        _dio.options.headers['Authorization'] = 'Bearer $token';

        _isAuthenticated = true;
        return true;
      }
      
      throw Exception('Backend login failed with status: ${response.statusCode}');
    } catch (e) {
      _logger.e('Backend login error: $e');
      throw e;
    }
  }

  // Login offline (cached authentication)
  Future<bool> _loginOffline(String username, String password) async {
    try {
      // Check if we have cached user data for this username
      final storedUserData = await _secureStorage.read(key: AppConfig.userDataKey);
      if (storedUserData != null) {
        final userData = jsonDecode(storedUserData);
        final cachedUser = User.fromJson(userData);
        
        if (cachedUser.username == username) {
          // In offline mode, we need to verify credentials locally
          // This is a simplified version - in production, you'd want secure credential storage
          final storedPasswordHash = await _secureStorage.read(key: 'password_hash');
          if (storedPasswordHash != null) {
            // Here you would verify the password hash
            // For demo purposes, we'll allow offline login if user exists
            _currentUser = cachedUser;
            _isAuthenticated = true;
            _lastLoginTime = DateTime.now();
            
            _logger.i('Offline authentication successful for user: $username');
            return true;
          }
        }
      }
      
      _setError('Aucune connexion réseau et aucune session locale trouvée pour cet utilisateur');
      return false;
    } catch (e) {
      _logger.e('Offline login error: $e');
      _setError('Erreur lors de l\'authentification hors ligne: $e');
      return false;
    }
  }

  // Decode JWT token (if needed)
  Map<String, dynamic> _decodeJwtToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid JWT token');
      }
      
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = base64Url.decode(normalized);
      final jsonString = utf8.decode(decoded);
      
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      _logger.e('Error decoding JWT token: $e');
      throw Exception('Failed to decode JWT token');
    }
  }

  // Handle login failure
  Future<void> _handleLoginFailure() async {
    _loginAttempts++;
    await _secureStorage.write(key: AppConfig.loginAttemptsKey, value: _loginAttempts.toString());

    if (_loginAttempts >= AppConfig.maxLoginAttempts) {
      _isLocked = true;
      _lockoutEndTime = DateTime.now().add(AppConfig.lockoutDuration);
      await _secureStorage.write(
        key: AppConfig.lockoutEndKey,
        value: _lockoutEndTime!.toIso8601String(),
      );
      _setError('Trop de tentatives de connexion. Compte bloqué pour ${AppConfig.lockoutDuration.inMinutes} minutes.');
    } else {
      final remainingAttempts = AppConfig.maxLoginAttempts - _loginAttempts;
      _setError('Identifiants incorrects. $remainingAttempts tentative(s) restante(s).');
    }
  }

  // Reset login attempts
  Future<void> _resetLoginAttempts() async {
    _loginAttempts = 0;
    _isLocked = false;
    _lockoutEndTime = null;
    await _secureStorage.delete(key: AppConfig.loginAttemptsKey);
    await _secureStorage.delete(key: AppConfig.lockoutEndKey);
  }

  // Biometric authentication
  Future<bool> authenticateWithBiometrics() async {
    if (!canUseBiometrics) {
      _setError('Aucun utilisateur connecté pour l\'authentification biométrique');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final canAuthenticate = await _localAuth.canCheckBiometrics;
      if (!canAuthenticate) {
        _setError('L\'authentification biométrique n\'est pas disponible sur cet appareil');
        return false;
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: AppConfig.biometricReason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        _logger.i('Biometric authentication successful');
        return true;
      } else {
        _setError('Échec de l\'authentification biométrique');
        return false;
      }
    } catch (e) {
      _logger.e('Biometric authentication error: $e');
      _setError('Erreur lors de l\'authentification biométrique: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _logger.i('Logging out user: ${_currentUser?.username}');

      // Call backend logout if online
      if (_token != null && !_isOffline) {
        try {
          await _dio.post(AppConfig.logoutEndpoint);
        } catch (e) {
          _logger.w('Backend logout failed (this is normal): $e');
        }
      }

      // Clear local data
      _isAuthenticated = false;
      _currentUser = null;
      _token = null;
      _lastLoginTime = null;
      await _resetLoginAttempts();

      // Clear secure storage
      await _secureStorage.deleteAll();

      // Remove authorization header
      _dio.options.headers.remove('Authorization');

      _logger.i('Logout successful');
      notifyListeners();
    } catch (e) {
      _logger.e('Error during logout: $e');
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    if (_token == null) return false;

    try {
      if (_isOffline) {
        _logger.w('Cannot refresh token while offline');
        return false;
      }

      // Call backend refresh endpoint
      final response = await _dio.post(AppConfig.refreshTokenEndpoint);
      
      if (response.statusCode == 200) {
        _token = response.data['access_token'];
        await _secureStorage.write(key: AppConfig.authTokenKey, value: _token!);
        _dio.options.headers['Authorization'] = 'Bearer $token';
        
        _lastLoginTime = DateTime.now();
        await _secureStorage.write(
          key: AppConfig.lastLoginKey,
          value: _lastLoginTime!.toIso8601String(),
        );
        
        return true;
      }
    } catch (e) {
      _logger.e('Error refreshing token: $e');
    }
    
    return false;
  }

  // Check if user has specific role
  bool hasRole(String role) {
    return _currentUser?.roles.contains(role) ?? false;
  }

  // Check if user has any of the specified roles
  bool hasAnyRole(List<String> roles) {
    if (_currentUser == null) return false;
    return roles.any((role) => _currentUser!.roles.contains(role));
  }

  // Check if user has specific permission
  bool hasPermission(String permission) {
    return _currentUser?.roles.contains(permission) ?? false;
  }

  // Get user display name
  String get userDisplayName => _currentUser?.fullName ?? 'Utilisateur';

  // Check if session needs refresh
  bool get needsTokenRefresh {
    if (_lastLoginTime == null) return true;
    final sessionDuration = DateTime.now().difference(_lastLoginTime!);
    return sessionDuration.inHours >= (AppConfig.sessionTimeoutHours - 1); // Refresh 1 hour before expiry
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
