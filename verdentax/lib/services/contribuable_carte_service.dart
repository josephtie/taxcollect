import 'dart:async';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';
import 'api_service.dart';

/// Service pour gérer la relation entre Contribuable et CarteContribuable
/// Un contribuable peut avoir plusieurs cartes dans le temps mais une seule active
class ContribuableCarteService {
  static final ContribuableCarteService _instance = ContribuableCarteService._internal();
  factory ContribuableCarteService() => _instance;
  ContribuableCarteService._internal();

  final Logger _logger = Logger();
  
  // Cache pour les cartes actives par contribuable
  final Map<String, CarteContribuable> _activeCarteCache = {};
  
  // Initialize the service
  Future<void> initialize() async {
    try {
      _logger.i('Initializing ContribuableCarteService...');
      
      // Load active cards cache
      await _loadActiveCardsCache();
      
      _logger.i('ContribuableCarteService initialized successfully');
    } catch (e) {
      _logger.e('Error initializing ContribuableCarteService: $e');
      rethrow;
    }
  }
  
  /// Obtenir la carte active d'un contribuable
  Future<CarteContribuable?> getActiveCarte(String contribuableId) async {
    try {
      // Check cache first
      if (_activeCarteCache.containsKey(contribuableId)) {
        final carte = _activeCarteCache[contribuableId];
        if (carte != null && carte.isValid) {
          return carte;
        }
        // Remove invalid card from cache
        _activeCarteCache.remove(contribuableId);
      }
      
      // Fetch from API
      final apiService = ApiService();
      final cartes = await apiService.getCartesByContribuable(contribuableId);
      
      // Find active card
      final activeCarte = cartes.where((c) => c.isValid).firstOrNull;
      
      // Update cache
      if (activeCarte != null) {
        _activeCarteCache[contribuableId] = activeCarte;
      }
      
      return activeCarte;
    } catch (e) {
      _logger.e('Error getting active carte for contribuable $contribuableId: $e');
      return null;
    }
  }
  
  /// Obtenir toutes les cartes d'un contribuable
  Future<List<CarteContribuable>> getAllCartes(String contribuableId) async {
    try {
      final apiService = ApiService();
      return await apiService.getCartesByContribuable(contribuableId);
    } catch (e) {
      _logger.e('Error getting all cartes for contribuable $contribuableId: $e');
      return [];
    }
  }
  
  /// Créer une nouvelle carte pour un contribuable
  Future<CarteContribuable> createCarte({
    required String contribuableId,
    CarteType type = CarteType.pvc,
    QRSecurityLevel securityLevel = QRSecurityLevel.standard,
    DateTime? expirationDate,
    String? agentId,
    String? zoneId,
  }) async {
    try {
      // Désactiver l'ancienne carte si elle existe
      await _deactivateOldCarte(contribuableId);
      
      final apiService = ApiService();
      
      // Create new carte
      final carte = await apiService.createCarte(CarteCreationRequest(
        contribuableId: contribuableId,
        type: type,
        securityLevel: securityLevel,
        dateExpiration: expirationDate ?? DateTime.now().add(const Duration(days: 365)),
        agentId: agentId,
        zoneId: zoneId,
      ));
      
      // Update cache
      _activeCarteCache[contribuableId] = carte;
      
      _logger.i('Created new carte ${carte.numeroCarte} for contribuable $contribuableId');
      return carte;
    } catch (e) {
      _logger.e('Error creating carte for contribuable $contribuableId: $e');
      rethrow;
    }
  }
  
  /// Renouveler une carte existante
  Future<CarteContribuable> renewCarte({
    required String contribuableId,
    String? agentId,
    DateTime? newExpirationDate,
  }) async {
    try {
      final oldCarte = await getActiveCarte(contribuableId);
      
      if (oldCarte == null) {
        throw Exception('No active carte found for contribuable $contribuableId');
      }
      
      // Create new carte with same type
      final newCarte = await createCarte(
        contribuableId: contribuableId,
        type: oldCarte.type,
        securityLevel: oldCarte.securityLevel,
        expirationDate: newExpirationDate,
        agentId: agentId,
        zoneId: oldCarte.zoneId,
      );
      
      // Mark old card as expired
      await _markCarteAsExpired(oldCarte.id);
      
      _logger.i('Renewed carte for contribuable $contribuableId: ${oldCarte.numeroCarte} -> ${newCarte.numeroCarte}');
      return newCarte;
    } catch (e) {
      _logger.e('Error renewing carte for contribuable $contribuableId: $e');
      rethrow;
    }
  }
  
  /// Désactiver une carte
  Future<void> deactivateCarte(String carteId, {String? reason}) async {
    try {
      final apiService = ApiService();
      await apiService.updateCarteStatus(carteId, CarteStatus.suspended);
      
      // Remove from cache
      _activeCarteCache.removeWhere((key, value) => value.id == carteId);
      
      _logger.i('Deactivated carte $carteId');
    } catch (e) {
      _logger.e('Error deactivating carte $carteId: $e');
      rethrow;
    }
  }
  
  /// Marquer une carte comme perdue
  Future<void> reportLostCarte(String carteId, {String? agentId}) async {
    try {
      final apiService = ApiService();
      await apiService.updateCarteStatus(carteId, CarteStatus.lost);
      
      // Remove from cache
      _activeCarteCache.removeWhere((key, value) => value.id == carteId);
      
      _logger.i('Reported lost carte $carteId');
    } catch (e) {
      _logger.e('Error reporting lost carte $carteId: $e');
      rethrow;
    }
  }
  
