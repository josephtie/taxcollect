enum NotificationType {
  nouvelleAffectation('NOUVELLE_AFFECTATION', 'Nouvelle affectation'),
  nouvelleTournee('NOUVELLE_TOURNEE', 'Nouvelle tournée'),
  aRevoir('A_REVOIR', 'Contribuable à revoir'),
  promesseEcheance('PROMESSE_ECHEANCE', 'Promesse à échéance'),
  paiementConfirme('PAIEMENT_CONFIRME', 'Paiement confirmé'),
  syncEchouee('SYNC_ECHOUEE', 'Synchronisation échouée'),
  anomalie('ANOMALIE', 'Anomalie détectée'),
  changementSecteur('CHANGEMENT_SECTEUR', 'Changement de secteur'),
  messageSuperviseur('MESSAGE_SUPERVISEUR', 'Message du superviseur');

  const NotificationType(this.code, this.label);
  final String code;
  final String label;
}

class NotificationDto {
  final String? id;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;
  final Map<String, dynamic>? data;

  NotificationDto({
    this.id,
    required this.type,
    required this.title,
    required this.body,
    this.isRead = false,
    this.createdAt,
    this.data,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id']?.toString(),
      type: NotificationType.values.firstWhere(
        (t) => t.code == json['type'],
        orElse: () => NotificationType.messageSuperviseur,
      ),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.code,
      'title': title,
      'body': body,
      'isRead': isRead,
      'createdAt': createdAt?.toIso8601String(),
      'data': data,
    };
  }

  NotificationDto copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationDto(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }
}
