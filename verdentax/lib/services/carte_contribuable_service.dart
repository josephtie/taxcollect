import 'dart:async';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import 'services.dart';

// Extension for firstWhereOrNull
extension FirstWhereOrNullExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final item in this) {
      if (test(item)) return item;
    }
    return null;
  }
}

class CarteContribuableService {
  static final CarteContribuableService _instance = CarteContribuableService._internal();
  factory CarteContribuableService() => _instance;
  CarteContribuableService._internal();

  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();

  // Cache for offline verification
  final Map<String, CarteContribuable> _carteCache = {};
  final Map<String, ContribuableForm> _contribuableCache = {};
  
  // Event streams
  final StreamController<CarteVerificationResult> _verificationStreamController = 
      StreamController<CarteVerificationResult>.broadcast();
  final StreamController<CarteStatistics> _statisticsStreamController = 
      StreamController<CarteStatistics>.broadcast();

  // Getters
  Stream<CarteVerificationResult> get verificationStream => _verificationStreamController.stream;
  Stream<CarteStatistics> get statisticsStream => _statisticsStreamController.stream;

  // Initialize the service
  Future<void> initialize() async {
    try {
      _logger.i('Initializing CarteContribuableService...');
      
      // Load cached data
      await _loadCachedData();
      
      // Start statistics updates
      _startStatisticsUpdates();
      
      _logger.i('CarteContribuableService initialized successfully');
    } catch (e) {
      _logger.e('Error initializing CarteContribuableService: $e');
      rethrow;
    }
  }

  // Create a new carte
  Future<CarteContribuable> createCarte({
    required String contribuableId,
    required ContribuableForm contribuable,
    CarteType type = CarteType.pvc,
    QRSecurityLevel securityLevel = QRSecurityLevel.standard,
    DateTime? expirationDate,
    String? photoData,
    String? agentId,
    String? zoneId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Generate unique identifiers
      final numeroCarte = QRCodeSecurityService.generateNumeroCarte();
      final matriculeUnique = QRCodeSecurityService.generateMatriculeUnique();
      
      // Set default expiration (1 year from now)
      expirationDate ??= DateTime.now().add(const Duration(days: 365));
      
      // Generate QR payload
      final qrPayload = QRCodeSecurityService.generateQRPayload(
        contribuableId: contribuableId,
        uniqueId: matriculeUnique,
        expirationDate: expirationDate,
      );
      
      // Create carte object
      final carte = CarteContribuable(
        id: _uuid.v4(),
        contribuableId: contribuableId,
        numeroCarte: numeroCarte,
        matriculeUnique: matriculeUnique,
        qrCodeData: qrPayload.toJsonString(),
        securityLevel: securityLevel,
        type: type,
        status: CarteStatus.active,
        dateEmission: DateTime.now(),
        dateExpiration: expirationDate,
        photoUrl: photoData,
        agentId: agentId,
        zoneId: zoneId,
        metadata: metadata,
        createdAt: DateTime.now(),
      );
      
      // Save to backend
      final savedCarte = await _saveCarteToBackend(carte);
      
      // Update cache
      _carteCache[savedCarte.id] = savedCarte;
      _contribuableCache[contribuableId] = contribuable;
      
      // Save locally
      await _saveCarteLocally(savedCarte);
      
      _logger.i('Carte created successfully: ${savedCarte.numeroCarte}');
      return savedCarte;
      
    } catch (e) {
      _logger.e('Error creating carte: $e');
      rethrow;
    }
  }

