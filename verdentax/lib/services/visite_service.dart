import 'dart:convert';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'connectivity_service.dart';

class VisiteService {
  static final VisiteService _instance = VisiteService._internal();
  factory VisiteService() => _instance;
  VisiteService._internal();

  final Logger _logger = Logger();
  final List<VisiteDto> _visitesCache = [];

  List<VisiteDto> get visites => List.unmodifiable(_visitesCache);

  Future<VisiteDto> startVisite({
    required int contribuableId,
    required String contribuableNom,
    String? contribuablePrenom,
    required int agentId,
    String? agentNom,
    required double gpsLat,
    required double gpsLng,
    double? gpsPrecision,
    String? deviceId,
  }) async {
    final now = DateTime.now();
    final visite = VisiteDto(
      id: 'visite_${now.millisecondsSinceEpoch}',
      contribuableId: contribuableId,
      contribuableNom: contribuableNom,
      contribuablePrenom: contribuablePrenom,
      agentId: agentId,
      agentNom: agentNom,
      dateVisite: now,
      heureDebut: now,
      gpsLat: gpsLat,
      gpsLng: gpsLng,
      gpsPrecision: gpsPrecision,
      deviceId: deviceId,
      syncStatus: 'PENDING',
      createdAt: now,
    );

    _visitesCache.add(visite);
    await _saveVisiteOffline(visite);
    _logger.i('Visite démarrée pour $contribuableNom');
    return visite;
  }

  Future<VisiteDto> finishVisite({
    required String visiteId,
    required VisiteResultat resultat,
    String? observation,
  }) async {
    final index = _visitesCache.indexWhere((v) => v.id == visiteId);
    if (index == -1) throw Exception('Visite non trouvée: $visiteId');

    final now = DateTime.now();
    final updated = _visitesCache[index].copyWith(
      heureFin: now,
      resultat: resultat,
      observation: observation,
    );
    _visitesCache[index] = updated;
    await _saveVisiteOffline(updated);
    _logger.i('Visite terminée: ${resultat.label}');
    return updated;
  }

  Future<List<VisiteDto>> getVisitesByAgent(int agentId) async {
    // Le backend (VisiteController) n'expose pas de route /agent/{agentId}.
    // Les visites sont accessibles par tournée (/tournee/{tourneeId}) ou par
    // contribuable (/contribuable/{contribuableId}). On retombe donc sur le
    // cache local ; la synchronisation reste assurée par syncVisites().
    return _getVisitesFromCache();
  }

  Future<List<VisiteDto>> getVisitesToday(int agentId) async {
    final today = DateTime.now();
    final all = await getVisitesByAgent(agentId);
    return all.where((v) =>
      v.dateVisite != null &&
      v.dateVisite!.year == today.year &&
      v.dateVisite!.month == today.month &&
      v.dateVisite!.day == today.day
    ).toList();
  }

  Future<int> countVisitesToday(int agentId) async {
    final visites = await getVisitesToday(agentId);
    return visites.length;
  }

  Future<int> countByResultat(VisiteResultat resultat, int agentId) async {
    final visites = await getVisitesToday(agentId);
    return visites.where((v) => v.resultat == resultat).length;
  }

  Future<void> syncVisites() async {
    final connectivityService = ConnectivityService();
    if (!connectivityService.canPerformOnlineOperation()) return;

    final storageService = StorageService();
    final keys = await storageService.getOfflineDataKeys();
    final visiteKeys = keys.where((k) => k.startsWith('visite_'));

    for (final key in visiteKeys) {
      final data = await storageService.getOfflineData(key);
      if (data != null && data['syncStatus'] == 'PENDING') {
        try {
          final apiService = ApiService();
          await apiService.post(
            AppConfig.visiteEndpoint,
            data: data,
          );
          data['syncStatus'] = 'SYNCED';
          data['syncedAt'] = DateTime.now().toIso8601String();
          await storageService.storeOfflineData(key, data);
          _logger.i('Visite synchronisée: $key');
        } catch (e) {
          _logger.e('Erreur sync visite $key: $e');
        }
      }
    }
  }

  Future<void> _saveVisiteOffline(VisiteDto visite) async {
    final storageService = StorageService();
    await storageService.storeOfflineData('visite_${visite.id}', visite.toJson());
  }

  List<VisiteDto> _getVisitesFromCache() {
    return List.from(_visitesCache);
  }
}
