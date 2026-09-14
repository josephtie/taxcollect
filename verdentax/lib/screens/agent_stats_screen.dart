import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class AgentStatsScreen extends StatefulWidget {
  const AgentStatsScreen({super.key});

  @override
  State<AgentStatsScreen> createState() => _AgentStatsScreenState();
}

class _AgentStatsScreenState extends State<AgentStatsScreen> {
  final Logger _logger = Logger();
  bool _isLoading = true;
  StatsPeriod _period = StatsPeriod.aujourdHui;
  AgentStats? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      final agentId = int.tryParse(user?.id ?? '') ?? 0;

      final statsService = AgentStatsService();
      final stats = await statsService.getStats(agentId, _period);
      if (mounted) setState(() { _stats = stats; _isLoading = false; });
    } catch (e) {
      _logger.e('Erreur stats: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _periodLabel {
    switch (_period) {
      case StatsPeriod.aujourdHui: return 'Aujourd\'hui';
      case StatsPeriod.semaine: return 'Cette semaine';
      case StatsPeriod.mois: return 'Ce mois';
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
      appBar: AppBar(title: const Text('Mes statistiques')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period selector
                  SegmentedButton<StatsPeriod>(
                    segments: const [
                      ButtonSegment(value: StatsPeriod.aujourdHui, label: Text('Jour')),
                      ButtonSegment(value: StatsPeriod.semaine, label: Text('Semaine')),
                      ButtonSegment(value: StatsPeriod.mois, label: Text('Mois')),
                    ],
                    selected: {_period},
                    onSelectionChanged: (set) {
                      setState(() => _period = set.first);
                      _loadStats();
                    },
                  ),
                  SizedBox(height: 16.h),

                  if (_stats != null) ...[
                    // Total collecté
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          Text('Total collecté', style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
                          SizedBox(height: 4.h),
                          Text(
                            '${_stats!.totalCollecte.toStringAsFixed(0)} FCFA',
                            style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4.h),
                          Text(_periodLabel, style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // KPIs grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 8.h,
                      crossAxisSpacing: 8.w,
                      childAspectRatio: 1.4,
                      children: [
                        KpiCard(title: 'Paiements', value: '${_stats!.nbPaiements}', icon: Icons.payments, color: Colors.green),
                        KpiCard(title: 'Visites', value: '${_stats!.nbVisites}', icon: Icons.visibility, color: Colors.blue),
                        KpiCard(title: 'Contribuables visités', value: '${_stats!.nbContribuablesVisites}', icon: Icons.people, color: Colors.teal),
                        KpiCard(title: 'Taux réussite', value: '${_stats!.tauxReussite.toStringAsFixed(0)}%', icon: Icons.trending_up, color: Colors.indigo),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Répartition par mode
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Répartition par mode', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                            SizedBox(height: 12.h),
                            _modeRow('Espèces', _stats!.especeCollecte, Colors.green),
                            SizedBox(height: 8.h),
                            _modeRow('Mobile Money', _stats!.mobileMoneyCollecte, Colors.blue),
                            SizedBox(height: 8.h),
                            Divider(),
                            _modeRow('Total', _stats!.totalCollecte, Theme.of(context).primaryColor, isBold: true),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Bar chart placeholder
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Évolution', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                            SizedBox(height: 12.h),
                            SizedBox(
                              height: 120.h,
                              child: CustomPaint(
                                size: Size(double.infinity, 120.h),
                                painter: SimpleBarChartPainter(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _modeRow(String label, double montant, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 12.w, height: 12.h, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3.r))),
            SizedBox(width: 8.w),
            Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
        Text('${montant.toStringAsFixed(0)} FCFA', style: TextStyle(fontSize: 14.sp, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: color)),
      ],
    );
  }
}

class SimpleBarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final values = [0.3, 0.5, 0.7, 0.4, 0.8, 0.6, 0.9];
    final barWidth = size.width / (values.length * 2);
    final paint = Paint()
      ..color = Colors.teal
      ..style = PaintingStyle.fill;

    for (int i = 0; i < values.length; i++) {
      final barHeight = size.height * values[i];
      final x = i * barWidth * 2 + barWidth / 2;
      final y = size.height - barHeight;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
