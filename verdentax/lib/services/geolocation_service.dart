import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../config/config.dart';
import '../models/models.dart';
import '../models/geolocation.dart';
import '../services/services.dart';

class GeolocationService {
  static final GeolocationService _instance = GeolocationService._internal();
  factory GeolocationService() => _instance;
  GeolocationService._internal();

  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();

  // GPS Tracking
  GpsTrackingMode _trackingMode = GpsTrackingMode.none;
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _trackingTimer;
  Position? _currentPosition;
  List<GpsPoint> _todayPositions = [];
  
  // Map State
  MapConfiguration _mapConfig = MapConfiguration();
  Set<Marker> _markers = {};
  Set<Polygon> _polygons = {};
  Set<Circle> _circles = {};
  GoogleMapController? _mapController;
  
  // Zones and Alerts
  List<GeoZone> _zones = [];
  List<ZoneAlert> _alerts = [];
  List<PointOfInterest> _pointsOfInterest = [];
  
  // Event streams
  final StreamController<GpsPoint> _positionStreamController = 
      StreamController<GpsPoint>.broadcast();
  final StreamController<ZoneAlert> _alertStreamController = 
      StreamController<ZoneAlert>.broadcast();
  final StreamController<GeolocationStatistics> _statsStreamController = 
      StreamController<GeolocationStatistics>.broadcast();

  // Getters
  GpsTrackingMode get trackingMode => _trackingMode;
  Position? get currentPosition => _currentPosition;
  MapConfiguration get mapConfig => _mapConfig;
  Set<Marker> get markers => _markers;
  Set<Polygon> get polygons => _polygons;
  Set<Circle> get circles => _circles;
  List<GeoZone> get zones => _zones;
  List<ZoneAlert> get alerts => _alerts;
  List<PointOfInterest> get pointsOfInterest => _pointsOfInterest;
  
  Stream<GpsPoint> get positionStream => _positionStreamController.stream;
  Stream<ZoneAlert> get alertStream => _alertStreamController.stream;
  Stream<GeolocationStatistics> get statsStream => _statsStreamController.stream;

  // Initialize the service
  Future<void> initialize() async {
    try {
      _logger.i('Initializing GeolocationService...');
      
      // Request location permissions
      await _requestLocationPermissions();
      
      // Load saved configuration
      await _loadMapConfiguration();
      
      // Load zones and points of interest
      await _loadZones();
      await _loadPointsOfInterest();
      
      // Start statistics updates
      _startStatisticsUpdates();
      
      _logger.i('GeolocationService initialized successfully');
    } catch (e) {
      _logger.e('Error initializing GeolocationService: $e');
      rethrow;
    }
  }