  /// Vérifier une carte via QR code
  Future<CarteVerificationResult> verifyCarte(String qrCodeData, {String? agentId}) async {
    try {
      // Parse QR code
      final payload = QRCodeSecurityService.parseQRCode(qrCodeData);
      if (payload == null) {
        return CarteVerificationResult.failure(
          message: 'Format QR Code invalide',
          error: VerificationError.invalidFormat,
        );
      }
      
      // Verify signature
      if (!QRCodeSecurityService.verifyQRSignature(payload)) {
        return CarteVerificationResult.failure(
          message: 'Signature QR Code invalide',
          error: VerificationError.invalidSignature,
        );
      }
      
      // Check expiration
      if (payload.isExpired) {
        return CarteVerificationResult.failure(
          message: 'Carte expirée le ${payload.displayExpiration}',
          error: VerificationError.expired,
        );
      }
      
      // Find carte
      final apiService = ApiService();
      final carte = await apiService.getCarteByMatricule(payload.uid);
      
      if (carte == null) {
        return CarteVerificationResult.failure(
          message: 'Carte non trouvée dans le système',
          error: VerificationError.notFound,
        );
      }
      
      // Check carte status
      if (carte.status == CarteStatus.suspended) {
        return CarteVerificationResult.failure(
          message: 'Carte suspendue',
          error: VerificationError.suspended,
        );
      }
      
      if (carte.status == CarteStatus.revoked) {
        return CarteVerificationResult.failure(
          message: 'Carte révoquée',
          error: VerificationError.revoked,
        );
      }
      
      // Get contribuable data
      final contribuable = await apiService.getContribuableById(int.parse(carte.contribuableId));
      
      if (contribuable == null) {
        return CarteVerificationResult.failure(
          message: 'Contribuable non trouvé',
          error: VerificationError.notFound,
        );
      }
      
      return CarteVerificationResult.success(
        payload: payload,
        carte: carte,
        contribuable: ContribuableForm(
          id: contribuable.id,
          nom: contribuable.nom,
          prenom: contribuable.prenom,
          telephone: contribuable.telephone ?? '',
          activite: contribuable.activites ?? '',
          zoneId: contribuable.zoneCollecteId?.toString() ?? '',
          type: ContribuableType.personnePhysique,
          typePiece: TypePieceIdentite.cni,
          numeroPiece: '',
          numeroContribuable: '',
          qrCode: '',
          agentId: agentId ?? 'system',
        ),
        verifiedBy: agentId ?? 'system',
      );
    } catch (e) {
      _logger.e('Error verifying carte: $e');
      return CarteVerificationResult.failure(
        message: 'Erreur lors de la vérification: ${e.toString()}',
      );
    }
  }
  
  /// Obtenir les statistiques des cartes
  Future<CarteStatistics> getStatistics() async {
    try {
      final apiService = ApiService();
      return await apiService.getCarteStatistics();
    } catch (e) {
      _logger.e('Error getting carte statistics: $e');
      return CarteStatistics(
        totalCartes: 0,
        cartesActives: 0,
        cartesExpirees: 0,
        cartesSuspendues: 0,
        cartesRevokes: 0,
        repartitionParType: {},
        repartitionParStatut: {},
        repartitionParZone: {},
        recentesCartes: [],
      );
    }
  }
  
  // Private methods
  
  Future<void> _loadActiveCardsCache() async {
    try {
      final apiService = ApiService();
      final stats = await apiService.getCarteStatistics();
      
      // Load recent active cards
      for (final carte in stats.recentesCartes) {
        if (carte.isValid) {
          _activeCarteCache[carte.contribuableId] = carte;
        }
      }
      
      _logger.i('Loaded ${_activeCarteCache.length} active cards in cache');
    } catch (e) {
      _logger.w('Error loading active cards cache: $e');
    }
  }
  
  Future<void> _deactivateOldCarte(String contribuableId) async {
    try {
      final oldCarte = await getActiveCarte(contribuableId);
      if (oldCarte != null) {
        await _markCarteAsExpired(oldCarte.id);
      }
    } catch (e) {
      _logger.w('Error deactivating old carte for $contribuableId: $e');
    }
  }
  
  Future<void> _markCarteAsExpired(String carteId) async {
    try {
      final apiService = ApiService();
      await apiService.updateCarteStatus(carteId, CarteStatus.expired);
    } catch (e) {
      _logger.e('Error marking carte as expired: $e');
    }
  }
}

// Extension on ApiService for carte operations
extension ApiServiceCarteExtension on ApiService {
  Future<CarteContribuable> createCarte(CarteCreationRequest request) async {
    try {
      final response = await post<CarteContribuable>(
        '${AppConfig.cartesEndpoint}/create',
        data: request.toJson(),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<CarteContribuable> getCarteByMatricule(String matricule) async {
    try {
      final response = await get<CarteContribuable>(
        '${AppConfig.cartesEndpoint}/matricule/$matricule',
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<List<CarteContribuable>> getCartesByContribuable(String contribuableId) async {
    try {
      final response = await get<List<dynamic>>(
        '${AppConfig.cartesEndpoint}/contribuable/$contribuableId',
      );
      return response.map((json) => CarteContribuable.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateCarteStatus(String carteId, CarteStatus status) async {
    try {
      await put(
        '${AppConfig.cartesEndpoint}/$carteId/status',
        data: {'status': status.code},
      );
    } catch (e) {
      rethrow;
    }
  }
  
  Future<CarteStatistics> getCarteStatistics() async {
    try {
      final response = await get<CarteStatistics>(
        '${AppConfig.cartesEndpoint}/statistics',
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
