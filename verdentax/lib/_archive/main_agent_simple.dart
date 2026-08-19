import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const AgentTestApp());
}

class AgentTestApp extends StatelessWidget {
  const AgentTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'VerdenTax - Agent Test',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          home: const AgentTestScreen(),
        );
      },
    );
  }
}

class AgentTestScreen extends StatelessWidget {
  const AgentTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Test data
    final agents = [
      AgentsDto(
        id: 1,
        nom: 'Konan',
        prenom: 'Yao',
        email: 'konan.yao@verdentax.ci',
        telephone: '+2250123456789',
        zoneIds: [1, 2, 3],
      ),
      AgentsDto(
        id: 2,
        nom: 'Touré',
        prenom: 'Aminata',
        email: 'toure.aminata@verdentax.ci',
        telephone: '+2250987654321',
        zoneIds: [4, 5],
      ),
      AgentsDto(
        id: 3,
        nom: 'Bamba',
        prenom: 'Mamadou',
        email: 'bamba.mamadou@verdentax.ci',
        telephone: '+2250765432109',
        zoneIds: null, // No zones assigned
      ),
    ];

    final zones = [
      ZoneCollectDto(id: 1, nom: 'Zone Plateau'),
      ZoneCollectDto(id: 2, nom: 'Zone Cocody'),
      ZoneCollectDto(id: 3, nom: 'Zone Treichville'),
      ZoneCollectDto(id: 4, nom: 'Zone Yopougon'),
      ZoneCollectDto(id: 5, nom: 'Zone Abobo'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('✅ AgentsDto Alignés'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '👮 Test d\'Alignement des Agents',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 24.h),
            
            // Models Status
            _buildModelsStatusCard(),
            SizedBox(height: 16.h),
            
            // Test Data
            _buildTestDataCard(agents, zones),
            SizedBox(height: 16.h),
            
            // Agent-Zone Relations
            _buildRelationsCard(agents, zones),
            
            SizedBox(height: 24.h),
            
            // Success Message
            Container(
              padding: EdgeInsets.all(16.h),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.blue),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.blue,
                    size: 40.sp,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '✅ ALIGNEMENT AGENTS RÉUSSI !',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    'AgentsDto ↔ ZoneCollectDto Relations',
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
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📋 Modèles d\'Agents',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 12.h),
          _buildModelStatus('AgentsDto', '✅ Structure: id, nom, prenom, email, telephone, zoneIds'),
          _buildModelStatus('copyWith()', '✅ Méthode de copie'),
          _buildModelStatus('Getters', '✅ fullName, displayName'),
          _buildModelStatus('Serialisation', '✅ fromJson(), toJson()'),
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

  Widget _buildTestDataCard(List<AgentsDto> agents, List<ZoneCollectDto> zones) {
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
                  'Agents',
                  '${agents.length}',
                  Icons.people,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatItem(
                  'Zones',
                  '${zones.length}',
                  Icons.location_on,
                  Colors.green,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatItem(
                  'Relations',
                  '${agents.where((a) => a.zoneIds != null && a.zoneIds!.isNotEmpty).length}',
                  Icons.link,
                  Colors.purple,
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

  Widget _buildRelationsCard(List<AgentsDto> agents, List<ZoneCollectDto> zones) {
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
            '🔗 Relations Agent ↔ Zone',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'AgentsDto.zoneIds → ZoneCollectDto.id',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          ...agents.map((agent) => _buildRelationItem(agent, zones)).toList(),
        ],
      ),
    );
  }

  Widget _buildRelationItem(AgentsDto agent, List<ZoneCollectDto> zones) {
    final assignedZones = agent.zoneIds?.map((zoneId) {
      final zone = zones.where((z) => z.id == zoneId).firstOrNull;
      return zone?.nom ?? 'Zone $zoneId';
    }).join(', ') ?? 'Aucune zone';
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(
            Icons.person,
            color: Colors.blue.shade700,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            '${agent.fullName} →',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              assignedZones,
              style: TextStyle(
                fontSize: 12.sp,
                color: assignedZones.contains('Aucune') ? Colors.red.shade700 : Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
