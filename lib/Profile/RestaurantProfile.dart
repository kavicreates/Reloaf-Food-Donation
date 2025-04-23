import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/Homes/RestaurantHome.dart';

class RestaurantProfile extends StatefulWidget {
  const RestaurantProfile({super.key});

  @override
  State<RestaurantProfile> createState() => _RestaurantProfileState();
}

class _RestaurantProfileState extends State<RestaurantProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? userData;
  bool isLoading = true;

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
        isLoading = false;
      });
    }
  }

  Future<void> updateField(String key, String value) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({key: value});
      await loadUserData(); // refresh the UI
    }
  }

  void showEditDialog(String field, String currentValue) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $field"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: "$field"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await updateField(field, controller.text);
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget userField(String label, String value) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value),
      trailing: IconButton(
        icon: Icon(Icons.edit, color: Colors.deepPurple),
        onPressed: () => showEditDialog(label, value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || userData == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Profile")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          userField("Name", userData!["name"] ?? ""),
          userField("Email", userData!["email"] ?? ""),
          userField("Phone", userData!["phone"] ?? ""),
          ElevatedButton(onPressed: ()=>{
            // User? currUser=_auth.currentUser;
            Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>RestaurantHome()))}, child: Text("Submit"),
          ),

        ],
      ),
    );
  }
}
