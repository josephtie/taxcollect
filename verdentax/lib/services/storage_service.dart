import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../config/config.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final Logger _logger = Logger();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  // Initialize the service
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _logger.i('StorageService initialized successfully');
    } catch (e) {
      _logger.e('Error initializing StorageService: $e');
    }
  }

  // Secure Storage Methods (sensitive data)
  Future<void> storeSecureData(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      _logger.d('Secure data stored for key: $key');
    } catch (e) {
      _logger.e('Error storing secure data for key $key: $e');
      throw Exception('Failed to store secure data');
    }
  }

  Future<String?> getSecureData(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      _logger.d('Secure data retrieved for key: $key');
      return value;
    } catch (e) {
      _logger.e('Error retrieving secure data for key $key: $e');
      return null;
    }
  }

  Future<void> removeSecureData(String key) async {
    try {
      await _secureStorage.delete(key: key);
      _logger.d('Secure data removed for key: $key');
    } catch (e) {
      _logger.e('Error removing secure data for key $key: $e');
    }
  }

  Future<void> clearAllSecureData() async {
    try {
      await _secureStorage.deleteAll();
      _logger.d('All secure data cleared');
    } catch (e) {
      _logger.e('Error clearing secure data: $e');
    }
  }

  // Local Storage Methods (non-sensitive data)
  Future<void> storeLocalData(String key, dynamic value) async {
    try {
      if (_prefs == null) {
        throw Exception('SharedPreferences not initialized');
      }

      String stringValue;
      if (value is String) {
        stringValue = value;
      } else if (value is bool) {
        stringValue = value.toString();
      } else if (value is int) {
        stringValue = value.toString();
      } else if (value is double) {
        stringValue = value.toString();
      } else if (value is List) {
        stringValue = jsonEncode(value);
      } else if (value is Map) {
        stringValue = jsonEncode(value);
      } else {
        stringValue = value.toString();
      }

      await _prefs!.setString(key, stringValue);
      _logger.d('Local data stored for key: $key');
    } catch (e) {
      _logger.e('Error storing local data for key $key: $e');
      throw Exception('Failed to store local data');
    }
  }

  Future<String?> getLocalData(String key) async {
    try {
      if (_prefs == null) return null;
      
      final value = _prefs!.getString(key);
      _logger.d('Local data retrieved for key: $key');
      return value;
    } catch (e) {
      _logger.e('Error retrieving local data for key $key: $e');
      return null;
    }
  }

  Future<bool?> getLocalBool(String key) async {
    try {
      if (_prefs == null) return null;
      
      final value = _prefs!.getBool(key);
      _logger.d('Local bool retrieved for key: $key: $value');
      return value;
    } catch (e) {
      _logger.e('Error retrieving local bool for key $key: $e');
      return null;
    }
  }

  Future<int?> getLocalInt(String key) async {
    try {
      if (_prefs == null) return null;
      
      final value = _prefs!.getInt(key);
      _logger.d('Local int retrieved for key: $key: $value');
      return value;
    } catch (e) {
      _logger.e('Error retrieving local int for key $key: $e');
      return null;
    }
  }

  Future<double?> getLocalDouble(String key) async {
    try {
      if (_prefs == null) return null;
      
      final value = _prefs!.getDouble(key);
      _logger.d('Local double retrieved for key: $key: $value');
      return value;
    } catch (e) {
      _logger.e('Error retrieving local double for key $key: $e');
      return null;
    }
  }

  Future<List<String>?> getLocalStringList(String key) async {
    try {
      if (_prefs == null) return null;
      
      final value = _prefs!.getStringList(key);
      _logger.d('Local string list retrieved for key: $key');
      return value;
    } catch (e) {
      _logger.e('Error retrieving local string list for key $key: $e');
      return null;
    }
  }

  Future<void> removeLocalData(String key) async {
    try {
      if (_prefs == null) return;
      
      await _prefs!.remove(key);
      _logger.d('Local data removed for key: $key');
    } catch (e) {
      _logger.e('Error removing local data for key $key: $e');
    }
  }

  Future<void> clearAllLocalData() async {
    try {
      if (_prefs == null) return;
      
      await _prefs!.clear();
      _logger.d('All local data cleared');
    } catch (e) {
      _logger.e('Error clearing local data: $e');
    }
  }

  // User Session Management
  Future<void> storeUserSession(Map<String, dynamic> userData) async {
    try {
      await storeSecureData(AppConfig.userDataKey, jsonEncode(userData));
      await storeLocalData('last_login_timestamp', DateTime.now().millisecondsSinceEpoch);
      _logger.i('User session stored');
    } catch (e) {
      _logger.e('Error storing user session: $e');
      throw Exception('Failed to store user session');
    }
  }

  Future<Map<String, dynamic>?> getUserSession() async {
    try {
      final String? encryptedData = await _secureStorage.read(key: AppConfig.userDataKey);
      if (encryptedData != null && encryptedData.isNotEmpty) {
        final decryptedData = jsonDecode(encryptedData);
        return decryptedData as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      _logger.e('Error retrieving user session: $e');
      return null;
    }
  }

  Future<void> clearUserSession() async {
    try {
      await removeSecureData(AppConfig.userDataKey);
      await removeSecureData(AppConfig.authTokenKey);
      await removeSecureData(AppConfig.lastLoginKey);
      await removeLocalData('last_login_timestamp');
      _logger.i('User session cleared');
    } catch (e) {
      _logger.e('Error clearing user session: $e');
    }
  }

  // App Settings
  Future<void> storeAppSettings(Map<String, dynamic> settings) async {
    try {
      for (String key in settings.keys) {
        final value = settings[key];
        if (value is bool) {
          await _prefs!.setBool(key, value);
        } else if (value is int) {
          await _prefs!.setInt(key, value);
        } else if (value is double) {
          await _prefs!.setDouble(key, value);
        } else if (value is String) {
          await _prefs!.setString(key, value);
        } else if (value is List) {
          await _prefs!.setStringList(key, List<String>.from(value));
        } else {
          await _prefs!.setString(key, value.toString());
        }
      }
      _logger.i('App settings stored');
    } catch (e) {
      _logger.e('Error storing app settings: $e');
      throw Exception('Failed to store app settings');
    }
  }

  Future<Map<String, dynamic>> getAppSettings(List<String> keys) async {
    try {
      final Map<String, dynamic> settings = {};
      for (String key in keys) {
        final value = _prefs!.get(key);
        if (value != null) {
          settings[key] = value;
        }
      }
      return settings;
    } catch (e) {
      _logger.e('Error retrieving app settings: $e');
      return {};
    }
  }

  // Offline Data Storage
  Future<void> storeOfflineData(String key, Map<String, dynamic> data) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final offlineData = {
        'data': data,
        'timestamp': timestamp,
        'synced': false,
      };
      
      await storeLocalData('offline_$key', jsonEncode(offlineData));
      _logger.d('Offline data stored for key: $key');
    } catch (e) {
      _logger.e('Error storing offline data for key $key: $e');
      throw Exception('Failed to store offline data');
    }
  }

  Future<Map<String, dynamic>?> getOfflineData(String key) async {
    try {
      final offlineDataJson = await getLocalData('offline_$key');
      if (offlineDataJson != null) {
        final offlineData = jsonDecode(offlineDataJson) as Map<String, dynamic>;
        return offlineData['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      _logger.e('Error retrieving offline data for key $key: $e');
      return null;
    }
  }

  Future<List<String>> getOfflineDataKeys() async {
    try {
      if (_prefs == null) return [];
      
      final keys = _prefs!.getKeys();
      return keys.where((key) => key.startsWith('offline_')).map((key) => key.substring(8)).toList();
    } catch (e) {
      _logger.e('Error getting offline data keys: $e');
      return [];
    }
  }

  Future<void> markOfflineDataAsSynced(String key) async {
    try {
      final offlineDataJson = await getLocalData('offline_$key');
      if (offlineDataJson != null) {
        final offlineData = jsonDecode(offlineDataJson) as Map<String, dynamic>;
        offlineData['synced'] = true;
        offlineData['sync_timestamp'] = DateTime.now().millisecondsSinceEpoch;
        
        await storeLocalData('offline_$key', jsonEncode(offlineData));
        _logger.d('Offline data marked as synced for key: $key');
      }
    } catch (e) {
      _logger.e('Error marking offline data as synced for key $key: $e');
    }
  }

  Future<void> removeOfflineData(String key) async {
    try {
      await removeLocalData('offline_$key');
      _logger.d('Offline data removed for key: $key');
    } catch (e) {
      _logger.e('Error removing offline data for key $key: $e');
    }
  }

  Future<void> cleanupExpiredOfflineData() async {
    try {
      final keys = await getOfflineDataKeys();
      final now = DateTime.now().millisecondsSinceEpoch;
      final retentionPeriod = AppConfig.offlineDataRetention.inMilliseconds;
      
      for (String key in keys) {
        final offlineDataJson = await getLocalData('offline_$key');
        if (offlineDataJson != null) {
          final offlineData = jsonDecode(offlineDataJson) as Map<String, dynamic>;
          final timestamp = offlineData['timestamp'] as int;
          
          if (now - timestamp > retentionPeriod) {
            await removeOfflineData(key);
            _logger.d('Expired offline data removed for key: $key');
          }
        }
      }
    } catch (e) {
      _logger.e('Error cleaning up expired offline data: $e');
    }
  }

  // Cache Management
  Future<void> storeCachedData(String key, dynamic data, {Duration? duration}) async {
    try {
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expiry': duration?.inMilliseconds ?? AppConfig.dataCacheDuration.inMilliseconds,
      };
      
      await storeLocalData('cache_$key', jsonEncode(cacheData));
      _logger.d('Cached data stored for key: $key');
    } catch (e) {
      _logger.e('Error storing cached data for key $key: $e');
    }
  }

  Future<T?> getCachedData<T>(String key) async {
    try {
      final cacheDataJson = await getLocalData('cache_$key');
      if (cacheDataJson != null) {
        final cacheData = jsonDecode(cacheDataJson) as Map<String, dynamic>;
        final timestamp = cacheData['timestamp'] as int;
        final expiry = cacheData['expiry'] as int;
        
        if (DateTime.now().millisecondsSinceEpoch - timestamp < expiry) {
          return cacheData['data'] as T?;
        } else {
          // Cache expired, remove it
          await removeLocalData('cache_$key');
          _logger.d('Expired cache data removed for key: $key');
        }
      }
      return null;
    } catch (e) {
      _logger.e('Error retrieving cached data for key $key: $e');
      return null;
    }
  }

  // Storage Statistics
  Future<Map<String, int>> getStorageStats() async {
    try {
      final secureKeys = await _secureStorage.readAll();
      final localKeys = _prefs?.getKeys() ?? <String>[];
      
      return {
        'secure_keys': secureKeys.length,
        'local_keys': localKeys.length,
        'offline_data': (await getOfflineDataKeys()).length,
      };
    } catch (e) {
      _logger.e('Error getting storage stats: $e');
      return {};
    }
  }
}
