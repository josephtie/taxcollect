import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../config/config.dart';
import '../models/models.dart';
import '../models/carte_contribuable.dart';
import '../models/recensement.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class QRScannerWidget extends StatefulWidget {
  final Function(String) onQRCodeScanned;
  final VoidCallback? onClose;
  final bool showFlashlight;
  final bool showGallery;
  final String? title;

  const QRScannerWidget({
    super.key,
    required this.onQRCodeScanned,
    this.onClose,
    this.showFlashlight = true,
    this.showGallery = true,
    this.title,
  });

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  final MobileScannerController controller = MobileScannerController();
  bool isFlashOn = false;
  bool isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title ?? 'Scanner QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: widget.onClose != null
            ? IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close),
              )
            : null,
        actions: [
          if (widget.showFlashlight)
            IconButton(
              onPressed: _toggleFlashlight,
              icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
            ),
        ],
      ),
      body: Column(
        children: [
          // QR Scanner
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: (capture) {
                    if (!isScanning) return;
                    
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null) {
                        setState(() {
                          isScanning = false;
                        });
                        
                        // Vibrate and beep feedback
                        _provideFeedback();
                        
                        // Handle scanned data
                        widget.onQRCodeScanned(barcode.rawValue!);
                        
                        // Stop scanning after successful scan
                        controller.stop();
                        return;
                      }
                    }
                  },
                ),
                
                // Overlay
                CustomPaint(
                  size: Size.infinite,
                  painter: QRScannerOverlayPainter(),
                ),
              ],
            ),
          ),
          
          // Instructions
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(16.h),
              child: Column(
                children: [
                  Text(
                    'Scannez le QR Code de la carte contribuable',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  Text(
                    'Positionnez le QR Code dans le cadre pour la lecture automatique',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const Spacer(),
                  
                  // Manual input option
                  TextButton.icon(
                    onPressed: _showManualInputDialog,
                    icon: const Icon(Icons.keyboard, color: Colors.white),
                    label: const Text(
                      'Saisie manuelle',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFlashlight() async {
    try {
      await controller.toggleTorch();
      setState(() {
        isFlashOn = !isFlashOn;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _provideFeedback() {
    // Vibration feedback
    // HapticFeedback.lightImpact();
    
    // Sound feedback (if enabled)
    // SoundPlayer.play('scan_success.mp3');
  }

  void _showManualInputDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saisie Manuelle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Entrez manuellement les données du QR Code:'),
            SizedBox(height: 16.h),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Données QR Code',
                hintText: '{"cid":"...", "uid":"...", "sig":"...", "exp":...}',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.of(context).pop();
                widget.onQRCodeScanned(controller.text.trim());
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class QRScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final cutoutSize = 250.0;
    final cutoutLeft = (size.width - cutoutSize) / 2;
    final cutoutTop = (size.height - cutoutSize) / 2 - 50; // Adjust for instructions area

    // Draw overlay with cutout
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(Rect.fromLTWH(cutoutLeft, cutoutTop, cutoutSize, cutoutSize))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw border around cutout
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cutoutLeft, cutoutTop, cutoutSize, cutoutSize),
        const Radius.circular(10),
      ),
      borderPaint,
    );

    // Draw corner markers
    final cornerLength = 30.0;
    final cornerWidth = 4.0;
    final cornerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = cornerWidth
      ..strokeCap = StrokeCap.round;

    // Top-left corner
    canvas.drawLine(
      Offset(cutoutLeft, cutoutTop + cornerLength),
      Offset(cutoutLeft, cutoutTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutoutLeft, cutoutTop),
      Offset(cutoutLeft + cornerLength, cutoutTop),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(cutoutLeft + cutoutSize - cornerLength, cutoutTop),
      Offset(cutoutLeft + cutoutSize, cutoutTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutoutLeft + cutoutSize, cutoutTop),
      Offset(cutoutLeft + cutoutSize, cutoutTop + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(cutoutLeft, cutoutTop + cutoutSize - cornerLength),
      Offset(cutoutLeft, cutoutTop + cutoutSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutoutLeft, cutoutTop + cutoutSize),
      Offset(cutoutLeft + cornerLength, cutoutTop + cutoutSize),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(cutoutLeft + cutoutSize - cornerLength, cutoutTop + cutoutSize),
      Offset(cutoutLeft + cutoutSize, cutoutTop + cutoutSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutoutLeft + cutoutSize, cutoutTop + cutoutSize),
      Offset(cutoutLeft + cutoutSize, cutoutTop + cutoutSize - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CartePreviewWidget extends StatelessWidget {
  final CarteContribuable carte;
  final ContribuableForm contribuable;
  final VoidCallback? onEdit;
  final VoidCallback? onPrint;
  final VoidCallback? onRenew;
  final bool showActions;

  const CartePreviewWidget({
    super.key,
    required this.carte,
    required this.contribuable,
    this.onEdit,
    this.onPrint,
    this.onRenew,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.05),
              Theme.of(context).primaryColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Government logo placeholder
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                
                SizedBox(width: 12.w),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RÉPUBLIQUE DE CÔTE D\'IVOIRE',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Text(
                        'DIRECTION GÉNÉRALE DES IMPÔTS',
                        style: TextStyle(
                          fontSize: 8.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(carte.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: _getStatusColor(carte.status)),
                  ),
                  child: Text(
                    carte.displayStatus,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: _getStatusColor(carte.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Carte title
            Center(
              child: Text(
                'CARTE CONTRIBUTABLE',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            
            SizedBox(height: 20.h),
            
            // Contribuable info
            Row(
              children: [
                // Photo placeholder
                Container(
                  width: 60.w,
                  height: 70.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: carte.photoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.network(
                            carte.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 30.sp,
                                color: Colors.grey.shade600,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 30.sp,
                          color: Colors.grey.shade600,
                        ),
                ),
                
                SizedBox(width: 16.w),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        contribuable.fullName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      SizedBox(height: 4.h),
                      
                      // Matricule
                      _buildInfoRow('MATRICULE:', carte.displayMatricule),
                      
                      SizedBox(height: 2.h),
                      
                      // Phone
                      _buildInfoRow('TÉL:', contribuable.telephone),
                      
                      SizedBox(height: 2.h),
                      
                      // Activity
                      _buildInfoRow('ACTIVITÉ:', contribuable.activite),
                      
                      SizedBox(height: 2.h),
                      
                      // Zone
                      _buildInfoRow('ZONE:', contribuable.zoneId),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // QR Code placeholder
            Center(
              child: Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code,
                      size: 40.sp,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'QR Code Sécurisé',
                      style: TextStyle(
                        fontSize: 8.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ÉMIS: ${_formatDate(carte.dateEmission)}',
                  style: TextStyle(
                    fontSize: 8.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  'EXP: ${_formatDate(carte.dateExpiration)}',
                  style: TextStyle(
                    fontSize: 8.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 8.h),
            
            Center(
              child: Text(
                'SIGNATURE NUMÉRIQUE SÉCURISÉE',
                style: TextStyle(
                  fontSize: 8.sp,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            // Actions
            if (showActions) ...[
              SizedBox(height: 20.h),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (onEdit != null)
                    _buildActionButton(
                      'Modifier',
                      Icons.edit,
                      Colors.blue,
                      onEdit!,
                    ),
                  
                  if (onPrint != null)
                    _buildActionButton(
                      'Imprimer',
                      Icons.print,
                      Colors.green,
                      onPrint!,
                    ),
                  
                  if (onRenew != null)
                    _buildActionButton(
                      'Renouveler',
                      Icons.refresh,
                      Colors.orange,
                      onRenew!,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 8.sp,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16.sp),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(CarteStatus status) {
    switch (status) {
      case CarteStatus.active:
        return Colors.green;
      case CarteStatus.expired:
        return Colors.red;
      case CarteStatus.suspended:
        return Colors.orange;
      case CarteStatus.revoked:
        return Colors.purple;
      case CarteStatus.lost:
        return Colors.grey;
      case CarteStatus.damaged:
        return Colors.brown;
      case CarteStatus.draft:
        return Colors.blue;
    }
    return Colors.grey; // Default value
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }
}

class CarteFormWidget extends StatefulWidget {
  final ContribuableForm contribuable;
  final Function(CarteCreationRequest) onSubmit;
  final VoidCallback? onCancel;

  const CarteFormWidget({
    super.key,
    required this.contribuable,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<CarteFormWidget> createState() => _CarteFormWidgetState();
}

class _CarteFormWidgetState extends State<CarteFormWidget> {
  final _formKey = GlobalKey<FormState>();
  
  CarteType _selectedType = CarteType.values.first; // Use first value instead of .pvc
  QRSecurityLevel _selectedSecurityLevel = QRSecurityLevel.values.first; // Use first value instead of .standard
  DateTime? _expirationDate;
  String? _selectedZone;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16.h),
      child: Padding(
        padding: EdgeInsets.all(20.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.credit_card,
                    color: Theme.of(context).primaryColor,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Créer une Carte Contribuable',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 8.h),
              
              // Contribuable info
              Container(
                padding: EdgeInsets.all(12.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.contribuable.fullName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${widget.contribuable.telephone} • ${widget.contribuable.activite}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Carte type
              Text(
                'Type de Carte',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: CarteType.values.map((type) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedType = type;
                          });
                        },
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            color: _selectedType == type
                                ? Theme.of(context).primaryColor.withOpacity(0.1)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: _selectedType == type
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _getCarteTypeIcon(type),
                                color: _selectedType == type
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade600,
                                size: 24.sp,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                type.label,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: _selectedType == type
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade700,
                                  fontWeight: _selectedType == type
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              SizedBox(height: 24.h),
              
              // Security level
              Text(
                'Niveau de Sécurité',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              DropdownButtonFormField<QRSecurityLevel>(
                value: _selectedSecurityLevel,
                decoration: const InputDecoration(
                  hintText: 'Sélectionner le niveau de sécurité',
                  border: OutlineInputBorder(),
                ),
                items: QRSecurityLevel.values.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Row(
                      children: [
                        Icon(
                          _getSecurityLevelIcon(level),
                          color: _getSecurityLevelColor(level),
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(level.label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSecurityLevel = value!;
                  });
                },
              ),
              
              SizedBox(height: 16.h),
              
              // Expiration date
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  'Date d\'Expiration',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  _expirationDate != null
                      ? _formatDate(_expirationDate!)
                      : '1 an par défaut',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _selectExpirationDate,
                tileColor: Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Submit buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      child: const Text('Annuler'),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isGenerating ? null : _submitForm,
                      child: _isGenerating
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Générer la Carte'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectExpirationDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now().add(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    
    if (date != null) {
      setState(() {
        _expirationDate = date;
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final request = CarteCreationRequest(
        contribuableId: widget.contribuable.numeroContribuable,
        type: _selectedType,
        securityLevel: _selectedSecurityLevel,
        dateExpiration: _expirationDate,
        zoneId: _selectedZone,
      );

      await widget.onSubmit(request);
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  IconData _getCarteTypeIcon(CarteType type) {
    switch (type) {
      case CarteType.paper:
        return Icons.description;
      case CarteType.pvc:
        return Icons.credit_card;
      case CarteType.digital:
        return Icons.smartphone;
    }
    return Icons.credit_card; // Default value
  }

  IconData _getSecurityLevelIcon(QRSecurityLevel level) {
    switch (level) {
      case QRSecurityLevel.basic:
        return Icons.lock_outline;
      case QRSecurityLevel.standard:
        return Icons.lock;
      case QRSecurityLevel.high:
        return Icons.security;
      case QRSecurityLevel.maximum:
        return Icons.enhanced_encryption;
    }
    return Icons.lock; // Default value
  }

  Color _getSecurityLevelColor(QRSecurityLevel level) {
    switch (level) {
      case QRSecurityLevel.basic:
        return Colors.blue;
      case QRSecurityLevel.standard:
        return Colors.green;
      case QRSecurityLevel.high:
        return Colors.orange;
      case QRSecurityLevel.maximum:
        return Colors.red;
    }
    return Colors.green; // Default value
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }
}
