enum ClotureStatus {
  enCours('EN_COURS', 'En cours'),
  soumise('SOUMISE', 'Soumise'),
  validee('VALIDEE', 'Validée'),
  rejetee('REJETEE', 'Rejetée'),
  deposee('DEPOSEE', 'Déposée');

  const ClotureStatus(this.code, this.label);
  final String code;
  final String label;
}

class ClotureCaisseDTO {
  final int? id;
  final int agentId;
  final DateTime dateCloture;
  final double montantTotal;
  final double montantTotalEspece;
  final double montantTotalMobileMoney;
  final ClotureStatus statut;
  final double? montantDeclare;
  final double? montantDepose;
  final String? referenceDepotBanque;
  final DateTime? dateDepotBanque;
  final String? commentaireAgent;
  final String? commentaireTresor;
  final DateTime? dateValidationTresor;
  final int? valideParId;
  final int? nombreTransactions;
  final String? agentNom;
  final String? agentPrenom;
  final String? valideParNom;
  final String? valideParPrenom;

  ClotureCaisseDTO({
    this.id,
    required this.agentId,
    required this.dateCloture,
    required this.montantTotal,
    required this.montantTotalEspece,
    required this.montantTotalMobileMoney,
    required this.statut,
    this.montantDeclare,
    this.montantDepose,
    this.referenceDepotBanque,
    this.dateDepotBanque,
    this.commentaireAgent,
    this.commentaireTresor,
    this.dateValidationTresor,
    this.valideParId,
    this.nombreTransactions,
    this.agentNom,
    this.agentPrenom,
    this.valideParNom,
    this.valideParPrenom,
  });

  factory ClotureCaisseDTO.fromJson(Map<String, dynamic> json) {
    return ClotureCaisseDTO(
      id: json['id'],
      agentId: json['agentId'] ?? 0,
      dateCloture: DateTime.parse(json['dateCloture']),
      montantTotal: (json['montantTotal'] ?? 0).toDouble(),
      montantTotalEspece: (json['montantTotalEspece'] ?? 0).toDouble(),
      montantTotalMobileMoney: (json['montantTotalMobileMoney'] ?? 0).toDouble(),
      statut: ClotureStatus.values.firstWhere(
        (status) => status.code == json['statut'],
        orElse: () => ClotureStatus.enCours,
      ),
      montantDeclare: json['montantDeclare']?.toDouble(),
      montantDepose: json['montantDepose']?.toDouble(),
      referenceDepotBanque: json['referenceDepotBanque'],
      dateDepotBanque: json['dateDepotBanque'] != null
          ? DateTime.parse(json['dateDepotBanque'])
          : null,
      commentaireAgent: json['commentaireAgent'],
      commentaireTresor: json['commentaireTresor'],
      dateValidationTresor: json['dateValidationTresor'] != null
          ? DateTime.parse(json['dateValidationTresor'])
          : null,
      valideParId: json['valideParId'],
      nombreTransactions: json['nombreTransactions'],
      agentNom: json['agentNom'],
      agentPrenom: json['agentPrenom'],
      valideParNom: json['valideParNom'],
      valideParPrenom: json['valideParPrenom'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agentId': agentId,
      'dateCloture': dateCloture.toIso8601String(),
      'montantTotal': montantTotal,
      'montantTotalEspece': montantTotalEspece,
      'montantTotalMobileMoney': montantTotalMobileMoney,
      'statut': statut.code,
      'montantDeclare': montantDeclare,
      'montantDepose': montantDepose,
      'referenceDepotBanque': referenceDepotBanque,
      'dateDepotBanque': dateDepotBanque?.toIso8601String(),
      'commentaireAgent': commentaireAgent,
      'commentaireTresor': commentaireTresor,
      'dateValidationTresor': dateValidationTresor?.toIso8601String(),
      'valideParId': valideParId,
      'nombreTransactions': nombreTransactions,
      'agentNom': agentNom,
      'agentPrenom': agentPrenom,
      'valideParNom': valideParNom,
      'valideParPrenom': valideParPrenom,
    };
  }

  String get agentFullName => 
      agentNom != null && agentPrenom != null
          ? '$agentPrenom $agentNom'
          : 'Agent inconnu';

  String get valideParNomComplet {
    if (valideParPrenom != null && valideParNom != null) {
      return '$valideParPrenom $valideParNom';
    }
    return valideParPrenom ?? valideParNom ?? 'Non spécifié';
  }

  bool get peutEtreModifiee => statut == ClotureStatus.enCours;
  
  bool get estSoumise => statut == ClotureStatus.soumise;
  
  bool get estValidee => statut == ClotureStatus.validee;
  
  bool get estRejetee => statut == ClotureStatus.rejetee;
  
  bool get estDeposee => statut == ClotureStatus.deposee;
}
