import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

// GPS Tracking Modes
enum GpsTrackingMode {
  none('none', 'Aucun'),
  passive('passive', 'Passif - Économie d\'énergie'),
  active('active', 'Actif - Suivi régulier'),
  continuous('continuous', 'Continu - Suivi constant');

  const GpsTrackingMode(this.code, this.label);
  final String code;
  final String label;
}

// Map View Types
enum MapViewType {
  normal('normal', 'Normal'),
  satellite('satellite', 'Satellite'),
  hybrid('hybrid', 'Hybride'),
  terrain('terrain', 'Relief');

  const MapViewType(this.code, this.label);
  final String code;
  final String label;
}

// Zone Types
enum ZoneType {
  administrative('administrative', 'Administrative'),
  commercial('commercial', 'Commerciale'),
  residential('residential', 'Résidentielle'),
  industrial('industrial', 'Industrielle'),
  mixed('mixed', 'Mixte');

  const ZoneType(this.code, this.label);
  final String code;
  final String label;
}

// Alert Types
enum AlertType {
  zoneExit('zone_exit', 'Sortie de zone'),
  zoneEntry('zone_entry', 'Entrée dans la zone'),
  signalLoss('signal_loss', 'Perte de signal'),
  timeout('timeout', 'Timeout'),
  lowBattery('low_battery', 'Batterie faible');

  const AlertType(this.code, this.label);
  final String code;
  final String label;
}

// Alert Severity Levels
enum AlertSeverity {
  low('low', 'Bas'),
  medium('medium', 'Moyen'),
  high('high', 'Haut'),
  critical('critical', 'Critique');

  const AlertSeverity(this.code, this.label);
  final String code;
  final String label;
}

// Heatmap Density Levels
enum HeatmapDensity {
  high('high', 'Zone bien recensée'),
  medium('medium', 'Zone partiellement recensée'),
  low('low', 'Zone faiblement recensée'),
  none('none', 'Zone non recensée');

  const HeatmapDensity(this.code, this.label);
  final String code;
  final String label;
}

// GPS Point Model
class GpsPoint {
  final String id;
  final double latitude;
  final double longitude;
  final double accuracy;
  final double? altitude;
  final double? speed;
  final double? heading;
  final DateTime timestamp;
  final String source; // gps, network, passive
  final String? action; // contribuable_scan, zone_entry, etc.
  final String? contribuableId;
  final String? agentId;

  GpsPoint({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    required this.timestamp,
    required this.source,
    this.action,
    this.contribuableId,
    this.agentId,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
      'source': source,
      'action': action,
      'contribuableId': contribuableId,
      'agentId': agentId,
    };
  }

