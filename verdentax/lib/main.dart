import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/theme_config.dart';
import 'services/services.dart';
import 'screens/screens.dart';

// Global service instances
late final StorageService storageService;
late final ConnectivityService connectivityService;
late final ApiService apiService;
late final AuthService authService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize services
  await _initializeServices();
  
  runApp(const VerdenTaxApp());
}

Future<void> _initializeServices() async {
  try {
    // Initialize storage service
    storageService = StorageService();
    await storageService.initialize();
    
    // Initialize connectivity service
    connectivityService = ConnectivityService();
    await connectivityService.initialize();
    
    // Initialize API service
    apiService = ApiService();
    await apiService.initialize();
    
    // Initialize auth service with dependencies
    authService = AuthService();
    await authService.initialize();
    
    debugPrint('✅ All services initialized successfully');
  } catch (e) {
    debugPrint('❌ Error initializing services: $e');
    // Continue with partial initialization for development
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
            ChangeNotifierProvider.value(value: connectivityService),
            ChangeNotifierProvider.value(value: authService),
          ],
          child: MaterialApp(
            title: 'VerdenTax',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
            routes: _buildRoutes(),
            onGenerateRoute: _generateRoute,
            onUnknownRoute: _onUnknownRoute,
          ),
        );
      },
    );
  }
}

Map<String, WidgetBuilder> _buildRoutes() {
  return {
    '/login': (context) => const LoginScreen(),
    '/dashboard': (context) => const DashboardScreen(),
    '/recensement': (context) => const RecensementScreen(),
    '/transaction': (context) => const TransactionScreen(),
    // '/geolocation': (context) => const GeolocationScreen(), // Temporarily disabled
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
    case '/recensement':
      return MaterialPageRoute(
        builder: (context) => const RecensementScreen(),
        settings: settings,
      );
    case '/transaction':
      return MaterialPageRoute(
        builder: (context) => const TransactionScreen(),
        settings: settings,
      );
    case '/geolocation':
      return MaterialPageRoute(
        builder: (context) => const GeolocationScreen(),
        settings: settings,
      );
    default:
      return null;
  }
}

Route<dynamic>? _onUnknownRoute(RouteSettings settings) {
  return MaterialPageRoute(
    builder: (context) => const LoginScreen(),
    settings: settings,
  );
}
