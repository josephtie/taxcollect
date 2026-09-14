class AuditEntryDto {
  final String? id;
  final int? agentId;
  final String agentName;
  final String action;
  final String entityType;
  final String? entityId;
  final String? details;
  final String? syncStatus;
  final DateTime? createdAt;
  final DateTime? syncedAt;

  AuditEntryDto({
    this.id,
    this.agentId,
    required this.agentName,
    required this.action,
    required this.entityType,
    this.entityId,
    this.details,
    this.syncStatus = 'PENDING',
    this.createdAt,
    this.syncedAt,
  });

  factory AuditEntryDto.fromJson(Map<String, dynamic> json) {
    return AuditEntryDto(
      id: json['id']?.toString(),
      agentId: json['agentId'],
      agentName: json['agentName'] ?? '',
      action: json['action'] ?? '',
      entityType: json['entityType'] ?? '',
      entityId: json['entityId']?.toString(),
      details: json['details'],
      syncStatus: json['syncStatus'] ?? 'PENDING',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      syncedAt: json['syncedAt'] != null ? DateTime.parse(json['syncedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agentId': agentId,
      'agentName': agentName,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'details': details,
      'syncStatus': syncStatus,
      'createdAt': createdAt?.toIso8601String(),
      'syncedAt': syncedAt?.toIso8601String(),
    };
  }
}
