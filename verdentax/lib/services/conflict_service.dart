import 'dart:convert';
import 'package:logger/logger.dart';
import '../models/conflict.dart';
import 'storage_service.dart';
import 'connectivity_service.dart';

class ConflictService {
  static final ConflictService _instance = ConflictService._internal();
  factory ConflictService() => _instance;
  ConflictService._internal();

  final Logger _logger = Logger();
  final List<ConflictDto> _conflicts = [];

  List<ConflictDto> get conflicts => List.unmodifiable(_conflicts);
  int get unresolvedCount => _conflicts.where((c) => !c.isResolved).length;

  void detectConflict(ConflictDto conflict) {
    _conflicts.add(conflict);
    _saveOffline(conflict);
    _logger.w('Conflit détecté: ${conflict.type.label} pour ${conflict.entityType}/${conflict.entityId}');
  }

  Future<void> resolveConflict(String conflictId, ConflictResolution resolution) async {
    final index = _conflicts.indexWhere((c) => c.id == conflictId);
    if (index == -1) return;

    final resolved = _conflicts[index].copyWith(
      resolution: resolution,
      isResolved: true,
      resolvedAt: DateTime.now(),
    );
    _conflicts[index] = resolved;
    await _saveOffline(resolved);
    _logger.i('Conflit résolu: $conflictId → ${resolution.label}');
  }

  Future<List<ConflictDto>> loadConflicts() async {
    final storageService = StorageService();
    final keys = await storageService.getOfflineDataKeys();
    final conflictKeys = keys.where((k) => k.startsWith('conflict_'));

    _conflicts.clear();
    for (final key in conflictKeys) {
      final data = await storageService.getOfflineData(key);
      if (data != null) {
        _conflicts.add(ConflictDto.fromJson(data));
      }
    }
    return _conflicts;
  }

  Future<void> _saveOffline(ConflictDto conflict) async {
    final storageService = StorageService();
    await storageService.storeOfflineData('conflict_${conflict.id}', conflict.toJson());
  }

  ConflictDto? checkTransactionConflict(Map<String, dynamic> localTx, Map<String, dynamic> serverTx) {
    final localMontant = (localTx['montant'] ?? 0).toDouble();
    final serverMontant = (serverTx['montant'] ?? 0).toDouble();

    if (localMontant == serverMontant) {
      return ConflictDto(
        id: 'conflict_${DateTime.now().millisecondsSinceEpoch}',
        entityType: 'transaction',
        entityId: localTx['id']?.toString() ?? '',
        localData: localTx,
        serverData: serverTx,
        type: ConflictType.doublon,
        description: 'Même montant détecté — probable doublon',
        createdAt: DateTime.now(),
      );
    } else {
      return ConflictDto(
        id: 'conflict_${DateTime.now().millisecondsSinceEpoch}',
        entityType: 'transaction',
        entityId: localTx['id']?.toString() ?? '',
        localData: localTx,
        serverData: serverTx,
        type: ConflictType.montantDifferent,
        description: 'Montant local: $localMontant FCFA vs serveur: $serverMontant FCFA',
        createdAt: DateTime.now(),
      );
    }
  }
}
