enum SyncStatus {
  pending('PENDING', 'En attente'),
  syncing('SYNCING', 'En cours'),
  synced('SYNCED', 'Synchronisé'),
  failed('FAILED', 'Échec'),
  conflict('CONFLICT', 'Conflit');

  const SyncStatus(this.code, this.label);
  final String code;
  final String label;
}

class SyncItemDto {
  final String id;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> data;
  final SyncStatus status;
  final DateTime createdAt;
  final DateTime? syncedAt;
  final String? errorMessage;

  SyncItemDto({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.data,
    this.status = SyncStatus.pending,
    required this.createdAt,
    this.syncedAt,
    this.errorMessage,
  });

  factory SyncItemDto.fromJson(Map<String, dynamic> json) {
    return SyncItemDto(
      id: json['id'] ?? '',
      entityType: json['entityType'] ?? '',
      entityId: json['entityId'] ?? '',
      data: json['data'] as Map<String, dynamic>? ?? {},
      status: SyncStatus.values.firstWhere(
        (s) => s.code == json['status'],
        orElse: () => SyncStatus.pending,
      ),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      syncedAt: json['syncedAt'] != null ? DateTime.parse(json['syncedAt']) : null,
      errorMessage: json['errorMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType,
      'entityId': entityId,
      'data': data,
      'status': status.code,
      'createdAt': createdAt.toIso8601String(),
      'syncedAt': syncedAt?.toIso8601String(),
      'errorMessage': errorMessage,
    };
  }

  SyncItemDto copyWith({
    String? id,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? data,
    SyncStatus? status,
    DateTime? createdAt,
    DateTime? syncedAt,
    String? errorMessage,
  }) {
    return SyncItemDto(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      data: data ?? this.data,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
