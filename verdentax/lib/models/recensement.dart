enum ContribuableType {
  personnePhysique('personne_physique', 'Personne Physique'),
  personneMorale('personne_morale', 'Personne Morale'),
  commercant('commercant', 'Commerçant'),
  transporteur('transporteur', 'Transporteur'),
  artisan('artisan', 'Artisan'),
  occupantDomainePublic('occupant_domaine_public', 'Occupant Domaine Public');

  const ContribuableType(this.code, this.label);
  final String code;
  final String label;
}

enum TypePieceIdentite {
  cni('cni', 'Carte Nationale d\'Identité'),
  passeport('passeport', 'Passeport'),
  permisConduire('permis_conduire', 'Permis de Conduire'),
  attestation('attestation', 'Attestation d\'Identité'),
  carteResidence('carte_residence', 'Carte de Résidence');

  const TypePieceIdentite(this.code, this.label);
  final String code;
  final String label;
}

enum ContribuableStatus {
  actif('actif', 'Actif'),
  inactif('inactif', 'Inactif'),
  enValidation('en_validation', 'En Validation'),
  suspendu('suspendu', 'Suspendu'),
  archive('archive', 'Archivé');

  const ContribuableStatus(this.code, this.label);
  final String code;
  final String label;
}

enum SyncStatus {
  synchronized('synchronized', 'Synchronisé'),
  pending('pending', 'En attente'),
  failed('failed', 'Échec'),
  conflict('conflict', 'Conflit');

  const SyncStatus(this.code, this.label);
  final String code;
  final String label;
}

class ContribuableForm {
  // Informations de base
  int? id;
  String? nom;
  String? prenoms;
  String telephone;
  ContribuableType type;
  String activite;
  
  // Localisation
  String zoneId;
  String? marche;
  String? quartier;
  double? latitude;
  double? longitude;
  
  // Identification
  TypePieceIdentite typePiece;
  String numeroPiece;
  String? photoPiece;
  String? photoContribuable;
  
  // Métadonnées
  String numeroContribuable;
  String qrCode;
  DateTime dateCreation;
  DateTime dateModification;
  ContribuableStatus statut;
  SyncStatus syncStatus;
  bool necessiteValidation;
  String agentId;
  int version;

  ContribuableForm({
    this.id,
    required this.telephone,
    required this.type,
    required this.activite,
    required this.zoneId,
    required this.typePiece,
    required this.numeroPiece,
    required this.numeroContribuable,
    required this.qrCode,
    required this.agentId,
    this.nom,
    this.prenoms,
    this.marche,
    this.quartier,
    this.latitude,
    this.longitude,
    this.photoPiece,
    this.photoContribuable,
    this.statut = ContribuableStatus.actif,
    this.syncStatus = SyncStatus.pending,
    this.necessiteValidation = false,
    this.version = 1,
  }) : dateCreation = DateTime.now(),
       dateModification = DateTime.now();

  // Validation
  bool get isValid {
    return _validateBasicInfo() && 
           _validateIdentification() && 
           _validateLocation();
  }

  bool _validateBasicInfo() {
    if (type == ContribuableType.personnePhysique) {
      return nom?.isNotEmpty == true && 
             prenoms?.isNotEmpty == true &&
             telephone.isNotEmpty &&
             activite.isNotEmpty;
    } else {
      return nom?.isNotEmpty == true &&
             telephone.isNotEmpty &&
             activite.isNotEmpty;
    }
  }

  bool _validateIdentification() {
    return numeroPiece.isNotEmpty && 
           typePiece != TypePieceIdentite.attestation ||
           photoPiece != null;
  }

  bool _validateLocation() {
    return zoneId.isNotEmpty;
  }

  // Getters
  String get fullName {
    if (type == ContribuableType.personnePhysique) {
      return '${prenoms ?? ''} ${nom ?? ''}'.trim();
    } else {
      return nom ?? '';
    }
  }

  String get displayType => type.label;
  String get displayStatus => statut.label;
  String get displaySyncStatus => syncStatus.label;

