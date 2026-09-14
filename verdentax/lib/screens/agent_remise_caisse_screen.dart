import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class AgentRemiseCaisseScreen extends StatefulWidget {
  const AgentRemiseCaisseScreen({super.key});

  @override
  State<AgentRemiseCaisseScreen> createState() => _AgentRemiseCaisseScreenState();
}

class _AgentRemiseCaisseScreenState extends State<AgentRemiseCaisseScreen> {
  final Logger _logger = Logger();
  final _montantController = TextEditingController();
  final _beneficiaireController = TextEditingController();
  final _referenceController = TextEditingController();
  final _observationController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _montantController.dispose();
    _beneficiaireController.dispose();
    _referenceController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  Future<void> _submitRemise() async {
    final montant = double.tryParse(_montantController.text);
    if (montant == null || montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant invalide')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      final agentId = int.tryParse(user?.id ?? '') ?? 0;

      final remise = RemiseCaisseDto(
        id: 'remise_${DateTime.now().millisecondsSinceEpoch}',
        agentId: agentId,
        agentNom: user?.fullName,
        montant: montant,
        beneficiaire: _beneficiaireController.text.trim().isEmpty ? null : _beneficiaireController.text.trim(),
        dateRemise: DateTime.now(),
        reference: _referenceController.text.trim().isEmpty ? null : _referenceController.text.trim(),
        observation: _observationController.text.trim().isEmpty ? null : _observationController.text.trim(),
        createdAt: DateTime.now(),
      );

      final storageService = StorageService();
      await storageService.storeOfflineData('remise_${remise.id}', remise.toJson());

      final auditService = AuditService();
      await auditService.logAction(
        agentId: agentId,
        agentName: user?.fullName ?? 'Agent',
        action: 'REMISE_CAISSE',
        entityType: 'CAISSE',
        details: 'Remise de ${montant.toStringAsFixed(0)} FCFA',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Remise de caisse enregistrée')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _logger.e('Erreur remise: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
        setState(() => _isSaving = false);
      }
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
      appBar: AppBar(title: const Text('Remise de caisse')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Déclarer une remise de caisse', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            TextField(
              controller: _montantController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Montant remis (FCFA) *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _beneficiaireController,
              decoration: InputDecoration(
                labelText: 'Bénéficiaire',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _referenceController,
              decoration: InputDecoration(
                labelText: 'Référence (optionnel)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _observationController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Observation',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _submitRemise,
                icon: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check),
                label: Text(_isSaving ? 'Enregistrement...' : 'ENREGISTRER LA REMISE'),
                style: ElevatedButton.styleFrom(
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
