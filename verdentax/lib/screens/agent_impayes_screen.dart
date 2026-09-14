import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class AgentImpayesScreen extends StatefulWidget {
  const AgentImpayesScreen({super.key});

  @override
  State<AgentImpayesScreen> createState() => _AgentImpayesScreenState();
}

class _AgentImpayesScreenState extends State<AgentImpayesScreen> {
  final Logger _logger = Logger();
  bool _isLoading = true;
  List<TransactionDTO> _impayes = [];

  @override
  void initState() {
    super.initState();
    _loadImpayes();
  }

  Future<void> _loadImpayes() async {
    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      final agentId = int.tryParse(user?.id ?? '') ?? 0;

      final apiService = ApiService();
      final allTx = await apiService.getTransactionsByAgent(agentId);
      final impayes = allTx.where((t) =>
        t.statut == TransactionStatus.enAttente ||
        t.statut == TransactionStatus.enErreur
      ).toList();

      if (mounted) {
        setState(() {
          _impayes = impayes;
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.e('Erreur chargement impayés: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double get _total => _impayes.fold(0, (sum, t) => sum + t.montant);

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
        title: const Text('Impayés'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadImpayes),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Total
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.h),
                  margin: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TOTAL', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                      Text('${_total.toStringAsFixed(0)} F', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.red.shade800)),
                    ],
                  ),
                ),
                // List
                Expanded(
                  child: _impayes.isEmpty
                      ? Center(child: Text('Aucun impayé', style: TextStyle(fontSize: 14.sp, color: Colors.grey)))
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          itemCount: _impayes.length,
                          itemBuilder: (context, index) {
                            final tx = _impayes[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 8.h),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red.withOpacity(0.1),
                                  child: Icon(Icons.warning, color: Colors.red, size: 20.sp),
                                ),
                                title: Text(tx.contribuableFullName, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                                subtitle: Text('${tx.montant.toStringAsFixed(0)} FCFA', style: TextStyle(fontSize: 13.sp, color: Colors.red.shade700)),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (action) {
                                    switch (action) {
                                      case 'encaisser':
                                        Navigator.pushNamed(context, '/agent-encaissement');
                                        break;
                                      case 'visiter':
                                        Navigator.pushNamed(context, '/agent-visite');
                                        break;
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'encaisser', child: Text('Encaisser')),
                                    const PopupMenuItem(value: 'visiter', child: Text('Visiter')),
                                    const PopupMenuItem(value: 'relancer', child: Text('Relancer')),
                                    const PopupMenuItem(value: 'promesse', child: Text('Promesse')),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
