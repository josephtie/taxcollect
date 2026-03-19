import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/models.dart';
import '../services/geolocation_service.dart';
import '../services/location_service.dart';
import '../services/recensement_service.dart';
import '../extensions/geolocation_extensions.dart';

/// Extensions pour aligner le recensement avec la géolocalisation
extension RecensementGeolocationExtensions on ContribuableForm {
  
  /// Créer un PointOfInterest à partir d'un ContribuableForm
  PointOfInterest toPointOfInterest() {
    return PointOfInterest(
      id: 'recense_${id ?? 'new'}',
      name: fullName,
      description: 'Contribuable: $fullName\nActivité: $activite\nType: $displayType',
      position: LatLng(
        latitude ?? 5.3600, // Centre d'Abidjan par défaut
        longitude ?? -4.0083,
      ),
      type: 'contribuable_recense',
      icon: _getIconForType(),
      metadata: {
        'contribuableId': id,
        'telephone': telephone,
        'type': type.code,
        'activite': activite,
        'zoneId': zoneId,
        'marche': marche,
        'quartier': quartier,
        'statut': statut.code,
        'syncStatus': syncStatus.code,
        'dateCreation': dateCreation.toIso8601String(),
        'agentId': agentId,
        'version': version,
        'necessiteValidation': necessiteValidation,
      },
    );
  }
  
  /// Créer un GpsPoint à partir d'un ContribuableForm
  GpsPoint toGpsPoint({
    String? action,
    String? agentIdOverride,
  }) {
    return GpsPoint(
      id: 'recense_${id ?? 'new'}_${DateTime.now().millisecondsSinceEpoch}',
      latitude: latitude ?? 5.3600,
      longitude: longitude ?? -4.0083,
      accuracy: 10.0,
      altitude: null,
      speed: null,
      heading: null,
      timestamp: DateTime.now(),
      source: 'recensement',
      action: action ?? 'registration',
      contribuableId: id?.toString(),
      agentId: agentIdOverride ?? agentId,
    );
  }
  
  /// Vérifier si le contribuable a des coordonnées GPS valides
  bool hasValidLocation() {
    return latitude != null && longitude != null &&
           latitude! >= -90 && latitude! <= 90 &&
           longitude! >= -180 && longitude! <= 180;
  }
  
  /// Vérifier si le contribuable est dans sa zone assignée
  Future<bool> isInAssignedZone() async {
    try {
      if (!hasValidLocation() || zoneId.isEmpty) return false;
      
      final locationService = LocationService();
      final zoneCollect = await locationService.getZoneById(int.tryParse(zoneId) ?? 0);
      
      if (zoneCollect == null) return false;
      
      // Créer une zone géographique pour la vérification
      final geoZone = GeolocationService().createGeoZoneFromZoneCollect(zoneCollect);
      final position = LatLng(latitude!, longitude!);
      
      return geoZone.containsPoint(position);
    } catch (e) {
      return false;
    }
  }
  
