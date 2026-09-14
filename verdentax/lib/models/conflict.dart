enum ConflictType {
  doublon('DOUBLON', 'Doublon probable'),
  montantDifferent('MONTANT_DIFFERENT', 'Montant différent'),
  contribuableModifie('CONTRIBUABLE_MODIFIE', 'Contribuable modifié'),
  visiteConflit('VISITE_CONFLIT', 'Visite en conflit');

  const ConflictType(this.code, this.label);
  final String code;
  final String label;
}

enum ConflictResolution {
  garderLocal('GARDER_LOCAL', 'Garder la version locale'),
  garderServeur('GARDER_SERVEUR', 'Garder la version serveur'),
  fusionner('FUSIONNER', 'Fusionner'),
  ignorer('IGNORER', 'Ignorer (doublon)');

  const ConflictResolution(this.code, this.label);
  final String code;
  final String label;
}

class ConflictDto {
  final String id;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> serverData;
  final ConflictType type;
  final String? description;
  final ConflictResolution? resolution;
  final bool isResolved;
  final DateTime? createdAt;
  final DateTime? resolvedAt;

  ConflictDto({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.localData,
    required this.serverData,
    required this.type,
    this.description,
    this.resolution,
    this.isResolved = false,
    this.createdAt,
    this.resolvedAt,
  });

  factory ConflictDto.fromJson(Map<String, dynamic> json) {
    return ConflictDto(
      id: json['id']?.toString() ?? '',
      entityType: json['entityType'] ?? '',
      entityId: json['entityId']?.toString() ?? '',
      localData: json['localData'] as Map<String, dynamic>? ?? {},
      serverData: json['serverData'] as Map<String, dynamic>? ?? {},
      type: ConflictType.values.firstWhere(
        (t) => t.code == json['type'],
        orElse: () => ConflictType.doublon,
      ),
      description: json['description'],
      resolution: json['resolution'] != null
          ? ConflictResolution.values.firstWhere(
              (r) => r.code == json['resolution'],
              orElse: () => ConflictResolution.garderLocal,
            )
          : null,
      isResolved: json['isResolved'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType,
      'entityId': entityId,
      'localData': localData,
      'serverData': serverData,
      'type': type.code,
      'description': description,
      'resolution': resolution?.code,
      'isResolved': isResolved,
      'createdAt': createdAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  ConflictDto copyWith({
    String? id,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? localData,
    Map<String, dynamic>? serverData,
    ConflictType? type,
    String? description,
    ConflictResolution? resolution,
    bool? isResolved,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return ConflictDto(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      localData: localData ?? this.localData,
      serverData: serverData ?? this.serverData,
      type: type ?? this.type,
      description: description ?? this.description,
      resolution: resolution ?? this.resolution,
      isResolved: isResolved ?? this.isResolved,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}
