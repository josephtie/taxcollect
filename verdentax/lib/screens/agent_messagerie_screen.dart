import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class AgentMessagerieScreen extends StatefulWidget {
  const AgentMessagerieScreen({super.key});

  @override
  State<AgentMessagerieScreen> createState() => _AgentMessagerieScreenState();
}

class _AgentMessagerieScreenState extends State<AgentMessagerieScreen> {
  final Logger _logger = Logger();
  bool _isLoading = true;
  List<MessageDto> _messages = [];
  SignalementType? _selectedSignalement;
  final _commentaireController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _commentaireController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      final agentId = int.tryParse(user?.id ?? '') ?? 0;

      final messagerieService = MessagerieService();
      final messages = await messagerieService.getMessages(agentId);
      if (mounted) setState(() { _messages = messages; _isLoading = false; });
    } catch (e) {
      _logger.e('Erreur messages: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendSignalement() async {
    if (_selectedSignalement == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez un type de signalement')),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      final agentId = int.tryParse(user?.id ?? '') ?? 0;

      final messagerieService = MessagerieService();
      await messagerieService.sendSignalement(
        agentId: agentId,
        agentNom: user?.fullName,
        signalementType: _selectedSignalement!,
        contenu: _commentaireController.text.trim().isEmpty ? null : _commentaireController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signalement envoyé')),
        );
        setState(() {
          _selectedSignalement = null;
          _commentaireController.clear();
          _isSending = false;
        });
        _loadMessages();
      }
    } catch (e) {
      _logger.e('Erreur envoi: $e');
      if (mounted) setState(() => _isSending = false);
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
        title: const Text('Messagerie'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMessages),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Signalement form
                Card(
                  margin: EdgeInsets.all(12.w),
                  child: Padding(
                    padding: EdgeInsets.all(16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Signaler un problème', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                        SizedBox(height: 12.h),
                        ...SignalementType.values.map((s) => RadioListTile<SignalementType>(
                          value: s,
                          groupValue: _selectedSignalement,
                          onChanged: (v) => setState(() => _selectedSignalement = v),
                          title: Text(s.label, style: TextStyle(fontSize: 13.sp)),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        )),
                        SizedBox(height: 8.h),
                        TextField(
                          controller: _commentaireController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Commentaire',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSending ? null : _sendSignalement,
                            icon: _isSending
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.send),
                            label: Text(_isSending ? 'Envoi...' : 'ENVOYER'),
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
                // Messages list
                Expanded(
                  child: _messages.isEmpty
                      ? Center(child: Text('Aucun message', style: TextStyle(fontSize: 14.sp, color: Colors.grey)))
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final m = _messages[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 6.h),
                              child: ListTile(
                                leading: Icon(
                                  m.isFromAgent ? Icons.send : Icons.mark_email_read,
                                  color: m.isFromAgent ? Colors.blue : Colors.green,
                                ),
                                title: Text(m.sujet ?? m.type.label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                                subtitle: Text(m.contenu, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600), maxLines: 2, overflow: TextOverflow.ellipsis),
                                trailing: m.isRead
                                    ? null
                                    : Container(width: 8.w, height: 8.h, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
