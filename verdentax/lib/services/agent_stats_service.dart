import 'package:logger/logger.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'connectivity_service.dart';
import 'visite_service.dart';

enum StatsPeriod { aujourdHui, semaine, mois }

class AgentStatsService {
  static final AgentStatsService _instance = AgentStatsService._internal();
  factory AgentStatsService() => _instance;
  AgentStatsService._internal();

  final Logger _logger = Logger();

  Future<AgentStats> getStats(int agentId, StatsPeriod period) async {
    final now = DateTime.now();
    DateTime start;
    switch (period) {
      case StatsPeriod.aujourdHui:
        start = DateTime(now.year, now.month, now.day);
        break;
      case StatsPeriod.semaine:
        start = now.subtract(const Duration(days: 7));
        break;
      case StatsPeriod.mois:
        start = DateTime(now.year, now.month, 1);
        break;
    }

    try {
      final apiService = ApiService();
      final transactions = await apiService.getTransactionsByAgent(agentId);

      final periodTx = transactions.where((t) =>
        t.dateCreation != null && t.dateCreation!.isAfter(start)
      ).toList();

      final visites = VisiteService().visites.where((v) =>
        v.dateVisite != null && v.dateVisite!.isAfter(start)
      ).toList();

      final totalCollecte = periodTx.fold<double>(0, (sum, t) => sum + t.montant);
      final nbPaiements = periodTx.length;
      final nbVisites = visites.length;
      final nbPayes = periodTx.where((t) => t.statut == TransactionStatus.validee).length;
      final tauxReussite = nbPaiements > 0 ? (nbPayes / nbPaiements * 100) : 0.0;

      final espece = periodTx
          .where((t) => t.modePaiement == ModePaiement.espece)
          .fold<double>(0, (sum, t) => sum + t.montant);
      final mobileMoney = periodTx
          .where((t) => t.modePaiement != ModePaiement.espece)
          .fold<double>(0, (sum, t) => sum + t.montant);

      return AgentStats(
        period: period,
        totalCollecte: totalCollecte,
        nbPaiements: nbPaiements,
        nbVisites: nbVisites,
        nbPayes: nbPayes,
        tauxReussite: tauxReussite,
        especeCollecte: espece,
        mobileMoneyCollecte: mobileMoney,
        nbContribuablesVisites: visites.map((v) => v.contribuableId).toSet().length,
      );
    } catch (e) {
      _logger.e('Erreur calcul stats: $e');
      return AgentStats(period: period);
    }
  }
}

class AgentStats {
  final StatsPeriod period;
  final double totalCollecte;
  final int nbPaiements;
  final int nbVisites;
  final int nbPayes;
  final double tauxReussite;
  final double especeCollecte;
  final double mobileMoneyCollecte;
  final int nbContribuablesVisites;

  AgentStats({
    required this.period,
    this.totalCollecte = 0,
    this.nbPaiements = 0,
    this.nbVisites = 0,
    this.nbPayes = 0,
    this.tauxReussite = 0,
    this.especeCollecte = 0,
    this.mobileMoneyCollecte = 0,
    this.nbContribuablesVisites = 0,
  });
}
