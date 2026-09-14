import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class AgentTourneeScreen extends StatefulWidget {
  const AgentTourneeScreen({super.key});

  @override
  State<AgentTourneeScreen> createState() => _AgentTourneeScreenState();
}

class _AgentTourneeScreenState extends State<AgentTourneeScreen> {
  final Logger _logger = Logger();
  bool _isLoading = true;
  bool _isOptimizing = false;
  TourneeDto? _tournee;
  List<ContribuableDto> _allContribuables = [];

  @override
  void initState() {
    super.initState();
    _loadTournee();
  }

  Future<void> _loadTournee() async {
    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      final agentId = int.tryParse(user?.id ?? '') ?? 0;

      final tourneeService = TourneeService();
      final existing = await tourneeService.getTodayTournee(agentId);

      if (existing != null) {
        if (mounted) setState(() { _tournee = existing; _isLoading = false; });
        return;
      }

      // Generate from contribuables
      final apiService = ApiService();
      _allContribuables = await apiService.getAllContribuables();

      final tournee = await tourneeService.generateTournee(
        agentId: agentId,
        agentNom: user?.fullName,
        contribuables: _allContribuables.take(20).toList(),
      );

      if (mounted) setState(() { _tournee = tournee; _isLoading = false; });
    } catch (e) {
      _logger.e('Erreur chargement tournée: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _statutColor(TourneeStatut statut) {
    switch (statut) {
      case TourneeStatut.aVisiter: return Colors.blue;
      case TourneeStatut.enCours: return Colors.orange;
      case TourneeStatut.visite: return Colors.teal;
      case TourneeStatut.paye: return Colors.green;
      case TourneeStatut.paiementPartiel: return Colors.amber;
      case TourneeStatut.refus: return Colors.red;
      case TourneeStatut.absent: return Colors.grey;
      case TourneeStatut.aRevoir: return Colors.purple;
      case TourneeStatut.introuvable: return Colors.brown;
    }
  }

  Future<void> _optimizeItineraire() async {
    setState(() => _isOptimizing = true);
    try {
      final tourneeService = TourneeService();
      final optimized = await tourneeService.optimizeItineraire();
      if (optimized != null && mounted) {
        setState(() { _tournee = optimized; _isOptimizing = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Itinéraire optimisé par proximité GPS')),
        );
      } else if (mounted) {
        setState(() => _isOptimizing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Position GPS non disponible')),
        );
      }
    } catch (e) {
      _logger.e('Erreur optimisation: $e');
      if (mounted) setState(() => _isOptimizing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
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
        title: const Text('Ma tournée'),
        actions: [
          if (_isOptimizing)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(Icons.route),
              tooltip: 'Optimiser l\'itinéraire',
              onPressed: _tournee != null ? _optimizeItineraire : null,
            ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTournee),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tournee == null
              ? Center(child: Text('Aucune tournée', style: TextStyle(fontSize: 14.sp)))
              : Column(
                  children: [
                    // Progress header
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.h),
                      margin: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Progression', style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: LinearProgressIndicator(
                                    value: _tournee!.totalItems > 0
                                        ? _tournee!.visites / _tournee!.totalItems
                                        : 0,
                                    backgroundColor: Colors.white.withOpacity(0.3),
                                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                                    minHeight: 8.h,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                '${_tournee!.visites}/${_tournee!.totalItems}',
                                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _chip('Payés: ${_tournee!.payes}', Colors.green),
                              _chip('Restants: ${_tournee!.restants}', Colors.orange),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Items list
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        itemCount: _tournee!.items.length,
                        itemBuilder: (context, index) {
                          final item = _tournee!.items[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 6.h),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _statutColor(item.statut).withOpacity(0.15),
                                child: Text('${item.ordre}', style: TextStyle(fontWeight: FontWeight.bold, color: _statutColor(item.statut))),
                              ),
                              title: Text(item.fullName, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                item.quartier ?? item.adresse ?? 'Adresse N/A',
                                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                              ),
                              trailing: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: _statutColor(item.statut).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  item.statut.label,
                                  style: TextStyle(fontSize: 10.sp, color: _statutColor(item.statut)),
                                ),
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/agent-contribuable-detail',
                                  arguments: ContribuableDto(
                                    id: item.contribuableId,
                                    nom: item.contribuableNom,
                                    prenom: item.contribuablePrenom ?? '',
                                    adresse: item.adresse,
                                    quartier: item.quartier,
                                    latitude: item.latitude,
                                    longitude: item.longitude,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(text, style: TextStyle(color: Colors.white, fontSize: 11.sp)),
    );
  }
}
