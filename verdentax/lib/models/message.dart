enum MessageType {
  signalement('SIGNALEMENT', 'Signalement'),
  message('MESSAGE', 'Message'),
  reponse('REPONSE', 'Réponse'),
  validation('VALIDATION', 'Validation');

  const MessageType(this.code, this.label);
  final String code;
  final String label;
}

enum SignalementType {
  adresseIncorrecte('ADRESSE_INCORRECTE', 'Adresse incorrecte'),
  mauvaiseAffectation('MAUVAISE_AFFECTATION', 'Mauvaise affectation'),
  contribuableContestataire('CONTRIBUABLE_CONTESTATAIRE', 'Contribuable contestataire'),
  montantConteste('MONTANT_CONTESTE', 'Montant contesté'),
  activiteFermee('ACTIVITE_FERMEE', 'Activité fermée'),
  problemePaiement('PROBLEME_PAIEMENT', 'Problème de paiement'),
  problemeApplication('PROBLEME_APPLICATION', 'Problème application');

  const SignalementType(this.code, this.label);
  final String code;
  final String label;
}

class MessageDto {
  final String? id;
  final int agentId;
  final String? agentNom;
  final MessageType type;
  final String? sujet;
  final String contenu;
  final SignalementType? signalementType;
  final int? contribuableId;
  final String? contribuableNom;
  final bool isFromAgent;
  final bool isRead;
  final String? syncStatus;
  final DateTime? createdAt;
  final DateTime? syncedAt;

  MessageDto({
    this.id,
    required this.agentId,
    this.agentNom,
    required this.type,
    this.sujet,
    required this.contenu,
    this.signalementType,
    this.contribuableId,
    this.contribuableNom,
    this.isFromAgent = true,
    this.isRead = false,
    this.syncStatus = 'PENDING',
    this.createdAt,
    this.syncedAt,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) {
    return MessageDto(
      id: json['id']?.toString(),
      agentId: json['agentId'] ?? 0,
      agentNom: json['agentNom'],
      type: MessageType.values.firstWhere(
        (t) => t.code == json['type'],
        orElse: () => MessageType.message,
      ),
      sujet: json['sujet'],
      contenu: json['contenu'] ?? '',
      signalementType: json['signalementType'] != null
          ? SignalementType.values.firstWhere(
              (s) => s.code == json['signalementType'],
              orElse: () => SignalementType.problemeApplication,
            )
          : null,
      contribuableId: json['contribuableId'],
      contribuableNom: json['contribuableNom'],
      isFromAgent: json['isFromAgent'] ?? true,
      isRead: json['isRead'] ?? false,
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
      'type': type.code,
      'sujet': sujet,
      'contenu': contenu,
      'signalementType': signalementType?.code,
      'contribuableId': contribuableId,
      'contribuableNom': contribuableNom,
      'isFromAgent': isFromAgent,
      'isRead': isRead,
      'syncStatus': syncStatus,
      'createdAt': createdAt?.toIso8601String(),
      'syncedAt': syncedAt?.toIso8601String(),
    };
  }

  MessageDto copyWith({
    String? id,
    int? agentId,
    String? agentNom,
    MessageType? type,
    String? sujet,
    String? contenu,
    SignalementType? signalementType,
    int? contribuableId,
    String? contribuableNom,
    bool? isFromAgent,
    bool? isRead,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? syncedAt,
  }) {
    return MessageDto(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      agentNom: agentNom ?? this.agentNom,
      type: type ?? this.type,
      sujet: sujet ?? this.sujet,
      contenu: contenu ?? this.contenu,
      signalementType: signalementType ?? this.signalementType,
      contribuableId: contribuableId ?? this.contribuableId,
      contribuableNom: contribuableNom ?? this.contribuableNom,
      isFromAgent: isFromAgent ?? this.isFromAgent,
      isRead: isRead ?? this.isRead,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}
