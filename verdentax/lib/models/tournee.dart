enum TourneeStatut {
  aVisiter('A_VISITER', 'À visiter'),
  enCours('EN_COURS', 'En cours'),
  visite('VISITE', 'Visité'),
  paye('PAYE', 'Payé'),
  paiementPartiel('PAIEMENT_PARTIEL', 'Partiellement payé'),
  refus('REFUS', 'Refus'),
  absent('ABSENT', 'Absent'),
  aRevoir('A_REVOIR', 'À revoir'),
  introuvable('INTROUVABLE', 'Introuvable');

  const TourneeStatut(this.code, this.label);
  final String code;
  final String label;
}

class TourneeDto {
  final String? id;
  final DateTime date;
  final int agentId;
  final String? agentNom;
  final List<TourneeItem> items;
  final String? syncStatus;
  final DateTime? createdAt;
  final DateTime? syncedAt;

  TourneeDto({
    this.id,
    required this.date,
    required this.agentId,
    this.agentNom,
    this.items = const [],
    this.syncStatus = 'PENDING',
    this.createdAt,
    this.syncedAt,
  });

  factory TourneeDto.fromJson(Map<String, dynamic> json) {
    return TourneeDto(
      id: json['id']?.toString(),
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      agentId: json['agentId'] ?? 0,
      agentNom: json['agentNom'],
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => TourneeItem.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      syncStatus: json['syncStatus'] ?? 'PENDING',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      syncedAt: json['syncedAt'] != null ? DateTime.parse(json['syncedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'agentId': agentId,
      'agentNom': agentNom,
      'items': items.map((e) => e.toJson()).toList(),
      'syncStatus': syncStatus,
      'createdAt': createdAt?.toIso8601String(),
      'syncedAt': syncedAt?.toIso8601String(),
    };
  }

  int get totalItems => items.length;
  int get visites => items.where((i) => i.statut != TourneeStatut.aVisiter && i.statut != TourneeStatut.enCours).length;
  int get payes => items.where((i) => i.statut == TourneeStatut.paye).length;
  int get restants => items.where((i) => i.statut == TourneeStatut.aVisiter || i.statut == TourneeStatut.enCours).length;

  TourneeDto copyWith({
    String? id,
    DateTime? date,
    int? agentId,
    String? agentNom,
    List<TourneeItem>? items,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? syncedAt,
  }) {
    return TourneeDto(
      id: id ?? this.id,
      date: date ?? this.date,
      agentId: agentId ?? this.agentId,
      agentNom: agentNom ?? this.agentNom,
      items: items ?? this.items,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}

class TourneeItem {
  final int contribuableId;
  final String contribuableNom;
  final String? contribuablePrenom;
  final String? adresse;
  final String? quartier;
  final double? latitude;
  final double? longitude;
  final int ordre;
  TourneeStatut statut;
  final String? visiteId;
  final String? observation;

  TourneeItem({
    required this.contribuableId,
    required this.contribuableNom,
    this.contribuablePrenom,
    this.adresse,
    this.quartier,
    this.latitude,
    this.longitude,
    required this.ordre,
    this.statut = TourneeStatut.aVisiter,
    this.visiteId,
    this.observation,
  });

  factory TourneeItem.fromJson(Map<String, dynamic> json) {
    return TourneeItem(
      contribuableId: json['contribuableId'] ?? 0,
      contribuableNom: json['contribuableNom'] ?? '',
      contribuablePrenom: json['contribuablePrenom'],
      adresse: json['adresse'],
      quartier: json['quartier'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      ordre: json['ordre'] ?? 0,
      statut: TourneeStatut.values.firstWhere(
        (s) => s.code == json['statut'],
        orElse: () => TourneeStatut.aVisiter,
      ),
      visiteId: json['visiteId']?.toString(),
      observation: json['observation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contribuableId': contribuableId,
      'contribuableNom': contribuableNom,
      'contribuablePrenom': contribuablePrenom,
      'adresse': adresse,
      'quartier': quartier,
      'latitude': latitude,
      'longitude': longitude,
      'ordre': ordre,
      'statut': statut.code,
      'visiteId': visiteId,
      'observation': observation,
    };
  }

  String get fullName => contribuablePrenom != null
      ? '$contribuablePrenom $contribuableNom'
      : contribuableNom;
}