  // Conversion
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenoms': prenoms,
      'telephone': telephone,
      'type': type.code,
      'activite': activite,
      'zoneId': zoneId,
      'marche': marche,
      'quartier': quartier,
      'latitude': latitude,
      'longitude': longitude,
      'typePiece': typePiece.code,
      'numeroPiece': numeroPiece,
      'photoPiece': photoPiece,
      'photoContribuable': photoContribuable,
      'numeroContribuable': numeroContribuable,
      'qrCode': qrCode,
      'dateCreation': dateCreation.toIso8601String(),
      'dateModification': dateModification.toIso8601String(),
      'statut': statut.code,
      'syncStatus': syncStatus.code,
      'necessiteValidation': necessiteValidation,
      'agentId': agentId,
      'version': version,
    };
  }

  factory ContribuableForm.fromJson(Map<String, dynamic> json) {
    return ContribuableForm(
      id: json['id'],
      telephone: json['telephone'] ?? '',
      type: ContribuableType.values.firstWhere(
        (t) => t.code == json['type'],
        orElse: () => ContribuableType.personnePhysique,
      ),
      activite: json['activite'] ?? '',
      zoneId: json['zoneId'] ?? '',
      typePiece: TypePieceIdentite.values.firstWhere(
        (t) => t.code == json['typePiece'],
        orElse: () => TypePieceIdentite.cni,
      ),
      numeroPiece: json['numeroPiece'] ?? '',
      numeroContribuable: json['numeroContribuable'] ?? '',
      qrCode: json['qrCode'] ?? '',
      agentId: json['agentId'] ?? '',
      nom: json['nom'],
      prenoms: json['prenoms'],
      marche: json['marche'],
      quartier: json['quartier'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      photoPiece: json['photoPiece'],
      photoContribuable: json['photoContribuable'],
      statut: ContribuableStatus.values.firstWhere(
        (s) => s.code == json['statut'],
        orElse: () => ContribuableStatus.actif,
      ),
      syncStatus: SyncStatus.values.firstWhere(
        (s) => s.code == json['syncStatus'],
        orElse: () => SyncStatus.pending,
      ),
      necessiteValidation: json['necessiteValidation'] ?? false,
      version: json['version'] ?? 1,
    );
  }

  ContribuableForm copyWith({
    String? nom,
    String? prenoms,
    String? telephone,
    ContribuableType? type,
    String? activite,
    String? zoneId,
    String? marche,
    String? quartier,
    double? latitude,
    double? longitude,
    TypePieceIdentite? typePiece,
    String? numeroPiece,
    String? photoPiece,
    String? photoContribuable,
    String? numeroContribuable,
    String? qrCode,
    ContribuableStatus? statut,
    SyncStatus? syncStatus,
    bool? necessiteValidation,
    String? agentId,
    int? version,
  }) {
    return ContribuableForm(
      telephone: telephone ?? this.telephone,
      type: type ?? this.type,
      activite: activite ?? this.activite,
      zoneId: zoneId ?? this.zoneId,
      typePiece: typePiece ?? this.typePiece,
      numeroPiece: numeroPiece ?? this.numeroPiece,
      numeroContribuable: numeroContribuable ?? this.numeroContribuable,
      qrCode: qrCode ?? this.qrCode,
      agentId: agentId ?? this.agentId,
      nom: nom ?? this.nom,
      prenoms: prenoms ?? this.prenoms,
      marche: marche ?? this.marche,
      quartier: quartier ?? this.quartier,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photoPiece: photoPiece ?? this.photoPiece,
      photoContribuable: photoContribuable ?? this.photoContribuable,
      statut: statut ?? this.statut,
      syncStatus: syncStatus ?? this.syncStatus,
      necessiteValidation: necessiteValidation ?? this.necessiteValidation,
      version: version ?? this.version,
    );
  }
}

class ContribuableSearchResult {
  final ContribuableForm contribuable;
  final double relevanceScore;
  final List<String> matchedFields;

  ContribuableSearchResult({
    required this.contribuable,
    required this.relevanceScore,
    required this.matchedFields,
  });
}

