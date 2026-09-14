enum CaisseStatut {
  fermee('FERMEE', 'Fermée'),
  ouverte('OUVERTE', 'Ouverte'),
  soumise('SOUMISE', 'Soumise'),
  validee('VALIDEE', 'Validée'),
  rejetee('REJETEE', 'Rejetée'),
  deposee('DEPOSEE', 'Déposée');

  const CaisseStatut(this.code, this.label);
  final String code;
  final String label;
}

class CaisseDto {
  final String? id;
  final int agentId;
  final String? agentNom;
  final DateTime date;
  final double soldeInitial;
  final double especeCollecte;
  final double mobileMoneyCollecte;
  final CaisseStatut statut;
  final double? montantDeclare;
  final double? montantRemis;
  final String? beneficiaireRemise;
  final String? commentaireAgent;
  final String? commentaireSuperviseur;
  final String? syncStatus;
  final DateTime? createdAt;
  final DateTime? clotureeAt;

  CaisseDto({
    this.id,
    required this.agentId,
    this.agentNom,
    required this.date,
    this.soldeInitial = 0,
    this.especeCollecte = 0,
    this.mobileMoneyCollecte = 0,
    this.statut = CaisseStatut.fermee,
    this.montantDeclare,
    this.montantRemis,
    this.beneficiaireRemise,
    this.commentaireAgent,
    this.commentaireSuperviseur,
    this.syncStatus = 'PENDING',
    this.createdAt,
    this.clotureeAt,
  });

  factory CaisseDto.fromJson(Map<String, dynamic> json) {
    return CaisseDto(
      id: json['id']?.toString(),
      agentId: json['agentId'] ?? 0,
      agentNom: json['agentNom'],
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      soldeInitial: (json['soldeInitial'] ?? 0).toDouble(),
      especeCollecte: (json['especeCollecte'] ?? 0).toDouble(),
      mobileMoneyCollecte: (json['mobileMoneyCollecte'] ?? 0).toDouble(),
      statut: CaisseStatut.values.firstWhere(
        (s) => s.code == json['statut'],
        orElse: () => CaisseStatut.fermee,
      ),
      montantDeclare: json['montantDeclare']?.toDouble(),
      montantRemis: json['montantRemis']?.toDouble(),
      beneficiaireRemise: json['beneficiaireRemise'],
      commentaireAgent: json['commentaireAgent'],
      commentaireSuperviseur: json['commentaireSuperviseur'],
      syncStatus: json['syncStatus'] ?? 'PENDING',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      clotureeAt: json['clotureeAt'] != null ? DateTime.parse(json['clotureeAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agentId': agentId,
      'agentNom': agentNom,
      'date': date.toIso8601String(),
      'soldeInitial': soldeInitial,
      'especeCollecte': especeCollecte,
      'mobileMoneyCollecte': mobileMoneyCollecte,
      'statut': statut.code,
      'montantDeclare': montantDeclare,
      'montantRemis': montantRemis,
      'beneficiaireRemise': beneficiaireRemise,
      'commentaireAgent': commentaireAgent,
      'commentaireSuperviseur': commentaireSuperviseur,
      'syncStatus': syncStatus,
      'createdAt': createdAt?.toIso8601String(),
      'clotureeAt': clotureeAt?.toIso8601String(),
    };
  }

  double get totalCollecte => especeCollecte + mobileMoneyCollecte;
  double get ecart => (montantDeclare ?? 0) - totalCollecte;
  bool get isOuverte => statut == CaisseStatut.ouverte;

  CaisseDto copyWith({
    String? id,
    int? agentId,
    String? agentNom,
    DateTime? date,
    double? soldeInitial,
    double? especeCollecte,
    double? mobileMoneyCollecte,
    CaisseStatut? statut,
    double? montantDeclare,
    double? montantRemis,
    String? beneficiaireRemise,
    String? commentaireAgent,
    String? commentaireSuperviseur,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? clotureeAt,
  }) {
    return CaisseDto(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      agentNom: agentNom ?? this.agentNom,
      date: date ?? this.date,
      soldeInitial: soldeInitial ?? this.soldeInitial,
      especeCollecte: especeCollecte ?? this.especeCollecte,
      mobileMoneyCollecte: mobileMoneyCollecte ?? this.mobileMoneyCollecte,
      statut: statut ?? this.statut,
      montantDeclare: montantDeclare ?? this.montantDeclare,
      montantRemis: montantRemis ?? this.montantRemis,
      beneficiaireRemise: beneficiaireRemise ?? this.beneficiaireRemise,
      commentaireAgent: commentaireAgent ?? this.commentaireAgent,
      commentaireSuperviseur: commentaireSuperviseur ?? this.commentaireSuperviseur,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      clotureeAt: clotureeAt ?? this.clotureeAt,
    );
  }
}
