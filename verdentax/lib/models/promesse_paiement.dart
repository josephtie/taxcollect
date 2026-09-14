class PromessePaiementDto {
  final String? id;
  final int contribuableId;
  final String? contribuableNom;
  final String? contribuablePrenom;
  final int agentId;
  final String? agentNom;
  final double montant;
  final DateTime datePromesse;
  final String? observation;
  final String statut;
  final String? syncStatus;
  final DateTime? createdAt;
  final DateTime? syncedAt;

  PromessePaiementDto({
    this.id,
    required this.contribuableId,
    this.contribuableNom,
    this.contribuablePrenom,
    required this.agentId,
    this.agentNom,
    required this.montant,
    required this.datePromesse,
    this.observation,
    this.statut = 'EN_ATTENTE',
    this.syncStatus = 'PENDING',
    this.createdAt,
    this.syncedAt,
  });

  factory PromessePaiementDto.fromJson(Map<String, dynamic> json) {
    return PromessePaiementDto(
      id: json['id']?.toString(),
      contribuableId: json['contribuableId'] ?? 0,
      contribuableNom: json['contribuableNom'],
      contribuablePrenom: json['contribuablePrenom'],
      agentId: json['agentId'] ?? 0,
      agentNom: json['agentNom'],
      montant: (json['montant'] ?? 0).toDouble(),
      datePromesse: json['datePromesse'] != null ? DateTime.parse(json['datePromesse']) : DateTime.now(),
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
      'contribuableId': contribuableId,
      'contribuableNom': contribuableNom,
      'contribuablePrenom': contribuablePrenom,
      'agentId': agentId,
      'agentNom': agentNom,
      'montant': montant,
      'datePromesse': datePromesse.toIso8601String(),
      'observation': observation,
      'statut': statut,
      'syncStatus': syncStatus,
      'createdAt': createdAt?.toIso8601String(),
      'syncedAt': syncedAt?.toIso8601String(),
    };
  }

  bool get isEcheanceToday {
    final today = DateTime.now();
    return datePromesse.year == today.year &&
        datePromesse.month == today.month &&
        datePromesse.day == today.day;
  }

  bool get isEcheancePassee => datePromesse.isBefore(DateTime.now());

  String get contribuableFullName => contribuablePrenom != null
      ? '$contribuablePrenom $contribuableNom'
      : contribuableNom ?? 'Contribuable';
}
