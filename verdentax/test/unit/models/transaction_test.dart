import 'package:flutter_test/flutter_test.dart';
import 'package:verdentax/models/models.dart';
import 'package:verdentax/services/transaction_service.dart';

void main() {
  group('TransactionDTO', () {
    final fullJson = <String, dynamic>{
      'id': 42,
      'numeroRecu': 'TAX-20260727-0001',
      'montant': 15000,
      'contribuableId': 7,
      'agentId': 3,
      'zoneId': 2,
      'modePaiement': 'MOBILE_MONEY',
      'statut': 'VALIDEE',
      'referencePaiement': 'REF-123',
      'hashTransaction': 'abc123',
      'latitude': 5.35,
      'longitude': -4.01,
      'adresseCollecte': 'Marché central',
      'offline': false,
      'dateSynchronisation': '2026-07-27T12:00:00.000Z',
      'dateCreation': '2026-07-27T11:00:00.000Z',
      'contribuableNom': 'Kouassi',
      'contribuablePrenom': 'Augustin',
      'agentNom': 'Guessan',
      'agentPrenom': 'Joseph',
      'zoneNom': 'Zone Centre',
      'taxeCollectId': 9,
    };

    test('TM-01: fromJson parse tous les champs', () {
      final t = TransactionDTO.fromJson(fullJson);
      expect(t.id, 42);
      expect(t.numeroRecu, 'TAX-20260727-0001');
      expect(t.montant, 15000.0);
      expect(t.contribuableId, 7);
      expect(t.agentId, 3);
      expect(t.zoneId, 2);
      expect(t.modePaiement, ModePaiement.mobileMoney);
      expect(t.statut, TransactionStatus.validee);
      expect(t.referencePaiement, 'REF-123');
      expect(t.hashTransaction, 'abc123');
      expect(t.latitude, 5.35);
      expect(t.longitude, -4.01);
      expect(t.adresseCollecte, 'Marché central');
      expect(t.offline, isFalse);
      expect(t.dateSynchronisation, DateTime.parse('2026-07-27T12:00:00.000Z'));
      expect(t.dateCreation, DateTime.parse('2026-07-27T11:00:00.000Z'));
      expect(t.contribuableNom, 'Kouassi');
      expect(t.taxeCollectId, 9);
    });

    test('TM-01b: fromJson valeurs par défaut quand enums inconnus', () {
      final t = TransactionDTO.fromJson(<String, dynamic>{
        'montant': 1000,
        'contribuableId': 1,
        'agentId': 1,
        'zoneId': 1,
        'modePaiement': 'INCONNU',
        'statut': 'INCONNU',
        'offline': false,
      });
      expect(t.modePaiement, ModePaiement.espece); // fallback
      expect(t.statut, TransactionStatus.enAttente); // fallback
      expect(t.offline, isFalse);
    });

    test('TM-02: toJson sérialise tous les champs', () {
      final t = TransactionDTO.fromJson(fullJson);
      final json = t.toJson();
      expect(json['numeroRecu'], 'TAX-20260727-0001');
      expect(json['montant'], 15000.0);
      expect(json['modePaiement'], 'MOBILE_MONEY');
      expect(json['statut'], 'VALIDEE');
      expect(json['offline'], false);
    });

    test('TM-03: round-trip toJson → fromJson', () {
      final t1 = TransactionDTO.fromJson(fullJson);
      final t2 = TransactionDTO.fromJson(t1.toJson());
      expect(t2.numeroRecu, t1.numeroRecu);
      expect(t2.montant, t1.montant);
      expect(t2.modePaiement, t1.modePaiement);
      expect(t2.statut, t1.statut);
      expect(t2.contribuableId, t1.contribuableId);
      expect(t2.contribuableNom, t1.contribuableNom);
    });

    test('getters contribuableFullName / agentFullName', () {
      final t = TransactionDTO.fromJson(fullJson);
      expect(t.contribuableFullName, 'Augustin Kouassi');
      expect(t.agentFullName, 'Joseph Guessan');

      final t2 = TransactionDTO(
        montant: 1,
        contribuableId: 1,
        agentId: 1,
        zoneId: 1,
        modePaiement: ModePaiement.espece,
        statut: TransactionStatus.enAttente,
        offline: false,
      );
      expect(t2.contribuableFullName, 'Contribuable inconnu');
      expect(t2.agentFullName, 'Agent inconnu');
    });
  });

  group('TransactionStatistics', () {
    test('fromJson / toJson round-trip', () {
      final json = <String, dynamic>{
        'totalTransactions': 10,
        'totalMontant': 5000.0,
        'transactionsValidees': 8,
        'transactionsEnAttente': 2,
        'transactionsAnnulees': 0,
        'moyenneMontant': 500.0,
        'montantTotalEspece': 3000.0,
        'montantTotalMobileMoney': 2000.0,
        'montantTotalQRCode': 0.0,
      };
      final s = TransactionStatistics.fromJson(json);
      expect(s.totalTransactions, 10);
      expect(s.totalMontant, 5000.0);
      expect(s.transactionsValidees, 8);
      expect(s.montantTotalEspece, 3000.0);

      final s2 = TransactionStatistics.fromJson(s.toJson());
      expect(s2.totalTransactions, 10);
      expect(s2.montantTotalEspece, 3000.0);
    });
  });
}
