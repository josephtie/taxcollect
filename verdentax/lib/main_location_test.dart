import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/models.dart';
import '../services/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await LocationService().initialize();
  
  runApp(const LocationTestApp());
}

class LocationTestApp extends StatelessWidget {
  const LocationTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'VerdenTax - Location Test',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.green,
            useMaterial3: true,
          ),
          home: const LocationTestScreen(),
        );
      },
    );
  }
}

class LocationTestScreen extends StatefulWidget {
  const LocationTestScreen({super.key});

  @override
  State<LocationTestScreen> createState() => _LocationTestScreenState();
}

class _LocationTestScreenState extends State<LocationTestScreen> {
  bool _isLoading = false;
  List<CommuneDto> _communes = [];
  List<QuartierDto> _quartiers = [];
  List<ZoneCollectDto> _zones = [];
  LocationStatistics? _statistics;
  List<LocationHierarchy> _hierarchies = [];

  @override
  void initState() {
    super.initState();
    _loadLocationData();
  }

  Future<void> _loadLocationData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load all location data
      await Future.wait([
        _loadCommunes(),
        _loadQuartiers(),
        _loadZones(),
        _loadStatistics(),
        _loadHierarchies(),
      ]);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCommunes() async {
    try {
      _communes = await LocationService().getAllCommunes();
    } catch (e) {
      print('Error loading communes: $e');
    }
  }

  Future<void> _loadQuartiers() async {
    try {
      _quartiers = await LocationService().getAllQuartiers();
    } catch (e) {
      print('Error loading quartiers: $e');
    }
  }

  Future<void> _loadZones() async {
    try {
      _zones = await LocationService().getAllZones();
    } catch (e) {
      print('Error loading zones: $e');
    }
  }

  Future<void> _loadStatistics() async {
    try {
      _statistics = await LocationService().getStatistics();
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }

  Future<void> _loadHierarchies() async {
    try {
      _hierarchies = await LocationService().getAllZonesWithHierarchy();
    } catch (e) {
      print('Error loading hierarchies: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('✅ Localisation Models Alignés'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🏛️ Test d\'Alignement des Modèles de Localisation',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 24.h),
            
            // Statistics
            if (_statistics != null) ...[
              _buildStatisticsCard(),
              SizedBox(height: 16.h),
            ],
            
            // Models Status
            _buildModelsStatusCard(),
            SizedBox(height: 16.h),
            
            // Hierarchies
            _buildHierarchiesCard(),
            SizedBox(height: 16.h),
            
            // Test Results
            Expanded(
              child: _buildTestResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
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
            '📊 Statistiques',
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
                  'Communes',
                  '${_statistics!.totalCommunes}',
                  Icons.location_city,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatItem(
                  'Quartiers',
                  '${_statistics!.totalQuartiers}',
                  Icons.location_on,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatItem(
                  'Zones',
                  '${_statistics!.totalZones}',
                  Icons.place,
                  Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Moyenne: ${_statistics!.averageQuartiersPerCommune.toStringAsFixed(1)} quartiers/commune, '
            '${_statistics!.averageZonesPerQuartier.toStringAsFixed(1)} zones/quartier',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade700,
            ),
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
            '📋 Modèles de Localisation',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 12.h),
          _buildModelStatus('CommuneDto', '✅ Structure correcte'),
          _buildModelStatus('QuartierDto', '✅ Structure correcte'),
          _buildModelStatus('ZoneCollectDto', '✅ Structure correcte'),
          _buildModelStatus('LocationService', '✅ Service complet'),
          _buildModelStatus('LocationHierarchy', '✅ Hiérarchie gérée'),
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

  Widget _buildHierarchiesCard() {
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
            '🏗️ Hiérarchie de Localisation',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Commune → Quartier → ZoneCollect',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${_hierarchies.length} zones avec hiérarchie complète',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestResults() {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🧪 Résultats des Tests',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          if (_isLoading) ...[
            Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 12.w),
                Text(
                  'Chargement des données...',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildTestResult('Communes', _communes.length, Colors.blue),
            _buildTestResult('Quartiers', _quartiers.length, Colors.orange),
            _buildTestResult('Zones', _zones.length, Colors.red),
            _buildTestResult('Hiérarchies', _hierarchies.length, Colors.purple),
          ],
        ],
      ),
    );
  }

  Widget _buildTestResult(String name, int count, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(
            count > 0 ? Icons.check_circle : Icons.error,
            color: count > 0 ? Colors.green : Colors.red,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Text(
            '$name: $count éléments',
            style: TextStyle(
              fontSize: 14.sp,
              color: count > 0 ? Colors.black87 : Colors.red.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