  // Location permissions
  Future<void> _requestLocationPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Les services de localisation sont désactivés');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Les permissions de localisation sont refusées');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Les permissions de localisation sont refusées de manière permanente');
    }
  }

  // GPS Tracking Management
  Future<void> setTrackingMode(GpsTrackingMode mode) async {
    if (_trackingMode == mode) return;

    _logger.i('Setting GPS tracking mode to: ${mode.label}');
    
    // Stop current tracking
    await _stopTracking();
    
    _trackingMode = mode;
    
    // Start new tracking if not none
    if (mode != GpsTrackingMode.none) {
      await _startTracking(mode);
    }
    
    // Save configuration
    await _saveTrackingMode(mode);
  }

  Future<void> _startTracking(GpsTrackingMode mode) async {
    try {
      LocationSettings locationSettings;
      Duration interval;

      switch (mode) {
        case GpsTrackingMode.passive:
          locationSettings = const LocationSettings(
            accuracy: LocationAccuracy.low,
            distanceFilter: 100,
          );
          interval = const Duration(minutes: 5);
          break;
        case GpsTrackingMode.active:
          locationSettings = const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          );
          interval = const Duration(seconds: 30);
          break;
        case GpsTrackingMode.continuous:
          locationSettings = const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          );
          interval = const Duration(seconds: 10);
          break;
        default:
          return;
      }

      // Start position stream
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(_onPositionUpdate);

      // Start periodic timer for additional tracking
      _trackingTimer = Timer.periodic(interval, (_) {
        _captureCurrentPosition('periodic');
      });

      // Get initial position
      await _captureCurrentPosition('initial');
      
    } catch (e) {
      _logger.e('Error starting GPS tracking: $e');
      throw Exception('Impossible de démarrer le suivi GPS: $e');
    }
  }

  Future<void> _stopTracking() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _trackingTimer?.cancel();
    _trackingTimer = null;
  }

  Future<void> _onPositionUpdate(Position position) async {
    _currentPosition = position;
    await _processPositionUpdate(position, 'stream');
  }

  Future<void> _captureCurrentPosition(String source) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = position;
      await _processPositionUpdate(position, source);
    } catch (e) {
      _logger.e('Error capturing current position: $e');
    }
  }

  Future<void> _processPositionUpdate(Position position, String source) async {
    try {
      final authService = Provider.of<AuthService>(
          GetMaterialApp().navigatorKey.currentContext!, 
          listen: false);
      
      final gpsPoint = GpsPoint(
        id: _uuid.v4(),
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        heading: position.heading,
        timestamp: DateTime.now(),
        source: source,
        agentId: authService.currentUser?.id,
      );

      // Add to today's positions
      _todayPositions.add(gpsPoint);
      
      // Save locally
      await _saveGpsPoint(gpsPoint);
      
      // Broadcast to listeners
      _positionStreamController.add(gpsPoint);
      
      // Check zone alerts
      await _checkZoneAlerts(gpsPoint);
      
      // Update map if needed
      if (_mapConfig.showMyPosition) {
        _updateMyPositionMarker(gpsPoint);
      }
      
      _logger.d('Position processed: ${gpsPoint.latitude}, ${gpsPoint.longitude}');
      
    } catch (e) {
      _logger.e('Error processing position update: $e');
    }
  }

  // Zone Management
  Future<void> createZone({
    required String name,
    required ZoneType type,
    required List<LatLng> points,
    String? description,
    LatLng? center,
    double? radius,
    String? agentId,
    String color = '#1976D2',
  }) async {
    try {
      final authService = Provider.of<AuthService>(
          GetMaterialApp().navigatorKey.currentContext!, 
          listen: false);
      
      final zone = GeoZone(
        id: _uuid.v4(),
        name: name,
        description: description ?? '',
        type: type,
        points: points,
        center: center,
        radius: radius,
        agentId: agentId ?? authService.currentUser?.id ?? '',
        color: color,
        createdAt: DateTime.now(),
      );

      _zones.add(zone);
      await _saveZone(zone);
      _updateZoneVisualization(zone);
      
      _logger.i('Zone created: $name');
      
    } catch (e) {
      _logger.e('Error creating zone: $e');
      rethrow;
    }
  }

  Future<void> updateZone(GeoZone zone) async {
    try {
      final index = _zones.indexWhere((z) => z.id == zone.id);
      if (index != -1) {
        _zones[index] = zone.copyWith(updatedAt: DateTime.now());
        await _saveZone(_zones[index]);
        _updateZoneVisualization(_zones[index]);
      }
    } catch (e) {
      _logger.e('Error updating zone: $e');
      rethrow;
    }
  }

  Future<void> deleteZone(String zoneId) async {
    try {
      _zones.removeWhere((z) => z.id == zoneId);
      await _deleteZoneFromStorage(zoneId);
      _removeZoneVisualization(zoneId);
    } catch (e) {
      _logger.e('Error deleting zone: $e');
      rethrow;
    }
  }

  // Zone Alerts
  Future<void> _checkZoneAlerts(GpsPoint gpsPoint) async {
    try {
      final position = gpsPoint.latLng;
      
      for (final zone in _zones) {
        final wasInside = _isAgentInZone(gpsPoint.agentId ?? '', zone.id);
        final isInside = zone.containsPoint(position);
        
        // Check for zone exit
        if (wasInside && !isInside) {
          await _createZoneAlert(
            agentId: gpsPoint.agentId ?? '',
            zoneId: zone.id,
            type: AlertType.zoneExit,
            position: position,
            message: 'L\'agent a quitté la zone: ${zone.name}',
          );
        }
        
        // Check for zone entry
        else if (!wasInside && isInside) {
          await _createZoneAlert(
            agentId: gpsPoint.agentId ?? '',
            zoneId: zone.id,
            type: AlertType.zoneEntry,
            position: position,
            message: 'L\'agent est entré dans la zone: ${zone.name}',
          );
        }
      }
    } catch (e) {
      _logger.e('Error checking zone alerts: $e');
    }
  }

  Future<void> _createZoneAlert({
    required String agentId,
    required String zoneId,
    required AlertType type,
    required LatLng position,
    required String message,
    AlertSeverity severity = AlertSeverity.medium,
  }) async {
    try {
      final alert = ZoneAlert(
        id: _uuid.v4(),
        agentId: agentId,
        zoneId: zoneId,
        type: type,
        severity: severity,
        position: position,
        timestamp: DateTime.now(),
        message: message,
      );

      _alerts.insert(0, alert); // Add to beginning
      await _saveAlert(alert);
      _alertStreamController.add(alert);
      
      _logger.i('Zone alert created: ${type.label} for agent $agentId');
      
    } catch (e) {
      _logger.e('Error creating zone alert: $e');
    }
  }

  bool _isAgentInZone(String agentId, String zoneId) {
    // Check recent positions to see if agent was in zone
    final recentPositions = _todayPositions
        .where((p) => p.agentId == agentId)
        .take(10) // Last 10 positions
        .toList();
    
    if (recentPositions.isEmpty) return false;
    
    final zone = _zones.firstWhere((z) => z.id == zoneId);
    return recentPositions.any((point) => zone.containsPoint(point.latLng));
  }

  // Map Management
  Future<void> updateMapConfiguration(MapConfiguration config) async {
    _mapConfig = config;
    await _saveMapConfiguration(config);
    await _refreshMapVisualization();
  }

  Future<void> setMapViewType(MapViewType viewType) async {
    _mapConfig = _mapConfig.copyWith(viewType: viewType);
    await _saveMapConfiguration(_mapConfig);
  }

  Future<void> toggleLayer(String layer) async {
    switch (layer) {
      case 'contribuables':
        _mapConfig = _mapConfig.copyWith(showContribuables: !_mapConfig.showContribuables);
        break;
      case 'zones':
        _mapConfig = _mapConfig.copyWith(showZones: !_mapConfig.showZones);
        break;
      case 'heatmap':
        _mapConfig = _mapConfig.copyWith(showHeatmap: !_mapConfig.showHeatmap);
        break;
      case 'otherAgents':
        _mapConfig = _mapConfig.copyWith(showOtherAgents: !_mapConfig.showOtherAgents);
        break;
      case 'pointsOfInterest':
        _mapConfig = _mapConfig.copyWith(showPointsOfInterest: !_mapConfig.showPointsOfInterest);
        break;
      case 'myPosition':
        _mapConfig = _mapConfig.copyWith(showMyPosition: !_mapConfig.showMyPosition);
        break;
    }
    
    await _saveMapConfiguration(_mapConfig);
    await _refreshMapVisualization();
  }

  Future<void> _refreshMapVisualization() async {
    // Clear current overlays
    _markers.clear();
    _polygons.clear();
    _circles.clear();
    
    // Rebuild based on configuration
    if (_mapConfig.showZones) {
      for (final zone in _zones) {
        _updateZoneVisualization(zone);
      }
    }
    
    if (_mapConfig.showMyPosition && _currentPosition != null) {
      final gpsPoint = GpsPoint(
        id: 'current',
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        accuracy: _currentPosition!.accuracy,
        timestamp: DateTime.now(),
        source: 'current',
      );
      _updateMyPositionMarker(gpsPoint);
    }
    
    if (_mapConfig.showPointsOfInterest) {
      _updatePointsOfInterestMarkers();
    }
    
    // Notify map controller if available
    _mapController?.notifyListeners();
  }

  void _updateZoneVisualization(GeoZone zone) {
    if (!_mapConfig.showZones) return;
    
    if (zone.isCircular && zone.center != null && zone.radius != null) {
      _circles.add(Circle(
        circleId: CircleId(zone.id),
        center: zone.center!,
        radius: zone.radius!,
        fillColor: _parseColor(zone.color).withOpacity(0.2),
        strokeColor: _parseColor(zone.color),
        strokeWidth: 2,
      ));
    } else if (zone.isPolygon && zone.points.isNotEmpty) {
      _polygons.add(Polygon(
        polygonId: PolygonId(zone.id),
        points: zone.points,
        fillColor: _parseColor(zone.color).withOpacity(0.2),
        strokeColor: _parseColor(zone.color),
        strokeWidth: 2,
      ));
    }
  }

  void _removeZoneVisualization(String zoneId) {
    _polygons.removeWhere((p) => p.polygonId.value == zoneId);
    _circles.removeWhere((c) => c.circleId.value == zoneId);
  }

  void _updateMyPositionMarker(GpsPoint gpsPoint) {
    if (!_mapConfig.showMyPosition) return;
    
    _markers.removeWhere((m) => m.markerId.value == 'my_position');
    
    _markers.add(Marker(
      markerId: const MarkerId('my_position'),
      position: gpsPoint.latLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(
        title: 'Ma Position',
        snippet: 'Précision: ${gpsPoint.accuracy.toStringAsFixed(1)}m',
      ),
    ));
  }

  void _updatePointsOfInterestMarkers() {
    if (!_mapConfig.showPointsOfInterest) return;
    
    for (final poi in _pointsOfInterest) {
      _markers.add(Marker(
        markerId: MarkerId(poi.id),
        position: poi.position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(
          title: poi.name,
          snippet: poi.description,
        ),
      ));
    }
  }

  // Heatmap Generation
  Future<Map<HeatmapDensity, List<LatLng>>> generateHeatmapData({
    double radius = 500.0, // meters
  }) async {
    try {
      final heatmapData = <HeatmapDensity, List<LatLng>>{
        for (final density in HeatmapDensity.values) density: <LatLng>[]
      };
      
      // Get all contribuable positions
      final contribuablePositions = await _getContribuablePositions();
      
      // Analyze density for each position
      for (final position in contribuablePositions) {
        final nearbyCount = contribuablePositions.where((other) {
          if (other == position) return false;
          final distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            other.latitude,
            other.longitude,
          );
          return distance <= radius;
        }).length;
        
        HeatmapDensity density;
        if (nearbyCount >= 10) {
          density = HeatmapDensity.high;
        } else if (nearbyCount >= 5) {
          density = HeatmapDensity.medium;
        } else if (nearbyCount >= 2) {
          density = HeatmapDensity.low;
        } else {
          density = HeatmapDensity.none;
        }
        
        heatmapData[density]!.add(position);
      }
      
      return heatmapData;
      
    } catch (e) {
      _logger.e('Error generating heatmap data: $e');
      rethrow;
    }
  }

  // Statistics
  Future<GeolocationStatistics> getStatistics() async {
    try {
      final activeAgents = await _getActiveAgentsCount();
      final todayPositions = _todayPositions.length;
      final zoneCoverage = _calculateZoneCoverage();
      final localizedContribuables = await _getLocalizedContribuablesCount();
      final activeAlerts = _alerts.where((a) => !a.isAcknowledged).length;
      final nonSurveyedZones = await _getNonSurveyedZonesCount();
      
      final agentPositions = <String, int>{};
      for (final position in _todayPositions) {
        final agentId = position.agentId ?? 'unknown';
        agentPositions[agentId] = (agentPositions[agentId] ?? 0) + 1;
      }
      
      final zoneDensity = <String, double>{};
      for (final zone in _zones) {
        final density = await _calculateZoneDensity(zone);
        zoneDensity[zone.id] = density;
      }
      
      final recentAlerts = _alerts.take(10).toList();
      
      final stats = GeolocationStatistics(
        activeAgents: activeAgents,
        todayPositions: todayPositions,
        zoneCoverage: zoneCoverage,
        localizedContribuables: localizedContribuables,
        activeAlerts: activeAlerts,
        nonSurveyedZones: nonSurveyedZones,
        agentPositions: agentPositions,
        zoneDensity: zoneDensity,
        recentAlerts: recentAlerts,
      );
      
      _statsStreamController.add(stats);
      return stats;
      
    } catch (e) {
      _logger.e('Error getting statistics: $e');
      rethrow;
    }
  }

  void _startStatisticsUpdates() {
    Timer.periodic(const Duration(minutes: 5), (_) {
      getStatistics();
    });
  }

  // Helper methods
  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      }
      return const Color(0xFF1976D2); // Default blue
    } catch (e) {
      return const Color(0xFF1976D2);
    }
  }

  Future<List<LatLng>> _getContribuablePositions() async {
    // This would get positions from the recensement service
    // For now, return empty list
    return [];
  }

  Future<int> _getActiveAgentsCount() async {
    // Count agents with positions today
    final uniqueAgents = _todayPositions
        .map((p) => p.agentId)
        .where((id) => id != null)
        .toSet();
    return uniqueAgents.length;
  }

  double _calculateZoneCoverage() {
    if (_zones.isEmpty) return 0.0;
    
    // Simple calculation: percentage of zones with recent activity
    final zonesWithActivity = _zones.where((zone) {
      return _todayPositions.any((position) {
        return zone.containsPoint(position.latLng);
      });
    }).length;
    
    return zonesWithActivity / _zones.length;
  }

  Future<int> _getLocalizedContribuablesCount() async {
    // This would count contribuables with GPS coordinates
    // For now, return 0
    return 0;
  }

  Future<int> _getNonSurveyedZonesCount() async {
    // This would calculate zones with low contribuable density
    // For now, return 0
    return 0;
  }

  Future<double> _calculateZoneDensity(GeoZone zone) async {
    final positionsInZone = _todayPositions.where((position) {
      return zone.containsPoint(position.latLng);
    }).length;
    
    // Calculate density per km²
    final zoneArea = _calculateZoneArea(zone); // in km²
    return zoneArea > 0 ? positionsInZone / zoneArea : 0.0;
  }

  double _calculateZoneArea(GeoZone zone) {
    // Simplified area calculation
    // For production, use proper geospatial calculations
    if (zone.isCircular && zone.radius != null) {
      return 3.14159 * (zone.radius! / 1000) * (zone.radius! / 1000); // km²
    } else if (zone.isPolygon && zone.points.isNotEmpty) {
      // Simplified polygon area calculation
      return 1.0; // Placeholder
    }
    return 0.0;
  }

  // Storage methods (simplified - would use actual database)
  Future<void> _saveGpsPoint(GpsPoint point) async {
    await _storageService.storeOfflineData(
      'gps_point_${point.id}',
      point.toJson(),
    );
  }

  Future<void> _saveZone(GeoZone zone) async {
    await _storageService.storeOfflineData(
      'geo_zone_${zone.id}',
      zone.toJson(),
    );
  }

  Future<void> _deleteZoneFromStorage(String zoneId) async {
    await _storageService.removeOfflineData('geo_zone_$zoneId');
  }

  Future<void> _saveAlert(ZoneAlert alert) async {
    await _storageService.storeOfflineData(
      'zone_alert_${alert.id}',
      alert.toJson(),
    );
  }

  Future<void> _saveMapConfiguration(MapConfiguration config) async {
    await _storageService.storeLocalData('map_config', config.toJson());
  }

  Future<void> _loadMapConfiguration() async {
    try {
      final configJson = await _storageService.getLocalData('map_config');
      if (configJson != null) {
        _mapConfig = MapConfiguration.fromJson(jsonDecode(configJson));
      }
    } catch (e) {
      _logger.e('Error loading map configuration: $e');
    }
  }

  Future<void> _loadZones() async {
    try {
      // Load zones from storage or API
      // For now, add some default zones
      _zones = [];
    } catch (e) {
      _logger.e('Error loading zones: $e');
    }
  }

  Future<void> _loadPointsOfInterest() async {
    try {
      // Load POIs from storage or API
      // For now, add some default POIs
      _pointsOfInterest = [];
    } catch (e) {
      _logger.e('Error loading points of interest: $e');
    }
  }

  Future<void> _saveTrackingMode(GpsTrackingMode mode) async {
    await _storageService.storeLocalData('gps_tracking_mode', mode.code);
  }

  // Getters for services
  StorageService get _storageService => StorageService();
}

// Extension methods for convenience
extension GeolocationServiceExtension on GeolocationService {
  Future<bool> isPointInZone(LatLng point, String zoneId) async {
    final zone = zones.firstWhere((z) => z.id == zoneId);
    return zone.containsPoint(point);
  }

  Future<List<GeoZone>> getZonesForAgent(String agentId) async {
    return zones.where((zone) => zone.agentId == agentId).toList();
  }

  Future<List<ZoneAlert>> getAlertsForAgent(String agentId) async {
    return alerts.where((alert) => alert.agentId == agentId).toList();
  }

  Future<List<GpsPoint>> getPositionsForAgent(String agentId, {DateTime? startDate, DateTime? endDate}) async {
    var positions = _todayPositions.where((p) => p.agentId == agentId).toList();
    
    if (startDate != null) {
      positions = positions.where((p) => p.timestamp.isAfter(startDate)).toList();
    }
    
    if (endDate != null) {
      positions = positions.where((p) => p.timestamp.isBefore(endDate)).toList();
    }
    
    return positions;
  }

  Future<double> calculateDistanceBetweenPoints(LatLng point1, LatLng point2) async {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  Future<LatLng> getCurrentPositionLatLng() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return LatLng(position.latitude, position.longitude);
  }
}