class ContribuableHistorique {
  final int id;
  final int contribuableId;
  final String? ancienNom;
  final String? nouveauNom;
  final String? ancienTelephone;
  final String? nouveauTelephone;
  final DateTime dateModification;
  final String agentId;
  final String raisonModification;
  final Map<String, dynamic>? anciennesValeurs;
  final Map<String, dynamic>? nouvellesValeurs;

  ContribuableHistorique({
    required this.id,
    required this.contribuableId,
    this.ancienNom,
    this.nouveauNom,
    this.ancienTelephone,
    this.nouveauTelephone,
    required this.dateModification,
    required this.agentId,
    required this.raisonModification,
    this.anciennesValeurs,
    this.nouvellesValeurs,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contribuableId': contribuableId,
      'ancienNom': ancienNom,
      'nouveauNom': nouveauNom,
      'ancienTelephone': ancienTelephone,
      'nouveauTelephone': nouveauTelephone,
      'dateModification': dateModification.toIso8601String(),
      'agentId': agentId,
      'raisonModification': raisonModification,
      'anciennesValeurs': anciennesValeurs,
      'nouvellesValeurs': nouvellesValeurs,
    };
  }

  factory ContribuableHistorique.fromJson(Map<String, dynamic> json) {
    return ContribuableHistorique(
      id: json['id'],
      contribuableId: json['contribuableId'],
      ancienNom: json['ancienNom'],
      nouveauNom: json['nouveauNom'],
      ancienTelephone: json['ancienTelephone'],
      nouveauTelephone: json['nouveauTelephone'],
      dateModification: DateTime.parse(json['dateModification']),
      agentId: json['agentId'],
      raisonModification: json['raisonModification'],
      anciennesValeurs: json['anciennesValeurs'],
      nouvellesValeurs: json['nouvellesValeurs'],
    );
  }
}

class RecensementStatistics {
  final int totalContribuables;
  final int nonSynchronises;
  final int enValidation;
  final int creesAujourdhui;
  final int misAJourAujourdhui;
  final Map<ContribuableType, int> repartitionParType;
  final Map<String, int> repartitionParZone;
  final double tauxSynchronisation;
  final DateTime? derniereSynchronisation;

  RecensementStatistics({
    required this.totalContribuables,
    required this.nonSynchronises,
    required this.enValidation,
    required this.creesAujourdhui,
    required this.misAJourAujourdhui,
    required this.repartitionParType,
    required this.repartitionParZone,
    required this.tauxSynchronisation,
    this.derniereSynchronisation,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalContribuables': totalContribuables,
      'nonSynchronises': nonSynchronises,
      'enValidation': enValidation,
      'creesAujourdhui': creesAujourdhui,
      'misAJourAujourdhui': misAJourAujourdhui,
      'repartitionParType': repartitionParType.map((k, v) => MapEntry(k.code, v)),
      'repartitionParZone': repartitionParZone,
      'tauxSynchronisation': tauxSynchronisation,
      'derniereSynchronisation': derniereSynchronisation?.toIso8601String(),
    };
  }

  factory RecensementStatistics.fromJson(Map<String, dynamic> json) {
    return RecensementStatistics(
      totalContribuables: json['totalContribuables'] ?? 0,
      nonSynchronises: json['nonSynchronises'] ?? 0,
      enValidation: json['enValidation'] ?? 0,
      creesAujourdhui: json['creesAujourdhui'] ?? 0,
      misAJourAujourdhui: json['misAJourAujourdhui'] ?? 0,
      repartitionParType: Map.from(
        json['repartitionParType'] ?? {}
      ).map((k, v) => MapEntry(
        ContribuableType.values.firstWhere(
          (t) => t.code == k,
          orElse: () => ContribuableType.personnePhysique,
        ),
        v,
      )),
      repartitionParZone: Map.from(json['repartitionParZone'] ?? {}),
      tauxSynchronisation: (json['tauxSynchronisation'] ?? 0).toDouble(),
      derniereSynchronisation: json['derniereSynchronisation'] != null
          ? DateTime.parse(json['derniereSynchronisation'])
          : null,
    );
  }
}
