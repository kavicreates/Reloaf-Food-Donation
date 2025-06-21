import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> checkAndRequestLocation(BuildContext context) async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enable Location"),
        content: const Text("Please turn on your device location."),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await requestLocationPermission(context);
            },
            child: const Text("Enable"),
          ),
        ],
      ),
    );
  } else {
    await requestLocationPermission(context);
  }
}

Future<void> requestLocationPermission(BuildContext context) async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.deniedForever) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Location permission permanently denied.")),
    );
    return;
  }

  if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
    Position position = await Geolocator.getCurrentPosition();
    await _saveLocationToFirestore(position, context);
  }
}

Future<void> _saveLocationToFirestore(Position position, BuildContext context) async {
  const String userId = "FL75iibXHBWXUhFWckDaG4IMzKf2";
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    await firestore.collection('users').doc(userId).set({
      'location': GeoPoint(position.latitude, position.longitude),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Location updated!")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Error saving location: $e")),
    );
  }
}
