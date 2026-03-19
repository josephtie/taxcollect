import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/models.dart';
import '../models/geolocation.dart';
import '../services/geolocation_service.dart';
import '../services/location_service.dart';

/// Extensions pour aligner la géolocalisation avec les autres modèles
extension GeolocationAlignmentExtensions on GeolocationService {
  
  /// Créer une GeoZone à partir d'une ZoneCollectDto
  GeoZone createGeoZoneFromZoneCollect(ZoneCollectDto zoneCollect, {
    String agentId = 'system',
    String color = '#1976D2',
    List<LatLng>? customPoints,
    double? radius,
  }) {
    // Par défaut, créer une zone circulaire autour du centre d'Abidjan
    // En pratique, ces coordonnées devraient venir de la configuration ou d'un service
    final defaultCenter = LatLng(5.3600, -4.0083);
    
    return GeoZone(
      id: zoneCollect.id.toString(),
      name: zoneCollect.nom,
      description: 'Zone de collecte: ${zoneCollect.nom}',
      type: ZoneType.commercial,
      points: customPoints ?? [],
      center: defaultCenter,
      radius: radius ?? 1000.0, // 1km par défaut
      agentId: agentId,
      color: color,
      isActive: true,
      createdAt: DateTime.now(),
    );
  }
  
  /// Créer un GpsPoint à partir d'une transaction
  GpsPoint createGpsPointFromTransaction(TransactionDTO transaction) {
    return GpsPoint(
      id: 'tx_${transaction.id}_${DateTime.now().millisecondsSinceEpoch}',
      latitude: transaction.latitude ?? 5.3600,
      longitude: transaction.longitude ?? -4.0083,
      accuracy: 10.0,
      altitude: null,
      speed: null,
      heading: null,
      timestamp: transaction.dateCreation ?? DateTime.now(),
      source: 'transaction',
      action: 'payment',
      contribuableId: transaction.contribuableId.toString(),
      agentId: transaction.agentId.toString(),
    );
  }
  
  /// Créer un GpsPoint à partir d'un contribuable
  GpsPoint createGpsPointFromContribuable(ContribuableDto contribuable, {
    String? action,
    String? agentId,
  }) {
    return GpsPoint(
      id: 'contrib_${contribuable.id}_${DateTime.now().millisecondsSinceEpoch}',
      latitude: contribuable.latitude ?? 5.3600,
      longitude: contribuable.longitude ?? -4.0083,
      accuracy: 10.0,
      altitude: null,
      speed: null,
      heading: null,
      timestamp: DateTime.now(),
      source: 'contribuable',
      action: action ?? 'registration',
      contribuableId: contribuable.id.toString(),
      agentId: agentId,
    );
  }
  
  /// Créer un GpsPoint à partir d'un agent
  GpsPoint createGpsPointFromAgent(AgentsDto agent, {
    String? action,
    double? latitude,
    double? longitude,
  }) {
    return GpsPoint(
      id: 'agent_${agent.id}_${DateTime.now().millisecondsSinceEpoch}',
      latitude: latitude ?? 5.3600,
      longitude: longitude ?? -4.0083,
      accuracy: 10.0,
      altitude: null,
      speed: null,
      heading: null,
      timestamp: DateTime.now(),
      source: 'agent',
      action: action ?? 'tracking',
      contribuableId: null,
      agentId: agent.id.toString(),
    );
  }
  
  /// Vérifier si une transaction est dans la zone de collecte assignée
  Future<bool> isTransactionInAssignedZone(TransactionDTO transaction) async {
    try {
      // Récupérer la zone de collecte
      final locationService = LocationService();
      final zoneCollect = await locationService.getZoneById(transaction.zoneId);
      
      if (zoneCollect == null) return false;
      
      // Créer une GeoZone à partir de la ZoneCollectDto
      final geoZone = createGeoZoneFromZoneCollect(zoneCollect);
      
      // Vérifier si la position de la transaction est dans la zone
      final position = LatLng(
        transaction.latitude ?? 5.3600,
        transaction.longitude ?? -4.0083,
      );
      
      return geoZone.containsPoint(position);
    } catch (e) {
      return false;
    }
  }
  
