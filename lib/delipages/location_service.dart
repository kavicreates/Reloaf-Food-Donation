// location_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';  // Import the Position class
import 'geolocator_service.dart'; // Import the simplified GeolocatorService

class LocationService {
  final GeolocatorService _geolocatorService = GeolocatorService();

  // Function to save the location to Firestore
  Future<void> saveLocationToFirestore() async {
    Position? position = await _geolocatorService.getCurrentPosition();

    if (position != null) {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "default_user_id"; // Get current user's UID
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      try {
        await firestore.collection('users').doc(userId).set({
          'location': GeoPoint(position.latitude, position.longitude),
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print("Location saved successfully!");
      } catch (e) {
        print("Error saving location: $e");
      }
    } else {
      print("Unable to get location");
    }
  }
}
