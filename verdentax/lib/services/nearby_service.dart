import 'dart:math';
import 'package:logger/logger.dart';
import '../models/models.dart';

class NearbyService {
  static final NearbyService _instance = NearbyService._internal();
  factory NearbyService() => _instance;
  NearbyService._internal();

  final Logger _logger = Logger();

  List<NearbyContribuable> findNearbyContribuables({
    required double agentLat,
    required double agentLng,
    required List<ContribuableDto> contribuables,
    double radiusMeters = 500,
  }) {
    final results = <NearbyContribuable>[];

    for (final c in contribuables) {
      if (c.latitude == null || c.longitude == null) continue;

      final distance = _haversineDistance(
        agentLat, agentLng,
        c.latitude!, c.longitude!,
      );

      if (distance <= radiusMeters) {
        results.add(NearbyContribuable(
          contribuable: c,
          distanceMeters: distance,
        ));
      }
    }

    results.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return results;
  }

  double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;
}

class NearbyContribuable {
  final ContribuableDto contribuable;
  final double distanceMeters;

  NearbyContribuable({
    required this.contribuable,
    required this.distanceMeters,
  });

  String get distanceLabel {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()} m';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }
}
