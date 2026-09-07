import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
  final _baseImposableController = TextEditingController();
  
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
  ContribuableForm? _savedContribuable;

  @override
  void initState() {
    super.initState();
    if (widget.initialContribuable != null) {
      _initializeFromContribuable(widget.initialContribuable!);
    }
    _loadZones();
  }

  void _initializeFromContribuable(ContribuableForm contribuable) {
    _nomController.text = contribuable.nom ?? '';
    _prenomsController.text = contribuable.prenoms ?? '';
    _telephoneController.text = contribuable.telephone;
    _activiteController.text = contribuable.activite;
    _numeroPieceController.text = contribuable.numeroPiece;
    if (contribuable.baseImposable != null) {
      _baseImposableController.text = contribuable.baseImposable!.toStringAsFixed(0);
    }
    
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
    if (_savedContribuable != null) {
      return _buildConfirmationScreen();
    }
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
                _buildStep1Identite(),
                _buildStep2Activite(),
                _buildStep3Zone(),
                _buildStep4Identification(),
                _buildStep5Geolocalisation(),
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

  Widget _buildStep1Identite() {
    return _buildStepContent(
      title: 'Identité',
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
          ],
        ),
      ),
    );
  }

  Widget _buildStep2Activite() {
    return _buildStepContent(
      title: 'Activité',
      child: Column(
        children: [
          TextFormField(
            controller: _activiteController,
            decoration: const InputDecoration(
              labelText: 'Type d\'activité *',
              hintText: 'Entrez l\'activité principale',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ce champ est obligatoire';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          
          // Marché
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
          SizedBox(height: 16.h),
          
          // Base imposable annuelle
          TextFormField(
            controller: _baseImposableController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Base imposable annuelle (FCFA)',
              hintText: 'Laisser vide pour estimation automatique',
              helperText: 'Chiffre d\'affaires annuel estimé. Utilisé pour le calcul des avis.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Zone() {
    return _buildStepContent(
      title: 'Zone de Collecte',
      child: Column(
        children: [
          if (_loadingZones)
            const Center(child: CircularProgressIndicator())
          else
            DropdownButtonFormField<String>(
              initialValue: _selectedZoneId,
              decoration: const InputDecoration(
                labelText: 'Zone *',
              ),
              items: _getZoneOptions().map((zone) {
                return DropdownMenuItem(
                  value: zone.id?.toString() ?? '',
                  child: Text(zone.nom.isNotEmpty ? zone.nom : 'Zone inconnue'),
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
          
          // Validation status indicator
          Container(
            padding: EdgeInsets.all(12.h),
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
                  _necessiteValidation ? Icons.warning : Icons.check_circle,
                  color: _necessiteValidation ? Colors.orange : Colors.green,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _necessiteValidation
                        ? 'Cette zone nécessite une validation administrative'
                        : 'Enregistrement direct possible',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: _necessiteValidation
                          ? Colors.orange.shade800
                          : Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4Identification() {
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
          
          // Photo piece button (facultatif)
          Row(
            children: [
              Icon(Icons.camera_alt, size: 20.sp, color: Colors.grey.shade600),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Photo de la pièce (facultatif)',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ElevatedButton.icon(
            onPressed: _takePiecePhoto,
            icon: const Icon(Icons.camera_alt),
            label: Text(_photoPiece != null ? 'Reprendre la photo' : 'Photographier la pièce'),
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
                child: _buildPhotoPreview(_photoPiece!, _photoPieceFile),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep5Geolocalisation() {
    return _buildStepContent(
      title: 'Géolocalisation',
      child: Column(
        children: [
          // GPS Location
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
          
          if (!_useCurrentLocation) ...[
            SizedBox(height: 16.h),
            Text(
              'Saisie manuelle (GPS indisponible)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: 8.h),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Latitude',
                hintText: 'Ex: 5.360000',
              ),
              onChanged: (value) {
                _latitude = double.tryParse(value);
              },
            ),
            SizedBox(height: 8.h),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Longitude',
                hintText: 'Ex: -4.008000',
              ),
              onChanged: (value) {
                _longitude = double.tryParse(value);
              },
            ),
          ],
          
          SizedBox(height: 32.h),
          
          // Photo contribuable (facultatif)
          Row(
            children: [
              Icon(Icons.camera_alt, size: 20.sp, color: Colors.grey.shade600),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Photo du contribuable (facultatif)',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ElevatedButton.icon(
            onPressed: _takeContribuablePhoto,
            icon: const Icon(Icons.camera_alt),
            label: Text(_photoContribuable != null ? 'Reprendre la photo' : 'Prendre une photo'),
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
                child: _buildPhotoPreview(_photoContribuable!, _photoContribuableFile),
              ),
            ),
          ],
          
          // Offline indicator
          SizedBox(height: 24.h),
          SwitchListTile(
            title: const Text('Enregistrer hors ligne'),
            subtitle: const Text('Synchronisation automatique dès connexion disponible'),
            value: !context.watch<ConnectivityService>().isOnline,
            onChanged: null,
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

  Widget _buildPhotoPreview(String photoPath, File? localFile) {
    if (localFile != null && photoPath == localFile.path) {
      return Image.file(localFile, fit: BoxFit.cover);
    }
    if (photoPath.startsWith('http')) {
      return Image.network(
        photoPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.error, color: Colors.red));
        },
      );
    }
    if (photoPath.startsWith('/')) {
      return Image.file(File(photoPath), fit: BoxFit.cover);
    }
    return const Center(child: Icon(Icons.image, color: Colors.grey));
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

  List<ZoneCollectDto> _zones = [];
  bool _loadingZones = false;

  Future<void> _loadZones() async {
    if (_zones.isNotEmpty || _loadingZones) return;
    setState(() => _loadingZones = true);
    try {
      final locationService = LocationService();
      _zones = await locationService.getAllZones();
    } catch (e) {
      _logger.e('Error loading zones: $e');
    } finally {
      if (mounted) setState(() => _loadingZones = false);
    }
  }

  List<ZoneCollectDto> _getZoneOptions() {
    return _zones;
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
      if (_currentStep == 3 && !_validateStep4()) return;
      
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
    return _activiteController.text.isNotEmpty;
  }

  bool _validateStep3() {
    return _selectedZoneId != null && _selectedZoneId!.isNotEmpty;
  }

  bool _validateStep4() {
    return _numeroPieceController.text.isNotEmpty;
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
        baseImposable: double.tryParse(_baseImposableController.text.trim()),
      );

      widget.onSave(contribuable);
      
      if (mounted) {
        setState(() {
          _savedContribuable = contribuable;
        });
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

  final Logger _logger = Logger();
  File? _photoPieceFile;
  File? _photoContribuableFile;

  Future<void> _scanPieceIdentite() async {
    await _takePiecePhoto();
  }

  Widget _buildConfirmationScreen() {
    final contribuable = _savedContribuable!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recensement réussi'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.h),
        child: Column(
          children: [
            // Success icon
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: Colors.green, size: 48.sp),
            ),
            SizedBox(height: 24.h),
            
            Text(
              'Contribuable enregistré',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              contribuable.numeroContribuable,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 32.h),
            
            // QR Code
            Container(
              padding: EdgeInsets.all(16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'QR Code du Contribuable',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 16.h),
                  QrImageView(
                    data: contribuable.qrCode,
                    version: QrVersions.auto,
                    size: 200.h,
                    gapless: true,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    contribuable.qrCode,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            
            // Contribuable info summary
            Container(
              padding: EdgeInsets.all(16.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  _buildSummaryItem('Nom', '${contribuable.prenoms ?? ''} ${contribuable.nom ?? ''}'),
                  _buildSummaryItem('Téléphone', contribuable.telephone),
                  _buildSummaryItem('Activité', contribuable.activite),
                  _buildSummaryItem('Type', contribuable.type.label),
                  _buildSummaryItem('Statut', contribuable.statut.label),
                  if (contribuable.baseImposable != null)
                    _buildSummaryItem('Base imposable', '${contribuable.baseImposable!.toStringAsFixed(0)} FCFA/an'),
                  if (contribuable.necessiteValidation)
                    _buildSummaryItem('Validation', 'Requise'),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _printReceipt(contribuable),
                    icon: const Icon(Icons.print),
                    label: const Text('Imprimer le reçu'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(0, 48.h),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.check),
                    label: const Text('Terminer'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(0, 48.h),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            
            // New recensement button
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _savedContribuable = null;
                  _nomController.clear();
                  _prenomsController.clear();
                  _telephoneController.clear();
                  _activiteController.clear();
                  _numeroPieceController.clear();
                  _baseImposableController.clear();
                  _photoPiece = null;
                  _photoContribuable = null;
                  _photoPieceFile = null;
                  _photoContribuableFile = null;
                  _latitude = null;
                  _longitude = null;
                  _selectedZoneId = null;
                  _selectedMarche = null;
                  _selectedQuartier = null;
                  _currentStep = 0;
                });
                _pageController.jumpToPage(0);
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Nouveau recensement'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _printReceipt(ContribuableForm contribuable) async {
    try {
      final doc = pw.Document();
      
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Center(
                  child: pw.Text(
                    'REÇU DE RECENSEMENT',
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Center(
                  child: pw.Text(
                    'TaxCollect — Collecte des Impôts',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  ),
                ),
                pw.Divider(),
                pw.SizedBox(height: 24),
                
                // Contribuable info
                pw.Text('Informations du Contribuable',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 12),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    pw.TableRow(children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('N° Contribuable')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(contribuable.numeroContribuable, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Nom')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${contribuable.prenoms ?? ''} ${contribuable.nom ?? ''}')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Téléphone')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(contribuable.telephone)),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Type')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(contribuable.type.label)),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Activité')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(contribuable.activite)),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Zone')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(contribuable.zoneId)),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Pièce d\'identité')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${contribuable.typePiece.label} — ${contribuable.numeroPiece}')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Statut')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(contribuable.statut.label)),
                    ]),
                  ],
                ),
                pw.SizedBox(height: 24),
                
                // QR Code
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text('QR Code', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      pw.Text(contribuable.qrCode, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 32),
                
                // Date and agent
                pw.Divider(),
                pw.SizedBox(height: 12),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Date: ${_formatDate(contribuable.dateCreation)}'),
                    pw.Text('Agent: ${contribuable.agentId}'),
                  ],
                ),
              ],
            );
          },
        ),
      );
      
      await Printing.layoutPdf(
        onLayout: (format) => doc.save(),
        name: 'recu_${contribuable.numeroContribuable}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur génération PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service de localisation désactivé'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission de localisation refusée'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

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
    await _capturePhoto(
      isContribuablePhoto: true,
      uploadEndpoint: '/api/taxcollect/upload/contribuable-photo',
    );
  }

  Future<void> _takePiecePhoto() async {
    await _capturePhoto(
      isContribuablePhoto: false,
      uploadEndpoint: '/api/taxcollect/upload/piece-identite',
    );
  }

  Future<void> _capturePhoto({
    required bool isContribuablePhoto,
    required String uploadEndpoint,
  }) async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1024,
      );

      if (photo == null) return;

      final file = File(photo.path);
      setState(() {
        if (isContribuablePhoto) {
          _photoContribuableFile = file;
        } else {
          _photoPieceFile = file;
        }
      });

      // Try to upload if online
      final recensementService = RecensementService();
      final connectivityService = ConnectivityService();
      if (connectivityService.canPerformOnlineOperation()) {
        String? url;
        if (isContribuablePhoto) {
          url = await recensementService.uploadContribuablePhoto(file);
        } else {
          url = await recensementService.uploadPieceIdentite(file);
        }
        if (url != null && mounted) {
          setState(() {
            if (isContribuablePhoto) {
              _photoContribuable = url;
            } else {
              _photoPiece = url;
            }
          });
        }
      } else {
        // Store local path for offline sync
        if (mounted) {
          setState(() {
            if (isContribuablePhoto) {
              _photoContribuable = photo.path;
            } else {
              _photoPiece = photo.path;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo enregistrée localement. Elle sera synchronisée plus tard.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la capture: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
