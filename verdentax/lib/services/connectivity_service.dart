import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import '../config/config.dart';

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Logger _logger = Logger();
  final StreamController<ConnectivityResult> _connectivityController = 
      StreamController<ConnectivityResult>.broadcast();

  bool _isOnline = true;
  bool _hasInternet = true;
  DateTime? _lastOnlineTime;
  DateTime? _lastOfflineTime;
  int _offlineCount = 0;

  // Getters
  bool get isOnline => _isOnline;
  bool get hasInternet => _hasInternet;
  DateTime? get lastOnlineTime => _lastOnlineTime;
  DateTime? get lastOfflineTime => _lastOfflineTime;
  int get offlineCount => _offlineCount;
  Stream<ConnectivityResult> get connectivityStream => _connectivityController.stream;

  // Initialize the service
  Future<void> initialize() async {
    try {
      _logger.i('Initializing ConnectivityService...');
      
      // Check initial connectivity
      await _checkConnectivity();
      
      // Listen for connectivity changes
      Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
        _handleConnectivityChange(results.first);
      });
      
      // Periodic connectivity check
      _startPeriodicCheck();
      
      _logger.i('ConnectivityService initialized successfully');
    } catch (e) {
      _logger.e('Error initializing ConnectivityService: $e');
    }
  }

  // Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      final connectivityResult = connectivityResults.first;
      await _updateConnectivityStatus(connectivityResult);
    } catch (e) {
      _logger.e('Error checking connectivity: $e');
    }
  }

  // Handle connectivity changes
  void _handleConnectivityChange(ConnectivityResult result) {
    _updateConnectivityStatus(result);
  }

  // Update connectivity status
  Future<void> _updateConnectivityStatus(ConnectivityResult result) async {
    final wasOnline = _isOnline;
    
    _isOnline = result != ConnectivityResult.none;
    
    // Check if we actually have internet access
    if (_isOnline) {
      _hasInternet = await _checkInternetAccess();
    } else {
      _hasInternet = false;
    }

    // Update timestamps
    if (_isOnline && !wasOnline) {
      _lastOnlineTime = DateTime.now();
      _logger.i('Connection restored at $_lastOnlineTime');
    } else if (!_isOnline && wasOnline) {
      _lastOfflineTime = DateTime.now();
      _offlineCount++;
      _logger.i('Connection lost at $_lastOfflineTime (offline count: $_offlineCount)');
    }

    // Broadcast connectivity change
    _connectivityController.add(result);
    
    _logger.d('Connectivity updated: $_isOnline (has internet: $_hasInternet)');
    
    // Notify listeners of state change
    notifyListeners();
  }

  // Check if we have actual internet access
  Future<bool> _checkInternetAccess() async {
    try {
      // Simple connectivity check - you can customize this
      // For now, we assume connectivity means internet access
      // In production, you might want to ping a reliable endpoint
      return _isOnline;
    } catch (e) {
      _logger.e('Error checking internet access: $e');
      return false;
    }
  }

  // Start periodic connectivity checks
  void _startPeriodicCheck() {
    Timer.periodic(AppConfig.syncInterval, (timer) {
      _checkConnectivity();
    });
  }

  // Wait for connectivity
  Future<bool> waitForConnectivity({Duration timeout = const Duration(seconds: 30)}) async {
    if (_isOnline && _hasInternet) return true;

    final completer = Completer<bool>();
    late StreamSubscription subscription;
    
    subscription = connectivityStream.listen((result) {
      if (_isOnline && _hasInternet) {
        subscription.cancel();
        completer.complete(true);
      }
    });

    // Timeout
    Timer(timeout, () {
      subscription.cancel();
      completer.complete(false);
    });

    return completer.future;
  }

  // Check if we can perform online operations
  bool canPerformOnlineOperation() {
    return _isOnline && _hasInternet;
  }

  // Get connectivity status description
  String get connectivityStatus {
    if (!_isOnline) {
      return 'Hors ligne';
    } else if (!_hasInternet) {
      return 'Connecté sans accès Internet';
    } else {
      return 'En ligne';
    }
  }

  // Get connectivity status for UI
  Map<String, dynamic> getConnectivityInfo() {
    return {
      'isOnline': _isOnline,
      'hasInternet': _hasInternet,
      'status': connectivityStatus,
      'lastOnlineTime': _lastOnlineTime?.toIso8601String(),
      'lastOfflineTime': _lastOfflineTime?.toIso8601String(),
      'offlineCount': _offlineCount,
      'downtimeDuration': _lastOfflineTime != null 
          ? DateTime.now().difference(_lastOfflineTime!).inMinutes 
          : 0,
    };
  }

  // Check if we should sync data
  bool shouldSyncData() {
    return _isOnline && _hasInternet;
  }

  // Get offline duration in minutes
  int get offlineDurationMinutes {
    if (_lastOfflineTime == null) return 0;
    return DateTime.now().difference(_lastOfflineTime!).inMinutes;
  }

  // Check if offline duration exceeds threshold
  bool isOfflineTooLong({int maxMinutes = 60}) {
    return offlineDurationMinutes > maxMinutes;
  }

  // Reset offline statistics
  void resetOfflineStats() {
    _lastOfflineTime = null;
    _offlineCount = 0;
    _logger.i('Offline statistics reset');
  }

  // Dispose the service
  void dispose() {
    _connectivityController.close();
  }

  // Connectivity monitoring for specific operations
  Future<T> executeWithConnectivityCheck<T>(
    Future<T> Function() onlineOperation,
    Future<T> Function() offlineOperation, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (canPerformOnlineOperation()) {
      try {
        return await onlineOperation();
      } catch (e) {
        _logger.w('Online operation failed, falling back to offline: $e');
        return await offlineOperation();
      }
    } else {
      _logger.i('No connectivity, executing offline operation');
      return await offlineOperation();
    }
  }

  // Batch operations with connectivity awareness
  Future<List<T>> executeBatchWithConnectivityCheck<T>(
    List<Future<T> Function()> operations,
    Future<T> Function() offlineFallback, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final results = <T>[];
    
    for (final operation in operations) {
      if (canPerformOnlineOperation()) {
        try {
          final result = await operation();
          results.add(result);
        } catch (e) {
          _logger.w('Batch operation failed, using fallback: $e');
          final fallbackResult = await offlineFallback();
          results.add(fallbackResult);
        }
      } else {
        _logger.i('No connectivity, using fallback for batch operation');
        final fallbackResult = await offlineFallback();
        results.add(fallbackResult);
      }
    }
    
    return results;
  }

  // Connectivity monitoring for background tasks
  Future<void> monitorConnectivityForBackgroundTask(
    String taskName,
    Future<void> Function() task,
    Future<void> Function()? onConnectivityLost, {
    Duration checkInterval = const Duration(seconds: 10),
  }) async {
    late StreamSubscription subscription;
    
    subscription = connectivityStream.listen((result) async {
      if (!canPerformOnlineOperation()) {
        _logger.w('Connectivity lost during $taskName');
        await onConnectivityLost?.call();
        subscription.cancel();
      }
    });

    try {
      if (canPerformOnlineOperation()) {
        await task();
      } else {
        _logger.w('Cannot start $taskName: No connectivity');
        await onConnectivityLost?.call();
      }
    } catch (e) {
      _logger.e('Error in background task $taskName: $e');
    } finally {
      subscription.cancel();
    }
  }

  // Get detailed connectivity report
  Map<String, dynamic> getConnectivityReport() {
    final now = DateTime.now();
    
    return {
      'current_status': {
        'isOnline': _isOnline,
        'hasInternet': _hasInternet,
        'status': connectivityStatus,
        'timestamp': now.toIso8601String(),
      },
      'statistics': {
        'lastOnlineTime': _lastOnlineTime?.toIso8601String(),
        'lastOfflineTime': _lastOfflineTime?.toIso8601String(),
        'offlineCount': _offlineCount,
        'totalOfflineMinutes': offlineDurationMinutes,
        'isOfflineTooLong': isOfflineTooLong(),
      },
      'recommendations': _getConnectivityRecommendations(),
    };
  }

  // Get connectivity recommendations
  List<String> _getConnectivityRecommendations() {
    final recommendations = <String>[];
    
    if (!_isOnline) {
      recommendations.add('Vérifiez votre connexion WiFi ou mobile');
      recommendations.add('Assurez-vous que les données mobiles sont activées');
    } else if (!_hasInternet) {
      recommendations.add('Votre connexion semble limitée');
      recommendations.add('Essayez de vous connecter à un autre réseau');
    }
    
    if (isOfflineTooLong()) {
      recommendations.add('Vous êtes hors ligne depuis ${offlineDurationMinutes} minutes');
      recommendations.add('Considérez de trouver une connexion stable');
    }
    
    if (_offlineCount > 5) {
      recommendations.add('Vous avez eu ${_offlineCount} déconnexions');
      recommendations.add('Vérifiez la stabilité de votre connexion');
    }
    
    return recommendations;
  }
}
