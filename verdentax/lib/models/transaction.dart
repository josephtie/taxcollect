enum TransactionStatus {
  enAttente('EN_ATTENTE', 'En attente'),
  validee('VALIDEE', 'Validée'),
  annulee('ANNULEE', 'Annulée'),
  synchronisee('SYNCHRONISEE', 'Synchronisée'),
  enErreur('EN_ERREUR', 'En erreur');

  const TransactionStatus(this.code, this.label);
  final String code;
  final String label;

  String get displayStatus => label;
}

enum ModePaiement {
  espece('ESPECE', 'Espèce'),
  mobileMoney('MOBILE_MONEY', 'Mobile Money'),
  qrCode('QR_CODE', 'QR Code');

  const ModePaiement(this.code, this.label);
  final String code;
  final String label;
}

class TransactionDTO {
  final int? id;
  final String? numeroRecu;
  final double montant;
  final int contribuableId;
  final int agentId;
  final int zoneId;
  final ModePaiement modePaiement;
  final TransactionStatus statut;
  final String? referencePaiement;
  final String? hashTransaction;
  final double? latitude;
  final double? longitude;
  final String? adresseCollecte;
  final bool offline;
  final DateTime? dateSynchronisation;
  final DateTime? dateCreation;
  final String? contribuableNom;
  final String? contribuablePrenom;
  final String? agentNom;
  final String? agentPrenom;
  final String? zoneNom;
  final int? taxeCollectId;

  TransactionDTO({
    this.id,
    this.numeroRecu,
    required this.montant,
    required this.contribuableId,
    required this.agentId,
    required this.zoneId,
    required this.modePaiement,
    required this.statut,
    this.referencePaiement,
    this.hashTransaction,
    this.latitude,
    this.longitude,
    this.adresseCollecte,
    required this.offline,
    this.dateSynchronisation,
    this.dateCreation,
    this.contribuableNom,
    this.contribuablePrenom,
    this.agentNom,
    this.agentPrenom,
    this.zoneNom,
    this.taxeCollectId,
  });

  factory TransactionDTO.fromJson(Map<String, dynamic> json) {
    return TransactionDTO(
      id: json['id'],
      numeroRecu: json['numeroRecu'],
      montant: (json['montant'] ?? 0).toDouble(),
      contribuableId: json['contribuableId'] ?? 0,
      agentId: json['agentId'] ?? 0,
      zoneId: json['zoneId'] ?? 0,
      modePaiement: ModePaiement.values.firstWhere(
        (mode) => mode.code == json['modePaiement'],
        orElse: () => ModePaiement.espece,
      ),
      statut: TransactionStatus.values.firstWhere(
        (status) => status.code == json['statut'],
        orElse: () => TransactionStatus.enAttente,
      ),
      referencePaiement: json['referencePaiement'],
      hashTransaction: json['hashTransaction'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      adresseCollecte: json['adresseCollecte'],
      offline: json['offline'] ?? false,
      dateSynchronisation: json['dateSynchronisation'] != null
          ? DateTime.parse(json['dateSynchronisation'])
          : null,
      dateCreation: json['dateCreation'] != null
          ? DateTime.parse(json['dateCreation'])
          : null,
      contribuableNom: json['contribuableNom'],
      contribuablePrenom: json['contribuablePrenom'],
      agentNom: json['agentNom'],
      agentPrenom: json['agentPrenom'],
      zoneNom: json['zoneNom'],
      taxeCollectId: json['taxeCollectId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numeroRecu': numeroRecu,
      'montant': montant,
      'contribuableId': contribuableId,
      'agentId': agentId,
      'zoneId': zoneId,
      'modePaiement': modePaiement.code,
      'statut': statut.code,
      'referencePaiement': referencePaiement,
      'hashTransaction': hashTransaction,
      'latitude': latitude,
      'longitude': longitude,
      'adresseCollecte': adresseCollecte,
      'offline': offline,
      'dateSynchronisation': dateSynchronisation?.toIso8601String(),
      'dateCreation': dateCreation?.toIso8601String(),
      'contribuableNom': contribuableNom,
      'contribuablePrenom': contribuablePrenom,
      'agentNom': agentNom,
      'agentPrenom': agentPrenom,
      'zoneNom': zoneNom,
      'taxeCollectId': taxeCollectId,
    };
  }

  String get contribuableFullName => 
      contribuableNom != null && contribuablePrenom != null
          ? '$contribuablePrenom $contribuableNom'
          : 'Contribuable inconnu';

  String get agentFullName => 
      agentNom != null && agentPrenom != null
          ? '$agentPrenom $agentNom'
          : 'Agent inconnu';

  TransactionDTO copyWith({
    int? id,
    String? numeroRecu,
    double? montant,
    int? contribuableId,
    int? agentId,
    int? zoneId,
    ModePaiement? modePaiement,
    TransactionStatus? statut,
    String? referencePaiement,
    String? hashTransaction,
    double? latitude,
    double? longitude,
    String? adresseCollecte,
    bool? offline,
    DateTime? dateSynchronisation,
    DateTime? dateCreation,
    String? contribuableNom,
    String? contribuablePrenom,
    String? agentNom,
    String? agentPrenom,
    String? zoneNom,
    int? taxeCollectId,
  }) {
    return TransactionDTO(
      id: id ?? this.id,
      numeroRecu: numeroRecu ?? this.numeroRecu,
      montant: montant ?? this.montant,
      contribuableId: contribuableId ?? this.contribuableId,
      agentId: agentId ?? this.agentId,
      zoneId: zoneId ?? this.zoneId,
      modePaiement: modePaiement ?? this.modePaiement,
      statut: statut ?? this.statut,
      referencePaiement: referencePaiement ?? this.referencePaiement,
      hashTransaction: hashTransaction ?? this.hashTransaction,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      adresseCollecte: adresseCollecte ?? this.adresseCollecte,
      offline: offline ?? this.offline,
      dateSynchronisation: dateSynchronisation ?? this.dateSynchronisation,
      dateCreation: dateCreation ?? this.dateCreation,
      contribuableNom: contribuableNom ?? this.contribuableNom,
      contribuablePrenom: contribuablePrenom ?? this.contribuablePrenom,
      agentNom: agentNom ?? this.agentNom,
      agentPrenom: agentPrenom ?? this.agentPrenom,
      zoneNom: zoneNom ?? this.zoneNom,
      taxeCollectId: taxeCollectId ?? this.taxeCollectId,
    );
  }
}
