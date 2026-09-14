import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class AgentSyncScreen extends StatefulWidget {
  const AgentSyncScreen({super.key});

  @override
  State<AgentSyncScreen> createState() => _AgentSyncScreenState();
}

class _AgentSyncScreenState extends State<AgentSyncScreen> {
  final Logger _logger = Logger();
  bool _isSyncing = false;
  DateTime? _lastSync;
  int _pendingCount = 0;
  List<SyncItemDto> _pendingItems = [];
  String _resultMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSyncInfo();
  }

  Future<void> _loadSyncInfo() async {
    final syncService = SyncService();
    final lastSync = await syncService.getLastSyncTime();
    final pending = await syncService.getPendingItems();
    if (mounted) {
      setState(() {
        _lastSync = lastSync;
        _pendingCount = pending.length;
        _pendingItems = pending;
      });
    }
  }

  Future<void> _synchronize() async {
    setState(() {
      _isSyncing = true;
      _resultMessage = '';
    });

    final syncService = SyncService();
    final result = await syncService.synchronize();

    if (mounted) {
      setState(() {
        _isSyncing = false;
        _resultMessage = result.message;
        if (result.success) {
          _lastSync = DateTime.now();
          _pendingCount = 0;
          _pendingItems = [];
        }
      });
    }
  }

  String get _lastSyncLabel {
    if (_lastSync == null) return 'Jamais';
    return '${_lastSync!.hour.toString().padLeft(2, '0')}:${_lastSync!.minute.toString().padLeft(2, '0')}:${_lastSync!.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final connectivityService = Provider.of<ConnectivityService>(context);
    final user = authService.currentUser;

    // Group pending items by type
    final byType = <String, int>{};
    for (final item in _pendingItems) {
      byType[item.entityType] = (byType[item.entityType] ?? 0) + 1;
    }

    return Scaffold(
      drawer: AgentDrawer(
        agentName: user?.fullName ?? 'Agent',
        agentEmail: user?.email ?? '',
        onLogout: () {
          authService.logout();
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      appBar: AppBar(title: const Text('Synchronisation')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          connectivityService.isOnline ? Icons.cloud_done : Icons.cloud_off,
                          color: connectivityService.isOnline ? Colors.green : Colors.orange,
                          size: 24.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          connectivityService.isOnline ? 'En ligne' : 'Hors ligne',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    _infoRow('Dernière synchronisation', _lastSyncLabel),
                    SizedBox(height: 4.h),
                    _infoRow('Éléments en attente', '$_pendingCount'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Pending items by type
            if (byType.isNotEmpty) ...[
              Text('À envoyer', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              ...byType.entries.map((entry) {
                final labels = {
                  'visite': 'Visites',
                  'transaction': 'Paiements',
                  'audit': 'Audit',
                  'contribuable': 'Nouveaux contribuables',
                };
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.pending_actions, color: Colors.orange, size: 20.sp),
                    title: Text(labels[entry.key] ?? entry.key, style: TextStyle(fontSize: 14.sp)),
                    trailing: Text('${entry.value}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ),
                );
              }),
              SizedBox(height: 16.h),
            ],

            // Result message
            if (_resultMessage.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.h),
                decoration: BoxDecoration(
                  color: _resultMessage.contains('réussie') ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _resultMessage.contains('réussie') ? Colors.green.shade200 : Colors.red.shade200,
                  ),
                ),
                child: Text(_resultMessage, style: TextStyle(fontSize: 13.sp)),
              ),
              SizedBox(height: 16.h),
            ],

            // Sync button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_isSyncing || !connectivityService.isOnline) ? null : _synchronize,
                icon: _isSyncing
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.sync),
                label: Text(_isSyncing ? 'Synchronisation...' : 'SYNCHRONISER'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),
            if (!connectivityService.isOnline) ...[
              SizedBox(height: 8.h),
              Text(
                'Connectez-vous à Internet pour synchroniser',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)),
        Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
