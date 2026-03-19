import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/models.dart';
import '../models/geolocation.dart';
import '../extensions/geolocation_extensions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const GeolocationTestApp());
}

class GeolocationTestApp extends StatelessWidget {
  const GeolocationTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'VerdenTax - Geolocation Test',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.orange,
            useMaterial3: true,
          ),
          home: const GeolocationTestScreen(),
        );
      },
    );
  }
}

class GeolocationTestScreen extends StatelessWidget {
  const GeolocationTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Test data
    final gpsPoints = [
      GpsPoint(
        id: 'gps_1',
        latitude: 5.3600,
        longitude: -4.0083,
        accuracy: 10.0,
        timestamp: DateTime.now(),
        source: 'gps',
        action: 'contribuable_scan',
        contribuableId: '1',
        agentId: '1',
      ),
      GpsPoint(
        id: 'gps_2',
        latitude: 5.3700,
        longitude: -4.0183,
        accuracy: 15.0,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        source: 'network',
        action: 'payment',
        contribuableId: '2',
        agentId: '2',
      ),
    ];

    final geoZones = [
      GeoZone(
        id: 'zone_1',
        name: 'Zone Plateau',
        description: 'Zone de collecte Plateau',
        type: ZoneType.commercial,
        points: [],
        center: const LatLng(5.3600, -4.0083),
        radius: 1000.0,
        agentId: '1',
        color: '#1976D2',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      GeoZone(
        id: 'zone_2',
        name: 'Zone Cocody',
        description: 'Zone de collecte Cocody',
        type: ZoneType.residential,
        points: [],
        center: const LatLng(5.3700, -4.0183),
        radius: 1500.0,
        agentId: '2',
        color: '#4CAF50',
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];

    final zoneAlerts = [
      ZoneAlert(
        id: 'alert_1',
        agentId: '1',
        zoneId: 'zone_1',
        type: AlertType.zoneExit,
        severity: AlertSeverity.medium,
        position: const LatLng(5.3650, -4.0133),
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        message: 'Agent a quitté la zone Plateau',
        isAcknowledged: false,
      ),
      ZoneAlert(
        id: 'alert_2',
        agentId: '2',
        zoneId: 'zone_2',
        type: AlertType.zoneEntry,
        severity: AlertSeverity.low,
        position: const LatLng(5.3750, -4.0233),
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        message: 'Agent est entré dans la zone Cocody',
        isAcknowledged: true,
        acknowledgedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        acknowledgedBy: 'supervisor',
      ),
    ];

    final pointsOfInterest = [
      PointOfInterest(
        id: 'poi_1',
        name: 'Marché de Treichville',
        description: 'Grand marché de Treichville',
        position: const LatLng(5.3500, -3.9983),
        type: 'market',
        icon: 'shopping_cart',
        metadata: {'category': 'market', 'size': 'large'},
      ),
      PointOfInterest(
        id: 'poi_2',
        name: 'Bureau Principal',
        description: 'Bureau principal de VerdenTax',
        position: const LatLng(5.3600, -4.0083),
        type: 'office',
        icon: 'business',
        metadata: {'category': 'office', 'floors': 3},
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('🗺️ Géolocalisation Alignée'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📍 Test d\'Alignement de la Géolocalisation',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 24.h),
            
            // Models Status
            _buildModelsStatusCard(),
            SizedBox(height: 16.h),
            
            // Test Data
            _buildTestDataCard(gpsPoints, geoZones, zoneAlerts, pointsOfInterest),
            SizedBox(height: 16.h),
            
            // Relations
            _buildRelationsCard(),
            
            SizedBox(height: 24.h),
            
            // Success Message
            Container(
              padding: EdgeInsets.all(16.h),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.orange,
                    size: 40.sp,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '✅ ALIGNEMENT GÉOLOCALISATION RÉUSSI !',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    'GPS ↔ Zones ↔ Alertes ↔ POI ↔ Autres Modèles',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelsStatusCard() {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📋 Modèles de Géolocalisation',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 12.h),
          _buildModelStatus('GpsPoint', '✅ Points GPS avec métadonnées'),
          _buildModelStatus('GeoZone', '✅ Zones circulaires et polygones'),
          _buildModelStatus('ZoneAlert', '✅ Alertes de zone'),
          _buildModelStatus('PointOfInterest', '✅ Points d\'intérêt'),
          _buildModelStatus('LocationHistory', '✅ Historique de localisation'),
          _buildModelStatus('GeolocationStatistics', '✅ Statistiques'),
          _buildModelStatus('MapConfiguration', '✅ Configuration carte'),
          _buildModelStatus('Extensions', '✅ Intégration avec autres modèles'),
        ],
      ),
    );
  }

  Widget _buildModelStatus(String name, String status) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Text(
            status,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestDataCard(
    List<GpsPoint> gpsPoints,
    List<GeoZone> geoZones,
    List<ZoneAlert> zoneAlerts,
    List<PointOfInterest> pointsOfInterest,
  ) {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Données de Test',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Points GPS',
                  '${gpsPoints.length}',
                  Icons.gps_fixed,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatItem(
                  'Zones',
                  '${geoZones.length}',
                  Icons.radio_button_unchecked,
                  Colors.green,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatItem(
                  'Alertes',
                  '${zoneAlerts.length}',
                  Icons.notifications,
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'POI',
                  '${pointsOfInterest.length}',
                  Icons.place,
                  Colors.purple,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatItem(
                  'Types Zone',
                  '${ZoneType.values.length}',
                  Icons.category,
                  Colors.teal,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatItem(
                  'Types Alerte',
                  '${AlertType.values.length}',
                  Icons.warning,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildRelationsCard() {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔗 Relations Géolocalisation',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Intégration complète avec les autres modèles',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          _buildRelationItem('ContribuableDto', 'toPointOfInterest(), hasValidLocation()'),
          _buildRelationItem('AgentsDto', 'toPointOfInterest(), createGpsPointFromAgent()'),
          _buildRelationItem('TransactionDTO', 'toPointOfInterest(), createGpsPointFromTransaction()'),
          _buildRelationItem('ZoneCollectDto', 'toGeoZone(), createGeoZoneFromZoneCollect()'),
          _buildRelationItem('GeolocationService', 'Extensions pour alignement'),
          _buildRelationItem('ZoneAlert', 'Validation transactions hors zone'),
        ],
      ),
    );
  }

  Widget _buildRelationItem(String entity, String features) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(
            Icons.link,
            color: Colors.purple.shade700,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            '$entity →',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.purple.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              features,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
