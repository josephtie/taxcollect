import 'dart:async';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';
import 'api_service.dart';

/// Service pour gérer la hiérarchie de localisation
/// Commune → Quartier → ZoneCollect → Contribuable
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final Logger _logger = Logger();
  
  // Cache pour les données de localisation
  List<CommuneDto> _communesCache = [];
  List<QuartierDto> _quartiersCache = [];
  List<ZoneCollectDto> _zonesCache = [];
  
  // Initialize the service
  Future<void> initialize() async {
    try {
      _logger.i('Initializing LocationService...');
      
      // Load all location data
      await _loadLocationData();
      
      _logger.i('LocationService initialized successfully');
    } catch (e) {
      _logger.e('Error initializing LocationService: $e');
      rethrow;
    }
  }
  
  /// Obtenir toutes les communes
  Future<List<CommuneDto>> getAllCommunes() async {
    try {
      if (_communesCache.isNotEmpty) {
        return _communesCache;
      }
      
      final apiService = ApiService();
      _communesCache = await apiService.getAllCommunes();
      return _communesCache;
    } catch (e) {
      _logger.e('Error getting communes: $e');
      return [];
    }
  }
  
  /// Obtenir une commune par ID
  Future<CommuneDto?> getCommuneById(int id) async {
    try {
      final communes = await getAllCommunes();
      return communes.where((c) => c.id == id).firstOrNull;
    } catch (e) {
      _logger.e('Error getting commune $id: $e');
      return null;
    }
  }
  
  /// Obtenir tous les quartiers d'une commune
  Future<List<QuartierDto>> getQuartiersByCommune(int communeId) async {
    try {
      if (_quartiersCache.isNotEmpty) {
        return _quartiersCache.where((q) => q.communeId == communeId).toList();
      }
      
      final apiService = ApiService();
      final quartiers = await apiService.getAllQuartiers();
      _quartiersCache = quartiers;
      return quartiers.where((q) => q.communeId == communeId).toList();
    } catch (e) {
      _logger.e('Error getting quartiers for commune $communeId: $e');
      return [];
    }
  }
  
  /// Obtenir un quartier par ID
  Future<QuartierDto?> getQuartierById(int id) async {
    try {
      final quartiers = await getAllQuartiers();
      return quartiers.where((q) => q.id == id).firstOrNull;
    } catch (e) {
      _logger.e('Error getting quartier $id: $e');
      return null;
    }
  }
  
  /// Obtenir tous les quartiers
  Future<List<QuartierDto>> getAllQuartiers() async {
    try {
      if (_quartiersCache.isNotEmpty) {
        return _quartiersCache;
      }
      
      final apiService = ApiService();
      _quartiersCache = await apiService.getAllQuartiers();
      return _quartiersCache;
    } catch (e) {
      _logger.e('Error getting all quartiers: $e');
      return [];
    }
  }
  
  /// Obtenir toutes les zones de collecte d'un quartier
  Future<List<ZoneCollectDto>> getZonesByQuartier(int quartierId) async {
    try {
      if (_zonesCache.isNotEmpty) {
        return _zonesCache.where((z) => z.quartierId == quartierId).toList();
      }
      
      final apiService = ApiService();
      final zones = await apiService.getAllZones();
      _zonesCache = zones;
      return zones.where((z) => z.quartierId == quartierId).toList();
    } catch (e) {
      _logger.e('Error getting zones for quartier $quartierId: $e');
      return [];
    }
  }
  
  /// Obtenir une zone de collecte par ID
  Future<ZoneCollectDto?> getZoneById(int id) async {
    try {
      final zones = await getAllZones();
      return zones.where((z) => z.id == id).firstOrNull;
    } catch (e) {
      _logger.e('Error getting zone $id: $e');
      return null;
    }
  }
  
  /// Obtenir toutes les zones de collecte
  Future<List<ZoneCollectDto>> getAllZones() async {
    try {
      if (_zonesCache.isNotEmpty) {
        return _zonesCache;
      }
      
      final apiService = ApiService();
      _zonesCache = await apiService.getAllZones();
      return _zonesCache;
    } catch (e) {
      _logger.e('Error getting all zones: $e');
      return [];
    }
  }
  
  /// Obtenir la hiérarchie complète d'une zone
  Future<LocationHierarchy?> getZoneHierarchy(int zoneId) async {
    try {
      final zone = await getZoneById(zoneId);
      if (zone == null) return null;
      
      final quartier = await getQuartierById(zone.quartierId ?? 0);
      if (quartier == null) return null;
      
      final commune = await getCommuneById(quartier.communeId ?? 0);
      if (commune == null) return null;
      
      return LocationHierarchy(
        commune: commune,
        quartier: quartier,
        zone: zone,
      );
    } catch (e) {
      _logger.e('Error getting hierarchy for zone $zoneId: $e');
      return null;
    }
  }
  
  /// Obtenir toutes les zones avec leur hiérarchie
  Future<List<LocationHierarchy>> getAllZonesWithHierarchy() async {
    try {
      final zones = await getAllZones();
      final hierarchies = <LocationHierarchy>[];
      
      for (final zone in zones) {
        final hierarchy = await getZoneHierarchy(zone.id ?? 0);
        if (hierarchy != null) {
          hierarchies.add(hierarchy);
        }
      }
      
      return hierarchies;
    } catch (e) {
      _logger.e('Error getting all zones with hierarchy: $e');
      return [];
    }
  }
  
  /// Créer une nouvelle commune
  Future<CommuneDto> createCommune(String nom) async {
    try {
      final apiService = ApiService();
      final commune = await apiService.createCommune(CommuneDto(nom: nom));
      
      // Update cache
      _communesCache.add(commune);
      
      _logger.i('Created commune: ${commune.nom}');
      return commune;
    } catch (e) {
      _logger.e('Error creating commune: $e');
      rethrow;
    }
  }
  
  /// Créer un nouveau quartier
  Future<QuartierDto> createQuartier({
    required String nom,
    required int communeId,
  }) async {
    try {
      final apiService = ApiService();
      final quartier = await apiService.createQuartier(QuartierDto(
        nom: nom,
        communeId: communeId,
      ));
      
      // Update cache
      _quartiersCache.add(quartier);
      
      _logger.i('Created quartier: ${quartier.nom}');
      return quartier;
    } catch (e) {
      _logger.e('Error creating quartier: $e');
      rethrow;
    }
  }
  
  /// Créer une nouvelle zone de collecte
  Future<ZoneCollectDto> createZone({
    required String nom,
    required int quartierId,
  }) async {
    try {
      final apiService = ApiService();
      final zone = await apiService.createZone(ZoneCollectDto(
        nom: nom,
        quartierId: quartierId,
      ));
      
      // Update cache
      _zonesCache.add(zone);
      
      _logger.i('Created zone: ${zone.nom}');
      return zone;
    } catch (e) {
      _logger.e('Error creating zone: $e');
      rethrow;
    }
  }
  
  /// Rechercher des zones par nom
  Future<List<ZoneCollectDto>> searchZones(String query) async {
    try {
      final zones = await getAllZones();
      return zones.where((zone) => 
        zone.nom.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      _logger.e('Error searching zones: $e');
      return [];
    }
  }
  
  /// Obtenir les statistiques de localisation
  Future<LocationStatistics> getStatistics() async {
    try {
      final communes = await getAllCommunes();
      final quartiers = await getAllQuartiers();
      final zones = await getAllZones();
      
      return LocationStatistics(
        totalCommunes: communes.length,
        totalQuartiers: quartiers.length,
        totalZones: zones.length,
        averageZonesPerQuartier: quartiers.isNotEmpty 
          ? zones.length / quartiers.length 
          : 0,
        averageQuartiersPerCommune: communes.isNotEmpty 
          ? quartiers.length / communes.length 
          : 0,
      );
    } catch (e) {
      _logger.e('Error getting location statistics: $e');
      return LocationStatistics(
        totalCommunes: 0,
        totalQuartiers: 0,
        totalZones: 0,
        averageZonesPerQuartier: 0,
        averageQuartiersPerCommune: 0,
      );
    }
  }
  
  // Private methods
  
  Future<void> _loadLocationData() async {
    try {
      await Future.wait([
        getAllCommunes(),
        getAllQuartiers(),
        getAllZones(),
      ]);
      
      _logger.i('Loaded location data: ${_communesCache.length} communes, ${_quartiersCache.length} quartiers, ${_zonesCache.length} zones');
    } catch (e) {
      _logger.w('Error loading location data: $e');
    }
  }
  
  /// Rafraîchir le cache
  void refreshCache() {
    _communesCache.clear();
    _quartiersCache.clear();
    _zonesCache.clear();
  }
}

