import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:verdentax/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E-AU: Authentification', () {
    testWidgets('E2E-AU-01: Login agent réussi', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Vérifier écran login
      expect(find.text('Connexion'), findsOneWidget);

      // Saisir credentials
      await tester.enterText(find.byKey(const Key('email-field')), 'agent@mairie.ci');
      await tester.enterText(find.byKey(const Key('password-field')), 'agent123');
      await tester.tap(find.byKey(const Key('login-button')));
      await tester.pumpAndSettle();

      // Vérifier dashboard
      expect(find.text('Tableau de bord'), findsOneWidget);
    });

    testWidgets('E2E-AU-02: Login échec — credentials invalides', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email-field')), 'wrong@email.com');
      await tester.enterText(find.byKey(const Key('password-field')), 'wrong');
      await tester.tap(find.byKey(const Key('login-button')));
      await tester.pumpAndSettle();

      expect(find.textContaining('erreur'), findsOneWidget);
    });
  });
}
