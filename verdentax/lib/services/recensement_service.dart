import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import '../config/config.dart';
import '../models/models.dart';
import '../models/recensement.dart';
import '../services/services.dart';

class RecensementService {
  static final RecensementService _instance = RecensementService._internal();
  factory RecensementService() => _instance;
  RecensementService._internal();

  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();
  final ApiService _apiService = ApiService();

  // Generate unique contribuable number
  String generateNumeroContribuable() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _uuid.v4().substring(0, 8).toUpperCase();
    return 'VTX${timestamp.toString().substring(6)}$random';
  }

  // Generate QR code content
  String generateQRCode(String numeroContribuable) {
    return '${AppConfig.qrCodePrefix}_$numeroContribuable';
  }

  // Create new contribuable
  Future<ContribuableForm> createContribuable({
    required String telephone,
    required ContribuableType type,
    required String activite,
    required String zoneId,
    required TypePieceIdentite typePiece,
    required String numeroPiece,
    String? nom,
    String? prenoms,
    String? marche,
    String? quartier,
    double? latitude,
    double? longitude,
    String? photoPiece,
    String? photoContribuable,
    required String agentId,
    double? baseImposable,
  }) async {
    try {
      _logger.i('Creating new contribuable: $telephone');

      // Validate required fields
      if (!_validateRequiredFields(telephone, type, activite, zoneId, typePiece, numeroPiece)) {
        throw Exception('Champs obligatoires manquants');
      }

      // Check if contribuable already exists
      final existingContribuable = await findContribuableByTelephone(telephone);
      if (existingContribuable != null) {
        throw Exception('Un contribuable avec ce numéro de téléphone existe déjà');
      }

      // Get current location if not provided
      if (latitude == null || longitude == null) {
        final position = await _getCurrentLocation();
        latitude = position?.latitude;
        longitude = position?.longitude;
      }

      // Generate unique identifiers
      final numeroContribuable = generateNumeroContribuable();
      final qrCode = generateQRCode(numeroContribuable);

      // Check if validation is required
      final necessiteValidation = _requiresValidation(type, activite, zoneId);

      // Create contribuable form
      final contribuable = ContribuableForm(
        telephone: telephone,
        type: type,
        activite: activite,
        zoneId: zoneId,
        typePiece: typePiece,
        numeroPiece: numeroPiece,
        numeroContribuable: numeroContribuable,
        qrCode: qrCode,
        agentId: agentId,
        nom: nom,
        prenoms: prenoms,
        marche: marche,
        quartier: quartier,
        latitude: latitude,
        longitude: longitude,
        photoPiece: photoPiece,
        photoContribuable: photoContribuable,
        necessiteValidation: necessiteValidation,
        baseImposable: baseImposable,
      );

      // Save locally first
      await _saveContribuableLocally(contribuable);

      // Try to sync if online
      if (_connectivityService.canPerformOnlineOperation()) {
        try {
          await _syncContribuable(contribuable);
        } catch (e) {
          _logger.w('Failed to sync contribuable immediately: $e');
          // Keep local copy for later sync
        }
      }

      _logger.i('Contribuable created successfully: $numeroContribuable');
      return contribuable;
    } catch (e) {
      _logger.e('Error creating contribuable: $e');
      rethrow;
    }
  }

  // Update existing contribuable
  Future<ContribuableForm> updateContribuable(
    ContribuableForm contribuable,
    String agentId, {
    String? raisonModification,
  }) async {
    try {
      _logger.i('Updating contribuable: ${contribuable.numeroContribuable}');

      // Create history entry
      if (raisonModification != null) {
        await _createHistoriqueEntry(contribuable, agentId, raisonModification);
      }

      // Update modification date and version
      final updatedContribuable = contribuable.copyWith(
        version: contribuable.version + 1,
        syncStatus: SyncStatus.pending,
      );

      // Save locally
      await _saveContribuableLocally(updatedContribuable);

      // Try to sync if online
      if (_connectivityService.canPerformOnlineOperation()) {
        try {
          await _syncContribuable(updatedContribuable);
        } catch (e) {
          _logger.w('Failed to sync updated contribuable: $e');
        }
      }

      _logger.i('Contribuable updated successfully');
      return updatedContribuable;
    } catch (e) {
      _logger.e('Error updating contribuable: $e');
      rethrow;
    }
  }

  // Search contribuables
  Future<List<ContribuableSearchResult>> searchContribuables({
    String? query,
    String? telephone,
    String? numeroContribuable,
    String? numeroPiece,
    ContribuableType? type,
    String? zoneId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      _logger.i('Searching contribuables with query: $query');

      final results = <ContribuableSearchResult>[];

      // Search locally first
      final localResults = await _searchContribuablesLocally(
        query: query,
        telephone: telephone,
        numeroContribuable: numeroContribuable,
        numeroPiece: numeroPiece,
        type: type,
        zoneId: zoneId,
        limit: limit,
        offset: offset,
      );

      results.addAll(localResults);

      // If online, search on server and merge results
      if (_connectivityService.canPerformOnlineOperation()) {
        try {
          final serverResults = await _searchContribuablesOnServer(
            query: query,
            telephone: telephone,
            numeroContribuable: numeroContribuable,
            numeroPiece: numeroPiece,
            type: type,
            zoneId: zoneId,
            limit: limit,
            offset: offset,
          );

          // Merge results, avoiding duplicates
          for (final serverResult in serverResults) {
            if (!results.any((r) => r.contribuable.numeroContribuable == serverResult.contribuable.numeroContribuable)) {
              results.add(serverResult);
            }
          }
        } catch (e) {
          _logger.w('Failed to search on server, using local results only: $e');
        }
      }

      // Sort by relevance score
      results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

      return results.take(limit).toList();
    } catch (e) {
      _logger.e('Error searching contribuables: $e');
      rethrow;
    }
  }

  // Find contribuable by telephone
  Future<ContribuableForm?> findContribuableByTelephone(String telephone) async {
    try {
      final results = await searchContribuables(telephone: telephone, limit: 1);
      return results.isNotEmpty ? results.first.contribuable : null;
    } catch (e) {
      _logger.e('Error finding contribuable by telephone: $e');
      return null;
    }
  }

  // Find contribuable by numero
  Future<ContribuableForm?> findContribuableByNumero(String numeroContribuable) async {
    try {
      final results = await searchContribuables(numeroContribuable: numeroContribuable, limit: 1);
      return results.isNotEmpty ? results.first.contribuable : null;
    } catch (e) {
      _logger.e('Error finding contribuable by numero: $e');
      return null;
    }
  }

  // Get contribuable by ID
  Future<ContribuableForm?> getContribuableById(int id) async {
    try {
      // Try local first
      final localContribuable = await _getContribuableLocally(id);
      if (localContribuable != null) {
        return localContribuable;
      }

      // Try server if online
      if (_connectivityService.canPerformOnlineOperation()) {
        final serverContribuable = await _getContribuableFromServer(id);
        if (serverContribuable != null) {
          // Cache locally
          await _saveContribuableLocally(serverContribuable);
          return serverContribuable;
        }
      }

      return null;
    } catch (e) {
      _logger.e('Error getting contribuable by ID: $e');
      return null;
    }
  }

  // Get all contribuables for an agent
  Future<List<ContribuableForm>> getContribuablesByAgent(String agentId) async {
    try {
      _logger.i('Getting contribuables for agent: $agentId');

      // Get local contribuables
      final localContribuables = await _getContribuablesByAgentLocally(agentId);

      // If online, get server contribuables and merge
      if (_connectivityService.canPerformOnlineOperation()) {
        try {
          final serverContribuables = await _getContribuablesByAgentFromServer(agentId);
          
          // Merge results
          final allContribuables = <String, ContribuableForm>{};
          
          for (final contribuable in localContribuables) {
            allContribuables[contribuable.numeroContribuable] = contribuable;
          }
          
          for (final contribuable in serverContribuables) {
            allContribuables[contribuable.numeroContribuable] = contribuable;
          }
          
          return allContribuables.values.toList();
        } catch (e) {
          _logger.w('Failed to get server contribuables, using local only: $e');
        }
      }

      return localContribuables;
    } catch (e) {
      _logger.e('Error getting contribuables by agent: $e');
      rethrow;
    }
  }

  // Sync pending contribuables
  Future<List<ContribuableForm>> syncPendingContribuables() async {
    try {
      _logger.i('Syncing pending contribuables');

      if (!_connectivityService.canPerformOnlineOperation()) {
        throw Exception('Pas de connexion disponible pour la synchronisation');
      }

      final pendingContribuables = await _getPendingContribuables();
      final syncedContribuables = <ContribuableForm>[];

      for (final contribuable in pendingContribuables) {
        try {
          await _syncContribuable(contribuable);
          syncedContribuables.add(contribuable);
        } catch (e) {
          _logger.e('Failed to sync contribuable ${contribuable.numeroContribuable}: $e');
        }
      }

      _logger.i('Synced ${syncedContribuables.length} contribuables');
      return syncedContribuables;
    } catch (e) {
      _logger.e('Error syncing pending contribuables: $e');
      rethrow;
    }
  }

  // Get recensement statistics
  Future<RecensementStatistics> getRecensementStatistics() async {
    try {
      _logger.i('Getting recensement statistics');

      // Get local statistics
      final localStats = await _getLocalStatistics();

      // If online, get server statistics and merge
      if (_connectivityService.canPerformOnlineOperation()) {
        try {
          final serverStats = await _getServerStatistics();
          
          // Merge statistics (server takes precedence)
          return RecensementStatistics(
            totalContribuables: serverStats.totalContribuables,
            nonSynchronises: localStats.nonSynchronises,
            enValidation: serverStats.enValidation,
            creesAujourdhui: serverStats.creesAujourdhui,
            misAJourAujourdhui: serverStats.misAJourAujourdhui,
            repartitionParType: serverStats.repartitionParType,
            repartitionParZone: serverStats.repartitionParZone,
            tauxSynchronisation: serverStats.tauxSynchronisation,
            derniereSynchronisation: serverStats.derniereSynchronisation,
          );
        } catch (e) {
          _logger.w('Failed to get server statistics, using local only: $e');
        }
      }

      return localStats;
    } catch (e) {
      _logger.e('Error getting recensement statistics: $e');
      rethrow;
    }
  }

  // Get contribuable history
  Future<List<ContribuableHistorique>> getContribuableHistorique(int contribuableId) async {
    try {
      _logger.i('Getting history for contribuable: $contribuableId');

      // Get local history
      final localHistory = await _getLocalHistorique(contribuableId);

      // If online, get server history
      if (_connectivityService.canPerformOnlineOperation()) {
        try {
          final serverHistory = await _getServerHistorique(contribuableId);
          
          // Merge histories
          final allHistory = <String, ContribuableHistorique>{};
          
          for (final entry in localHistory) {
            allHistory[entry.dateModification.toIso8601String()] = entry;
          }
          
          for (final entry in serverHistory) {
            allHistory[entry.dateModification.toIso8601String()] = entry;
          }
          
          return allHistory.values.toList()
            ..sort((a, b) => b.dateModification.compareTo(a.dateModification));
        } catch (e) {
          _logger.w('Failed to get server history, using local only: $e');
        }
      }

      return localHistory;
    } catch (e) {
      _logger.e('Error getting contribuable history: $e');
      rethrow;
    }
  }

  // Validation methods
  bool _validateRequiredFields(
    String telephone,
    ContribuableType type,
    String activite,
    String zoneId,
    TypePieceIdentite typePiece,
    String numeroPiece,
  ) {
    if (telephone.isEmpty || !AppConfigExtension.isValidPhone(telephone)) {
      return false;
    }
    
    if (activite.isEmpty) {
      return false;
    }
    
    if (zoneId.isEmpty) {
      return false;
    }
    
    if (numeroPiece.isEmpty) {
      return false;
    }
    
    if (type == ContribuableType.personnePhysique) {
      // Additional validation for person physique if needed
    }
    
    return true;
  }

  bool _requiresValidation(ContribuableType type, String activite, String zoneId) {
    // Validation required for certain types or activities
    return type == ContribuableType.personneMorale ||
           activite.toLowerCase().contains('import') ||
           zoneId.toLowerCase().contains('zone_speciale');
  }

  // Location methods
  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _logger.w('Location services are disabled');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _logger.w('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _logger.w('Location permissions are permanently denied');
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      _logger.e('Error getting current location: $e');
      return null;
    }
  }

  // Local storage methods (simplified - would use actual database)
  Future<void> _saveContribuableLocally(ContribuableForm contribuable) async {
    try {
      await _storageService.storeOfflineData(
        'contribuable_${contribuable.numeroContribuable}',
        contribuable.toJson(),
      );
      _logger.d('Contribuable saved locally: ${contribuable.numeroContribuable}');
    } catch (e) {
      _logger.e('Error saving contribuable locally: $e');
    }
  }

  Future<ContribuableForm?> _getContribuableLocally(int id) async {
    try {
      // This would query the local database
      // Simplified implementation
      return null;
    } catch (e) {
      _logger.e('Error getting contribuable locally: $e');
      return null;
    }
  }

  Future<List<ContribuableForm>> _getContribuablesByAgentLocally(String agentId) async {
    try {
      // This would query the local database
      // Simplified implementation
      return [];
    } catch (e) {
      _logger.e('Error getting contribuables by agent locally: $e');
      return [];
    }
  }

  Future<List<ContribuableForm>> _getPendingContribuables() async {
    try {
      // This would query the local database for pending sync
      // Simplified implementation
      return [];
    } catch (e) {
      _logger.e('Error getting pending contribuables: $e');
      return [];
    }
  }

  Future<List<ContribuableSearchResult>> _searchContribuablesLocally({
    String? query,
    String? telephone,
    String? numeroContribuable,
    String? numeroPiece,
    ContribuableType? type,
    String? zoneId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // This would search the local database
      // Simplified implementation
      return [];
    } catch (e) {
      _logger.e('Error searching contribuables locally: $e');
      return [];
    }
  }

  // Server methods
  Future<void> _syncContribuable(ContribuableForm contribuable) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '${AppConfig.contribuablesEndpoint}',
        data: contribuable.toJson(),
      );

      if (response != null) {
        // Update sync status
        final syncedContribuable = contribuable.copyWith(
          syncStatus: SyncStatus.synchronized,
        );
        await _saveContribuableLocally(syncedContribuable);
      }
    } catch (e) {
      _logger.e('Error syncing contribuable: $e');
      rethrow;
    }
  }

  Future<ContribuableForm?> _getContribuableFromServer(int id) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${AppConfig.contribuablesEndpoint}/$id',
      );
      
      if (response != null) {
        return ContribuableForm.fromJson(response);
      }
      return null;
    } catch (e) {
      _logger.e('Error getting contribuable from server: $e');
      return null;
    }
  }

  Future<List<ContribuableForm>> _getContribuablesByAgentFromServer(String agentId) async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        '${AppConfig.contribuablesEndpoint}/zone/${agentId}',
      );
      
      if (response != null) {
        return response.map((json) => ContribuableForm.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      _logger.e('Error getting contribuables by agent from server: $e');
      return [];
    }
  }

  Future<List<ContribuableSearchResult>> _searchContribuablesOnServer({
    String? query,
    String? telephone,
    String? numeroContribuable,
    String? numeroPiece,
    ContribuableType? type,
    String? zoneId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      
      if (query != null) queryParams['query'] = query;
      if (telephone != null) queryParams['telephone'] = telephone;
      if (numeroContribuable != null) queryParams['numeroContribuable'] = numeroContribuable;
      if (numeroPiece != null) queryParams['numeroPiece'] = numeroPiece;
      if (type != null) queryParams['type'] = type.code;
      if (zoneId != null) queryParams['zoneId'] = zoneId;

      final response = await _apiService.get<List<dynamic>>(
        '${AppConfig.contribuablesEndpoint}/search',
        queryParameters: queryParams,
      );
      
      if (response != null) {
        return response.map((json) {
          final contribuable = ContribuableForm.fromJson(json);
          return ContribuableSearchResult(
            contribuable: contribuable,
            relevanceScore: 1.0, // Server would calculate this
            matchedFields: ['query'], // Server would provide this
          );
        }).toList();
      }
      return [];
    } catch (e) {
      _logger.e('Error searching contribuables on server: $e');
      return [];
    }
  }

  Future<RecensementStatistics> _getLocalStatistics() async {
    try {
      // This would calculate statistics from local database
      // Simplified implementation
      return RecensementStatistics(
        totalContribuables: 0,
        nonSynchronises: 0,
        enValidation: 0,
        creesAujourdhui: 0,
        misAJourAujourdhui: 0,
        repartitionParType: {},
        repartitionParZone: {},
        tauxSynchronisation: 0.0,
      );
    } catch (e) {
      _logger.e('Error getting local statistics: $e');
      rethrow;
    }
  }

  Future<RecensementStatistics> _getServerStatistics() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${AppConfig.contribuablesEndpoint}/stats',
      );
      
      if (response != null) {
        return RecensementStatistics.fromJson(response);
      }
      
      // Return empty stats if no response
      return RecensementStatistics(
        totalContribuables: 0,
        nonSynchronises: 0,
        enValidation: 0,
        creesAujourdhui: 0,
        misAJourAujourdhui: 0,
        repartitionParType: {},
        repartitionParZone: {},
        tauxSynchronisation: 0.0,
      );
    } catch (e) {
      _logger.e('Error getting server statistics: $e');
      rethrow;
    }
  }

  Future<List<ContribuableHistorique>> _getLocalHistorique(int contribuableId) async {
    try {
      // This would query local database
      // Simplified implementation
      return [];
    } catch (e) {
      _logger.e('Error getting local historique: $e');
      return [];
    }
  }

  Future<List<ContribuableHistorique>> _getServerHistorique(int contribuableId) async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        '${AppConfig.contribuablesEndpoint}/$contribuableId/historique',
      );
      
      if (response != null) {
        return response.map((json) => ContribuableHistorique.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      _logger.e('Error getting server historique: $e');
      return [];
    }
  }

  Future<void> _createHistoriqueEntry(
    ContribuableForm contribuable,
    String agentId,
    String raisonModification,
  ) async {
    try {
      final historique = ContribuableHistorique(
        id: DateTime.now().millisecondsSinceEpoch,
        contribuableId: int.tryParse(contribuable.numeroContribuable.substring(3)) ?? 0,
        ancienNom: contribuable.nom,
        nouveauNom: contribuable.nom,
        ancienTelephone: contribuable.telephone,
        nouveauTelephone: contribuable.telephone,
        dateModification: DateTime.now(),
        agentId: agentId,
        raisonModification: raisonModification,
        anciennesValeurs: contribuable.toJson(),
        nouvellesValeurs: contribuable.toJson(),
      );

      // Save locally
      await _storageService.storeOfflineData(
        'historique_${historique.id}',
        historique.toJson(),
      );

      // Sync if online
      if (_connectivityService.canPerformOnlineOperation()) {
        try {
          await _apiService.post<Map<String, dynamic>>(
            '${AppConfig.contribuablesEndpoint}/historique',
            data: historique.toJson(),
          );
        } catch (e) {
          _logger.w('Failed to sync historique entry: $e');
        }
      }
    } catch (e) {
      _logger.e('Error creating historique entry: $e');
    }
  }

  // Getters for services
  StorageService get _storageService => StorageService();
  ConnectivityService get _connectivityService => ConnectivityService();

  // Upload photo to server
  Future<String?> uploadPhoto(File imageFile, String endpoint) async {
    try {
      if (!_connectivityService.canPerformOnlineOperation()) {
        _logger.w('Cannot upload photo: no connectivity');
        return null;
      }

      final dio = _apiService.dio;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
      });

      final response = await dio.post(
        '${AppConfig.baseUrl}$endpoint',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final url = response.data['url'];
        if (url != null) {
          _logger.i('Photo uploaded successfully: $url');
          return url as String;
        }
      }
      return null;
    } catch (e) {
      _logger.e('Error uploading photo: $e');
      return null;
    }
  }

  // Upload contribuable photo
  Future<String?> uploadContribuablePhoto(File imageFile) async {
    return uploadPhoto(imageFile, '/api/taxcollect/upload/contribuable-photo');
  }

  // Upload piece identite photo
  Future<String?> uploadPieceIdentite(File imageFile) async {
    return uploadPhoto(imageFile, '/api/taxcollect/upload/piece-identite');
  }
}
