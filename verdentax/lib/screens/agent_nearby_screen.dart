import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class AgentNearbyScreen extends StatefulWidget {
  const AgentNearbyScreen({super.key});

  @override
  State<AgentNearbyScreen> createState() => _AgentNearbyScreenState();
}

class _AgentNearbyScreenState extends State<AgentNearbyScreen> {
  final Logger _logger = Logger();
  bool _isLoading = true;
  List<NearbyContribuable> _nearby = [];
  double _selectedRadius = 500;
  final List<double> _radiusOptions = [50, 100, 250, 500, 1000];

  @override
  void initState() {
    super.initState();
    _loadNearby();
  }

  Future<void> _loadNearby() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ApiService();
      final contribuables = await apiService.getAllContribuables();

      final nearbyService = NearbyService();
      final results = nearbyService.findNearbyContribuables(
        agentLat: AppConfig.defaultLatitude,
        agentLng: AppConfig.defaultLongitude,
        contribuables: contribuables,
        radiusMeters: _selectedRadius,
      );

      if (mounted) {
        setState(() {
          _nearby = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.e('Erreur chargement proximité: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _distanceColor(double distance) {
    if (distance < 100) return Colors.green;
    if (distance < 250) return Colors.orange;
    return Colors.red;
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
        title: const Text('Proche de moi'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadNearby),
        ],
      ),
      body: Column(
        children: [
          // Radius selector
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Wrap(
              spacing: 8.w,
              children: _radiusOptions.map((radius) {
                return ChoiceChip(
                  label: Text(radius < 1000 ? '${radius.round()} m' : '${(radius / 1000).toStringAsFixed(1)} km'),
                  selected: _selectedRadius == radius,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedRadius = radius);
                      _loadNearby();
                    }
                  },
                );
              }).toList(),
            ),
          ),
          // Agent position
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Icon(Icons.my_location, color: Theme.of(context).primaryColor, size: 18.sp),
                SizedBox(width: 6.w),
                Text('Ma position: ${AppConfig.defaultLatitude}, ${AppConfig.defaultLongitude}', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _nearby.isEmpty
                    ? Center(child: Text('Aucun contribuable dans un rayon de ${_selectedRadius.round()}m', style: TextStyle(fontSize: 13.sp, color: Colors.grey)))
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        itemCount: _nearby.length,
                        itemBuilder: (context, index) {
                          final item = _nearby[index];
                          final c = item.contribuable;
                          return Card(
                            margin: EdgeInsets.only(bottom: 8.h),
                            child: ListTile(
                              leading: Container(
                                width: 12.w,
                                height: 12.h,
                                decoration: BoxDecoration(
                                  color: _distanceColor(item.distanceMeters),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              title: Text(c.fullName, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                              subtitle: Text(c.activite ?? '', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                              trailing: Text(
                                item.distanceLabel,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: _distanceColor(item.distanceMeters),
                                ),
                              ),
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
}
