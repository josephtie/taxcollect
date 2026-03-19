import 'dart:async';
import 'dart:math';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';
import 'api_service.dart';

/// Service pour gérer les transactions et leurs relations
class TransactionService {
  static final TransactionService _instance = TransactionService._internal();
  factory TransactionService() => _instance;
  TransactionService._internal();

  final Logger _logger = Logger();
  final Random _random = Random();
  
  // Cache pour les données de transactions
  final List<TransactionDTO> _transactionsCache = [];
  
  // Initialize the service
  Future<void> initialize() async {
    try {
      _logger.i('Initializing TransactionService...');
      
      _logger.i('TransactionService initialized successfully');
    } catch (e) {
      _logger.e('Error initializing TransactionService: $e');
      rethrow;
    }
  }
  
  /// Créer une nouvelle transaction
  Future<TransactionDTO> createTransaction({
    required double montant,
    required int contribuableId,
    required int agentId,
    required int zoneId,
    required ModePaiement modePaiement,
    String? referencePaiement,
    double? latitude,
    double? longitude,
    String? adresseCollecte,
    bool offline = false,
    String? contribuableNom,
    String? contribuablePrenom,
    String? agentNom,
    String? agentPrenom,
    String? zoneNom,
  }) async {
    try {
      // Validation des données
      _validateTransactionData(montant, contribuableId, agentId, zoneId);
      
      // Génération du numéro de reçu
      final numeroRecu = _generateNumeroRecu();
      
      // Génération du hash de transaction
      final hashTransaction = _generateTransactionHash(montant, contribuableId, agentId);
      
      final transaction = TransactionDTO(
        numeroRecu: numeroRecu,
        montant: montant,
        contribuableId: contribuableId,
        agentId: agentId,
        zoneId: zoneId,
        modePaiement: modePaiement,
        statut: TransactionStatus.enAttente,
        referencePaiement: referencePaiement,
        hashTransaction: hashTransaction,
        latitude: latitude,
        longitude: longitude,
        adresseCollecte: adresseCollecte,
        offline: offline,
        dateCreation: DateTime.now(),
        contribuableNom: contribuableNom,
        contribuablePrenom: contribuablePrenom,
        agentNom: agentNom,
        agentPrenom: agentPrenom,
        zoneNom: zoneNom,
      );
      
      final apiService = ApiService();
      final createdTransaction = await apiService.createTransaction(transaction);
      
      _logger.i('Created transaction: ${createdTransaction.numeroRecu}');
      return createdTransaction;
    } catch (e) {
      _logger.e('Error creating transaction: $e');
      rethrow;
    }
  }
  
  /// Obtenir une transaction par ID
  Future<TransactionDTO?> getTransactionById(int id) async {
    try {
      final apiService = ApiService();
      return await apiService.getTransactionById(id);
    } catch (e) {
      _logger.e('Error getting transaction $id: $e');
      return null;
    }
  }
  
  /// Obtenir une transaction par numéro de reçu
  Future<TransactionDTO?> getTransactionByNumeroRecu(String numeroRecu) async {
    try {
      final apiService = ApiService();
      return await apiService.getTransactionByNumeroRecu(numeroRecu);
    } catch (e) {
      _logger.e('Error getting transaction by receipt $numeroRecu: $e');
      return null;
    }
  }
  
  /// Obtenir les transactions d'un agent
  Future<List<TransactionDTO>> getTransactionsByAgent(int agentId) async {
    try {
      final apiService = ApiService();
      return await apiService.getTransactionsByAgent(agentId);
    } catch (e) {
      _logger.e('Error getting transactions for agent $agentId: $e');
      return [];
    }
  }
  
