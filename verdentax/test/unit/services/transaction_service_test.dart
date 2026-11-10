import 'package:flutter_test/flutter_test.dart';
import 'package:verdentax/models/models.dart';
import 'package:verdentax/services/transaction_service.dart';

void main() {
  group('TransactionService — validation (TS-01)', () {
    final service = TransactionService();

    Future<void> expectInvalid({
      required double montant,
      required int contribuableId,
      required int agentId,
      required int zoneId,
    }) async {
      await expectLater(
        service.createTransaction(
          montant: montant,
          contribuableId: contribuableId,
          agentId: agentId,
          zoneId: zoneId,
          modePaiement: ModePaiement.espece,
        ),
        throwsA(isA<Exception>()),
      );
    }

    test('montant <= 0 est rejeté', () async {
      await expectInvalid(montant: -1, contribuableId: 1, agentId: 1, zoneId: 1);
      await expectInvalid(montant: 0, contribuableId: 1, agentId: 1, zoneId: 1);
    });

    test('contribuableId <= 0 est rejeté', () async {
      await expectInvalid(montant: 100, contribuableId: 0, agentId: 1, zoneId: 1);
    });

    test('agentId <= 0 est rejeté', () async {
      await expectInvalid(montant: 100, contribuableId: 1, agentId: 0, zoneId: 1);
    });

    test('zoneId <= 0 est rejeté', () async {
      await expectInvalid(montant: 100, contribuableId: 1, agentId: 1, zoneId: 0);
    });

    test('montant trop élevé est rejeté', () async {
      await expectInvalid(montant: 1000000000, contribuableId: 1, agentId: 1, zoneId: 1);
    });
  });
}
