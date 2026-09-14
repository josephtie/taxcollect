import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class AgentJournalScreen extends StatefulWidget {
  const AgentJournalScreen({super.key});

  @override
  State<AgentJournalScreen> createState() => _AgentJournalScreenState();
}

class _AgentJournalScreenState extends State<AgentJournalScreen> {
  final Logger _logger = Logger();
  List<AuditEntryDto> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    try {
      final auditService = AuditService();
      final entries = await auditService.getAuditEntries(limit: 100);
      if (mounted) {
        setState(() {
          _entries = entries;
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.e('Erreur chargement journal: $e');
      if (mounted) setState(() => _isLoading = false);
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
      appBar: AppBar(
        title: const Text('Journal d\'activité'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadEntries),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? Center(child: Text('Aucune activité', style: TextStyle(fontSize: 14.sp, color: Colors.grey)))
              : ListView.builder(
                  padding: EdgeInsets.all(12.w),
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 6.h),
                      child: ListTile(
                        leading: _actionIcon(entry.action),
                        title: Text(entry.action, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (entry.details != null)
                              Text(entry.details!, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                            Text(
                              _formatTime(entry.createdAt),
                              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                        trailing: entry.syncStatus == 'PENDING'
                            ? Icon(Icons.cloud_off, size: 16.sp, color: Colors.orange)
                            : Icon(Icons.cloud_done, size: 16.sp, color: Colors.green),
                      ),
                    );
                  },
                ),
    );
  }

  Icon _actionIcon(String action) {
    switch (action) {
      case 'VISITE_DEBUT':
      case 'VISITE_FIN':
        return const Icon(Icons.visibility, color: Colors.blue);
      case 'ENCAISSEMENT':
        return const Icon(Icons.payments, color: Colors.green);
      case 'SYNC':
        return const Icon(Icons.sync, color: Colors.teal);
      default:
        return const Icon(Icons.history, color: Colors.grey);
    }
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} - '
        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
