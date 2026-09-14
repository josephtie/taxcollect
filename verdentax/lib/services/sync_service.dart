import 'dart:convert';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';
import '../models/sync_item.dart' as sync_item;
import 'storage_service.dart';
import 'connectivity_service.dart';
import 'transaction_service.dart';
import 'visite_service.dart';
import 'audit_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final Logger _logger = Logger();

  DateTime? _lastSyncTime;
  DateTime? get lastSyncTime => _lastSyncTime;

  Future<SyncResult> synchronize() async {
    final connectivityService = ConnectivityService();
    if (!connectivityService.canPerformOnlineOperation()) {
      return SyncResult(
        success: false,
        message: 'Pas de connexion Internet',
        itemsSent: 0,
        itemsReceived: 0,
        conflicts: [],
      );
    }

    int itemsSent = 0;
    int itemsReceived = 0;
    List<SyncConflict> conflicts = [];

    try {
      // Sync transactions
      final transactionService = TransactionService();
      final syncedTx = await transactionService.synchronizeAllOfflineTransactions();
      itemsSent += syncedTx.length;

      // Sync visites
      final visiteService = VisiteService();
      await visiteService.syncVisites();

      // Sync audit entries
      final auditService = AuditService();
      await auditService.syncAuditEntries();

      // Count pending items
      final storageService = StorageService();
      final keys = await storageService.getOfflineDataKeys();
      final pendingCount = keys.where((k) {
        final data = storageService.getLocalData('offline_$k');
        return true;
      }).length;

      _lastSyncTime = DateTime.now();
      await storageService.storeLocalData('last_sync_time', _lastSyncTime!.toIso8601String());

      _logger.i('Synchronisation terminée: $itemsSent envoyés');
      return SyncResult(
        success: true,
        message: 'Synchronisation réussie',
        itemsSent: itemsSent,
        itemsReceived: itemsReceived,
        conflicts: conflicts,
      );
    } catch (e) {
      _logger.e('Erreur synchronisation: $e');
      return SyncResult(
        success: false,
        message: 'Erreur: $e',
        itemsSent: itemsSent,
        itemsReceived: itemsReceived,
        conflicts: conflicts,
      );
    }
  }

  Future<List<SyncItemDto>> getPendingItems() async {
    final storageService = StorageService();
    final keys = await storageService.getOfflineDataKeys();
    final items = <SyncItemDto>[];

    for (final key in keys) {
      final data = await storageService.getOfflineData(key);
      if (data != null && data['syncStatus'] == 'PENDING') {
        items.add(SyncItemDto(
          id: key,
          entityType: key.split('_').first,
          entityId: key,
          data: data,
          status: sync_item.SyncStatus.pending,
          createdAt: DateTime.now(),
        ));
      }
    }
    return items;
  }

  Future<DateTime?> getLastSyncTime() async {
    if (_lastSyncTime != null) return _lastSyncTime;
    final storageService = StorageService();
    final stored = await storageService.getLocalData('last_sync_time');
    if (stored != null) {
      _lastSyncTime = DateTime.parse(stored);
      return _lastSyncTime;
    }
    return null;
  }

  Future<int> getPendingCount() async {
    final items = await getPendingItems();
    return items.length;
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int itemsSent;
  final int itemsReceived;
  final List<SyncConflict> conflicts;

  SyncResult({
    required this.success,
    required this.message,
    required this.itemsSent,
    required this.itemsReceived,
    required this.conflicts,
  });
}

class SyncConflict {
  final String entityType;
  final String entityId;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> serverData;
  final String description;

  SyncConflict({
    required this.entityType,
    required this.entityId,
    required this.localData,
    required this.serverData,
    required this.description,
  });
}