  /// Obtenir la distance par rapport au centre de la zone
  Future<double?> getDistanceToZoneCenter() async {
    try {
      if (!hasValidLocation() || zoneId.isEmpty) return null;
      
      final locationService = LocationService();
      final zoneCollect = await locationService.getZoneById(int.tryParse(zoneId) ?? 0);
      
      if (zoneCollect == null) return null;
      
      final geoZone = GeolocationService().createGeoZoneFromZoneCollect(zoneCollect);
      if (geoZone.center == null) return null;
      
      // Calculer la distance avec Geolocator
      return Geolocator.distanceBetween(
        latitude!,
        longitude!,
        geoZone.center!.latitude,
        geoZone.center!.longitude,
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Créer une alerte si le contribuable est hors zone
  Future<ZoneAlert?> createOutOfZoneAlert() async {
    try {
      if (await isInAssignedZone()) return null;
      
      final locationService = LocationService();
      final zoneCollect = await locationService.getZoneById(int.tryParse(zoneId) ?? 0);
      
      if (zoneCollect == null) return null;
      
      return ZoneAlert(
        id: 'recense_oob_${id ?? 'new'}_${DateTime.now().millisecondsSinceEpoch}',
        agentId: agentId,
        zoneId: zoneId,
        type: AlertType.zoneExit,
        severity: AlertSeverity.medium,
        position: LatLng(
          latitude ?? 5.3600,
          longitude ?? -4.0083,
        ),
        timestamp: DateTime.now(),
        message: 'Contribuable $fullName enregistré hors de sa zone assignée: ${zoneCollect.nom}',
        isAcknowledged: false,
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Obtenir l'icône appropriée selon le type de contribuable
  String _getIconForType() {
    switch (type) {
      case ContribuableType.personnePhysique:
        return 'person';
      case ContribuableType.personneMorale:
        return 'business';
      case ContribuableType.commercant:
        return 'store';
      case ContribuableType.transporteur:
        return 'directions_car';
      case ContribuableType.artisan:
        return 'construction';
      case ContribuableType.occupantDomainePublic:
        return 'location_city';
    }
  }
  
  /// Valider et corriger les coordonnées GPS
  ContribuableForm validateAndCorrectLocation() {
    if (!hasValidLocation()) {
      // Si les coordonnées sont invalides, utiliser le centre de la zone
      return copyWith(
        latitude: 5.3600, // Centre d'Abidjan par défaut
        longitude: -4.0083,
      );
    }
    return this;
  }
  
  /// Mettre à jour les coordonnées depuis un GpsPoint
  ContribuableForm updateFromGpsPoint(GpsPoint gpsPoint) {
    return copyWith(
      latitude: gpsPoint.latitude,
      longitude: gpsPoint.longitude,
      version: version + 1,
    );
  }
}

/// Extensions pour le service de recensement
extension RecensementServiceGeolocation on RecensementService {
  
  /// Synchroniser les contribuables avec le service de géolocalisation
  Future<void> syncWithGeolocationService() async {
    try {
      final geolocationService = GeolocationService();
      final contribuables = await getAllContribuables();
      
      for (final contribuable in contribuables) {
        // Créer un PointOfInterest pour chaque contribuable
        final poi = contribuable.toPointOfInterest();
        
        // Ajouter au service de géolocalisation (méthode hypothétique)
        // geolocationService.addPointOfInterest(poi);
        
        // Créer un GpsPoint pour le suivi
        final gpsPoint = contribuable.toGpsPoint(action: 'sync');
        
        // Ajouter au suivi GPS (méthode hypothétique)
        // geolocationService.addGpsPoint(gpsPoint);
        
        // Vérifier si le contribuable est hors zone
        final alert = await contribuable.createOutOfZoneAlert();
        if (alert != null) {
          // Ajouter l'alerte (méthode hypothétique)
          // geolocationService.addAlert(alert);
        }
      }
    } catch (e) {
      // Logger l'erreur mais ne pas arrêter le processus
    }
  }
  
  /// Obtenir les contribuables dans une zone géographique
  Future<List<ContribuableForm>> getContribuablesInZone(
    GeoZone geoZone, {
    ContribuableType? type,
    ContribuableStatus? status,
  }) async {
    try {
      final contribuables = await getAllContribuables();
      
      return contribuables.where((contribuable) {
        // Vérifier si le contribuable a des coordonnées valides
        if (!contribuable.hasValidLocation()) return false;
        
        // Vérifier si le contribuable est dans la zone
        final position = LatLng(
          contribuable.latitude!,
          contribuable.longitude!,
        );
        
        if (!geoZone.containsPoint(position)) return false;
        
        // Filtrer par type si spécifié
        if (type != null && contribuable.type != type) return false;
        
        // Filtrer par statut si spécifié
        if (status != null && contribuable.statut != status) return false;
        
        return true;
      }).toList();
    } catch (e) {
      return [];
    }
  }
  
  /// Obtenir les statistiques de recensement par zone géographique
  Future<Map<String, RecensementZoneStatistics>> getStatisticsByZone() async {
    try {
      final locationService = LocationService();
      final zones = await locationService.getAllZones();
      final contribuables = await getAllContribuables();
      
      final statistics = <String, RecensementZoneStatistics>{};
      
      for (final zone in zones) {
        final geoZone = GeolocationService().createGeoZoneFromZoneCollect(zone);
        final zoneContribuables = await getContribuablesInZone(geoZone);
        
        statistics[zone.id.toString()] = RecensementZoneStatistics(
          zoneId: zone.id.toString(),
          zoneNom: zone.nom,
          totalContribuables: zoneContribuables.length,
          contribuablesActifs: zoneContribuables
              .where((c) => c.statut == ContribuableStatus.actif)
              .length,
          contribuablesSynchronises: zoneContribuables
              .where((c) => c.syncStatus == SyncStatus.synchronized)
              .length,
          contribuablesHorsZone: zoneContribuables
              .where((c) => !c.hasValidLocation())
              .length,
          repartitionParType: _calculateTypeDistribution(zoneContribuables),
        );
      }
      
      return statistics;
    } catch (e) {
      return {};
    }
  }
  
  /// Calculer la répartition par type pour une liste de contribuables
  Map<ContribuableType, int> _calculateTypeDistribution(List<ContribuableForm> contribuables) {
    final distribution = <ContribuableType, int>{};
    
    for (final contribuable in contribuables) {
      distribution[contribuable.type] = (distribution[contribuable.type] ?? 0) + 1;
    }
    
    return distribution;
  }
  
  /// Optimiser les coordonnées des contribuables sans localisation valide
  Future<void> optimizeContribuableLocations() async {
    try {
      final contribuables = await getAllContribuables();
      final locationService = LocationService();
      
      for (final contribuable in contribuables) {
        if (!contribuable.hasValidLocation() && contribuable.zoneId.isNotEmpty) {
          final zone = await locationService.getZoneById(int.tryParse(contribuable.zoneId) ?? 0);
          
          if (zone != null) {
            final geoZone = GeolocationService().createGeoZoneFromZoneCollect(zone);
            if (geoZone.center != null) {
              // Mettre à jour le contribuable avec le centre de la zone
              final updatedContribuable = contribuable.copyWith(
                latitude: geoZone.center!.latitude,
                longitude: geoZone.center!.longitude,
                version: contribuable.version + 1,
              );
              
              // Sauvegarder les modifications
              await updateContribuable(updatedContribuable);
            }
          }
        }
      }
    } catch (e) {
      // Logger l'erreur mais ne pas arrêter le processus
    }
  }
}

/// Statistiques de recensement par zone
class RecensementZoneStatistics {
  final String zoneId;
  final String zoneNom;
  final int totalContribuables;
  final int contribuablesActifs;
  final int contribuablesSynchronises;
  final int contribuablesHorsZone;
  final Map<ContribuableType, int> repartitionParType;
  
  RecensementZoneStatistics({
    required this.zoneId,
    required this.zoneNom,
    required this.totalContribuables,
    required this.contribuablesActifs,
    required this.contribuablesSynchronises,
    required this.contribuablesHorsZone,
    required this.repartitionParType,
  });
  
  double get tauxSynchronisation => 
      totalContribuables > 0 ? contribuablesSynchronises / totalContribuables : 0.0;
  
  double get tauxActivite => 
      totalContribuables > 0 ? contribuablesActifs / totalContribuables : 0.0;
  
  Map<String, dynamic> toJson() {
    return {
      'zoneId': zoneId,
      'zoneNom': zoneNom,
      'totalContribuables': totalContribuables,
      'contribuablesActifs': contribuablesActifs,
      'contribuablesSynchronises': contribuablesSynchronises,
      'contribuablesHorsZone': contribuablesHorsZone,
      'repartitionParType': repartitionParType.map((k, v) => MapEntry(k.code, v)),
      'tauxSynchronisation': tauxSynchronisation,
      'tauxActivite': tauxActivite,
    };
  }
  
  factory RecensementZoneStatistics.fromJson(Map<String, dynamic> json) {
    return RecensementZoneStatistics(
      zoneId: json['zoneId'],
      zoneNom: json['zoneNom'],
      totalContribuables: json['totalContribuables'],
      contribuablesActifs: json['contribuablesActifs'],
      contribuablesSynchronises: json['contribuablesSynchronises'],
      contribuablesHorsZone: json['contribuablesHorsZone'],
      repartitionParType: Map.from(json['repartitionParType'] ?? {})
          .map((k, v) => MapEntry(
            ContribuableType.values.firstWhere(
              (t) => t.code == k,
              orElse: () => ContribuableType.personnePhysique,
            ),
            v,
          )),
    );
  }
}

/// Extensions sur RecensementStatistics pour la géolocalisation
extension RecensementStatisticsGeolocation on RecensementStatistics {
  
  /// Ajouter les statistiques géolocalisées
  RecensementStatistics withGeolocationStats({
    required Map<String, RecensementZoneStatistics> zoneStats,
    required int contribuablesAvecCoordonnees,
    required int contribuablesHorsZone,
  }) {
    return RecensementStatistics(
      totalContribuables: totalContribuables,
      nonSynchronises: nonSynchronises,
      enValidation: enValidation,
      creesAujourdhui: creesAujourdhui,
      misAJourAujourdhui: misAJourAujourdhui,
      repartitionParType: repartitionParType,
      repartitionParZone: repartitionParType.map((k, v) => MapEntry(k.code, v)),
      tauxSynchronisation: tauxSynchronisation,
      derniereSynchronisation: derniereSynchronisation,
    );
  }
}
