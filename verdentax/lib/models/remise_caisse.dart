class RemiseCaisseDto {
  final String? id;
  final int agentId;
  final String? agentNom;
  final double montant;
  final String? beneficiaire;
  final DateTime dateRemise;
  final String? reference;
  final String? observation;
  final String statut;
  final String? syncStatus;
  final DateTime? createdAt;
  final DateTime? syncedAt;

  RemiseCaisseDto({
    this.id,
    required this.agentId,
    this.agentNom,
    required this.montant,
    this.beneficiaire,
    required this.dateRemise,
    this.reference,
    this.observation,
    this.statut = 'EN_ATTENTE',
    this.syncStatus = 'PENDING',
    this.createdAt,
    this.syncedAt,
  });

  factory RemiseCaisseDto.fromJson(Map<String, dynamic> json) {
    return RemiseCaisseDto(
      id: json['id']?.toString(),
      agentId: json['agentId'] ?? 0,
      agentNom: json['agentNom'],
      montant: (json['montant'] ?? 0).toDouble(),
      beneficiaire: json['beneficiaire'],
      dateRemise: json['dateRemise'] != null ? DateTime.parse(json['dateRemise']) : DateTime.now(),
      reference: json['reference'],
      observation: json['observation'],
      statut: json['statut'] ?? 'EN_ATTENTE',
      syncStatus: json['syncStatus'] ?? 'PENDING',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      syncedAt: json['syncedAt'] != null ? DateTime.parse(json['syncedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agentId': agentId,
      'agentNom': agentNom,
      'montant': montant,
      'beneficiaire': beneficiaire,
      'dateRemise': dateRemise.toIso8601String(),
      'reference': reference,
      'observation': observation,
      'statut': statut,
      'syncStatus': syncStatus,
      'createdAt': createdAt?.toIso8601String(),
      'syncedAt': syncedAt?.toIso8601String(),
    };
  }
}