  // Verify QR code
  Future<CarteVerificationResult> verifyQRCode({
    required String qrCodeData,
    String? agentId,
    double? latitude,
    double? longitude,
    String? deviceId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final verificationRequest = CarteVerificationRequest(
        qrCodeData: qrCodeData,
        agentId: agentId,
        latitude: latitude,
        longitude: longitude,
        deviceId: deviceId,
        metadata: metadata,
      );
      
      // Parse QR code
      final payload = QRCodeSecurityService.parseQRCode(qrCodeData);
      if (payload == null) {
        final result = CarteVerificationResult.failure(
          message: 'Format QR Code invalide',
          error: VerificationError.invalidFormat,
          metadata: verificationRequest.toJson(),
        );
        _verificationStreamController.add(result);
        return result;
      }
      
      // Verify signature
      if (!QRCodeSecurityService.verifyQRSignature(payload)) {
        final result = CarteVerificationResult.failure(
          message: 'Signature QR Code invalide',
          error: VerificationError.invalidSignature,
          metadata: verificationRequest.toJson(),
        );
        _verificationStreamController.add(result);
        return result;
      }
      
      // Check expiration
      if (payload.isExpired) {
        final result = CarteVerificationResult.failure(
          message: 'Carte expirée le ${payload.displayExpiration}',
          error: VerificationError.expired,
          metadata: verificationRequest.toJson(),
        );
        _verificationStreamController.add(result);
        return result;
      }
      
      // Find carte in cache or backend
      CarteContribuable? carte = await _findCarteByPayload(payload);
      if (carte == null) {
        final result = CarteVerificationResult.failure(
          message: 'Carte non trouvée dans le système',
          error: VerificationError.notFound,
          metadata: verificationRequest.toJson(),
        );
        _verificationStreamController.add(result);
        return result;
      }
      
      // Check carte status
      if (carte.status == CarteStatus.suspended) {
        final result = CarteVerificationResult.failure(
          message: 'Carte suspendue',
          error: VerificationError.suspended,
          metadata: verificationRequest.toJson(),
        );
        _verificationStreamController.add(result);
        return result;
      }
      
      if (carte.status == CarteStatus.revoked) {
        final result = CarteVerificationResult.failure(
          message: 'Carte révoquée',
          error: VerificationError.revoked,
          metadata: verificationRequest.toJson(),
        );
        _verificationStreamController.add(result);
        return result;
      }
      
      // Get contribuable data
      ContribuableForm? contribuable = await _getContribuableById(carte.contribuableId);
      if (contribuable == null) {
        final result = CarteVerificationResult.failure(
          message: 'Contribuable non trouvé',
          error: VerificationError.notFound,
          metadata: verificationRequest.toJson(),
        );
        _verificationStreamController.add(result);
        return result;
      }
      
      // Record verification history
      await _recordVerificationHistory(
        carteId: carte.id,
        agentId: agentId,
        isValid: true,
        message: 'Carte vérifiée avec succès',
        latitude: latitude,
        longitude: longitude,
        deviceId: deviceId,
        metadata: metadata,
      );
      
      // Success result
      final result = CarteVerificationResult.success(
        payload: payload,
        carte: carte,
        contribuable: contribuable,
        verifiedBy: agentId ?? 'unknown',
        metadata: verificationRequest.toJson(),
      );
      
      _verificationStreamController.add(result);
      return result;
      
    } catch (e) {
      _logger.e('Error verifying QR code: $e');
      
      final result = CarteVerificationResult.failure(
        message: 'Erreur lors de la vérification: $e',
        error: VerificationError.serverError,
      );
      
      _verificationStreamController.add(result);
      return result;
    }
  }

  // Get carte by contribuable ID
  Future<CarteContribuable?> getCarteByContribuableId(String contribuableId) async {
    try {
      // Check cache first
      final cachedCarte = _carteCache.values
          .where((c) => c.contribuableId == contribuableId)
          .firstOrNull;
      
      if (cachedCarte != null) {
        return cachedCarte;
      }
      
      // Fetch from backend
      final carte = await _fetchCarteFromBackend(contribuableId);
      if (carte != null) {
        _carteCache[carte.id] = carte;
      }
      
      return carte;
    } catch (e) {
      _logger.e('Error getting carte by contribuable ID: $e');
      return null;
    }
  }

