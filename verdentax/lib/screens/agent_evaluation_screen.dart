import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class AgentEvaluationScreen extends StatefulWidget {
  const AgentEvaluationScreen({super.key});

  @override
  State<AgentEvaluationScreen> createState() => _AgentEvaluationScreenState();
}

class _AgentEvaluationScreenState extends State<AgentEvaluationScreen> {
  ContribuableDto? _contribuable;
  int _evaluation = 3;
  final _commentaireController = TextEditingController();
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ContribuableDto) {
      _contribuable = args;
    }
  }

  @override
  void dispose() {
    _commentaireController.dispose();
    super.dispose();
  }

  Future<void> _saveEvaluation() async {
    setState(() => _isSaving = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      final agentId = int.tryParse(user?.id ?? '') ?? 0;

      final auditService = AuditService();
      await auditService.logAction(
        agentId: agentId,
        agentName: user?.fullName ?? 'Agent',
        action: 'EVALUATION_CONTRIBUABLE',
        entityType: 'CONTRIBUABLE',
        entityId: _contribuable?.id?.toString(),
        details: 'Note: $_evaluation/5 - ${_commentaireController.text.trim()}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Évaluation enregistrée')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
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
      appBar: AppBar(title: const Text('Évaluation')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_contribuable != null)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.h),
                  child: Text(_contribuable!.fullName, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                ),
              ),
            SizedBox(height: 16.h),

            Text('Évaluation du contribuable', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Text('Comment évaluez-vous la coopération de ce contribuable ?', style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)),
            SizedBox(height: 16.h),

            // Stars
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _evaluation ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40.sp,
                    ),
                    onPressed: () => setState(() => _evaluation = index + 1),
                  );
                }),
              ),
            ),
            Center(
              child: Text(
                _evaluationLabels[_evaluation - 1],
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: _evaluationColors[_evaluation - 1]),
              ),
            ),
            SizedBox(height: 16.h),

            // Commentaire
            TextField(
              controller: _commentaireController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Commentaire (optionnel)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
            SizedBox(height: 16.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveEvaluation,
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
    );
  }

  static const _evaluationLabels = [
    'Très mauvaise coopération',
    'Mauvaise coopération',
    'Coopération moyenne',
    'Bonne coopération',
    'Excellente coopération',
  ];

  static const _evaluationColors = [
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.lightGreen,
    Colors.green,
  ];
}