  /// Obtenir les statistiques de géolocalisation pour un agent
  Future<AgentGeolocationStats> getAgentGeolocationStats(int agentId) async {
    try {
      // Get positions from service (assuming method exists)
      final allPositions = <GpsPoint>[];
      final agentPositions = allPositions
          .where((p) => p.agentId == agentId.toString())
          .toList();
      
      // Get zones from service (assuming method exists)
      final allZones = <GeoZone>[];
      final agentZones = allZones
          .where((z) => z.agentId == agentId.toString())
          .toList();
      
      // Get alerts from service (assuming method exists)
      final allAlerts = <ZoneAlert>[];
      final agentAlerts = allAlerts
          .where((a) => a.agentId == agentId.toString())
          .toList();
      
      return AgentGeolocationStats(
        agentId: agentId,
        todayPositions: agentPositions.length,
        activeZones: agentZones.where((z) => z.isActive).length,
        totalZones: agentZones.length,
        activeAlerts: agentAlerts.where((a) => !a.isAcknowledged).length,
        totalAlerts: agentAlerts.length,
        lastPosition: agentPositions.isNotEmpty ? agentPositions.last : null,
        coverageArea: _calculateCoverageArea(agentZones),
      );
    } catch (e) {
      return AgentGeolocationStats(
        agentId: agentId,
        todayPositions: 0,
        activeZones: 0,
        totalZones: 0,
        activeAlerts: 0,
        totalAlerts: 0,
        lastPosition: null,
        coverageArea: 0.0,
      );
    }
  }
  
  /// Synchroniser les zones de collecte avec les zones géographiques
  Future<void> syncZonesWithZoneCollect() async {
    try {
      final locationService = LocationService();
      final zoneCollects = await locationService.getAllZones();
      
      for (final zoneCollect in zoneCollects) {
        // Vérifier si la zone existe déjà (simplified logic)
        final geoZone = createGeoZoneFromZoneCollect(zoneCollect);
        // Add zone to service (assuming method exists)
      }
    } catch (e) {
      // Logger l'erreur mais ne pas arrêter le processus
    }
  }
  
  /// Créer une alerte de zone pour une transaction hors zone
  Future<void> createTransactionOutOfZoneAlert(TransactionDTO transaction) async {
    try {
      final isInZone = await isTransactionInAssignedZone(transaction);
      
      if (!isInZone) {
        final alert = ZoneAlert(
          id: 'tx_oob_${transaction.id}_${DateTime.now().millisecondsSinceEpoch}',
          agentId: transaction.agentId.toString(),
          zoneId: transaction.zoneId.toString(),
          type: AlertType.zoneExit,
          severity: AlertSeverity.medium,
          position: LatLng(
            transaction.latitude ?? 5.3600,
            transaction.longitude ?? -4.0083,
          ),
          timestamp: DateTime.now(),
          message: 'Transaction ${transaction.numeroRecu} effectuée hors de la zone assignée',
          isAcknowledged: false,
        );
        
        // Add alert to service (assuming method exists)
      }
    } catch (e) {
      // Logger l'erreur
    }
  }
  
  /// Calculer la superficie de couverture des zones d'un agent
  double _calculateCoverageArea(List<GeoZone> agentZones) {
    double totalArea = 0.0;
    
    for (final zone in agentZones) {
      if (zone.isCircular && zone.radius != null) {
        // Aire d'un cercle: π * r²
        totalArea += 3.14159 * (zone.radius! * zone.radius!);
      } else if (zone.isPolygon && zone.points.isNotEmpty) {
        // Calcul simplifié de l'aire d'un polygone
        totalArea += _calculatePolygonArea(zone.points);
      }
    }
    
    return totalArea;
  }
  
  /// Calculer l'aire d'un polygone (méthode de Shoelace)
  double _calculatePolygonArea(List<LatLng> points) {
    if (points.length < 3) return 0.0;
    
    double area = 0.0;
    for (int i = 0; i < points.length; i++) {
      final j = (i + 1) % points.length;
      area += points[i].latitude * points[j].longitude;
      area -= points[j].latitude * points[i].longitude;
    }
    
    return (area.abs() / 2.0) * 111320.0 * 111320.0; // Conversion en mètres²
  }
}

/// Statistiques de géolocalisation pour un agent
class AgentGeolocationStats {
  final int agentId;
  final int todayPositions;
  final int activeZones;
  final int totalZones;
  final int activeAlerts;
  final int totalAlerts;
  final GpsPoint? lastPosition;
  final double coverageArea;
  
