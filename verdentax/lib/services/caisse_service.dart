import 'dart:convert';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'connectivity_service.dart';

class CaisseService {
  static final CaisseService _instance = CaisseService._internal();
  factory CaisseService() => _instance;
  CaisseService._internal();

  final Logger _logger = Logger();
  CaisseDto? _caisseToday;

  CaisseDto? get caisseToday => _caisseToday;

  Future<CaisseDto> ouvrirCaisse({
    required int agentId,
    String? agentNom,
    required double soldeInitial,
  }) async {
    final caisse = CaisseDto(
      id: 'caisse_${DateTime.now().millisecondsSinceEpoch}',
      agentId: agentId,
      agentNom: agentNom,
      date: DateTime.now(),
      soldeInitial: soldeInitial,
      statut: CaisseStatut.ouverte,
      createdAt: DateTime.now(),
    );

    _caisseToday = caisse;
    await _saveCaisseOffline(caisse);
    _logger.i('Caisse ouverte: solde initial $soldeInitial FCFA');
    return caisse;
  }

  Future<void> encaisserEspece(double montant) async {
    if (_caisseToday == null || !_caisseToday!.isOuverte) return;
    _caisseToday = _caisseToday!.copyWith(
      especeCollecte: _caisseToday!.especeCollecte + montant,
    );
    await _saveCaisseOffline(_caisseToday!);
  }

  Future<void> encaisserMobileMoney(double montant) async {
    if (_caisseToday == null || !_caisseToday!.isOuverte) return;
    _caisseToday = _caisseToday!.copyWith(
      mobileMoneyCollecte: _caisseToday!.mobileMoneyCollecte + montant,
    );
    await _saveCaisseOffline(_caisseToday!);
  }

  Future<CaisseDto> cloturerCaisse({
    required double montantDeclare,
    String? commentaireAgent,
  }) async {
    if (_caisseToday == null) throw Exception('Aucune caisse ouverte');

    final updated = _caisseToday!.copyWith(
      statut: CaisseStatut.soumise,
      montantDeclare: montantDeclare,
      commentaireAgent: commentaireAgent,
      clotureeAt: DateTime.now(),
    );

    _caisseToday = updated;
    await _saveCaisseOffline(updated);

    final connectivityService = ConnectivityService();
    if (connectivityService.canPerformOnlineOperation()) {
      try {
        final apiService = ApiService();
        await apiService.post(
          '${AppConfig.clotureCaisseEndpoint}/initier',
          data: updated.toJson(),
        );
        _caisseToday = updated.copyWith(syncStatus: 'SYNCED');
        await _saveCaisseOffline(_caisseToday!);
      } catch (e) {
        _logger.e('Erreur sync caisse: $e');
      }
    }

    _logger.i('Caisse clôturée: ${updated.totalCollecte} FCFA');
    return updated;
  }

  Future<CaisseDto?> getCaisseToday(int agentId) async {
    if (_caisseToday != null) return _caisseToday;

    final storageService = StorageService();
    final data = await storageService.getOfflineData('caisse_today');
    if (data != null) {
      _caisseToday = CaisseDto.fromJson(data);
      return _caisseToday;
    }

    final connectivityService = ConnectivityService();
    if (connectivityService.canPerformOnlineOperation()) {
      try {
        final apiService = ApiService();
        final response = await apiService.get<Map<String, dynamic>>(
          '${AppConfig.clotureCaisseEndpoint}/agent/$agentId',
        );
        _caisseToday = CaisseDto.fromJson(response);
        return _caisseToday;
      } catch (e) {
        _logger.e('Erreur chargement caisse: $e');
      }
    }
    return null;
  }

  Future<void> _saveCaisseOffline(CaisseDto caisse) async {
    final storageService = StorageService();
    await storageService.storeOfflineData('caisse_today', caisse.toJson());
  }
}
