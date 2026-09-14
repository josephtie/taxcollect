import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class AgentEncaissementScreen extends StatefulWidget {
  const AgentEncaissementScreen({super.key});

  @override
  State<AgentEncaissementScreen> createState() => _AgentEncaissementScreenState();
}

class _AgentEncaissementScreenState extends State<AgentEncaissementScreen> {
  final Logger _logger = Logger();
  ContribuableDto? _contribuable;
  bool _isProcessing = false;
  ModePaiement _selectedMode = ModePaiement.espece;
  final TextEditingController _montantController = TextEditingController(text: '25000');
  bool _isPartial = false;
  final TextEditingController _partialMontantController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ContribuableDto) {
      _contribuable = args;
    }
  }

  @override
  void dispose() {
    _montantController.dispose();
    _partialMontantController.dispose();
    super.dispose();
  }

  bool get _isOnlineMode => _selectedMode != ModePaiement.espece;

  Future<void> _processPayment() async {
    final montant = double.tryParse(_isPartial ? _partialMontantController.text : _montantController.text);
    if (montant == null || montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Montant invalide')),
      );
      return;
    }

    final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
    if (_isOnlineMode && !connectivityService.canPerformOnlineOperation()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paiement électronique impossible hors ligne. Connexion requise.'),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      final agentId = int.tryParse(user?.id ?? '') ?? 0;

      final transactionService = TransactionService();
      final transaction = await transactionService.createTransaction(
        montant: montant,
        contribuableId: _contribuable!.id ?? 0,
        agentId: agentId,
        zoneId: _contribuable?.zoneId ?? 0,
        modePaiement: _selectedMode,
        offline: !connectivityService.canPerformOnlineOperation(),
        contribuableNom: _contribuable!.nom,
        contribuablePrenom: _contribuable!.prenom,
        agentNom: user?.lastName,
        agentPrenom: user?.firstName,
        zoneNom: null,
        taxeCollectId: null,
      );

      final auditService = AuditService();
      await auditService.logAction(
        agentId: agentId,
        agentName: user?.fullName ?? 'Agent',
        action: 'ENCAISSEMENT',
        entityType: 'TRANSACTION',
        entityId: transaction.id?.toString(),
        details: 'Paiement ${_selectedMode.label} de $montant FCFA pour ${_contribuable!.fullName}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paiement de $montant FCFA enregistré'),
          ),
        );
        Navigator.pushReplacementNamed(
          context,
          '/agent-recu',
          arguments: transaction,
        );
      }
    } catch (e) {
      _logger.e('Erreur encaissement: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_contribuable == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Encaissement')),
        body: const Center(child: Text('Contribuable introuvable')),
      );
    }

    final c = _contribuable!;
    final connectivityService = Provider.of<ConnectivityService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Encaissement')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contribuable info
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.h),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Icon(Icons.person, color: Theme.of(context).primaryColor),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.fullName, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                          Text(c.activite ?? '', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Montant dû
            Text('Montant dû', style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)),
            SizedBox(height: 4.h),
            Text('25 000 FCFA', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
            SizedBox(height: 16.h),

            // Mode de paiement
            Text('Mode de paiement', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              children: ModePaiement.values.map((mode) {
                return ChoiceChip(
                  label: Text(mode.label),
                  selected: _selectedMode == mode,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedMode = mode);
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),

            // Paiement partiel
            CheckboxListTile(
              value: _isPartial,
              onChanged: (v) => setState(() => _isPartial = v ?? false),
              title: Text('Paiement partiel', style: TextStyle(fontSize: 14.sp)),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            if (_isPartial) ...[
              SizedBox(height: 8.h),
              TextField(
                controller: _partialMontantController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant payé',
                  suffixText: 'FCFA',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(height: 8.h),
              if (_partialMontantController.text.isNotEmpty)
                Text(
                  'Reste: ${(25000 - (double.tryParse(_partialMontantController.text) ?? 0)).toStringAsFixed(0)} FCFA',
                  style: TextStyle(fontSize: 13.sp, color: Colors.orange),
                ),
            ],
            SizedBox(height: 16.h),

            // Online warning
            if (_isOnlineMode && !connectivityService.isOnline)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.h),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off, color: Colors.red, size: 18.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Paiement électronique nécessite une connexion Internet',
                        style: TextStyle(fontSize: 12.sp, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 16.h),

            // Process button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _processPayment,
                icon: _isProcessing
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle),
                label: Text(_isProcessing ? 'Traitement...' : 'VALIDER LE PAIEMENT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
