import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class AgentPromesseScreen extends StatefulWidget {
  const AgentPromesseScreen({super.key});

  @override
  State<AgentPromesseScreen> createState() => _AgentPromesseScreenState();
}

class _AgentPromesseScreenState extends State<AgentPromesseScreen> {
  final Logger _logger = Logger();
  bool _isLoading = true;
  List<PromessePaiementDto> _promesses = [];
  ContribuableDto? _contribuable;

  // Form
  final _montantController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  final _observationController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ContribuableDto) {
      _contribuable = args;
    }
    _loadPromesses();
  }

  @override
  void dispose() {
    _montantController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  Future<void> _loadPromesses() async {
    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      final agentId = int.tryParse(user?.id ?? '') ?? 0;

      final promesseService = PromesseService();
      final promesses = await promesseService.getPromessesByAgent(agentId);
      if (mounted) {
        setState(() { _promesses = promesses; _isLoading = false; });
      }
    } catch (e) {
      _logger.e('Erreur chargement promesses: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createPromesse() async {
    final montant = double.tryParse(_montantController.text);
    if (montant == null || montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant invalide')),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    final agentId = int.tryParse(user?.id ?? '') ?? 0;

    final promesseService = PromesseService();
    await promesseService.createPromesse(
      contribuableId: _contribuable?.id ?? 0,
      contribuableNom: _contribuable?.nom,
      contribuablePrenom: _contribuable?.prenom,
      agentId: agentId,
      agentNom: user?.fullName,
      montant: montant,
      datePromesse: _selectedDate,
      observation: _observationController.text.trim().isEmpty ? null : _observationController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Promesse enregistrée')),
      );
      _montantController.clear();
      _observationController.clear();
      _loadPromesses();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
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
      appBar: AppBar(title: const Text('Promesses')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // New promesse form
                if (_contribuable != null)
                  Card(
                    margin: EdgeInsets.all(12.w),
                    child: Padding(
                      padding: EdgeInsets.all(16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nouvelle promesse', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4.h),
                          Text(_contribuable!.fullName, style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)),
                          SizedBox(height: 12.h),
                          TextField(
                            controller: _montantController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Montant promis (FCFA)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          InkWell(
                            onTap: _pickDate,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Date promesse',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                                suffixIcon: const Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          TextField(
                            controller: _observationController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: 'Observation (optionnel)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _createPromesse,
                              icon: const Icon(Icons.check),
                              label: const Text('ENREGISTRER LA PROMESSE'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Existing promesses
                Expanded(
                  child: _promesses.isEmpty
                      ? Center(child: Text('Aucune promesse', style: TextStyle(fontSize: 14.sp, color: Colors.grey)))
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          itemCount: _promesses.length,
                          itemBuilder: (context, index) {
                            final p = _promesses[index];
                            final isRetard = p.isEcheancePassee && p.statut == 'EN_ATTENTE';
                            final isToday = p.isEcheanceToday && p.statut == 'EN_ATTENTE';

                            return Card(
                              margin: EdgeInsets.only(bottom: 6.h),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isRetard
                                      ? Colors.red.withOpacity(0.15)
                                      : isToday
                                          ? Colors.orange.withOpacity(0.15)
                                          : Colors.green.withOpacity(0.15),
                                  child: Icon(
                                    isRetard ? Icons.warning : isToday ? Icons.schedule : Icons.handshake,
                                    color: isRetard ? Colors.red : isToday ? Colors.orange : Colors.green,
                                  ),
                                ),
                                title: Text(p.contribuableFullName, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${p.montant.toStringAsFixed(0)} FCFA', style: TextStyle(fontSize: 13.sp)),
                                    Text(
                                      'Échéance: ${p.datePromesse.day}/${p.datePromesse.month}/${p.datePromesse.year}',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: isRetard ? Colors.red : isToday ? Colors.orange : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: p.statut == 'REALISEE'
                                        ? Colors.green.withOpacity(0.15)
                                        : isRetard
                                            ? Colors.red.withOpacity(0.15)
                                            : Colors.orange.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    p.statut == 'REALISEE' ? 'Réalisée' : isRetard ? 'En retard' : 'En attente',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: p.statut == 'REALISEE' ? Colors.green : isRetard ? Colors.red : Colors.orange,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(context, '/agent-contribuable-detail', arguments: ContribuableDto(
                                    id: p.contribuableId,
                                    nom: p.contribuableNom ?? '',
                                    prenom: p.contribuablePrenom ?? '',
                                  ));
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
}
