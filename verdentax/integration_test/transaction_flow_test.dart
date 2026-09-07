import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:verdentax/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E-TR: Transactions', () {
    testWidgets('E2E-TR-01: Transaction espèces complète', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(find.byKey(const Key('email-field')), 'agent@mairie.ci');
      await tester.enterText(find.byKey(const Key('password-field')), 'agent123');
      await tester.tap(find.byKey(const Key('login-button')));
      await tester.pumpAndSettle();

      // Naviguer vers transactions
      await tester.tap(find.byKey(const Key('nav-transactions')));
      await tester.pumpAndSettle();

      // Nouvelle transaction
      await tester.tap(find.byKey(const Key('new-transaction-button')));
      await tester.pumpAndSettle();

      // Sélectionner contribuable (via QR scan simulé)
      await tester.tap(find.byKey(const Key('scan-qr-button')));
      await tester.pumpAndSettle();

      // Sélectionner mode espèces
      await tester.tap(find.byKey(const Key('mode-espece')));
      await tester.pumpAndSettle();

      // Saisir montant
      await tester.enterText(find.byKey(const Key('amount-field')), '5000');
      await tester.pumpAndSettle();

      // Valider
      await tester.tap(find.byKey(const Key('validate-button')));
      await tester.pumpAndSettle();

      // Vérifier reçu
      expect(find.text('Reçu'), findsOneWidget);
      expect(find.textContaining('5000'), findsWidgets);
    });

    testWidgets('E2E-TR-04: Refus mobile money offline', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(find.byKey(const Key('email-field')), 'agent@mairie.ci');
      await tester.enterText(find.byKey(const Key('password-field')), 'agent123');
      await tester.tap(find.byKey(const Key('login-button')));
      await tester.pumpAndSettle();

      // Naviguer vers transactions
      await tester.tap(find.byKey(const Key('nav-transactions')));
      await tester.pumpAndSettle();

      // Nouvelle transaction
      await tester.tap(find.byKey(const Key('new-transaction-button')));
      await tester.pumpAndSettle();

      // Sélectionner mode mobile money
      await tester.tap(find.byKey(const Key('mode-mobile-money')));
      await tester.pumpAndSettle();

      // Vérifier dialog "Connexion requise" (offline simulé)
      expect(find.textContaining('Connexion requise'), findsOneWidget);
    });
  });
}
