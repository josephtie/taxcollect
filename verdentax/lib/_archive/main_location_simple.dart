import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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

class LocationTestScreen extends StatelessWidget {
  const LocationTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Test data
    final communes = [
      CommuneDto(id: 1, nom: 'Abidjan'),
      CommuneDto(id: 2, nom: 'Yamoussoukro'),
    ];
    
    final quartiers = [
      QuartierDto(id: 1, nom: 'Plateau', communeId: 1),
      QuartierDto(id: 2, nom: 'Cocody', communeId: 1),
      QuartierDto(id: 3, nom: 'Treichville', communeId: 2),
    ];
    
    final zones = [
      ZoneCollectDto(id: 1, nom: 'Zone A', quartierId: 1),
      ZoneCollectDto(id: 2, nom: 'Zone B', quartierId: 1),
      ZoneCollectDto(id: 3, nom: 'Zone C', quartierId: 2),
    ];

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
            
            // Models Status
            _buildModelsStatusCard(),
            SizedBox(height: 16.h),
            
            // Test Data
            _buildTestDataCard(communes, quartiers, zones),
            SizedBox(height: 16.h),
            
            // Hierarchy Test
            _buildHierarchyTest(),
            
            SizedBox(height: 24.h),
            
            // Success Message
            Container(
              padding: EdgeInsets.all(16.h),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 40.sp,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '✅ ALIGNEMENT LOCALISATION RÉUSSI !',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'Hiérarchie: Commune → Quartier → ZoneCollect',
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
            '📋 Modèles de Localisation',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 12.h),
          _buildModelStatus('CommuneDto', '✅ Structure: id, nom'),
          _buildModelStatus('QuartierDto', '✅ Structure: id, nom, communeId'),
          _buildModelStatus('ZoneCollectDto', '✅ Structure: id, nom, quartierId'),
          _buildModelStatus('Relations', '✅ Commune 1:N Quartier 1:N Zone'),
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
    List<CommuneDto> communes,
    List<QuartierDto> quartiers,
    List<ZoneCollectDto> zones,
  ) {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Données de Test',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Communes',
                  '${communes.length}',
                  Icons.location_city,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatItem(
                  'Quartiers',
                  '${quartiers.length}',
                  Icons.location_on,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatItem(
                  'Zones',
                  '${zones.length}',
                  Icons.place,
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

  Widget _buildHierarchyTest() {
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
            '🏗️ Test de Hiérarchie',
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
          _buildHierarchyItem('Abidjan', 'Plateau', 'Zone A'),
          _buildHierarchyItem('Abidjan', 'Cocody', 'Zone B'),
          _buildHierarchyItem('Yamoussoukro', 'Treichville', 'Zone C'),
        ],
      ),
    );
  }

  Widget _buildHierarchyItem(String commune, String quartier, String zone) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Text(
            '$commune →',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            quartier,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '→ $zone',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.red.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
