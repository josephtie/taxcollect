import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../config/config.dart';
import '../models/models.dart';

class AgentRecuScreen extends StatelessWidget {
  const AgentRecuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    TransactionDTO? transaction;
    if (args is TransactionDTO) {
      transaction = args;
    }

    if (transaction == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reçu')),
        body: const Center(child: Text('Transaction introuvable')),
      );
    }

    final tx = transaction;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reçu de paiement'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: share via share_plus
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Success icon
            Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: Colors.green, size: 40.sp),
            ),
            SizedBox(height: 12.h),
            Text('PAIEMENT CONFIRMÉ', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.green)),
            SizedBox(height: 24.h),

            // Reçu card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              child: Padding(
                padding: EdgeInsets.all(20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _recuRow('Référence', tx.numeroRecu ?? 'EC-${now.year}-${now.millisecondsSinceEpoch.toString().substring(7)}'),
                    Divider(height: 20.h),
                    _recuRow('Contribuable', tx.contribuableFullName),
                    Divider(height: 20.h),
                    _recuRow('Taxe', 'Taxe communale'),
                    Divider(height: 20.h),
                    _recuRow('Montant', '${tx.montant.toStringAsFixed(0)} FCFA', isBold: true),
                    Divider(height: 20.h),
                    _recuRow('Mode de paiement', tx.modePaiement.label),
                    Divider(height: 20.h),
                    _recuRow('Date', _formatDateTime(tx.dateCreation ?? now)),
                    Divider(height: 20.h),
                    _recuRow('Agent', tx.agentFullName),
                    Divider(height: 20.h),
                    _recuRow('Statut', tx.statut.label),
                    if (tx.offline) ...[
                      Divider(height: 20.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_off, size: 14.sp, color: Colors.orange),
                            SizedBox(width: 4.w),
                            Text('Reçu provisoire (hors ligne)', style: TextStyle(fontSize: 11.sp, color: Colors.orange)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // QR Code placeholder
            Container(
              width: 150.w,
              height: 150.h,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_2, size: 80.sp, color: Colors.grey.shade700),
                  SizedBox(height: 4.h),
                  Text('QR Code', style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: share via WhatsApp
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('WhatsApp'),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: send SMS
                    },
                    icon: const Icon(Icons.sms),
                    label: const Text('SMS'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/agent-dashboard', (route) => false);
                },
                icon: const Icon(Icons.home),
                label: const Text('RETOUR AU TABLEAU DE BORD'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recuRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? Colors.green.shade800 : Colors.black87,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
