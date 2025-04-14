// geolocator_service.dart
import 'package:geolocator/geolocator.dart';

class GeolocatorService {
  // Function to get the current position (latitude and longitude)
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    // If location services are not enabled, return null
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    // Request location permission if not granted
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // If permission is permanently denied, return null
    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // Get and return the current position (latitude and longitude)
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
