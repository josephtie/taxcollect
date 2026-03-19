import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../config/config.dart';
import '../models/models.dart';
import '../services/services.dart';

class RecensementWizard extends StatefulWidget {
  final ContribuableForm? initialContribuable;
  final Function(ContribuableForm) onSave;
  final VoidCallback onCancel;

  const RecensementWizard({
    super.key,
    this.initialContribuable,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<RecensementWizard> createState() => _RecensementWizardState();
}

class _RecensementWizardState extends State<RecensementWizard> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  
  int _currentStep = 0;
  bool _isLoading = false;
  
  // Form data
  final _nomController = TextEditingController();
  final _prenomsController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _activiteController = TextEditingController();
  final _numeroPieceController = TextEditingController();
  
  ContribuableType _selectedType = ContribuableType.personnePhysique;
  TypePieceIdentite _selectedTypePiece = TypePieceIdentite.cni;
  String? _selectedZoneId;
  String? _selectedMarche;
  String? _selectedQuartier;
  
  double? _latitude;
  double? _longitude;
  String? _photoPiece;
  String? _photoContribuable;
  
  bool _useCurrentLocation = true;
  bool _necessiteValidation = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialContribuable != null) {
      _initializeFromContribuable(widget.initialContribuable!);
    }
  }

  void _initializeFromContribuable(ContribuableForm contribuable) {
    _nomController.text = contribuable.nom ?? '';
    _prenomsController.text = contribuable.prenoms ?? '';
    _telephoneController.text = contribuable.telephone;
    _activiteController.text = contribuable.activite;
    _numeroPieceController.text = contribuable.numeroPiece;
    
    _selectedType = contribuable.type;
    _selectedTypePiece = contribuable.typePiece;
    _selectedZoneId = contribuable.zoneId;
    _selectedMarche = contribuable.marche;
    _selectedQuartier = contribuable.quartier;
    
    _latitude = contribuable.latitude;
    _longitude = contribuable.longitude;
    _photoPiece = contribuable.photoPiece;
    _photoContribuable = contribuable.photoContribuable;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialContribuable != null 
              ? 'Modifier Contribuable' 
              : 'Nouveau Contribuable',
        ),
        actions: [
          TextButton(
            onPressed: widget.onCancel,
            child: const Text('Annuler'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          
          // Form content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
                _buildStep4(),
                _buildStep5(),
              ],
            ),
          ),
          
          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.all(16.h),
      child: Row(
        children: List.generate(5, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              height: 4.h,
              margin: EdgeInsets.only(right: index < 4 ? 8.w : 0),
              decoration: BoxDecoration(
                color: isActive 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1() {
    return _buildStepContent(
      title: 'Informations de Base',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Type selection
            Text(
              'Type de Contribuable',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16.h),
            _buildTypeSelector(),
            SizedBox(height: 24.h),
            
            // Name fields
            TextFormField(
              controller: _nomController,
              decoration: const InputDecoration(
                labelText: 'Nom *',
                hintText: 'Entrez le nom',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ce champ est obligatoire';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            
            if (_selectedType == ContribuableType.personnePhysique) ...[
              TextFormField(
                controller: _prenomsController,
                decoration: const InputDecoration(
                  labelText: 'Prénoms',
                  hintText: 'Entrez les prénoms',
                ),
              ),
              SizedBox(height: 16.h),
            ],
            
            // Telephone
            TextFormField(
              controller: _telephoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Téléphone *',
                hintText: 'Entrez le numéro de téléphone',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppConfig.fieldRequired;
                }
                if (!RegExp(r'^[0-9]{8,15}$').hasMatch(value)) {
                  return 'Format de téléphone invalide';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            
            // Activity
            TextFormField(
              controller: _activiteController,
              decoration: const InputDecoration(
                labelText: 'Activité *',
                hintText: 'Entrez l\'activité principale',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ce champ est obligatoire';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return _buildStepContent(
      title: 'Identification',
      child: Column(
        children: [
          Text(
            'Pièce d\'Identité',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 16.h),
          
          // Type piece selector
          DropdownButtonFormField<TypePieceIdentite>(
            initialValue: _selectedTypePiece,
            decoration: const InputDecoration(
              labelText: 'Type de pièce *',
            ),
            items: TypePieceIdentite.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.label),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedTypePiece = value!;
              });
            },
          ),
          SizedBox(height: 16.h),
          
          // Numero piece
          TextFormField(
            controller: _numeroPieceController,
            decoration: const InputDecoration(
              labelText: 'Numéro de pièce *',
              hintText: 'Entrez le numéro de la pièce',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ce champ est obligatoire';
              }
              return null;
            },
          ),
          SizedBox(height: 24.h),
          
          // Scan piece button
          ElevatedButton.icon(
            onPressed: _scanPieceIdentite,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Scanner la pièce'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 48.h),
            ),
          ),
          
          if (_photoPiece != null) ...[
            SizedBox(height: 16.h),
            Container(
              height: 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  _photoPiece!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.error, color: Colors.red),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return _buildStepContent(
      title: 'Localisation',
      child: Column(
        children: [
          // Zone selection
          DropdownButtonFormField<String>(
            initialValue: _selectedZoneId,
            decoration: const InputDecoration(
              labelText: 'Zone *',
            ),
            items: _getZoneOptions().map((zone) {
              return DropdownMenuItem(
                value: zone['id'],
                child: Text(zone['name'] ?? 'Zone inconnue'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedZoneId = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ce champ est obligatoire';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          
          // Marche
          TextFormField(
            initialValue: _selectedMarche,
            decoration: const InputDecoration(
              labelText: 'Marché',
              hintText: 'Entrez le nom du marché',
            ),
            onChanged: (value) {
              _selectedMarche = value;
            },
          ),
          SizedBox(height: 16.h),
          
          // Quartier
          TextFormField(
            initialValue: _selectedQuartier,
            decoration: const InputDecoration(
              labelText: 'Quartier',
              hintText: 'Entrez le nom du quartier',
            ),
            onChanged: (value) {
              _selectedQuartier = value;
            },
          ),
          SizedBox(height: 24.h),
          
          // Location
          SwitchListTile(
            title: const Text('Utiliser ma position actuelle'),
            subtitle: const Text('Géolocalisation automatique'),
            value: _useCurrentLocation,
            onChanged: (value) {
              setState(() {
                _useCurrentLocation = value;
              });
            },
          ),
          
          if (_useCurrentLocation) ...[
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Obtenir ma position'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48.h),
              ),
            ),
          ],
          
          if (_latitude != null && _longitude != null) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Position actuelle:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(height: 8.h),
                  Text('Latitude: ${_latitude!.toStringAsFixed(6)}'),
                  Text('Longitude: ${_longitude!.toStringAsFixed(6)}'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return _buildStepContent(
      title: 'Photos',
      child: Column(
        children: [
          // Contribuable photo
          Text(
            'Photo du Contribuable',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 16.h),
          
          ElevatedButton.icon(
            onPressed: _takeContribuablePhoto,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Prendre une photo'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 48.h),
            ),
          ),
          
          if (_photoContribuable != null) ...[
            SizedBox(height: 16.h),
            Container(
              height: 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  _photoContribuable!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.error, color: Colors.red),
                    );
                  },
                ),
              ),
            ),
          ],
          
          SizedBox(height: 32.h),
          
          // Piece photo (if not already taken)
          if (_photoPiece == null) ...[
            Text(
              'Photo de la Pièce d\'Identité',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16.h),
            
            ElevatedButton.icon(
              onPressed: _takePiecePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Photographier la pièce'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48.h),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep5() {
    return _buildStepContent(
      title: 'Validation',
      child: Column(
        children: [
          // Summary
          Text(
            'Résumé des Informations',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 24.h),
          
          _buildSummaryItem('Type', _selectedType.label),
          _buildSummaryItem('Nom', _nomController.text),
          if (_selectedType == ContribuableType.personnePhysique)
            _buildSummaryItem('Prénoms', _prenomsController.text),
          _buildSummaryItem('Téléphone', _telephoneController.text),
          _buildSummaryItem('Activité', _activiteController.text),
          _buildSummaryItem('Type de pièce', _selectedTypePiece.label),
          _buildSummaryItem('Numéro de pièce', _numeroPieceController.text),
          _buildSummaryItem('Zone', _selectedZoneId ?? 'Non sélectionnée'),
          if (_selectedMarche != null)
            _buildSummaryItem('Marché', _selectedMarche!),
          if (_selectedQuartier != null)
            _buildSummaryItem('Quartier', _selectedQuartier!),
          
          if (_latitude != null && _longitude != null) ...[
            _buildSummaryItem('Position', '${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}'),
          ],
          
          // Validation status
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(16.h),
            decoration: BoxDecoration(
              color: _necessiteValidation 
                  ? Colors.orange.shade50 
                  : Colors.green.shade50,
              border: Border.all(
                color: _necessiteValidation 
                    ? Colors.orange.shade200 
                    : Colors.green.shade200,
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  _necessiteValidation 
                      ? Icons.warning 
                      : Icons.check_circle,
                  color: _necessiteValidation 
                      ? Colors.orange 
                      : Colors.green,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    _necessiteValidation 
                        ? 'Ce contribuable nécessite une validation administrative'
                        : 'Ce contribuable peut être enregistré directement',
                    style: TextStyle(
                      color: _necessiteValidation 
                          ? Colors.orange.shade800 
                          : Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Offline option
          SizedBox(height: 16.h),
          SwitchListTile(
            title: const Text('Enregistrer hors ligne'),
            subtitle: const Text('Synchronisation automatique dès connexion disponible'),
            value: !context.watch<ConnectivityService>().isOnline,
            onChanged: null, // Read-only based on connectivity
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Non renseigné' : value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: value.isEmpty ? Colors.grey : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent({required String title, required Widget child}) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Étape ${_currentStep + 1}/5',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),
          child,
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(16.h),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Précédent'),
              ),
            ),
          
          if (_currentStep > 0) SizedBox(width: 16.w),
          
          Expanded(
            flex: _currentStep == 4 ? 2 : 1,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(_currentStep == 4 ? 'Enregistrer' : 'Suivant'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: ContribuableType.values.map((type) {
        final isSelected = _selectedType == type;
        return ChoiceChip(
          label: Text(type.label),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedType = type;
                _necessiteValidation = _requiresValidation(type);
              });
            }
          },
          avatar: Icon(_getTypeIcon(type)),
        );
      }).toList(),
    );
  }

  IconData _getTypeIcon(ContribuableType type) {
    switch (type) {
      case ContribuableType.personnePhysique:
        return Icons.person;
      case ContribuableType.personneMorale:
        return Icons.business;
      case ContribuableType.commercant:
        return Icons.store;
      case ContribuableType.transporteur:
        return Icons.directions_car;
      case ContribuableType.artisan:
        return Icons.build;
      case ContribuableType.occupantDomainePublic:
        return Icons.location_city;
    }
  }

  bool _requiresValidation(ContribuableType type) {
    return type == ContribuableType.personneMorale ||
           _activiteController.text.toLowerCase().contains('import') ||
           _selectedZoneId?.toLowerCase().contains('zone_speciale') == true;
  }

  List<Map<String, String>> _getZoneOptions() {
    // This would come from the API or local database
    return [
      {'id': 'zone1', 'name': 'Zone Centre-ville'},
      {'id': 'zone2', 'name': 'Zone Marché Central'},
      {'id': 'zone3', 'name': 'Zone Portuaire'},
      {'id': 'zone4', 'name': 'Zone Industrielle'},
    ];
  }

  void _nextStep() async {
    if (_currentStep == 4) {
      // Save the contribuable
      await _saveContribuable();
    } else {
      // Validate current step
      if (_currentStep == 0 && !_validateStep1()) return;
      if (_currentStep == 1 && !_validateStep2()) return;
      if (_currentStep == 2 && !_validateStep3()) return;
      
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _validateStep1() {
    return _formKey.currentState?.validate() ?? false;
  }

  bool _validateStep2() {
    return _numeroPieceController.text.isNotEmpty;
  }

  bool _validateStep3() {
    return _selectedZoneId != null && _selectedZoneId!.isNotEmpty;
  }

  Future<void> _saveContribuable() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = context.read<AuthService>();
      final recensementService = RecensementService();

      final contribuable = await recensementService.createContribuable(
        telephone: _telephoneController.text,
        type: _selectedType,
        activite: _activiteController.text,
        zoneId: _selectedZoneId!,
        typePiece: _selectedTypePiece,
        numeroPiece: _numeroPieceController.text,
        nom: _nomController.text,
        prenoms: _prenomsController.text,
        marche: _selectedMarche,
        quartier: _selectedQuartier,
        latitude: _latitude,
        longitude: _longitude,
        photoPiece: _photoPiece,
        photoContribuable: _photoContribuable,
        agentId: authService.currentUser?.id ?? 'unknown',
      );

      widget.onSave(contribuable);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Contribuable ${contribuable.numeroContribuable} créé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _scanPieceIdentite() async {
    // Implement OCR scanning
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité de scan OCR à implémenter')),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      final geolocationService = GeolocationService();
      final position = await geolocationService.getCurrentPositionLatLng();
      
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'obtention de la position: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _takeContribuablePhoto() async {
    // Implement photo capture
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité photo à implémenter')),
    );
  }

  Future<void> _takePiecePhoto() async {
    // Implement photo capture
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité photo à implémenter')),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nomController.dispose();
    _prenomsController.dispose();
    _telephoneController.dispose();
    _activiteController.dispose();
    _numeroPieceController.dispose();
    super.dispose();
  }
}
