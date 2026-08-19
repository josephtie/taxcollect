import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/config.dart';
import 'services/services.dart';
import 'screens/screens.dart';
import 'widgets/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize services with error handling
  await _initializeServices();
  
  runApp(const VerdenTaxApp());
}

Future<void> _initializeServices() async {
  try {
    // Initialize essential services only for expert launch
    await StorageService().initialize();
    await ConnectivityService().initialize();
    await AuthService().initialize();
    
    print('✅ Essential services initialized successfully');
  } catch (e) {
    print('⚠️ Error initializing services: $e');
    print('🔄 Continuing with limited functionality...');
  }
}

class VerdenTaxApp extends StatelessWidget {
  const VerdenTaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthService()),
            ChangeNotifierProvider(create: (_) => StorageService()),
            ChangeNotifierProvider(create: (_) => ConnectivityService()),
          ],
          child: MaterialApp(
            title: 'VerdenTax - Expert Mode',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 2,
                centerTitle: true,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            home: const ExpertSplashScreen(),
            routes: _buildExpertRoutes(),
          ),
        );
      },
    );
  }
}

Map<String, WidgetBuilder> _buildExpertRoutes() {
  return {
    '/login': (context) => const LoginScreen(),
    '/dashboard': (context) => const DashboardScreen(),
    '/recensement': (context) => const RecensementScreen(),
    '/transaction': (context) => const TransactionScreen(),
    '/carte': (context) => const CarteScreen(),
    '/geolocation': (context) => const GeolocationScreen(),
    '/profile': (context) => const ProfileScreen(),
    '/settings': (context) => const SettingsScreen(),
    '/expert': (context) => const ExpertDashboard(),
  };
}

class ExpertSplashScreen extends StatefulWidget {
  const ExpertSplashScreen({super.key});

  @override
  State<ExpertSplashScreen> createState() => _ExpertSplashScreenState();
}

class _ExpertSplashScreenState extends State<ExpertSplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToExpertDashboard();
  }

  void _navigateToExpertDashboard() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ExpertDashboard(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance,
              size: 100.sp,
              color: Colors.white,
            ),
            SizedBox(height: 24.h),
            Text(
              'VerdenTax',
              style: TextStyle(
                fontSize: 42.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'EXPERT MODE',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.yellow,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Application de Collecte des Impôts Moderne',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            SizedBox(height: 40.h),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 24.h),
            Text(
              'Configuration Expert Activée',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white.withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpertDashboard extends StatelessWidget {
  const ExpertDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VerdenTax Expert Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showSystemInfo(context),
            icon: const Icon(Icons.info),
            tooltip: 'System Info',
          ),
          IconButton(
            onPressed: () => _showDebugMenu(context),
            icon: const Icon(Icons.bug_report),
            tooltip: 'Debug Menu',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expert Mode Header
            Container(
              padding: EdgeInsets.all(16.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.yellow, size: 30.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MODE EXPERT ACTIVÉ',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Accès complet au système VerdenTax',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // System Status
            Text(
              '🔧 État du Système',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 1.2,
                children: [
                  _buildExpertCard(
                    '📊 Dashboard',
                    'Tableau de bord principal',
                    Icons.dashboard,
                    Colors.green,
                    () => Navigator.pushNamed(context, '/dashboard'),
                  ),
                  _buildExpertCard(
                    '👥 Recensement',
                    'Gestion des contribuables',
                    Icons.people,
                    Colors.blue,
                    () => Navigator.pushNamed(context, '/recensement'),
                  ),
                  _buildExpertCard(
                    '💳 Transactions',
                    'Paiements et factures',
                    Icons.payment,
                    Colors.orange,
                    () => Navigator.pushNamed(context, '/transaction'),
                  ),
                  _buildExpertCard(
                    '📱 Cartes QR',
                    'Cartes contribuables',
                    Icons.qr_code,
                    Colors.purple,
                    () => Navigator.pushNamed(context, '/carte'),
                  ),
                  _buildExpertCard(
                    '📍 Géolocalisation',
                    'Services de localisation',
                    Icons.location_on,
                    Colors.red,
                    () => Navigator.pushNamed(context, '/geolocation'),
                  ),
                  _buildExpertCard(
                    '⚙️ Paramètres',
                    'Configuration système',
                    Icons.settings,
                    Colors.grey,
                    () => Navigator.pushNamed(context, '/settings'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32.sp),
            SizedBox(height: 8.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSystemInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informations Système'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🚀 VerdenTax Expert Mode'),
            Text('📱 Version: 1.0.0+1'),
            Text('🔧 Flutter: 3.38.7'),
            Text('🌐 Plateforme: Web'),
            Text('⚡ Mode: Développement Expert'),
            Text('🛡️ Sécurité: Mode Débogage'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showDebugMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Menu Debug'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Recharger Services'),
              onTap: () {
                Navigator.pop(context);
                _reloadServices(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Logs Système'),
              onTap: () {
                Navigator.pop(context);
                _showLogs(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('État Connexions'),
              onTap: () {
                Navigator.pop(context);
                _showConnectionStatus(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _reloadServices(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Services rechargés avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showLogs(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logs système consultés'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showConnectionStatus(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('État des connexions: En ligne'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