/// Modèle pour la hiérarchie de localisation
class LocationHierarchy {
  final CommuneDto commune;
  final QuartierDto quartier;
  final ZoneCollectDto zone;
  
  LocationHierarchy({
    required this.commune,
    required this.quartier,
    required this.zone,
  });
  
  String get fullLocation => '${commune.nom} > ${quartier.nom} > ${zone.nom}';
  
  Map<String, dynamic> toJson() {
    return {
      'commune': commune.toJson(),
      'quartier': quartier.toJson(),
      'zone': zone.toJson(),
    };
  }
  
  factory LocationHierarchy.fromJson(Map<String, dynamic> json) {
    return LocationHierarchy(
      commune: CommuneDto.fromJson(json['commune']),
      quartier: QuartierDto.fromJson(json['quartier']),
      zone: ZoneCollectDto.fromJson(json['zone']),
    );
  }
}

/// Statistiques de localisation
class LocationStatistics {
  final int totalCommunes;
  final int totalQuartiers;
  final int totalZones;
  final double averageZonesPerQuartier;
  final double averageQuartiersPerCommune;
  
  LocationStatistics({
    required this.totalCommunes,
    required this.totalQuartiers,
    required this.totalZones,
    required this.averageZonesPerQuartier,
    required this.averageQuartiersPerCommune,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'totalCommunes': totalCommunes,
      'totalQuartiers': totalQuartiers,
      'totalZones': totalZones,
      'averageZonesPerQuartier': averageZonesPerQuartier,
      'averageQuartiersPerCommune': averageQuartiersPerCommune,
    };
  }
}

// Extension on ApiService for location operations
extension ApiServiceLocationExtension on ApiService {
  Future<CommuneDto> createCommune(CommuneDto commune) async {
    try {
      final response = await post<CommuneDto>(
        '${AppConfig.communesEndpoint}',
        data: commune.toJson(),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<List<CommuneDto>> getAllCommunes() async {
    try {
      final response = await get<List<dynamic>>(
        '${AppConfig.communesEndpoint}/all',
      );
      return response.map((json) => CommuneDto.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<QuartierDto> createQuartier(QuartierDto quartier) async {
    try {
      final response = await post<QuartierDto>(
        '${AppConfig.quartiersEndpoint}',
        data: quartier.toJson(),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<List<QuartierDto>> getAllQuartiers() async {
    try {
      final response = await get<List<dynamic>>(
        '${AppConfig.quartiersEndpoint}/all',
      );
      return response.map((json) => QuartierDto.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
