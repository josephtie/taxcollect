import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:verdentax/services/auth_service.dart';
import 'package:verdentax/services/connectivity_service.dart';
import 'package:verdentax/screens/login_screen.dart';

void main() {
  Future<void> pumpLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MultiProvider(
          providers: [
            ChangeNotifierProvider<ConnectivityService>.value(
              value: ConnectivityService(),
            ),
            ChangeNotifierProvider<AuthService>.value(
              value: AuthService(),
            ),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('LW-01: le formulaire de login se rend', (tester) async {
    await pumpLoginScreen(tester);

    expect(find.text('Connexion'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byKey(const Key('email-field')), findsOneWidget);
    expect(find.byKey(const Key('password-field')), findsOneWidget);
    expect(find.byKey(const Key('login-button')), findsOneWidget);
    expect(find.text('SE CONNECTER'), findsOneWidget);
  });

  testWidgets('LW-02: champs vides → messages de validation', (tester) async {
    await pumpLoginScreen(tester);

    await tester.ensureVisible(find.text('SE CONNECTER'));
    await tester.tap(find.text('SE CONNECTER'));
    await tester.pump();

    // "Ce champ est obligatoire" apparaît pour les deux champs
    expect(find.text('Ce champ est obligatoire'), findsNWidgets(2));
  });
}
