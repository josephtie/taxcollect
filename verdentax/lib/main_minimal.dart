import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'services/services.dart';
import 'screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize only essential services
  try {
    await StorageService().initialize();
    await AuthService().initialize();
    print('✅ Essential services initialized successfully');
  } catch (e) {
    print('❌ Error initializing services: $e');
  }
  
  runApp(const VerdenTaxMinimalApp());
}

class VerdenTaxMinimalApp extends StatelessWidget {
  const VerdenTaxMinimalApp({super.key});

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
          ],
          child: MaterialApp(
            title: 'VerdenTax - Minimal',
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
            ),
            home: const LoginScreen(),
            routes: _buildMinimalRoutes(),
          ),
        );
      },
    );
  }
}

Map<String, WidgetBuilder> _buildMinimalRoutes() {
  return {
    '/login': (context) => const LoginScreen(),
    '/dashboard': (context) => const DashboardScreen(),
    '/recensement': (context) => const RecensementScreen(),
    '/transaction': (context) => const TransactionScreen(),
  };
}