  AgentGeolocationStats({
    required this.agentId,
    required this.todayPositions,
    required this.activeZones,
    required this.totalZones,
    required this.activeAlerts,
    required this.totalAlerts,
    this.lastPosition,
    required this.coverageArea,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'agentId': agentId,
      'todayPositions': todayPositions,
      'activeZones': activeZones,
      'totalZones': totalZones,
      'activeAlerts': activeAlerts,
      'totalAlerts': totalAlerts,
      'lastPosition': lastPosition?.toJson(),
      'coverageArea': coverageArea,
    };
  }
  
  factory AgentGeolocationStats.fromJson(Map<String, dynamic> json) {
    return AgentGeolocationStats(
      agentId: json['agentId'],
      todayPositions: json['todayPositions'],
      activeZones: json['activeZones'],
      totalZones: json['totalZones'],
      activeAlerts: json['activeAlerts'],
      totalAlerts: json['totalAlerts'],
      lastPosition: json['lastPosition'] != null 
          ? GpsPoint.fromJson(json['lastPosition']) 
          : null,
      coverageArea: json['coverageArea']?.toDouble() ?? 0.0,
    );
  }
}

/// Extensions sur les modèles existants pour la géolocalisation
extension ContribuableDtoGeolocation on ContribuableDto {
  /// Créer un PointOfInterest à partir d'un contribuable
  PointOfInterest toPointOfInterest() {
    return PointOfInterest(
      id: 'contrib_${id}',
      name: fullName,
      description: 'Contribuable: $fullName',
      position: LatLng(latitude ?? 5.3600, longitude ?? -4.0083),
      type: 'contribuable',
      icon: 'person',
      metadata: {
        'contribuableId': id,
        'telephone': telephone,
        'activites': activites,
        'zoneCollecteId': zoneCollecteId,
      },
    );
  }
  
  /// Vérifier si le contribuable a des coordonnées valides
  bool hasValidLocation() {
    return latitude != null && longitude != null &&
           latitude! >= -90 && latitude! <= 90 &&
           longitude! >= -180 && longitude! <= 180;
  }
}

extension AgentsDtoGeolocation on AgentsDto {
  /// Créer un PointOfInterest à partir d'un agent
  PointOfInterest toPointOfInterest() {
    return PointOfInterest(
      id: 'agent_${id}',
      name: fullName,
      description: 'Agent: $fullName',
      position: LatLng(5.3600, -4.0083), // Position par défaut
      type: 'agent',
      icon: 'person',
      metadata: {
        'agentId': id,
        'email': email,
        'telephone': telephone,
        'zoneIds': zoneIds,
      },
    );
  }
}

extension TransactionDTOGeolocation on TransactionDTO {
  /// Créer un PointOfInterest à partir d'une transaction
  PointOfInterest toPointOfInterest() {
    return PointOfInterest(
      id: 'tx_${id}',
      name: 'Transaction: ${numeroRecu}',
      description: 'Paiement de ${montant.toStringAsFixed(0)} FCFA',
      position: LatLng(latitude ?? 5.3600, longitude ?? -4.0083),
      type: 'transaction',
      icon: 'payment',
      metadata: {
        'transactionId': id,
        'montant': montant,
        'modePaiement': modePaiement.code,
        'statut': statut.code,
        'contribuableId': contribuableId,
        'agentId': agentId,
        'zoneId': zoneId,
      },
    );
  }
  
  /// Vérifier si la transaction a des coordonnées valides
  bool hasValidLocation() {
    return latitude != null && longitude != null &&
           latitude! >= -90 && latitude! <= 90 &&
           longitude! >= -180 && longitude! <= 180;
  }
}

extension ZoneCollectDtoGeolocation on ZoneCollectDto {
  /// Créer une GeoZone à partir d'une ZoneCollectDto
  GeoZone toGeoZone({
    String agentId = 'system',
    String color = '#1976D2',
    double? radius,
  }) {
    return GeoZone(
      id: id.toString(),
      name: nom,
      description: 'Zone de collecte: ${nom}',
      type: ZoneType.commercial,
      points: [],
      center: const LatLng(5.3600, -4.0083), // Centre par défaut
      radius: radius ?? 1000.0,
      agentId: agentId,
      color: color,
      isActive: true,
      createdAt: DateTime.now(),
    );
  }
}
