import 'package:flutter_test/flutter_test.dart';
import 'package:verdentax/models/models.dart';

void main() {
  group('ContribuableDto', () {
    test('EM-01: fromJson parse tous les champs', () {
      final dto = ContribuableDto.fromJson(<String, dynamic>{
        'id': 42,
        'nom': 'Kouassi',
        'prenom': 'Augustin',
        'telephone': '0707070707',
        'zoneId': 2,
        'numeroContribuable': 'VTX00000042',
        'typeContribuable': 'commercant',
        'statut': 'actif',
        'necessiteValidation': false,
      });
      expect(dto.id, 42);
      expect(dto.nom, 'Kouassi');
      expect(dto.prenom, 'Augustin');
      expect(dto.zoneId, 2);
      expect(dto.numeroContribuable, 'VTX00000042');
    });

    test('EM-01b: fromJson fallback zoneCollecteId', () {
      final dto = ContribuableDto.fromJson(<String, dynamic>{
        'nom': 'X',
        'prenom': 'Y',
        'zoneCollecteId': 5,
      });
      expect(dto.zoneId, 5);
    });

    test('EM-02: toJson round-trip + fullName', () {
      final dto = ContribuableDto(
        nom: 'Kouassi',
        prenom: 'Augustin',
        telephone: '0707070707',
        zoneId: 2,
      );
      final dto2 = ContribuableDto.fromJson(dto.toJson());
      expect(dto2.nom, 'Kouassi');
      expect(dto2.zoneId, 2);
      expect(dto2.fullName, 'Augustin Kouassi');
      expect(dto2.displayName, 'Augustin Kouassi');
    });
  });

  group('TaxeDto', () {
    test('EM-03: fromJson nom + taux', () {
      final t = TaxeDto.fromJson(<String, dynamic>{
        'id': 1,
        'nom': 'Taxe marché',
        'taux': 5000,
      });
      expect(t.nom, 'Taxe marché');
      expect(t.taux, 5000.0);
      expect(t.libelle, 'Taxe marché');
      expect(t.montant, 5000.0);
    });

    test('EM-03b: fromJson alias libelle + montant', () {
      final t = TaxeDto.fromJson(<String, dynamic>{
        'id': 1,
        'libelle': 'Taxe X',
        'montant': 3000,
      });
      expect(t.nom, 'Taxe X');
      expect(t.taux, 3000.0);
    });
  });

  group('AgentsDto / ZoneCollectDto / CommuneDto', () {
    test('AgentsDto fromJson/toJson', () {
      final a = AgentsDto.fromJson(<String, dynamic>{
        'id': 1,
        'nom': 'Guessan',
        'prenom': 'Joseph',
        'zoneIds': [1, 2],
      });
      expect(a.fullName, 'Joseph Guessan');
      expect(a.zoneIds, [1, 2]);
      expect(AgentsDto.fromJson(a.toJson()).nom, 'Guessan');
    });

    test('ZoneCollectDto fromJson/toJson', () {
      final z = ZoneCollectDto.fromJson(<String, dynamic>{'id': 1, 'nom': 'Centre', 'quartierId': 2});
      expect(z.nom, 'Centre');
      expect(ZoneCollectDto.fromJson(z.toJson()).quartierId, 2);
    });

    test('CommuneDto fromJson', () {
      final c = CommuneDto.fromJson(<String, dynamic>{'id': 1, 'nom': 'Grand-Bassam'});
      expect(c.nom, 'Grand-Bassam');
    });
  });
}
