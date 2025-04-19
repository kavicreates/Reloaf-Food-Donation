import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/pages/LoginPage.dart';

class OrphanageHome extends StatefulWidget {
  const OrphanageHome({super.key});

  @override
  State<OrphanageHome> createState() => _OrphanageHomeState();
}

class _OrphanageHomeState extends State<OrphanageHome> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  User? currUser;

  List<String> tabs = ["Home", "History", "Tracking"];
  int tabindex = 0;

  TextEditingController reqnumcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    currUser = FirebaseAuth.instance.currentUser;
  }

  void onTabTap(index) {
    setState(() {
      tabindex = index;
    });
  }

  //method for loading history
  // Widget buildStream(){
  //   return StreamBuilder(stream: getHistory, builder: ()=>{
  //
  //   })
  // }

  //method to update current requirement
  void updateReqNum() {
    if (currUser != null && reqnumcontroller.text.isNotEmpty) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(currUser!.uid)
          .collection("Requirement")
          .doc(currUser!.uid)
          .set({
        "amount": reqnumcontroller.text,
        "timestamp": FieldValue.serverTimestamp()
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("User not logged in", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginPage()));
                },
                child: const Text("Login"),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Orphanage ${tabs[tabindex]}"),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add Requirement",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurpleAccent),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: "Enter number of people",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                controller: reqnumcontroller,
              ),
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton(
                  onPressed: updateReqNum,
                  child: const Text("Submit"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Your current requirement:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(currUser!.uid)
                          .collection("Requirement")
                          .doc(currUser!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Text("0",
                              style: TextStyle(fontSize: 24));
                        }
                        final data =
                        snapshot.data!.data() as Map<String, dynamic>;
                        final reqnum = data["amount"];
                        return Text(
                          reqnum,
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurpleAccent),
                        );
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTap,
        currentIndex: tabindex,
        selectedItemColor: Colors.deepPurple,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping), label: "Tracking"),
        ],
      ),
    );
  }
}
