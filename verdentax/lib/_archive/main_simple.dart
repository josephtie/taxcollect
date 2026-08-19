import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'config/config.dart';
import 'services/services.dart';
import 'screens/screens.dart';
import 'widgets/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await _initializeServices();
  
  runApp(const VerdenTaxApp());
}

Future<void> _initializeServices() async {
  try {
    // Initialize storage service
    await StorageService().initialize();
    
    // Initialize connectivity service
    await ConnectivityService().initialize();
    
    // Initialize API service
    await ApiService().initialize();
    
    // Initialize auth service
    await AuthService().initialize();
    
    print('✅ Core services initialized successfully');
  } catch (e) {
    print('❌ Error initializing services: $e');
  }
}

class VerdenTaxApp extends StatelessWidget {
  const VerdenTaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ApiService()),
        ChangeNotifierProvider(create: (_) => StorageService()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
      ],
      child: MaterialApp(
        title: 'VerdenTax',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),
        home: const SplashScreen(),
        routes: _buildRoutes(),
        onGenerateRoute: _generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

Map<String, WidgetBuilder> _buildRoutes() {
  return {
    '/login': (context) => const LoginScreen(),
    '/dashboard': (context) => const DashboardScreen(),
  };
}

Route<dynamic>? _generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/login':
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
        settings: settings,
      );
    case '/dashboard':
      return MaterialPageRoute(
        builder: (context) => const DashboardScreen(),
        settings: settings,
      );
    default:
      return null;
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
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
              size: 80.sp,
              color: Colors.white,
            ),
            SizedBox(height: 20.h),
            Text(
              'VerdenTax',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Application de Collecte des Impôts',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 40.h),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
