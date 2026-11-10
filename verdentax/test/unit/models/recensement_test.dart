import 'package:flutter_test/flutter_test.dart';
import 'package:verdentax/models/models.dart';

void main() {
  group('ContribuableForm', () {
    ContribuableForm validPhysique() => ContribuableForm(
          nom: 'Kouassi',
          prenoms: 'Augustin',
          telephone: '0707070707',
          type: ContribuableType.personnePhysique,
          activite: 'Commerce',
          zoneId: '2',
          typePiece: TypePieceIdentite.cni,
          numeroPiece: 'CNI-123',
          numeroContribuable: 'VTX00000042',
          qrCode: 'VTXQR_VTX00000042_A1B2C3D4',
          agentId: '3',
        );

    test('RM-01: toJson sérialise les champs', () {
      final json = validPhysique().toJson();
      expect(json['nom'], 'Kouassi');
      expect(json['type'], 'personne_physique');
      expect(json['typePiece'], 'cni');
      expect(json['numeroContribuable'], 'VTX00000042');
      expect(json['statut'], 'actif');
      expect(json['syncStatus'], 'pending');
    });

    test('RM-02: fromJson parse les champs', () {
      final f = validPhysique();
      final f2 = ContribuableForm.fromJson(f.toJson());
      expect(f2.nom, 'Kouassi');
      expect(f2.type, ContribuableType.personnePhysique);
      expect(f2.typePiece, TypePieceIdentite.cni);
      expect(f2.numeroContribuable, 'VTX00000042');
    });

    test('RM-03: isValid — personne physique complète', () {
      expect(validPhysique().isValid, isTrue);
    });

    test('RM-03b: isValid — nom manquant', () {
      final f = validPhysique().copyWith(nom: '');
      expect(f.isValid, isFalse);
    });

    test('RM-03c: isValid — téléphone manquant', () {
      final f = validPhysique().copyWith(telephone: '');
      expect(f.isValid, isFalse);
    });

    test('RM-03d: isValid — personne morale sans prenoms', () {
      final f = ContribuableForm(
        nom: 'Entreprise SA',
        telephone: '0707070707',
        type: ContribuableType.personneMorale,
        activite: 'Commerce',
        zoneId: '2',
        typePiece: TypePieceIdentite.cni,
        numeroPiece: 'RCCM-123',
        numeroContribuable: 'VTX00000043',
        qrCode: 'VTXQR_X',
        agentId: '3',
      );
      expect(f.isValid, isTrue); // prenoms non requis pour une personne morale
    });

    test('fullName — personne physique vs morale', () {
      expect(validPhysique().fullName, 'Augustin Kouassi');
      final f = ContribuableForm(
        nom: 'Entreprise SA',
        telephone: '07',
        type: ContribuableType.personneMorale,
        activite: 'C',
        zoneId: '2',
        typePiece: TypePieceIdentite.cni,
        numeroPiece: 'P',
        numeroContribuable: 'N',
        qrCode: 'Q',
        agentId: '3',
      );
      expect(f.fullName, 'Entreprise SA');
    });
  });
}
