import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../services/services.dart';

class AgentContribuableDetailScreen extends StatefulWidget {
  const AgentContribuableDetailScreen({super.key});

  @override
  State<AgentContribuableDetailScreen> createState() => _AgentContribuableDetailScreenState();
}

class _AgentContribuableDetailScreenState extends State<AgentContribuableDetailScreen> {
  ContribuableDto? _contribuable;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ContribuableDto) {
      _contribuable = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (_contribuable == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Contribuable')),
        body: const Center(child: Text('Contribuable introuvable')),
      );
    }

    final c = _contribuable!;

    return Scaffold(
      appBar: AppBar(
        title: Text(c.fullName, style: TextStyle(fontSize: 16.sp)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              child: Padding(
                padding: EdgeInsets.all(16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28.r,
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Icon(Icons.store, size: 28.sp, color: Theme.of(context).primaryColor),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.fullName, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                              if (c.typeContribuable != null)
                                Text(c.typeContribuable!, style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    _infoRow(Icons.location_on, c.quartier ?? c.adresse ?? 'Adresse non renseignée'),
                    SizedBox(height: 6.h),
                    _infoRow(Icons.phone, c.telephone ?? 'Téléphone non renseigné'),
                    SizedBox(height: 6.h),
                    _infoRow(Icons.work, c.activite ?? 'Activité non renseignée'),
                    if (c.numeroContribuable != null) ...[
                      SizedBox(height: 6.h),
                      _infoRow(Icons.badge, 'N° ${c.numeroContribuable}'),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Taxe à payer card
            Card(
              elevation: 2,
              color: Colors.orange.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              child: Padding(
                padding: EdgeInsets.all(16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TAXE À PAYER', style: TextStyle(fontSize: 12.sp, color: Colors.orange, fontWeight: FontWeight.w600)),
                    SizedBox(height: 4.h),
                    Text('25 000 FCFA', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: c.statut != null ? _statusColor(c.statut!).withOpacity(0.2) : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            c.statut ?? 'Statut inconnu',
                            style: TextStyle(fontSize: 11.sp, color: c.statut != null ? _statusColor(c.statut!) : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Action buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/agent-encaissement', arguments: c);
                },
                icon: const Icon(Icons.payments),
                label: const Text('ENCAISSER'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/agent-visite', arguments: c);
                },
                icon: const Icon(Icons.visibility),
                label: const Text('VISITER'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/agent-carte', arguments: c);
                },
                icon: const Icon(Icons.directions),
                label: const Text('ITINÉRAIRE'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            if (c.telephone != null && c.telephone!.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse('tel:${c.telephone}');
                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('APPELER'),
                  style: OutlinedButton.styleFrom(
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

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey.shade600),
        SizedBox(width: 6.w),
        Expanded(child: Text(text, style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700))),
      ],
    );
  }

  Color _statusColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'actif': return Colors.green;
      case 'à recouvrer':
      case 'a recouvrer': return Colors.orange;
      case 'payé':
      case 'paye': return Colors.blue;
      case 'suspendu': return Colors.red;
      default: return Colors.grey;
    }
  }
}
