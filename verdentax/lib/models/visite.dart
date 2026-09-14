enum VisiteResultat {
  paiementEffectue('PAIEMENT_EFFECTUE', 'Paiement effectué'),
  paiementPartiel('PAIEMENT_PARTIEL', 'Paiement partiel'),
  promessePaiement('PROMESSE_PAIEMENT', 'Promesse de paiement'),
  absent('ABSENT', 'Contribuable absent'),
  refus('REFUS', 'Refus de payer'),
  activiteFermee('ACTIVITE_FERMEE', 'Activité fermée'),
  adresseIncorrecte('ADRESSE_INCORRECTE', 'Adresse incorrecte'),
  introuvable('INTROUVABLE', 'Contribuable introuvable'),
  autre('AUTRE', 'Autre');

  const VisiteResultat(this.code, this.label);
  final String code;
  final String label;
}

class VisiteDto {
  final String? id;
  final int? contribuableId;
  final String? contribuableNom;
  final String? contribuablePrenom;
  final int? agentId;
  final String? agentNom;
  final DateTime? dateVisite;
  final DateTime? heureDebut;
  final DateTime? heureFin;
  final double? gpsLat;
  final double? gpsLng;
  final double? gpsPrecision;
  final String? deviceId;
  final VisiteResultat? resultat;
  final String? observation;
  final String? syncStatus;
  final DateTime? createdAt;
  final DateTime? syncedAt;

  VisiteDto({
    this.id,
    this.contribuableId,
    this.contribuableNom,
    this.contribuablePrenom,
    this.agentId,
    this.agentNom,
    this.dateVisite,
    this.heureDebut,
    this.heureFin,
    this.gpsLat,
    this.gpsLng,
    this.gpsPrecision,
    this.deviceId,
    this.resultat,
    this.observation,
    this.syncStatus = 'PENDING',
    this.createdAt,
    this.syncedAt,
  });

  factory VisiteDto.fromJson(Map<String, dynamic> json) {
    return VisiteDto(
      id: json['id']?.toString(),
      contribuableId: json['contribuableId'],
      contribuableNom: json['contribuableNom'],
      contribuablePrenom: json['contribuablePrenom'],
      agentId: json['agentId'],
      agentNom: json['agentNom'],
      dateVisite: json['dateVisite'] != null ? DateTime.parse(json['dateVisite']) : null,
      heureDebut: json['heureDebut'] != null ? DateTime.parse(json['heureDebut']) : null,
      heureFin: json['heureFin'] != null ? DateTime.parse(json['heureFin']) : null,
      gpsLat: json['gpsLat']?.toDouble(),
      gpsLng: json['gpsLng']?.toDouble(),
      gpsPrecision: json['gpsPrecision']?.toDouble(),
      deviceId: json['deviceId'],
      resultat: json['resultat'] != null
          ? VisiteResultat.values.firstWhere(
              (r) => r.code == json['resultat'],
              orElse: () => VisiteResultat.autre,
            )
          : null,
      observation: json['observation'],
      syncStatus: json['syncStatus'] ?? 'PENDING',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      syncedAt: json['syncedAt'] != null ? DateTime.parse(json['syncedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contribuableId': contribuableId,
      'contribuableNom': contribuableNom,
      'contribuablePrenom': contribuablePrenom,
      'agentId': agentId,
      'agentNom': agentNom,
      'dateVisite': dateVisite?.toIso8601String(),
      'heureDebut': heureDebut?.toIso8601String(),
      'heureFin': heureFin?.toIso8601String(),
      'gpsLat': gpsLat,
      'gpsLng': gpsLng,
      'gpsPrecision': gpsPrecision,
      'deviceId': deviceId,
      'resultat': resultat?.code,
      'observation': observation,
      'syncStatus': syncStatus,
      'createdAt': createdAt?.toIso8601String(),
      'syncedAt': syncedAt?.toIso8601String(),
    };
  }

  VisiteDto copyWith({
    String? id,
    int? contribuableId,
    String? contribuableNom,
    String? contribuablePrenom,
    int? agentId,
    String? agentNom,
    DateTime? dateVisite,
    DateTime? heureDebut,
    DateTime? heureFin,
    double? gpsLat,
    double? gpsLng,
    double? gpsPrecision,
    String? deviceId,
    VisiteResultat? resultat,
    String? observation,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? syncedAt,
  }) {
    return VisiteDto(
      id: id ?? this.id,
      contribuableId: contribuableId ?? this.contribuableId,
      contribuableNom: contribuableNom ?? this.contribuableNom,
      contribuablePrenom: contribuablePrenom ?? this.contribuablePrenom,
      agentId: agentId ?? this.agentId,
      agentNom: agentNom ?? this.agentNom,
      dateVisite: dateVisite ?? this.dateVisite,
      heureDebut: heureDebut ?? this.heureDebut,
      heureFin: heureFin ?? this.heureFin,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      gpsPrecision: gpsPrecision ?? this.gpsPrecision,
      deviceId: deviceId ?? this.deviceId,
      resultat: resultat ?? this.resultat,
      observation: observation ?? this.observation,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}
