import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:verdentax/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E-RS: Recensement', () {
    testWidgets('E2E-RS-01: Recensement complet', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(find.byKey(const Key('email-field')), 'agent@mairie.ci');
      await tester.enterText(find.byKey(const Key('password-field')), 'agent123');
      await tester.tap(find.byKey(const Key('login-button')));
      await tester.pumpAndSettle();

      // Naviguer vers recensement
      await tester.tap(find.byKey(const Key('nav-recensement')));
      await tester.pumpAndSettle();

      // Remplir formulaire
      await tester.enterText(find.byKey(const Key('nom-field')), 'Doe');
      await tester.enterText(find.byKey(const Key('prenom-field')), 'John');
      await tester.enterText(find.byKey(const Key('telephone-field')), '0701020304');
      await tester.enterText(find.byKey(const Key('activite-field')), 'Commerce général');
      await tester.pumpAndSettle();

      // Sélectionner type
      await tester.tap(find.byKey(const Key('type-commercant')));
      await tester.pumpAndSettle();

      // Sauvegarder
      await tester.tap(find.byKey(const Key('save-button')));
      await tester.pumpAndSettle();

      // Vérifier QR code généré
      expect(find.textContaining('QR Code'), findsOneWidget);
      expect(find.textContaining('Doe'), findsWidgets);
    });
  });
}
