import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../deliverypages/order_accepted_page.dart';

class AvailabilityToggleWidget extends StatefulWidget {
  const AvailabilityToggleWidget({super.key});

  @override
  State<AvailabilityToggleWidget> createState() => _AvailabilityToggleWidgetState();
}

class _AvailabilityToggleWidgetState extends State<AvailabilityToggleWidget> {
  bool _available = false;

  Future<void> _updateAvailability(bool status) async {
    // Get the currently logged-in user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;  // Get the user's unique ID from Firebase Auth
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      try {
        // Update the availability status in Firestore for the current user
        await firestore.collection('users').doc(userId).set({
          'available': status,
        }, SetOptions(merge: true));

        // If the status is enabled, navigate to the available orders page
        if (status) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AvailableOrdersPage()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to update availability: $e")),
        );
      }
    } else {
      // Handle case where no user is logged in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ No user logged in")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("🟢 Enable Availability", style: TextStyle(fontSize: 18)),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _available = !_available;
            });
            _updateAvailability(_available);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _available ? Colors.green : Colors.grey,
          ),
          child: Text(_available ? "Enabled" : "Enable"),
        ),
      ],
    );
  }
}
