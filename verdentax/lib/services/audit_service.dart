import 'dart:convert';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';
import 'storage_service.dart';

class AuditService {
  static final AuditService _instance = AuditService._internal();
  factory AuditService() => _instance;
  AuditService._internal();

  final Logger _logger = Logger();
  final List<AuditEntryDto> _entries = [];

  List<AuditEntryDto> get entries => List.unmodifiable(_entries);

  Future<void> logAction({
    required int? agentId,
    required String agentName,
    required String action,
    required String entityType,
    String? entityId,
    String? details,
  }) async {
    final entry = AuditEntryDto(
      id: 'audit_${DateTime.now().millisecondsSinceEpoch}',
      agentId: agentId,
      agentName: agentName,
      action: action,
      entityType: entityType,
      entityId: entityId,
      details: details,
      syncStatus: 'PENDING',
      createdAt: DateTime.now(),
    );

    _entries.insert(0, entry);
    await _saveAuditOffline(entry);
    _logger.d('Audit: $action on $entityType');
  }

  Future<List<AuditEntryDto>> getAuditEntries({int limit = 50}) async {
    return _entries.take(limit).toList();
  }

  Future<List<AuditEntryDto>> getAuditEntriesToday() async {
    final today = DateTime.now();
    return _entries.where((e) =>
      e.createdAt != null &&
      e.createdAt!.year == today.year &&
      e.createdAt!.month == today.month &&
      e.createdAt!.day == today.day
    ).toList();
  }

  Future<void> syncAuditEntries() async {
    final storageService = StorageService();
    final keys = await storageService.getOfflineDataKeys();
    final auditKeys = keys.where((k) => k.startsWith('audit_'));

    for (final key in auditKeys) {
      final data = await storageService.getOfflineData(key);
      if (data != null && data['syncStatus'] == 'PENDING') {
        try {
          data['syncStatus'] = 'SYNCED';
          data['syncedAt'] = DateTime.now().toIso8601String();
          await storageService.storeOfflineData(key, data);
        } catch (e) {
          _logger.e('Erreur sync audit $key: $e');
        }
      }
    }
  }

  Future<void> _saveAuditOffline(AuditEntryDto entry) async {
    final storageService = StorageService();
    await storageService.storeOfflineData('audit_${entry.id}', entry.toJson());
  }
}
