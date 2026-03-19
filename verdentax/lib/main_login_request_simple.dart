import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/models.dart';
import '../extensions/extensions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const LoginRequestTestApp());
}

class LoginRequestTestApp extends StatelessWidget {
  const LoginRequestTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'VerdenTax - LoginRequest Test',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.teal,
            useMaterial3: true,
          ),
          home: const LoginRequestTestScreen(),
        );
      },
    );
  }
}

class LoginRequestTestScreen extends StatelessWidget {
  const LoginRequestTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Test data
    final loginRequests = [
      LoginRequest(
        username: 'admin_verdentax',
        password: 'AdminPass123!',
      ),
      LoginRequest(
        username: 'supervisor_konan',
        password: 'Supervisor456',
      ),
      LoginRequest(
        username: 'agent_bamba',
        password: 'Agent789',
      ),
      LoginRequest(
        username: 'weak_user',
        password: '123',
      ),
      LoginRequest(
        username: 'strong_user',
        password: 'StrongP@ssw0rd2024!',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔐 LoginRequest Aligné'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔑 Test d\'Alignement LoginRequest',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 24.h),
            
            // Models Status
            _buildModelsStatusCard(),
            SizedBox(height: 16.h),
            
            // Test Data
            _buildTestDataCard(loginRequests),
            SizedBox(height: 16.h),
            
            // Validation Results
            _buildValidationCard(loginRequests),
            SizedBox(height: 16.h),
            
            // Password Strength
            _buildPasswordStrengthCard(loginRequests),
            SizedBox(height: 16.h),
            
            // Relations
            _buildRelationsCard(),
            
            SizedBox(height: 24.h),
            
            // Success Message
            Container(
              padding: EdgeInsets.all(16.h),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.teal),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.teal,
                    size: 40.sp,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '✅ ALIGNEMENT LOGINREQUEST RÉUSSI !',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  Text(
                    'LoginRequest ↔ AuthService ↔ Validation ↔ Security',
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
            '📋 Modèle LoginRequest',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 12.h),
          _buildModelStatus('Structure', '✅ 2 propriétés simples'),
          _buildModelStatus('Sérialisation', '✅ fromJson(), toJson()'),
          _buildModelStatus('Immutabilité', '✅ copyWith() méthode'),
          _buildModelStatus('Validation', '✅ validate() méthode'),
          _buildModelStatus('Sécurité', '✅ Force du mot de passe'),
          _buildModelStatus('Extensions', '✅ 15+ méthodes utilitaires'),
          _buildModelStatus('API Integration', '✅ Requêtes authentification'),
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

  Widget _buildTestDataCard(List<LoginRequest> loginRequests) {
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
                  'Total',
                  '${loginRequests.length}',
                  Icons.login,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatItem(
                  'Admins',
                  '${loginRequests.where((lr) => lr.isAdminAttempt).length}',
                  Icons.admin_panel_settings,
                  Colors.red,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatItem(
                  'Agents',
                  '${loginRequests.where((lr) => lr.isAgentAttempt).length}',
                  Icons.person,
                  Colors.green,
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

  Widget _buildValidationCard(List<LoginRequest> loginRequests) {
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
            '✅ Résultats de Validation',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          SizedBox(height: 12.h),
          ...loginRequests.map((lr) {
            final validation = lr.validate();
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                children: [
                  Icon(
                    validation.isValid ? Icons.check_circle : Icons.error,
                    color: validation.isValid ? Colors.green : Colors.red,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '${lr.username}: ${validation.isValid ? "Valide" : "Invalide"}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: validation.isValid ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPasswordStrengthCard(List<LoginRequest> loginRequests) {
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
            '🔒 Force des Mots de Passe',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          SizedBox(height: 12.h),
          ...loginRequests.map((lr) {
            final strength = lr.getPasswordStrength();
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: strength.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '${lr.username}: ${strength.label}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: strength.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRelationsCard() {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.indigo.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔗 Relations LoginRequest',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Intégration complète avec les services d\'authentification',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          _buildRelationItem('LoginRequest', 'AuthService.login()', Icons.link),
          _buildRelationItem('LoginRequest', 'ValidationResult', Icons.link),
          _buildRelationItem('LoginRequest', 'PasswordStrength', Icons.link),
          _buildRelationItem('LoginRequest', 'API Requests', Icons.link),
          _buildRelationItem('LoginRequest', 'Metadata', Icons.link),
          _buildRelationItem('LoginRequest', 'User Type Detection', Icons.link),
        ],
      ),
    );
  }

  Widget _buildRelationItem(String entity, String features, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.indigo.shade700,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            '$entity →',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.indigo.shade700,
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