  /// Obtenir les transactions d'un agent par période
  Future<List<TransactionDTO>> getTransactionsByAgentAndDateRange(
    int agentId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final apiService = ApiService();
      return await apiService.getTransactionsByAgentAndDateRange(
        agentId,
        startDate,
        endDate,
      );
    } catch (e) {
      _logger.e('Error getting transactions for agent $agentId in date range: $e');
      return [];
    }
  }
  
  /// Obtenir les transactions d'un contribuable
  Future<List<TransactionDTO>> getTransactionsByContribuable(int contribuableId) async {
    try {
      final apiService = ApiService();
      final response = await apiService.get<List<dynamic>>(
        '${AppConfig.transactionsEndpoint}/contribuable/$contribuableId',
      );
      return response.map((json) => TransactionDTO.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Error getting transactions for contribuable $contribuableId: $e');
      return [];
    }
  }
  
  /// Mettre à jour le statut d'une transaction
  Future<TransactionDTO> updateTransactionStatus(int id, TransactionStatus status) async {
    try {
      final apiService = ApiService();
      return await apiService.updateTransactionStatus(id, status.code);
    } catch (e) {
      _logger.e('Error updating transaction status $id: $e');
      rethrow;
    }
  }
  
  /// Valider une transaction
  Future<TransactionDTO> validateTransaction(int id) async {
    try {
      return await updateTransactionStatus(id, TransactionStatus.validee);
    } catch (e) {
      _logger.e('Error validating transaction $id: $e');
      rethrow;
    }
  }
  
  /// Annuler une transaction
  Future<TransactionDTO> cancelTransaction(int id, {String? motif}) async {
    try {
      final apiService = ApiService();
      final response = await apiService.put<TransactionDTO>(
        '${AppConfig.transactionsEndpoint}/$id/cancel',
        data: {'motif': motif},
      );
      return response;
    } catch (e) {
      _logger.e('Error cancelling transaction $id: $e');
      rethrow;
    }
  }
  
  /// Synchroniser une transaction
  Future<TransactionDTO> synchronizeTransaction(int id) async {
    try {
      final apiService = ApiService();
      return await apiService.synchronizeTransaction(id);
    } catch (e) {
      _logger.e('Error synchronizing transaction $id: $e');
      rethrow;
    }
  }
  
  /// Synchroniser toutes les transactions offline
  Future<List<TransactionDTO>> synchronizeAllOfflineTransactions() async {
    try {
      final apiService = ApiService();
      return await apiService.synchronizeAllOfflineTransactions();
    } catch (e) {
      _logger.e('Error synchronizing offline transactions: $e');
      return [];
    }
  }
  
  /// Obtenir les transactions offline
  Future<List<TransactionDTO>> getOfflineTransactions() async {
    try {
      final apiService = ApiService();
      final response = await apiService.get<List<dynamic>>(
        '${AppConfig.transactionsEndpoint}/offline',
      );
      return response.map((json) => TransactionDTO.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Error getting offline transactions: $e');
      return [];
    }
  }
  
  /// Obtenir les statistiques des transactions
  Future<TransactionStatistics> getStatistics({
    int? agentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final apiService = ApiService();
      Map<String, dynamic> queryParams = {};
      
      if (agentId != null) queryParams['agentId'] = agentId.toString();
      if (startDate != null) queryParams['debut'] = startDate.toIso8601String();
      if (endDate != null) queryParams['fin'] = endDate.toIso8601String();
      
      final response = await apiService.get<TransactionStatistics>(
        '${AppConfig.transactionsEndpoint}/statistics',
        queryParameters: queryParams,
      );
      return response;
    } catch (e) {
      _logger.e('Error getting transaction statistics: $e');
      return TransactionStatistics(
        totalTransactions: 0,
        totalMontant: 0.0,
        transactionsValidees: 0,
        transactionsEnAttente: 0,
        transactionsAnnulees: 0,
        moyenneMontant: 0.0,
        montantTotalEspece: 0.0,
        montantTotalMobileMoney: 0.0,
        montantTotalQRCode: 0.0,
      );
    }
  }
  
  /// Obtenir les transactions par période
  Future<List<TransactionDTO>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? agentId,
    TransactionStatus? status,
  }) async {
    try {
      final apiService = ApiService();
      Map<String, dynamic> queryParams = {
        'debut': startDate.toIso8601String(),
        'fin': endDate.toIso8601String(),
      };
      
      if (agentId != null) queryParams['agentId'] = agentId.toString();
      if (status != null) queryParams['statut'] = status.code;
      
      final response = await apiService.get<List<dynamic>>(
        '${AppConfig.transactionsEndpoint}/range',
        queryParameters: queryParams,
      );
      return response.map((json) => TransactionDTO.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Error getting transactions in date range: $e');
      return [];
    }
  }
  
  /// Rechercher des transactions
  Future<List<TransactionDTO>> searchTransactions({
    String? numeroRecu,
    String? contribuableNom,
    String? agentNom,
    double? minMontant,
    double? maxMontant,
    DateTime? startDate,
    DateTime? endDate,
    TransactionStatus? status,
    ModePaiement? modePaiement,
  }) async {
    try {
      final apiService = ApiService();
      Map<String, dynamic> queryParams = {};
      
      if (numeroRecu != null) queryParams['numeroRecu'] = numeroRecu;
      if (contribuableNom != null) queryParams['contribuableNom'] = contribuableNom;
      if (agentNom != null) queryParams['agentNom'] = agentNom;
      if (minMontant != null) queryParams['minMontant'] = minMontant.toString();
      if (maxMontant != null) queryParams['maxMontant'] = maxMontant.toString();
      if (startDate != null) queryParams['debut'] = startDate.toIso8601String();
      if (endDate != null) queryParams['fin'] = endDate.toIso8601String();
      if (status != null) queryParams['statut'] = status.code;
      if (modePaiement != null) queryParams['modePaiement'] = modePaiement.code;
      
      final response = await apiService.get<List<dynamic>>(
        '${AppConfig.transactionsEndpoint}/search',
        queryParameters: queryParams,
      );
      return response.map((json) => TransactionDTO.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Error searching transactions: $e');
      return [];
    }
  }
  
  // Private methods
  
  void _validateTransactionData(double montant, int contribuableId, int agentId, int zoneId) {
    if (montant <= 0) {
      throw Exception('Le montant doit être supérieur à 0');
    }
    
    if (contribuableId <= 0) {
      throw Exception('L\'ID du contribuable est invalide');
    }
    
    if (agentId <= 0) {
      throw Exception('L\'ID de l\'agent est invalide');
    }
    
    if (zoneId <= 0) {
      throw Exception('L\'ID de la zone est invalide');
    }
    
    if (montant > 999999999) {
      throw Exception('Le montant est trop élevé');
    }
  }
  
  String _generateNumeroRecu() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _random.nextInt(10000);
    return 'VTX${timestamp.toString().substring(-6)}${random.toString().padLeft(4, '0')}';
  }
  
  String _generateTransactionHash(double montant, int contribuableId, int agentId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = '$montant-$contribuableId-$agentId-$timestamp';
    return data.hashCode.toString();
  }
  
  /// Rafraîchir le cache
  void refreshCache() {
    _transactionsCache.clear();
  }
}

