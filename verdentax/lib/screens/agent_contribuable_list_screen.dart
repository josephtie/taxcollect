import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class AgentContribuableListScreen extends StatefulWidget {
  const AgentContribuableListScreen({super.key});

  @override
  State<AgentContribuableListScreen> createState() => _AgentContribuableListScreenState();
}

class _AgentContribuableListScreenState extends State<AgentContribuableListScreen> {
  final Logger _logger = Logger();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<ContribuableDto> _contribuables = [];
  List<ContribuableDto> _filtered = [];

  @override
  void initState() {
    super.initState();
    _loadContribuables();
  }

  Future<void> _loadContribuables() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ApiService();
      final result = await apiService.getAllContribuables();
      if (mounted) {
        setState(() {
          _contribuables = result;
          _filtered = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.e('Erreur chargement contribuables: $e');
      // Try offline cache
      final storageService = StorageService();
      final cached = await storageService.getCachedData<List<dynamic>>('contribuables');
      if (cached != null && mounted) {
        setState(() {
          _contribuables = cached.map((j) => ContribuableDto.fromJson(j as Map<String, dynamic>)).toList();
          _filtered = _contribuables;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filter(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      _filtered = _contribuables.where((c) {
        final nom = c.nom.toLowerCase();
        final prenom = c.prenom.toLowerCase();
        final tel = c.telephone?.toLowerCase() ?? '';
        final activite = c.activite?.toLowerCase() ?? '';
        final adresse = c.adresse?.toLowerCase() ?? '';
        final numero = c.numeroContribuable?.toLowerCase() ?? '';
        return nom.contains(q) ||
            prenom.contains(q) ||
            tel.contains(q) ||
            activite.contains(q) ||
            adresse.contains(q) ||
            numero.contains(q);
      }).toList();
    });
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
        title: const Text('Contribuables'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadContribuables,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(12.w),
            child: TextField(
              controller: _searchController,
              onChanged: _filter,
              decoration: InputDecoration(
                hintText: 'Nom, téléphone, numéro, activité...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filter('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
          // Count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_filtered.length} contribuable(s)',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? Center(
                        child: Text(AppConfig.noDataFound, style: TextStyle(fontSize: 14.sp)),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final c = _filtered[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 8.h),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                child: Icon(Icons.person, color: Theme.of(context).primaryColor),
                              ),
                              title: Text(c.fullName, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (c.activite != null)
                                    Text(c.activite!, style: TextStyle(fontSize: 12.sp)),
                                  if (c.telephone != null)
                                    Text('Tél: ${c.telephone}', style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
                                  if (c.quartier != null)
                                    Text('Quartier: ${c.quartier}', style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
                                ],
                              ),
                              trailing: c.statut != null
                                  ? Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: _statusColor(c.statut!).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: Text(
                                        c.statut!,
                                        style: TextStyle(fontSize: 10.sp, color: _statusColor(c.statut!)),
                                      ),
                                    )
                                  : null,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/agent-contribuable-detail',
                                  arguments: c,
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'actif':
        return Colors.green;
      case 'à recouvrer':
      case 'a recouvrer':
        return Colors.orange;
      case 'payé':
      case 'paye':
        return Colors.blue;
      case 'suspendu':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
