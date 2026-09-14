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

    // Auto-sync offline transactions when connectivity is restored
    connectivityService.connectivityStream.listen((result) {
      if (connectivityService.canPerformOnlineOperation()) {
        _syncOfflineData();
      }
    });
    // Also try sync on startup if already online
    if (connectivityService.canPerformOnlineOperation()) {
      _syncOfflineData();
    }

    debugPrint('✅ All services initialized successfully');
  } catch (e) {
    debugPrint('❌ Error initializing services: $e');
    // Continue with partial initialization for development
  }
}

Future<void> _syncOfflineData() async {
  try {
    final transactionService = TransactionService();
    final synced = await transactionService.synchronizeAllOfflineTransactions();
    if (synced.isNotEmpty) {
      debugPrint('✅ Synced ${synced.length} offline transactions');
    }
  } catch (e) {
    debugPrint('⚠️ Error syncing offline data: $e');
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
    // Agent P0 routes
    '/agent-dashboard': (context) => const AgentDashboardScreen(),
    '/agent-contribuables': (context) => const AgentContribuableListScreen(),
    '/agent-contribuable-detail': (context) => const AgentContribuableDetailScreen(),
    '/agent-visite': (context) => const AgentVisiteScreen(),
    '/agent-encaissement': (context) => const AgentEncaissementScreen(),
    '/agent-recu': (context) => const AgentRecuScreen(),
    '/agent-impayes': (context) => const AgentImpayesScreen(),
    '/agent-sync': (context) => const AgentSyncScreen(),
    '/agent-journal': (context) => const AgentJournalScreen(),
    '/agent-nearby': (context) => const AgentNearbyScreen(),
    '/agent-tournee': (context) => const AgentTourneeScreen(),
    '/agent-promesse': (context) => const AgentPromesseScreen(),
    '/agent-nouveau-contribuable': (context) => const AgentNouveauContribuableScreen(),
    '/agent-caisse': (context) => const AgentCaisseScreen(),
    '/agent-evaluation': (context) => const AgentEvaluationScreen(),
    '/agent-notifications': (context) => const AgentNotificationsScreen(),
    '/agent-stats': (context) => const AgentStatsScreen(),
    '/agent-messagerie': (context) => const AgentMessagerieScreen(),
    '/agent-verif-recu': (context) => const AgentVerifRecuScreen(),
    '/agent-conflict': (context) => const AgentConflictScreen(),
    '/agent-remise-caisse': (context) => const AgentRemiseCaisseScreen(),
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
    case '/agent-dashboard':
      return MaterialPageRoute(
        builder: (context) => const AgentDashboardScreen(),
        settings: settings,
      );
    case '/agent-contribuables':
      return MaterialPageRoute(
        builder: (context) => const AgentContribuableListScreen(),
        settings: settings,
      );
    case '/agent-contribuable-detail':
      return MaterialPageRoute(
        builder: (context) => const AgentContribuableDetailScreen(),
        settings: settings,
      );
    case '/agent-visite':
      return MaterialPageRoute(
        builder: (context) => const AgentVisiteScreen(),
        settings: settings,
      );
    case '/agent-encaissement':
      return MaterialPageRoute(
        builder: (context) => const AgentEncaissementScreen(),
        settings: settings,
      );
    case '/agent-recu':
      return MaterialPageRoute(
        builder: (context) => const AgentRecuScreen(),
        settings: settings,
      );
    case '/agent-impayes':
      return MaterialPageRoute(
        builder: (context) => const AgentImpayesScreen(),
        settings: settings,
      );
    case '/agent-sync':
      return MaterialPageRoute(
        builder: (context) => const AgentSyncScreen(),
        settings: settings,
      );
    case '/agent-journal':
      return MaterialPageRoute(
        builder: (context) => const AgentJournalScreen(),
        settings: settings,
      );
    case '/agent-nearby':
      return MaterialPageRoute(
        builder: (context) => const AgentNearbyScreen(),
        settings: settings,
      );
    case '/agent-tournee':
      return MaterialPageRoute(
        builder: (context) => const AgentTourneeScreen(),
        settings: settings,
      );
    case '/agent-promesse':
      return MaterialPageRoute(
        builder: (context) => const AgentPromesseScreen(),
        settings: settings,
      );
    case '/agent-nouveau-contribuable':
      return MaterialPageRoute(
        builder: (context) => const AgentNouveauContribuableScreen(),
        settings: settings,
      );
    case '/agent-caisse':
      return MaterialPageRoute(
        builder: (context) => const AgentCaisseScreen(),
        settings: settings,
      );
    case '/agent-evaluation':
      return MaterialPageRoute(
        builder: (context) => const AgentEvaluationScreen(),
        settings: settings,
      );
    case '/agent-notifications':
      return MaterialPageRoute(
        builder: (context) => const AgentNotificationsScreen(),
        settings: settings,
      );
    case '/agent-stats':
      return MaterialPageRoute(
        builder: (context) => const AgentStatsScreen(),
        settings: settings,
      );
    case '/agent-messagerie':
      return MaterialPageRoute(
        builder: (context) => const AgentMessagerieScreen(),
        settings: settings,
      );
    case '/agent-verif-recu':
      return MaterialPageRoute(
        builder: (context) => const AgentVerifRecuScreen(),
        settings: settings,
      );
    case '/agent-conflict':
      return MaterialPageRoute(
        builder: (context) => const AgentConflictScreen(),
        settings: settings,
      );
    case '/agent-remise-caisse':
      return MaterialPageRoute(
        builder: (context) => const AgentRemiseCaisseScreen(),
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