/// Statistiques des transactions
class TransactionStatistics {
  final int totalTransactions;
  final double totalMontant;
  final int transactionsValidees;
  final int transactionsEnAttente;
  final int transactionsAnnulees;
  final double moyenneMontant;
  final double montantTotalEspece;
  final double montantTotalMobileMoney;
  final double montantTotalQRCode;
  
  TransactionStatistics({
    required this.totalTransactions,
    required this.totalMontant,
    required this.transactionsValidees,
    required this.transactionsEnAttente,
    required this.transactionsAnnulees,
    required this.moyenneMontant,
    required this.montantTotalEspece,
    required this.montantTotalMobileMoney,
    required this.montantTotalQRCode,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'totalTransactions': totalTransactions,
      'totalMontant': totalMontant,
      'transactionsValidees': transactionsValidees,
      'transactionsEnAttente': transactionsEnAttente,
      'transactionsAnnulees': transactionsAnnulees,
      'moyenneMontant': moyenneMontant,
      'montantTotalEspece': montantTotalEspece,
      'montantTotalMobileMoney': montantTotalMobileMoney,
      'montantTotalQRCode': montantTotalQRCode,
    };
  }
  
  factory TransactionStatistics.fromJson(Map<String, dynamic> json) {
    return TransactionStatistics(
      totalTransactions: json['totalTransactions'] ?? 0,
      totalMontant: (json['totalMontant'] ?? 0).toDouble(),
      transactionsValidees: json['transactionsValidees'] ?? 0,
      transactionsEnAttente: json['transactionsEnAttente'] ?? 0,
      transactionsAnnulees: json['transactionsAnnulees'] ?? 0,
      moyenneMontant: (json['moyenneMontant'] ?? 0).toDouble(),
      montantTotalEspece: (json['montantTotalEspece'] ?? 0).toDouble(),
      montantTotalMobileMoney: (json['montantTotalMobileMoney'] ?? 0).toDouble(),
      montantTotalQRCode: (json['montantTotalQRCode'] ?? 0).toDouble(),
    );
  }
}

// Extension on TransactionDTO