  factory GpsPoint.fromJson(Map<String, dynamic> json) {
    return GpsPoint(
      id: json['id'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      accuracy: json['accuracy'].toDouble(),
      altitude: json['altitude']?.toDouble(),
      speed: json['speed']?.toDouble(),
      heading: json['heading']?.toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      source: json['source'],
      action: json['action'],
      contribuableId: json['contribuableId'],
      agentId: json['agentId'],
    );
  }

  GpsPoint copyWith({
    String? id,
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    DateTime? timestamp,
    String? source,
    String? action,
    String? contribuableId,
    String? agentId,
  }) {
    return GpsPoint(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      timestamp: timestamp ?? this.timestamp,
      source: source ?? this.source,
      action: action ?? this.action,
      contribuableId: contribuableId ?? this.contribuableId,
      agentId: agentId ?? this.agentId,
    );
  }
}

// Zone Model
class GeoZone {
  final String id;
  final String name;
  final String description;
  final ZoneType type;
  final List<LatLng> points; // Polygon points
  final LatLng? center; // For circular zones
  final double? radius; // For circular zones
  final String agentId;
  final String color;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  GeoZone({
    required this.id,
    required this.name,
    this.description = '',
    required this.type,
    required this.points,
    this.center,
    this.radius,
    required this.agentId,
    required this.color,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isCircular => center != null && radius != null;
  bool get isPolygon => points.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.code,
      'points': points.map((p) => {'latitude': p.latitude, 'longitude': p.longitude}).toList(),
      'center': center != null ? {'latitude': center!.latitude, 'longitude': center!.longitude} : null,
      'radius': radius,
      'agentId': agentId,
      'color': color,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory GeoZone.fromJson(Map<String, dynamic> json) {
    return GeoZone(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      type: ZoneType.values.firstWhere((t) => t.code == json['type']),
      points: (json['points'] as List)
          .map((p) => LatLng(p['latitude'], p['longitude']))
          .toList(),
      center: json['center'] != null
          ? LatLng(json['center']['latitude'], json['center']['longitude'])
          : null,
      radius: json['radius']?.toDouble(),
      agentId: json['agentId'],
      color: json['color'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  GeoZone copyWith({
    String? id,
    String? name,
    String? description,
    ZoneType? type,
    List<LatLng>? points,
    LatLng? center,
    double? radius,
    String? agentId,
    String? color,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GeoZone(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      points: points ?? this.points,
      center: center ?? this.center,
      radius: radius ?? this.radius,
      agentId: agentId ?? this.agentId,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if a point is inside this zone
  bool containsPoint(LatLng point) {
    if (isCircular && center != null && radius != null) {
      final distance = Geolocator.distanceBetween(
        center!.latitude,
        center!.longitude,
        point.latitude,
        point.longitude,
      );
      return distance <= radius!;
    } else if (isPolygon) {
      return _isPointInPolygon(point, points);
    }
    return false;
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return false;

    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final xi = polygon[i].longitude, yi = polygon[i].latitude;
      final xj = polygon[j].longitude, yj = polygon[j].latitude;

      final intersect = ((yi > point.latitude) != (yj > point.latitude))
          && (point.longitude < (xj - xi) * (point.latitude - yi) / (yj - yi) + xi);
      if (intersect) inside = !inside;
    }

    return inside;
  }
}

// Point of Interest Model
class PointOfInterest {
  final String id;
  final String name;
  final String description;
  final LatLng position;
  final String type; // market, office, landmark, etc.
  final String? icon;
  final Map<String, dynamic>? metadata;

  PointOfInterest({
    required this.id,
    required this.name,
    this.description = '',
    required this.position,
    required this.type,
    this.icon,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'position': {'latitude': position.latitude, 'longitude': position.longitude},
      'type': type,
      'icon': icon,
      'metadata': metadata,
    };
  }

  factory PointOfInterest.fromJson(Map<String, dynamic> json) {
    return PointOfInterest(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      position: LatLng(
        json['position']['latitude'],
        json['position']['longitude'],
      ),
      type: json['type'],
      icon: json['icon'],
      metadata: json['metadata'],
    );
  }

  PointOfInterest copyWith({
    String? id,
    String? name,
    String? description,
    LatLng? position,
    String? type,
    String? icon,
    Map<String, dynamic>? metadata,
  }) {
    return PointOfInterest(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      position: position ?? this.position,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      metadata: metadata ?? this.metadata,
    );
  }
}

// Zone Alert Model
class ZoneAlert {
  final String id;
  final String agentId;
  final String zoneId;
  final AlertType type;
  final AlertSeverity severity;
  final LatLng position;
  final DateTime timestamp;
  final String message;
  final bool isAcknowledged;
  final DateTime? acknowledgedAt;
  final String? acknowledgedBy;

  ZoneAlert({
    required this.id,
    required this.agentId,
    required this.zoneId,
    required this.type,
    required this.severity,
    required this.position,
    required this.timestamp,
    required this.message,
    this.isAcknowledged = false,
    this.acknowledgedAt,
    this.acknowledgedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agentId': agentId,
      'zoneId': zoneId,
      'type': type.code,
      'severity': severity.code,
      'position': {'latitude': position.latitude, 'longitude': position.longitude},
      'timestamp': timestamp.toIso8601String(),
      'message': message,
      'isAcknowledged': isAcknowledged,
      'acknowledgedAt': acknowledgedAt?.toIso8601String(),
      'acknowledgedBy': acknowledgedBy,
    };
  }

  factory ZoneAlert.fromJson(Map<String, dynamic> json) {
    return ZoneAlert(
      id: json['id'],
      agentId: json['agentId'],
      zoneId: json['zoneId'],
      type: AlertType.values.firstWhere((t) => t.code == json['type']),
      severity: AlertSeverity.values.firstWhere((s) => s.code == json['severity']),
      position: LatLng(
        json['position']['latitude'],
        json['position']['longitude'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      message: json['message'],
      isAcknowledged: json['isAcknowledged'] ?? false,
      acknowledgedAt: json['acknowledgedAt'] != null 
          ? DateTime.parse(json['acknowledgedAt']) 
          : null,
      acknowledgedBy: json['acknowledgedBy'],
    );
  }

  ZoneAlert copyWith({
    String? id,
    String? agentId,
    String? zoneId,
    AlertType? type,
    AlertSeverity? severity,
    LatLng? position,
    DateTime? timestamp,
    String? message,
    bool? isAcknowledged,
    DateTime? acknowledgedAt,
    String? acknowledgedBy,
  }) {
    return ZoneAlert(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      zoneId: zoneId ?? this.zoneId,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      position: position ?? this.position,
      timestamp: timestamp ?? this.timestamp,
      message: message ?? this.message,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
    );
  }
}

// Location History Model
class LocationHistory {
  final String id;
  final String agentId;
  final List<GpsPoint> points;
  final DateTime startDate;
  final DateTime endDate;
  final double totalDistance;
  final int totalPoints;

  LocationHistory({
    required this.id,
    required this.agentId,
    required this.points,
    required this.startDate,
    required this.endDate,
    required this.totalDistance,
    required this.totalPoints,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agentId': agentId,
      'points': points.map((p) => p.toJson()).toList(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalDistance': totalDistance,
      'totalPoints': totalPoints,
    };
  }

  factory LocationHistory.fromJson(Map<String, dynamic> json) {
    return LocationHistory(
      id: json['id'],
      agentId: json['agentId'],
      points: (json['points'] as List)
          .map((p) => GpsPoint.fromJson(p))
          .toList(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalDistance: json['totalDistance'].toDouble(),
      totalPoints: json['totalPoints'],
    );
  }
}

// Geolocation Statistics Model
class GeolocationStatistics {
  final int activeAgents;
  final int todayPositions;
  final double zoneCoverage;
  final int localizedContribuables;
  final int activeAlerts;
  final int nonSurveyedZones;
  final Map<String, int> agentPositions;
  final Map<String, double> zoneDensity;
  final List<ZoneAlert> recentAlerts;

  GeolocationStatistics({
    required this.activeAgents,
    required this.todayPositions,
    required this.zoneCoverage,
    required this.localizedContribuables,
    required this.activeAlerts,
    required this.nonSurveyedZones,
    required this.agentPositions,
    required this.zoneDensity,
    required this.recentAlerts,
  });

  Map<String, dynamic> toJson() {
    return {
      'activeAgents': activeAgents,
      'todayPositions': todayPositions,
      'zoneCoverage': zoneCoverage,
      'localizedContribuables': localizedContribuables,
      'activeAlerts': activeAlerts,
      'nonSurveyedZones': nonSurveyedZones,
      'agentPositions': agentPositions,
      'zoneDensity': zoneDensity,
      'recentAlerts': recentAlerts.map((a) => a.toJson()).toList(),
    };
  }

  factory GeolocationStatistics.fromJson(Map<String, dynamic> json) {
    return GeolocationStatistics(
      activeAgents: json['activeAgents'],
      todayPositions: json['todayPositions'],
      zoneCoverage: json['zoneCoverage'].toDouble(),
      localizedContribuables: json['localizedContribuables'],
      activeAlerts: json['activeAlerts'],
      nonSurveyedZones: json['nonSurveyedZones'],
      agentPositions: Map<String, int>.from(json['agentPositions']),
      zoneDensity: Map<String, double>.from(json['zoneDensity']),
      recentAlerts: (json['recentAlerts'] as List)
          .map((a) => ZoneAlert.fromJson(a))
          .toList(),
    );
  }
}

// Map Configuration Model
class MapConfiguration {
  final MapViewType viewType;
  final bool showContribuables;
  final bool showZones;
  final bool showHeatmap;
  final bool showOtherAgents;
  final bool showPointsOfInterest;
  final bool showMyPosition;
  final double zoomLevel;
  final LatLng? center;

  MapConfiguration({
    this.viewType = MapViewType.normal,
    this.showContribuables = true,
    this.showZones = true,
    this.showHeatmap = false,
    this.showOtherAgents = true,
    this.showPointsOfInterest = false,
    this.showMyPosition = true,
    this.zoomLevel = 15.0,
    this.center,
  });

  Map<String, dynamic> toJson() {
    return {
      'viewType': viewType.code,
      'showContribuables': showContribuables,
      'showZones': showZones,
      'showHeatmap': showHeatmap,
      'showOtherAgents': showOtherAgents,
      'showPointsOfInterest': showPointsOfInterest,
      'showMyPosition': showMyPosition,
      'zoomLevel': zoomLevel,
      'center': center != null 
          ? {'latitude': center!.latitude, 'longitude': center!.longitude}
          : null,
    };
  }

  factory MapConfiguration.fromJson(Map<String, dynamic> json) {
    return MapConfiguration(
      viewType: MapViewType.values.firstWhere((v) => v.code == json['viewType']),
      showContribuables: json['showContribuables'] ?? true,
      showZones: json['showZones'] ?? true,
      showHeatmap: json['showHeatmap'] ?? false,
      showOtherAgents: json['showOtherAgents'] ?? true,
      showPointsOfInterest: json['showPointsOfInterest'] ?? false,
      showMyPosition: json['showMyPosition'] ?? true,
      zoomLevel: json['zoomLevel']?.toDouble() ?? 15.0,
      center: json['center'] != null
          ? LatLng(json['center']['latitude'], json['center']['longitude'])
          : null,
    );
  }

  MapConfiguration copyWith({
    MapViewType? viewType,
    bool? showContribuables,
    bool? showZones,
    bool? showHeatmap,
    bool? showOtherAgents,
    bool? showPointsOfInterest,
    bool? showMyPosition,
    double? zoomLevel,
    LatLng? center,
  }) {
    return MapConfiguration(
      viewType: viewType ?? this.viewType,
      showContribuables: showContribuables ?? this.showContribuables,
      showZones: showZones ?? this.showZones,
      showHeatmap: showHeatmap ?? this.showHeatmap,
      showOtherAgents: showOtherAgents ?? this.showOtherAgents,
      showPointsOfInterest: showPointsOfInterest ?? this.showPointsOfInterest,
      showMyPosition: showMyPosition ?? this.showMyPosition,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      center: center ?? this.center,
    );
  }
}
