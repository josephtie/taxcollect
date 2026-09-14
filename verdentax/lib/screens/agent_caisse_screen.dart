import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class AgentCaisseScreen extends StatefulWidget {
  const AgentCaisseScreen({super.key});

  @override
  State<AgentCaisseScreen> createState() => _AgentCaisseScreenState();
}

class _AgentCaisseScreenState extends State<AgentCaisseScreen> {
  final Logger _logger = Logger();
  bool _isLoading = true;
  CaisseDto? _caisse;
  final _soldeInitialController = TextEditingController();
  final _montantDeclareController = TextEditingController();
  final _commentaireController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCaisse();
  }

  @override
  void dispose() {
    _soldeInitialController.dispose();
    _montantDeclareController.dispose();
    _commentaireController.dispose();
    super.dispose();
  }

  Future<void> _loadCaisse() async {
    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      final agentId = int.tryParse(user?.id ?? '') ?? 0;

      final caisseService = CaisseService();
      final caisse = await caisseService.getCaisseToday(agentId);
      if (mounted) {
        setState(() { _caisse = caisse; _isLoading = false; });
        if (caisse != null) {
          _montantDeclareController.text = caisse.totalCollecte.toStringAsFixed(0);
        }
      }
    } catch (e) {
      _logger.e('Erreur chargement caisse: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _ouvrirCaisse() async {
    final solde = double.tryParse(_soldeInitialController.text) ?? 0;
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    final agentId = int.tryParse(user?.id ?? '') ?? 0;

    final caisseService = CaisseService();
    final caisse = await caisseService.ouvrirCaisse(
      agentId: agentId,
      agentNom: user?.fullName,
      soldeInitial: solde,
    );
    setState(() => _caisse = caisse);
  }

  Future<void> _cloturerCaisse() async {
    final montantDeclare = double.tryParse(_montantDeclareController.text);
    if (montantDeclare == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant déclaré invalide')),
      );
      return;
    }

    final caisseService = CaisseService();
    final caisse = await caisseService.cloturerCaisse(
      montantDeclare: montantDeclare,
      commentaireAgent: _commentaireController.text.trim().isEmpty ? null : _commentaireController.text.trim(),
    );

    final ecart = caisse.ecart;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ecart.abs() < 1
                ? 'Caisse clôturée — Écart: 0 FCFA ✓'
                : 'Caisse clôturée — Écart: ${ecart.toStringAsFixed(0)} FCFA',
          ),
        ),
      );
      setState(() => _caisse = caisse);
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
      appBar: AppBar(title: const Text('Caisse')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_caisse == null) ...[
                    // Open caisse form
                    Text('Ouverture de caisse', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: _soldeInitialController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Solde initial (FCFA)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _ouvrirCaisse,
                        icon: const Icon(Icons.lock_open),
                        label: const Text('OUVRIR LA CAISSE'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Status card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _caisse!.isOuverte
                              ? [Colors.green, Colors.green.withOpacity(0.7)]
                              : [Colors.orange, Colors.orange.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(_caisse!.isOuverte ? Icons.lock_open : Icons.lock, color: Colors.white, size: 20.sp),
                              SizedBox(width: 8.w),
                              Text(_caisse!.statut.label, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text('Date: ${_caisse!.date.day}/${_caisse!.date.month}/${_caisse!.date.year}', style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // KPIs
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 8.h,
                      crossAxisSpacing: 8.w,
                      childAspectRatio: 1.5,
                      children: [
                        KpiCard(title: 'Solde initial', value: '${_caisse!.soldeInitial.toStringAsFixed(0)} F', icon: Icons.account_balance, color: Colors.indigo),
                        KpiCard(title: 'Espèces', value: '${_caisse!.especeCollecte.toStringAsFixed(0)} F', icon: Icons.money, color: Colors.green),
                        KpiCard(title: 'Mobile Money', value: '${_caisse!.mobileMoneyCollecte.toStringAsFixed(0)} F', icon: Icons.phone_android, color: Colors.blue),
                        KpiCard(title: 'Total collecté', value: '${_caisse!.totalCollecte.toStringAsFixed(0)} F', icon: Icons.savings, color: Colors.teal),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    if (_caisse!.isOuverte) ...[
                      // Cloture form
                      Text('Clôture de caisse', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 12.h),
                      TextField(
                        controller: _montantDeclareController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Montant déclaré (FCFA)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _commentaireController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Commentaire (optionnel)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      if (_montantDeclareController.text.isNotEmpty)
                        Builder(builder: (context) {
                          final declared = double.tryParse(_montantDeclareController.text) ?? 0;
                          final ecart = declared - _caisse!.totalCollecte;
                          return Text(
                            'Écart: ${ecart.toStringAsFixed(0)} FCFA',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: ecart.abs() < 1 ? Colors.green : Colors.red,
                            ),
                          );
                        }),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _cloturerCaisse,
                          icon: const Icon(Icons.lock),
                          label: const Text('CLÔTURER LA CAISSE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                        ),
                      ),
                    ] else if (_caisse!.montantDeclare != null) ...[
                      // Cloture summary
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Récapitulatif de clôture', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                              SizedBox(height: 12.h),
                              _row('Montant déclaré', '${_caisse!.montantDeclare!.toStringAsFixed(0)} FCFA'),
                              _row('Total collecté', '${_caisse!.totalCollecte.toStringAsFixed(0)} FCFA'),
                              _row('Écart', '${_caisse!.ecart.toStringAsFixed(0)} FCFA', color: _caisse!.ecart.abs() < 1 ? Colors.green : Colors.red),
                              if (_caisse!.commentaireAgent != null) ...[
                                SizedBox(height: 8.h),
                                Text('Commentaire: ${_caisse!.commentaireAgent}', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
    );
  }

  Widget _row(String label, String value, {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)),
          Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
