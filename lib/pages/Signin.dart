import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginPage.dart';
import 'package:geolocator/geolocator.dart';



class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  String role = "Orphanage";
  final isProfileComplete=false;

  Future<Position> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied.");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> signin() async {
    try {
      Position position = await getUserLocation();
      GeoPoint geoPoint = GeoPoint(position.latitude, position.longitude);

      UserCredential userCredentials = await _auth
          .createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: pwController.text.trim());

      await _firestore.collection("users").doc(userCredentials.user!.uid).set({
        "email": emailController.text,
        "password": pwController.text,
        "role": role,
        "location": geoPoint,
        "isProfileComplete": false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Created account successfully")));
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign In"),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),


            SizedBox(height: 16),
            TextField(
              controller: pwController,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),
            Text("Select Role", style: TextStyle(fontWeight: FontWeight.bold)),
            Column(
              children: [
                RadioListTile(
                  value: "Orphanage",
                  title: Text("Orphanage"),
                  groupValue: role,
                  onChanged: (value) {
                    setState(() {
                      role = value.toString();
                    });
                  },
                ),
                RadioListTile(
                  title: Text("Restaurant"),
                  value: "Restaurant",
                  groupValue: role,
                  onChanged: (value) {
                    setState(() {
                      role = value.toString();
                    });
                  },
                ),
                RadioListTile(
                  title: Text("Delivery Partner"),
                  value: "DeliveryPartner",
                  groupValue: role,
                  onChanged: (value) {
                    setState(() {
                      role = value.toString();
                    });
                  },
                )
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: signin,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text("Sign In", style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(height: 12),
            Text("Already have an account?"),
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              ),
              child: Text("Login Here"),
            )
          ],
        ),
      ),
    );
  }
}
