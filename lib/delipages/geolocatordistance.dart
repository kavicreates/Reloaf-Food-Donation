// geolocator_distance.dart

import 'package:geolocator/geolocator.dart';

class GeolocatorDistance {
  // Method to calculate the distance between two locations
  static Future<double> calculateDistance(
      double lat1, double lon1, double lat2, double lon2) async {
    // Using Geolocator to calculate the distance
    double distanceInMeters = await Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    return distanceInMeters / 1000; // Return distance in kilometers
  }
}
