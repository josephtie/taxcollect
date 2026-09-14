import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class AgentVerifRecuScreen extends StatefulWidget {
  const AgentVerifRecuScreen({super.key});

  @override
  State<AgentVerifRecuScreen> createState() => _AgentVerifRecuScreenState();
}

class _AgentVerifRecuScreenState extends State<AgentVerifRecuScreen> {
  final Logger _logger = Logger();
  bool _isScanning = true;
  bool _isVerifying = false;
  TransactionDTO? _transaction;
  String? _scannedCode;
  String? _error;

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
      appBar: AppBar(title: const Text('Vérifier un reçu')),
      body: Column(
        children: [
          if (_isScanning)
            Expanded(
              child: Stack(
                children: [
                  MobileScanner(
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final code = barcodes.first.rawValue;
                    if (code != null) {
                      setState(() {
                        _scannedCode = code;
                        _isScanning = false;
                      });
                      _verifyRecu(code);
                    }
                  }
                },
              ),
                  // Scan overlay
                  Center(
                    child: Container(
                      width: 250.w,
                      height: 250.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 3),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  // Instructions
                  Positioned(
                    bottom: 20.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'Scannez le QR Code du reçu',
                        style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (_isVerifying)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                      SizedBox(height: 12.h),
                      Text(_error!, style: TextStyle(fontSize: 14.sp, color: Colors.red), textAlign: TextAlign.center),
                      SizedBox(height: 16.h),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isScanning = true;
                            _error = null;
                            _transaction = null;
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('RESCANNER'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_transaction != null)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    Icon(Icons.verified, size: 64.sp, color: Colors.green),
                    SizedBox(height: 8.h),
                    Text('REÇU VÉRIFIÉ', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.green)),
                    SizedBox(height: 24.h),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _row('Référence', _transaction!.numeroRecu ?? _scannedCode ?? ''),
                            Divider(height: 16.h),
                            _row('Contribuable', '${_transaction!.contribuablePrenom ?? ''} ${_transaction!.contribuableNom ?? ''}'.trim()),
                            Divider(height: 16.h),
                            _row('Montant', '${_transaction!.montant.toStringAsFixed(0)} FCFA'),
                            Divider(height: 16.h),
                            _row('Mode', _transaction!.modePaiement.label),
                            Divider(height: 16.h),
                            _row('Date', _formatDate(_transaction!.dateCreation)),
                            Divider(height: 16.h),
                            _row('Statut', _transaction!.statut.label),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isScanning = true;
                            _transaction = null;
                            _scannedCode = null;
                          });
                        },
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('VÉRIFIER UN AUTRE REÇU'),
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
        ],
      ),
    );
  }

  Future<void> _verifyRecu(String code) async {
    setState(() => _isVerifying = true);
    try {
      final apiService = ApiService();
      final response = await apiService.get<Map<String, dynamic>>(
        '${AppConfig.apiUrl}/transactions/by-reference/$code',
      );
      _transaction = TransactionDTO.fromJson(response);
      if (mounted) setState(() => _isVerifying = false);
    } catch (e) {
      _logger.e('Erreur vérification reçu: $e');
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _error = 'Reçu introuvable ou erreur de vérification';
        });
      }
    }
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)),
        Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
      ],
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
