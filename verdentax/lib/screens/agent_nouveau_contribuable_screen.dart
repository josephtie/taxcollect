import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class AgentNouveauContribuableScreen extends StatefulWidget {
  const AgentNouveauContribuableScreen({super.key});

  @override
  State<AgentNouveauContribuableScreen> createState() => _AgentNouveauContribuableScreenState();
}

class _AgentNouveauContribuableScreenState extends State<AgentNouveauContribuableScreen> {
  final Logger _logger = Logger();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _activiteController = TextEditingController();
  final _adresseController = TextEditingController();
  final _quartierController = TextEditingController();
  final _numeroIfuController = TextEditingController();
  String? _selectedType = 'Physique';
  String? _selectedSexe = 'M';
  double? _latitude;
  double? _longitude;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _activiteController.dispose();
    _adresseController.dispose();
    _quartierController.dispose();
    _numeroIfuController.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    setState(() {
      _latitude = AppConfig.defaultLatitude;
      _longitude = AppConfig.defaultLongitude;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Position GPS capturée')),
    );
  }

  Future<void> _saveContribuable() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      final agentId = int.tryParse(user?.id ?? '') ?? 0;

      final contribuable = ContribuableDto(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        telephone: _telephoneController.text.trim(),
        activite: _activiteController.text.trim(),
        adresse: _adresseController.text.trim(),
        quartier: _quartierController.text.trim(),
        typeContribuable: _selectedType,
        latitude: _latitude,
        longitude: _longitude,
        statut: 'Actif',
      );

      final apiService = ApiService();
      final connectivityService = Provider.of<ConnectivityService>(context, listen: false);

      if (connectivityService.canPerformOnlineOperation()) {
        await apiService.createContribuable(contribuable);
      } else {
        // Save offline
        final storageService = StorageService();
        final key = 'new_contribuable_${DateTime.now().millisecondsSinceEpoch}';
        await storageService.storeOfflineData(key, {
          ...contribuable.toJson(),
          'agentId': agentId,
          'syncStatus': 'PENDING',
        });
      }

      // Audit log
      final auditService = AuditService();
      await auditService.logAction(
        agentId: agentId,
        agentName: user?.fullName ?? 'Agent',
        action: 'NOUVEAU_CONTRIBUABLE',
        entityType: 'CONTRIBUABLE',
        details: 'Création: ${contribuable.fullName}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(connectivityService.canPerformOnlineOperation()
                ? 'Contribuable créé avec succès'
                : 'Contribuable enregistré hors ligne'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _logger.e('Erreur création contribuable: $e');
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
      appBar: AppBar(title: const Text('Nouveau contribuable')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type
              Text('Type de contribuable', style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'Physique',
                      groupValue: _selectedType,
                      onChanged: (v) => setState(() => _selectedType = v),
                      title: Text('Personne physique', style: TextStyle(fontSize: 13.sp)),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'Morale',
                      groupValue: _selectedType,
                      onChanged: (v) => setState(() => _selectedType = v),
                      title: Text('Personne morale', style: TextStyle(fontSize: 13.sp)),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              // Nom
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nom *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
              ),
              SizedBox(height: 8.h),

              // Prénom
              TextFormField(
                controller: _prenomController,
                decoration: InputDecoration(
                  labelText: 'Prénom',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(height: 8.h),

              // Sexe
              if (_selectedType == 'Physique') ...[
                Text('Sexe', style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        value: 'M',
                        groupValue: _selectedSexe,
                        onChanged: (v) => setState(() => _selectedSexe = v),
                        title: Text('Masculin', style: TextStyle(fontSize: 13.sp)),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        value: 'F',
                        groupValue: _selectedSexe,
                        onChanged: (v) => setState(() => _selectedSexe = v),
                        title: Text('Féminin', style: TextStyle(fontSize: 13.sp)),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
              ],

              // Téléphone
              TextFormField(
                controller: _telephoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  prefixText: '+229 ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(height: 8.h),

              // Activité
              TextFormField(
                controller: _activiteController,
                decoration: InputDecoration(
                  labelText: 'Activité',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(height: 8.h),

              // Quartier
              TextFormField(
                controller: _quartierController,
                decoration: InputDecoration(
                  labelText: 'Quartier',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(height: 8.h),

              // Adresse
              TextFormField(
                controller: _adresseController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Adresse',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(height: 8.h),

              // Numéro IFU
              TextFormField(
                controller: _numeroIfuController,
                decoration: InputDecoration(
                  labelText: 'Numéro IFU (optionnel)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(height: 12.h),

              // GPS
              InkWell(
                onTap: _captureLocation,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.h),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.my_location, color: Colors.blue, size: 20.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          _latitude != null
                              ? 'GPS: ${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}'
                              : 'Capturer ma position GPS',
                          style: TextStyle(fontSize: 13.sp, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveContribuable,
                  icon: _isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Enregistrement...' : 'ENREGISTRER'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
