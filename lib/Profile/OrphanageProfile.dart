import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:untitled/Homes/OrphanageHome.dart';
class OrphanageProfile extends StatefulWidget {
  @override
  _OrphanageProfileState createState() => _OrphanageProfileState();
}

class _OrphanageProfileState extends State<OrphanageProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? userData;
  bool isLoading = true;

  // Controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final capacityController = TextEditingController();

  bool isSubmitEnabled = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        userData = doc.data();
        nameController.text = userData?["name"] ?? "";
        phoneController.text = userData?["phone"] ?? "";
        addressController.text = userData?["address"] ?? "";
        capacityController.text = userData?["capacity"]?.toString() ?? "";
        isLoading = false;
      });
      checkIfAllFilled();
    }
  }

  void checkIfAllFilled() {
    setState(() {
      isSubmitEnabled = nameController.text.isNotEmpty &&
          phoneController.text.isNotEmpty &&
          addressController.text.isNotEmpty &&
          capacityController.text.isNotEmpty;
    });
  }

  Future<void> submitProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        "name": nameController.text,
        "phone": phoneController.text,
        "address": addressController.text,
        "capacity": int.tryParse(capacityController.text) ?? 0,
        "isProfileComplete": true
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>OrphanageHome()));
    }
  }

  Widget editableField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      onChanged: (val) => checkIfAllFilled(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Orphanage Profile")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Orphanage Profile"), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            editableField("Name", nameController),
            editableField("Phone", phoneController),
            editableField("Address", addressController),
            editableField("Capacity", capacityController),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: updateLocation,
              icon: Icon(Icons.location_on),
              label: Text("Update Location"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSubmitEnabled ? submitProfile : null,
              child: Text("Submit Profile"),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSubmitEnabled ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final user = _auth.currentUser;
    if (user != null) {
      GeoPoint geoPoint = GeoPoint(position.latitude, position.longitude);
      await _firestore.collection('users').doc(user.uid).update({
        'location': geoPoint,
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Location updated!")));
    }
  }
}
