import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class AgentVisiteScreen extends StatefulWidget {
  const AgentVisiteScreen({super.key});

  @override
  State<AgentVisiteScreen> createState() => _AgentVisiteScreenState();
}

class _AgentVisiteScreenState extends State<AgentVisiteScreen> {
  final Logger _logger = Logger();
  ContribuableDto? _contribuable;
  VisiteDto? _currentVisite;
  bool _isStarting = false;
  bool _isFinishing = false;
  VisiteResultat? _selectedResultat;
  final TextEditingController _observationController = TextEditingController();

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
    _observationController.dispose();
    super.dispose();
  }

  Future<void> _startVisite() async {
    if (_contribuable == null) return;
    setState(() => _isStarting = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      final agentId = int.tryParse(user?.id ?? '') ?? 0;

      final visiteService = VisiteService();
      _currentVisite = await visiteService.startVisite(
        contribuableId: _contribuable!.id ?? 0,
        contribuableNom: _contribuable!.nom,
        contribuablePrenom: _contribuable!.prenom,
        agentId: agentId,
        agentNom: user?.fullName,
        gpsLat: AppConfig.defaultLatitude,
        gpsLng: AppConfig.defaultLongitude,
      );

      final auditService = AuditService();
      await auditService.logAction(
        agentId: agentId,
        agentName: user?.fullName ?? 'Agent',
        action: 'VISITE_DEBUT',
        entityType: 'CONTRIBUABLE',
        entityId: _contribuable!.id?.toString(),
        details: 'Visite démarrée pour ${_contribuable!.fullName}',
      );

      if (mounted) setState(() => _isStarting = false);
    } catch (e) {
      _logger.e('Erreur démarrage visite: $e');
      if (mounted) setState(() => _isStarting = false);
    }
  }

  Future<void> _finishVisite() async {
    if (_currentVisite == null || _selectedResultat == null) return;
    setState(() => _isFinishing = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      final agentId = int.tryParse(user?.id ?? '') ?? 0;

      final visiteService = VisiteService();
      await visiteService.finishVisite(
        visiteId: _currentVisite!.id!,
        resultat: _selectedResultat!,
        observation: _observationController.text.trim().isEmpty ? null : _observationController.text.trim(),
      );

      final auditService = AuditService();
      await auditService.logAction(
        agentId: agentId,
        agentName: user?.fullName ?? 'Agent',
        action: 'VISITE_FIN',
        entityType: 'CONTRIBUABLE',
        entityId: _contribuable!.id?.toString(),
        details: 'Résultat: ${_selectedResultat!.label}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Visite enregistrée: ${_selectedResultat!.label}')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _logger.e('Erreur fin visite: $e');
      if (mounted) setState(() => _isFinishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_contribuable == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Visite')),
        body: const Center(child: Text('Contribuable introuvable')),
      );
    }

    final c = _contribuable!;
    final hasVisite = _currentVisite != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Visite terrain')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contribuable info
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.fullName, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4.h),
                    Text(c.activite ?? '', style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)),
                    SizedBox(height: 8.h),
                    Text('Quartier: ${c.quartier ?? 'N/A'}', style: TextStyle(fontSize: 13.sp)),
                    Text('Téléphone: ${c.telephone ?? 'N/A'}', style: TextStyle(fontSize: 13.sp)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),

            if (!hasVisite) ...[
              // Start visite button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isStarting ? null : _startVisite,
                  icon: _isStarting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.play_arrow),
                  label: Text(_isStarting ? 'Démarrage...' : 'DÉMARRER LA VISITE'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
            ] else ...[
              // Visite info
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.h),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 18.sp),
                        SizedBox(width: 6.w),
                        Text('Visite en cours', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.green)),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text('GPS: ${_currentVisite!.gpsLat?.toStringAsFixed(5)}, ${_currentVisite!.gpsLng?.toStringAsFixed(5)}', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                    Text('Début: ${_formatTime(_currentVisite!.heureDebut)}', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Resultat selection
              Text('Résultat de la visite', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              ...VisiteResultat.values.map((r) => RadioListTile<VisiteResultat>(
                value: r,
                groupValue: _selectedResultat,
                onChanged: (v) => setState(() => _selectedResultat = v),
                title: Text(r.label, style: TextStyle(fontSize: 14.sp)),
                dense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
              )),
              SizedBox(height: 12.h),

              // Observation
              TextField(
                controller: _observationController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Observation (optionnel)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(height: 16.h),

              // Finish button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_selectedResultat == null || _isFinishing) ? null : _finishVisite,
                  icon: _isFinishing
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check),
                  label: Text(_isFinishing ? 'Enregistrement...' : 'VALIDER LA VISITE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return 'N/A';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
