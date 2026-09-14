import 'dart:convert';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'connectivity_service.dart';

class PromesseService {
  static final PromesseService _instance = PromesseService._internal();
  factory PromesseService() => _instance;
  PromesseService._internal();

  final Logger _logger = Logger();
  final List<PromessePaiementDto> _promesses = [];

  List<PromessePaiementDto> get promesses => List.unmodifiable(_promesses);

  Future<PromessePaiementDto> createPromesse({
    required int contribuableId,
    String? contribuableNom,
    String? contribuablePrenom,
    required int agentId,
    String? agentNom,
    required double montant,
    required DateTime datePromesse,
    String? observation,
  }) async {
    final promesse = PromessePaiementDto(
      id: 'promesse_${DateTime.now().millisecondsSinceEpoch}',
      contribuableId: contribuableId,
      contribuableNom: contribuableNom,
      contribuablePrenom: contribuablePrenom,
      agentId: agentId,
      agentNom: agentNom,
      montant: montant,
      datePromesse: datePromesse,
      observation: observation,
      createdAt: DateTime.now(),
    );

    _promesses.add(promesse);
    await _savePromesseOffline(promesse);
    _logger.i('Promesse créée pour $contribuableNom: $montant FCFA');
    return promesse;
  }

  Future<List<PromessePaiementDto>> getPromessesByAgent(int agentId) async {
    final connectivityService = ConnectivityService();
    if (connectivityService.canPerformOnlineOperation()) {
      try {
        final apiService = ApiService();
        final response = await apiService.get<List<dynamic>>(
          '${AppConfig.promesseEndpoint}/agent/$agentId',
        );
        final promesses = response.map((j) => PromessePaiementDto.fromJson(j)).toList();
        _promesses.clear();
        _promesses.addAll(promesses);
        return promesses;
      } catch (e) {
        _logger.e('Erreur chargement promesses: $e');
      }
    }
    return _promesses.where((p) => p.agentId == agentId).toList();
  }

  Future<List<PromessePaiementDto>> getPromessesEcheanceToday() async {
    return _promesses.where((p) => p.isEcheanceToday && p.statut == 'EN_ATTENTE').toList();
  }

  Future<List<PromessePaiementDto>> getPromessesEnRetard() async {
    return _promesses.where((p) => p.isEcheancePassee && p.statut == 'EN_ATTENTE').toList();
  }

  Future<void> marquerRealisee(String promesseId) async {
    final index = _promesses.indexWhere((p) => p.id == promesseId);
    if (index != -1) {
      final updated = PromessePaiementDto(
        id: _promesses[index].id,
        contribuableId: _promesses[index].contribuableId,
        contribuableNom: _promesses[index].contribuableNom,
        contribuablePrenom: _promesses[index].contribuablePrenom,
        agentId: _promesses[index].agentId,
        agentNom: _promesses[index].agentNom,
        montant: _promesses[index].montant,
        datePromesse: _promesses[index].datePromesse,
        observation: _promesses[index].observation,
        statut: 'REALISEE',
        createdAt: _promesses[index].createdAt,
      );
      _promesses[index] = updated;
      await _savePromesseOffline(updated);
    }
  }

  Future<void> syncPromesses() async {
    final connectivityService = ConnectivityService();
    if (!connectivityService.canPerformOnlineOperation()) return;

    final storageService = StorageService();
    final keys = await storageService.getOfflineDataKeys();
    final promesseKeys = keys.where((k) => k.startsWith('promesse_'));

    for (final key in promesseKeys) {
      final data = await storageService.getOfflineData(key);
      if (data != null && data['syncStatus'] == 'PENDING') {
        try {
          final apiService = ApiService();
          await apiService.post(
            AppConfig.promesseEndpoint,
            data: data,
          );
          data['syncStatus'] = 'SYNCED';
          data['syncedAt'] = DateTime.now().toIso8601String();
          await storageService.storeOfflineData(key, data);
        } catch (e) {
          _logger.e('Erreur sync promesse $key: $e');
        }
      }
    }
  }

  Future<void> _savePromesseOffline(PromessePaiementDto promesse) async {
    final storageService = StorageService();
    await storageService.storeOfflineData('promesse_${promesse.id}', promesse.toJson());
  }
}
