import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../models/conflict.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class AgentConflictScreen extends StatefulWidget {
  const AgentConflictScreen({super.key});

  @override
  State<AgentConflictScreen> createState() => _AgentConflictScreenState();
}

class _AgentConflictScreenState extends State<AgentConflictScreen> {
  final Logger _logger = Logger();
  bool _isLoading = true;
  List<ConflictDto> _conflicts = [];

  @override
  void initState() {
    super.initState();
    _loadConflicts();
  }

  Future<void> _loadConflicts() async {
    setState(() => _isLoading = true);
    try {
      final conflictService = ConflictService();
      final conflicts = await conflictService.loadConflicts();
      if (mounted) setState(() { _conflicts = conflicts; _isLoading = false; });
    } catch (e) {
      _logger.e('Erreur conflits: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resolve(ConflictDto conflict, ConflictResolution resolution) async {
    final conflictService = ConflictService();
    await conflictService.resolveConflict(conflict.id, resolution);
    _loadConflicts();
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
        title: const Text('Conflits de sync'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadConflicts),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conflicts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 64.sp, color: Colors.green),
                      SizedBox(height: 8.h),
                      Text('Aucun conflit', style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(12.w),
                  itemCount: _conflicts.length,
                  itemBuilder: (context, index) {
                    final c = _conflicts[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 8.h),
                      child: Padding(
                        padding: EdgeInsets.all(16.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  c.isResolved ? Icons.check_circle : Icons.warning,
                                  color: c.isResolved ? Colors.green : Colors.orange,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(c.type.label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                                const Spacer(),
                                if (c.isResolved && c.resolution != null)
                                  Text(c.resolution!.label, style: TextStyle(fontSize: 11.sp, color: Colors.green)),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text('${c.entityType} #${c.entityId}', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                            if (c.description != null) ...[
                              SizedBox(height: 4.h),
                              Text(c.description!, style: TextStyle(fontSize: 12.sp)),
                            ],
                            if (!c.isResolved) ...[
                              SizedBox(height: 12.h),
                              Wrap(
                                spacing: 8.w,
                                children: ConflictResolution.values.map((r) {
                                  return ElevatedButton(
                                    onPressed: () => _resolve(c, r),
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                      minimumSize: Size.zero,
                                    ),
                                    child: Text(r.label, style: TextStyle(fontSize: 11.sp)),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