  // Update carte status
  Future<CarteContribuable> updateCarteStatus({
    required String carteId,
    required CarteStatus newStatus,
    String? reason,
    String? agentId,
  }) async {
    try {
      final carte = _carteCache[carteId];
      if (carte == null) {
        throw Exception('Carte non trouvée');
      }
      
      final updatedCarte = carte.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
        metadata: {
          ...?carte.metadata,
          'statusChangeReason': reason,
          'statusChangedBy': agentId,
          'statusChangedAt': DateTime.now().toIso8601String(),
        },
      );
      
      // Save to backend
      final savedCarte = await _saveCarteToBackend(updatedCarte);
      
      // Update cache
      _carteCache[carteId] = savedCarte;
      
      // Save locally
      await _saveCarteLocally(savedCarte);
      
      _logger.i('Carte status updated: ${savedCarte.numeroCarte} -> ${newStatus.label}');
      return savedCarte;
      
    } catch (e) {
      _logger.e('Error updating carte status: $e');
      rethrow;
    }
  }

  // Renew carte
  Future<CarteContribuable> renewCarte({
    required String carteId,
    DateTime? newExpirationDate,
    String? agentId,
  }) async {
    try {
      final carte = _carteCache[carteId];
      if (carte == null) {
        throw Exception('Carte non trouvée');
      }
      
      // Set new expiration (default 1 year from now)
      newExpirationDate ??= DateTime.now().add(const Duration(days: 365));
      
      // Generate new QR payload
      final qrPayload = QRCodeSecurityService.generateQRPayload(
        contribuableId: carte.contribuableId,
        uniqueId: carte.matriculeUnique,
        expirationDate: newExpirationDate,
      );
      
      final renewedCarte = carte.copyWith(
        qrCodeData: qrPayload.toJsonString(),
        dateExpiration: newExpirationDate,
        status: CarteStatus.active,
        updatedAt: DateTime.now(),
        metadata: {
          ...?carte.metadata,
          'renewedBy': agentId,
          'renewedAt': DateTime.now().toIso8601String(),
          'previousExpiration': carte.dateExpiration.toIso8601String(),
        },
      );
      
      // Save to backend
      final savedCarte = await _saveCarteToBackend(renewedCarte);
      
      // Update cache
      _carteCache[carteId] = savedCarte;
      
      // Save locally
      await _saveCarteLocally(savedCarte);
      
      _logger.i('Carte renewed: ${savedCarte.numeroCarte}');
      return savedCarte;
      
    } catch (e) {
      _logger.e('Error renewing carte: $e');
      rethrow;
    }
  }

  // Get verification history
  Future<List<CarteVerificationHistory>> getVerificationHistory({
    String? carteId,
    String? agentId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      // This would fetch from backend API
      // For now, return empty list
      return [];
    } catch (e) {
      _logger.e('Error getting verification history: $e');
      return [];
    }
  }

  // Get statistics
  Future<CarteStatistics> getStatistics() async {
    try {
      // This would calculate real statistics from backend
      // For now, return mock statistics
      final now = DateTime.now();
      final thirtyDaysFromNow = now.add(const Duration(days: 30));
      
      final totalCartes = _carteCache.length;
      final cartesActives = _carteCache.values
          .where((c) => c.status == CarteStatus.active && !c.isExpired)
          .length;
      final cartesExpirees = _carteCache.values
          .where((c) => c.isExpired)
          .length;
      final cartesSuspendues = _carteCache.values
          .where((c) => c.status == CarteStatus.suspended)
          .length;
      final cartesExpirantDans30Jours = _carteCache.values
          .where((c) => !c.isExpired && c.dateExpiration.isBefore(thirtyDaysFromNow))
          .length;
      final cartesEmisesAujourdhui = _carteCache.values
          .where((c) => c.createdAt.day == now.day &&
                     c.createdAt.month == now.month &&
                     c.createdAt.year == now.year)
          .length;
      final cartesRevokes = _carteCache.values
          .where((c) => c.status == CarteStatus.revoked)
          .length;
      
      final repartitionParType = <String, int>{};
      for (final type in CarteType.values) {
        repartitionParType[type.label] = _carteCache.values
            .where((c) => c.type == type)
            .length;
      }
      
      final repartitionParStatut = <String, int>{};
      for (final status in CarteStatus.values) {
        repartitionParStatut[status.label] = _carteCache.values
            .where((c) => c.status == status)
            .length;
      }
      
      final repartitionParZone = <String, int>{};
      for (final carte in _carteCache.values) {
        final zone = carte.zoneId ?? 'Non assignée';
        repartitionParZone[zone] = (repartitionParZone[zone] ?? 0) + 1;
      }
      
      final recentesCartes = _carteCache.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      final statistics = CarteStatistics(
        totalCartes: totalCartes,
        cartesActives: cartesActives,
        cartesExpirees: cartesExpirees,
        cartesSuspendues: cartesSuspendues,
        cartesExpirantDans30Jours: cartesExpirantDans30Jours,
        cartesEmisesAujourdhui: cartesEmisesAujourdhui,
        cartesNonSynchronisees: 0,
        cartesRevokes: cartesRevokes,
        repartitionParType: repartitionParType,
        repartitionParStatut: repartitionParStatut,
        repartitionParZone: repartitionParZone,
        recentesCartes: recentesCartes.take(10).toList(),
      );
      
      _statisticsStreamController.add(statistics);
      return statistics;
      
    } catch (e) {
      _logger.e('Error getting statistics: $e');
      rethrow;
    }
  }

  // Search cartes
  Future<List<CarteContribuable>> searchCartes({
    String? query,
    CarteType? type,
    CarteStatus? status,
    String? zoneId,
    int limit = 50,
  }) async {
    try {
      List<CarteContribuable> results = _carteCache.values.toList();
      
      // Apply filters
      if (query != null && query.isNotEmpty) {
        results = results.where((c) =>
          c.numeroCarte.toLowerCase().contains(query.toLowerCase()) ||
          c.matriculeUnique.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
      
      if (type != null) {
        results = results.where((c) => c.type == type).toList();
      }
      
      if (status != null) {
        results = results.where((c) => c.status == status).toList();
      }
      
      if (zoneId != null) {
        results = results.where((c) => c.zoneId == zoneId).toList();
      }
      
      // Sort by creation date (most recent first)
      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Apply limit
      return results.take(limit).toList();
      
    } catch (e) {
      _logger.e('Error searching cartes: $e');
      return [];
    }
  }

  // Sync cartes with backend
  Future<void> syncCartes() async {
    try {
      // This would sync all local changes with backend
      _logger.i('Cartes synchronization completed');
    } catch (e) {
      _logger.e('Error syncing cartes: $e');
      rethrow;
    }
  }

  // Private helper methods
  Future<CarteContribuable?> _findCarteByPayload(QRCodePayload payload) async {
    try {
      // Find carte by contribuable ID and matricule
      final carte = _carteCache.values.firstWhereOrNull(
        (c) => c.contribuableId == payload.cid && c.matriculeUnique == payload.uid,
      );
      
      if (carte != null) {
        return carte;
      }
      
      // If not in cache, fetch from backend
      return await _fetchCarteFromBackend(payload.cid);
    } catch (e) {
      _logger.e('Error finding carte by payload: $e');
      return null;
    }
  }

  Future<ContribuableForm?> _getContribuableById(String contribuableId) async {
    try {
      // Check cache first
      if (_contribuableCache.containsKey(contribuableId)) {
        return _contribuableCache[contribuableId];
      }
      
      // Fetch from recensement service
      final recensementService = RecensementService();
      final contribuables = await recensementService.searchContribuables(
        query: contribuableId,
        limit: 1,
      );
      
      if (contribuables.isNotEmpty) {
        final contribuable = contribuables.first.contribuable;
        _contribuableCache[contribuableId] = contribuable;
        return contribuable;
      }
      
      return null;
    } catch (e) {
      _logger.e('Error getting contribuable by ID: $e');
      return null;
    }
  }

  Future<void> _recordVerificationHistory({
    required String carteId,
    required String? agentId,
    required bool isValid,
    required String message,
    VerificationError? error,
    double? latitude,
    double? longitude,
    String? deviceId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final history = CarteVerificationHistory(
        id: _uuid.v4(),
        carteId: carteId,
        agentId: agentId ?? 'unknown',
        isValid: isValid,
        message: message,
        error: error,
        verifiedAt: DateTime.now(),
        latitude: latitude,
        longitude: longitude,
        deviceId: deviceId,
        metadata: metadata,
      );
      
      // Save to backend
      await _saveVerificationHistoryToBackend(history);
      
      // Save locally
      await _saveVerificationHistoryLocally(history);
      
    } catch (e) {
      _logger.e('Error recording verification history: $e');
    }
  }

  // Backend API methods (simplified)
  Future<CarteContribuable> _saveCarteToBackend(CarteContribuable carte) async {
    try {
      final apiService = ApiService();
      
      // This would make actual API call
      // For now, return the carte as-is
      return carte;
    } catch (e) {
      _logger.e('Error saving carte to backend: $e');
      rethrow;
    }
  }

  Future<CarteContribuable?> _fetchCarteFromBackend(String contribuableId) async {
    try {
      final apiService = ApiService();
      
      // This would make actual API call
      // For now, return null
      return null;
    } catch (e) {
      _logger.e('Error fetching carte from backend: $e');
      return null;
    }
  }

  Future<void> _saveVerificationHistoryToBackend(CarteVerificationHistory history) async {
    try {
      final apiService = ApiService();
      
      // This would make actual API call
      // For now, do nothing
    } catch (e) {
      _logger.e('Error saving verification history to backend: $e');
    }
  }

  // Local storage methods
  Future<void> _saveCarteLocally(CarteContribuable carte) async {
    try {
      final storageService = StorageService();
      await storageService.storeOfflineData(
        'carte_${carte.id}',
        carte.toJson(),
      );
    } catch (e) {
      _logger.e('Error saving carte locally: $e');
    }
  }

  Future<void> _saveVerificationHistoryLocally(CarteVerificationHistory history) async {
    try {
      final storageService = StorageService();
      await storageService.storeOfflineData(
        'verification_history_${history.id}',
        history.toJson(),
      );
    } catch (e) {
      _logger.e('Error saving verification history locally: $e');
    }
  }

  Future<void> _loadCachedData() async {
    try {
      final storageService = StorageService();
      
      // Load cached cartes
      // This would load all cached cartes from local storage
      // For now, cache is empty
      
      _logger.i('Cached data loaded successfully');
    } catch (e) {
      _logger.e('Error loading cached data: $e');
    }
  }

  void _startStatisticsUpdates() {
    Timer.periodic(const Duration(minutes: 5), (_) {
      getStatistics();
    });
  }
}

// Extension methods for convenience
extension CarteContribuableServiceExtension on CarteContribuableService {
  Future<bool> isQRCodeValid(String qrCodeData) async {
    final result = await verifyQRCode(qrCodeData: qrCodeData);
    return result.isValid;
  }

  Future<CarteContribuable?> getCarteByNumero(String numeroCarte) async {
    try {
      final carte = _carteCache.values.firstWhereOrNull(
        (c) => c.numeroCarte == numeroCarte,
      );
      
      if (carte != null) {
        return carte;
      }
      
      // Search in backend
      final results = await searchCartes(query: numeroCarte, limit: 1);
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      _logger.e('Error getting carte by number: $e');
      return null;
    }
  }

  Future<List<CarteContribuable>> getCartesExpiringSoon({int days = 30}) async {
    try {
      final cutoffDate = DateTime.now().add(Duration(days: days));
      
      return _carteCache.values.where((c) =>
        c.status == CarteStatus.active &&
        c.dateExpiration.isBefore(cutoffDate) &&
        !c.isExpired
      ).toList()
        ..sort((a, b) => a.dateExpiration.compareTo(b.dateExpiration));
    } catch (e) {
      _logger.e('Error getting expiring cartes: $e');
      return [];
    }
  }

  Future<List<CarteContribuable>> getCartesByAgent(String agentId) async {
    try {
      return _carteCache.values
          .where((c) => c.agentId == agentId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _logger.e('Error getting cartes by agent: $e');
      return [];
    }
  }

  Future<void> bulkUpdateStatus({
    required List<String> carteIds,
    required CarteStatus newStatus,
    String? reason,
    String? agentId,
  }) async {
    try {
      for (final carteId in carteIds) {
        await updateCarteStatus(
          carteId: carteId,
          newStatus: newStatus,
          reason: reason,
          agentId: agentId,
        );
      }
      
      _logger.i('Bulk status update completed: ${carteIds.length} cartes');
    } catch (e) {
      _logger.e('Error in bulk status update: $e');
      rethrow;
    }
  }
}
