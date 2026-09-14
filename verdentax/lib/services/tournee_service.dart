import 'dart:convert';
import 'dart:math';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'connectivity_service.dart';
import 'geolocation_service.dart';

class TourneeService {
  static final TourneeService _instance = TourneeService._internal();
  factory TourneeService() => _instance;
  TourneeService._internal();

  final Logger _logger = Logger();
  TourneeDto? _todayTournee;

  TourneeDto? get todayTournee => _todayTournee;

  Future<TourneeDto> generateTournee({
    required int agentId,
    String? agentNom,
    required List<ContribuableDto> contribuables,
  }) async {
    final items = <TourneeItem>[];
    int ordre = 1;

    for (final c in contribuables) {
      items.add(TourneeItem(
        contribuableId: c.id ?? 0,
        contribuableNom: c.nom,
        contribuablePrenom: c.prenom,
        adresse: c.adresse,
        quartier: c.quartier,
        latitude: c.latitude,
        longitude: c.longitude,
        ordre: ordre++,
      ));
    }

    final tournee = TourneeDto(
      id: 'tournee_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      agentId: agentId,
      agentNom: agentNom,
      items: items,
      createdAt: DateTime.now(),
    );

    _todayTournee = tournee;
    await _saveTourneeOffline(tournee);
    _logger.i('Tournée générée avec ${items.length} contribuables');
    return tournee;
  }

  Future<TourneeDto?> getTodayTournee(int agentId) async {
    if (_todayTournee != null) return _todayTournee;

    final connectivityService = ConnectivityService();
    if (connectivityService.canPerformOnlineOperation()) {
      try {
        final apiService = ApiService();
        final response = await apiService.get<Map<String, dynamic>>(
          '${AppConfig.tourneeEndpoint}/agent/$agentId',
        );
        _todayTournee = TourneeDto.fromJson(response);
        return _todayTournee;
      } catch (e) {
        _logger.e('Erreur chargement tournée: $e');
      }
    }

    final storageService = StorageService();
    final data = await storageService.getOfflineData('tournee_today');
    if (data != null) {
      _todayTournee = TourneeDto.fromJson(data);
      return _todayTournee;
    }
    return null;
  }

  Future<void> updateItemStatut({
    required int contribuableId,
    required TourneeStatut statut,
    String? observation,
    String? visiteId,
  }) async {
    if (_todayTournee == null) return;

    final items = _todayTournee!.items.map((item) {
      if (item.contribuableId == contribuableId) {
        return TourneeItem(
          contribuableId: item.contribuableId,
          contribuableNom: item.contribuableNom,
          contribuablePrenom: item.contribuablePrenom,
          adresse: item.adresse,
          quartier: item.quartier,
          latitude: item.latitude,
          longitude: item.longitude,
          ordre: item.ordre,
          statut: statut,
          visiteId: visiteId ?? item.visiteId,
          observation: observation ?? item.observation,
        );
      }
      return item;
    }).toList();

    _todayTournee = _todayTournee!.copyWith(items: items);
    await _saveTourneeOffline(_todayTournee!);
  }

  Future<void> _saveTourneeOffline(TourneeDto tournee) async {
    final storageService = StorageService();
    await storageService.storeOfflineData('tournee_today', tournee.toJson());
  }

  Future<TourneeDto?> optimizeItineraire() async {
    if (_todayTournee == null) return null;

    final geoService = GeolocationService();
    final position = geoService.currentPosition;
    if (position == null) {
      _logger.w('Position GPS non disponible pour optimisation');
      return null;
    }

    final agentLat = position.latitude;
    final agentLng = position.longitude;

    final visited = <TourneeItem>[];
    final remaining = <TourneeItem>[];

    for (final item in _todayTournee!.items) {
      if (item.statut == TourneeStatut.aVisiter || item.statut == TourneeStatut.enCours) {
        remaining.add(item);
      } else {
        visited.add(item);
      }
    }

    if (remaining.isEmpty) {
      _logger.i('Aucun item restant à optimiser');
      return _todayTournee;
    }

    final optimized = <TourneeItem>[];
    double currentLat = agentLat;
    double currentLng = agentLng;
    final pool = List<TourneeItem>.from(remaining);

    while (pool.isNotEmpty) {
      int nearestIdx = 0;
      double nearestDist = double.infinity;

      for (int i = 0; i < pool.length; i++) {
        final item = pool[i];
        if (item.latitude == null || item.longitude == null) {
          if (nearestDist == double.infinity) nearestIdx = i;
          continue;
        }
        final dist = _haversineDistance(currentLat, currentLng, item.latitude!, item.longitude!);
        if (dist < nearestDist) {
          nearestDist = dist;
          nearestIdx = i;
        }
      }

      final next = pool.removeAt(nearestIdx);
      optimized.add(TourneeItem(
        contribuableId: next.contribuableId,
        contribuableNom: next.contribuableNom,
        contribuablePrenom: next.contribuablePrenom,
        adresse: next.adresse,
        quartier: next.quartier,
        latitude: next.latitude,
        longitude: next.longitude,
        ordre: visited.length + optimized.length + 1,
        statut: next.statut,
        visiteId: next.visiteId,
        observation: next.observation,
      ));

      if (next.latitude != null && next.longitude != null) {
        currentLat = next.latitude!;
        currentLng = next.longitude!;
      }
    }

    final allItems = [...visited, ...optimized];
    _todayTournee = _todayTournee!.copyWith(items: allItems);
    await _saveTourneeOffline(_todayTournee!);
    _logger.i('Itinéraire optimisé: ${optimized.length} items restants triés par proximité');
    return _todayTournee;
  }

  double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  Future<void> syncTournee() async {
    if (_todayTournee == null) return;
    final connectivityService = ConnectivityService();
    if (!connectivityService.canPerformOnlineOperation()) return;

    try {
      final apiService = ApiService();
      await apiService.post(
        AppConfig.syncEndpoint,
        data: _todayTournee!.toJson(),
      );
      _todayTournee = _todayTournee!.copyWith(syncStatus: 'SYNCED', syncedAt: DateTime.now());
      await _saveTourneeOffline(_todayTournee!);
      _logger.i('Tournée synchronisée');
    } catch (e) {
      _logger.e('Erreur sync tournée: $e');
    }
  }
}
