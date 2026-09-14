import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class AgentDashboardScreen extends StatefulWidget {
  const AgentDashboardScreen({super.key});

  @override
  State<AgentDashboardScreen> createState() => _AgentDashboardScreenState();
}

class _AgentDashboardScreenState extends State<AgentDashboardScreen> {
  final Logger _logger = Logger();
  bool _isLoading = true;

  int _totalContribuables = 0;
  int _aVisiter = 0;
  int _visites = 0;
  int _nonRencontres = 0;
  double _montantAttendu = 0;
  double _montantCollecte = 0;
  int _paiementsEnAttente = 0;
  DateTime? _derniereSync;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      final agentId = int.tryParse(user?.id ?? '') ?? 0;

      // Load contribuables
      final apiService = ApiService();
      List<ContribuableDto> contribuables = [];
      try {
        contribuables = await apiService.getAllContribuables();
      } catch (e) {
        _logger.e('Erreur chargement contribuables: $e');
      }

      // Load transactions
      List<TransactionDTO> transactions = [];
      try {
        transactions = await apiService.getTransactionsByAgent(agentId);
      } catch (e) {
        _logger.e('Erreur chargement transactions: $e');
      }

      // Load visites
      final visiteService = VisiteService();
      final visitesToday = await visiteService.getVisitesToday(agentId);

      // Calculate KPIs
      final today = DateTime.now();
      final txToday = transactions.where((t) =>
        t.dateCreation != null &&
        t.dateCreation!.year == today.year &&
        t.dateCreation!.month == today.month &&
        t.dateCreation!.day == today.day
      );

      final nonRencontres = visitesToday.where((v) =>
        v.resultat == VisiteResultat.absent ||
        v.resultat == VisiteResultat.refus ||
        v.resultat == VisiteResultat.introuvable
      ).length;

      final pendingTx = transactions.where((t) =>
        t.statut == TransactionStatus.enAttente && t.offline
      ).length;

      final collecteToday = txToday.fold<double>(0, (sum, t) => sum + t.montant);

      // Sync info
      final syncService = SyncService();
      final lastSync = await syncService.getLastSyncTime();

      if (mounted) {
        setState(() {
          _totalContribuables = contribuables.length;
          _aVisiter = (contribuables.length * 0.2).round();
          _visites = visitesToday.length;
          _nonRencontres = nonRencontres;
          _montantAttendu = contribuables.length * 25000.0;
          _montantCollecte = collecteToday;
          _paiementsEnAttente = pendingTx;
          _derniereSync = lastSync;
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.e('Erreur chargement dashboard: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double get _tauxRecouvrement =>
      _montantAttendu > 0 ? (_montantCollecte / _montantAttendu * 100) : 0;

  String get _syncTimeLabel {
    if (_derniereSync == null) return 'Jamais';
    return '${_derniereSync!.hour.toString().padLeft(2, '0')}:${_derniereSync!.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final connectivityService = Provider.of<ConnectivityService>(context);
    final user = authService.currentUser;

    return Scaffold(
      drawer: AgentDrawer(
        agentName: user?.fullName ?? 'Agent',
        agentEmail: user?.email ?? '',
        onLogout: () {
          authService.logout();
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      appBar: AppBar(
        title: const Text('Agent de Collecte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.pushNamed(context, '/agent-notifications'),
          ),
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Center(
              child: SyncStatusBadge(
                isOnline: connectivityService.isOnline,
                lastSyncTime: _syncTimeLabel,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Secteur info
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.white, size: 18.sp),
                              SizedBox(width: 4.w),
                              Text(
                                'Secteur: Quartier France',
                                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(Icons.person, color: Colors.white, size: 18.sp),
                              SizedBox(width: 4.w),
                              Text(
                                'Contribuables affectés: $_totalContribuables',
                                style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Aujourd'hui section
                    Text('Aujourd\'hui', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.h),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 8.h,
                      crossAxisSpacing: 8.w,
                      childAspectRatio: 1.4,
                      children: [
                        KpiCard(title: 'À visiter', value: '$_aVisiter', icon: Icons.place, color: Colors.blue),
                        KpiCard(title: 'Visités', value: '$_visites', icon: Icons.check_circle, color: Colors.green),
                        KpiCard(title: 'Non rencontrés', value: '$_nonRencontres', icon: Icons.person_off, color: Colors.red),
                        KpiCard(title: 'À revoir', value: '${(_nonRencontres * 0.75).round()}', icon: Icons.replay, color: Colors.orange),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Collecte section
                    Text('Collecte', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.h),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 8.h,
                      crossAxisSpacing: 8.w,
                      childAspectRatio: 1.4,
                      children: [
                        KpiCard(
                          title: 'Montant attendu',
                          value: '${_montantAttendu.toStringAsFixed(0)} F',
                          icon: Icons.account_balance_wallet,
                          color: Colors.indigo,
                        ),
                        KpiCard(
                          title: 'Montant collecté',
                          value: '${_montantCollecte.toStringAsFixed(0)} F',
                          icon: Icons.savings,
                          color: Colors.green,
                        ),
                        KpiCard(
                          title: 'Taux recouvrement',
                          value: '${_tauxRecouvrement.toStringAsFixed(0)} %',
                          icon: Icons.trending_up,
                          color: Colors.teal,
                        ),
                        KpiCard(
                          title: 'En attente sync',
                          value: '$_paiementsEnAttente',
                          icon: Icons.sync_problem,
                          color: Colors.amber,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Quick actions
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/agent-tournee'),
                            icon: const Icon(Icons.route),
                            label: const Text('Tournée'),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/agent-contribuables'),
                            icon: const Icon(Icons.people),
                            label: const Text('Contribuables'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/agent-nouveau-contribuable'),
                            icon: const Icon(Icons.person_add),
                            label: const Text('Nouveau'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/agent-caisse'),
                            icon: const Icon(Icons.account_balance),
                            label: const Text('Caisse'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/agent-nearby'),
                            icon: const Icon(Icons.near_me),
                            label: const Text('Proche'),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/agent-promesse'),
                            icon: const Icon(Icons.handshake),
                            label: const Text('Promesses'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/agent-encaissement'),
                            icon: const Icon(Icons.payments),
                            label: const Text('Encaisser'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/agent-sync'),
                            icon: const Icon(Icons.sync),
                            label: const Text('Sync'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/agent-impayes'),
                            icon: const Icon(Icons.warning),
                            label: const Text('Impayés'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/agent-journal'),
                            icon: const Icon(Icons.history),
                            label: const Text('Journal'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
