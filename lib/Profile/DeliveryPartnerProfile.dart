import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Homes/DeliveryPartnerHome.dart';

class DeliveryPartnerProfile extends StatefulWidget {
  const DeliveryPartnerProfile({super.key});

  @override
  State<DeliveryPartnerProfile> createState() => _DeliveryPartnerProfileState();
}

class _DeliveryPartnerProfileState extends State<DeliveryPartnerProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final vehicleController = TextEditingController();

  bool isEditing = true;
  Map<String, dynamic>? userProfile;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          userProfile = data;
          nameController.text = data['name'] ?? '';
          phoneController.text = data['phone'] ?? '';
          addressController.text = data['address'] ?? '';
          vehicleController.text = data['vehicle'] ?? '';
          isEditing = !(data['isProfileComplete'] ?? false);
        });
      }
    }
  }

  Future<void> submitProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      final profileData = {
        "name": nameController.text,
        "phone": phoneController.text,
        "address": addressController.text,
        "vehicle": vehicleController.text,
        "isProfileComplete": true,
      };

      await _firestore.collection('users').doc(user.uid).update(profileData);

      setState(() {
        userProfile = {...userProfile ?? {}, ...profileData};
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile submitted successfully!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DeliveryPartnerHome()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delivery Partner Profile"),
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
              enabled: isEditing,
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
              enabled: isEditing,
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: "Address"),
              enabled: isEditing,
            ),
            TextField(
              controller: vehicleController,
              decoration: const InputDecoration(labelText: "Vehicle"),
              enabled: isEditing,
            ),
            const SizedBox(height: 30),
            if (isEditing)
              ElevatedButton(
                onPressed: submitProfile,
                child: const Text("Submit"),
              ),
          ],
        ),
      ),
    );
  }
}
