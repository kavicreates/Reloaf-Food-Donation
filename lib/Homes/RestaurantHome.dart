import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RestaurantHome extends StatefulWidget {
  const RestaurantHome({Key? key}) : super(key: key);

  @override
  State<RestaurantHome> createState() => _RestaurantHomeState();
}

class _RestaurantHomeState extends State<RestaurantHome> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0;

  final List<String> _tabs = ['Current', 'History', 'Tracking','Profile'];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void addFood() {
    TextEditingController nameController = TextEditingController();
    TextEditingController descController = TextEditingController();
    TextEditingController quantityController = TextEditingController();
    String selectedType = "Veg";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add New Food"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Name"),
                    ),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: "Description"),
                    ),
                    TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(labelText: "Quantity"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: selectedType,
                      items: ["Veg", "Non-Veg"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    // Fetch user's document
                    if (user != null &&
                        nameController.text.isNotEmpty &&
                        quantityController.text.isNotEmpty) {
                      DocumentSnapshot userDoc = await _firestore
                          .collection("users")
                          .doc(user.uid)
                          .get();
                      GeoPoint? userLocation = userDoc.get("location");
                      await _firestore
                          .collection("users")
                          .doc(user.uid)
                          .collection("food")
                          .add({
                        "name": nameController.text,
                        "description": descController.text,
                        "quantity": quantityController.text,
                        "type": selectedType,
                        "timestamp": FieldValue.serverTimestamp(),
                        "status": "draft",
                        "location":userLocation
                      });
                      await _firestore
                          .collection("food")
                          .add({
                        "name": nameController.text,
                        "description": descController.text,
                        "quantity": quantityController.text,
                        "type": selectedType,
                        "timestamp": FieldValue.serverTimestamp(),
                        "status": "draft",
                        "location":userLocation
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> getFoodStream(String filter) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    // return _firestore
    //     .collection("users")
    //     .doc(user.uid)
    //     .collection("food")
    //     .where("status", isEqualTo: filter)
    //     .orderBy("timestamp", descending: true)
    //     .snapshots();
    final ref = _firestore
        .collection("users")
        .doc(user.uid)
        .collection("food");

    if (filter == "combined") {
      return ref
          .where("status", whereIn: ["draft", "available"])
          .orderBy("timestamp", descending: true)
          .snapshots();
    } else {
      return ref
          .where("status", isEqualTo: filter)
          .orderBy("timestamp", descending: true)
          .snapshots();
    }
  }

  Widget buildProfile (BuildContext context){

      final user=FirebaseAuth.instance.currentUser;
      if(user==null) return const Center(child: Text("not logged in lil bro"),);
      final profileObj=_firestore.collection("users").doc(user.uid).get();

    return FutureBuilder<DocumentSnapshot>(
      future: profileObj,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong"));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("No profile found"));
        }
        final data = snapshot.data!.data() as Map<String, dynamic>;
        return SingleChildScrollView(
          child: Column(
            children: [
              const Text("Name:"),
              Text(data['name'] ?? 'No name'),
              // Add more fields like email, age, etc., if needed
            ],
          ),
        );
      },
    );
  }
  Widget buildFoodList(String filter) {
    return StreamBuilder<QuerySnapshot>(
      stream: getFoodStream(filter),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final foodList = snapshot.data!.docs;

        if (foodList.isEmpty) {
          return const Center(child: Text("No items to show."));
        }

        return ListView.builder(
          itemCount: foodList.length,
          itemBuilder: (context, index) {
            final food = foodList[index];
            final data = food.data() as Map<String, dynamic>;

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: Icon(
                  data["type"] == "Veg" ? Icons.eco : Icons.no_meals,
                  color: data["type"] == "Veg" ? Colors.green : Colors.red,
                ),
                title: Text(data["name"]),
                subtitle: Text("${data["description"]} • Qty: ${data["quantity"]}"),
                // trailing: filter == "available"
                //     ? IconButton(
                //   icon: const Icon(Icons.delete, color: Colors.grey),
                //   onPressed: () async {
                //     await food.reference.delete();
                //   },
                // )
                //     : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (data["status"] == "draft") ...[
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () async {
                          await food.reference.delete();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.lock_outline, color: Colors.blueAccent),
                        tooltip: "Freeze Donation",
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Freeze Donation?"),
                              content: const Text("Once frozen, this food item cannot be edited or deleted."),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Freeze")),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await food.reference.update({"status": "available"});
                          }
                        },
                      ),
                    ] else
                      const Icon(Icons.lock, color: Colors.grey),
                  ],
                ),

              ),
            );
          },
        );
      },
    );
  }
  Widget buildCombinedFoodList() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("Not logged in"));

    final ref = _firestore
        .collection("users")
        .doc(user.uid)
        .collection("food")
        .orderBy("timestamp", descending: true);

    final draftStream = ref.where("status", isEqualTo: "draft").snapshots();
    final availableStream = ref.where("status", isEqualTo: "available").snapshots();

    return SingleChildScrollView(
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Expanded(
                 StreamBuilder<QuerySnapshot>(
                  stream: draftStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final items = snapshot.data!.docs;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text("Draft Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        if (items.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text("No draft items."),
                          ),
                        ...items.map((doc) => buildFoodCard(doc)).toList(),
                      ],
                    );
                  },
                ),
        // ),
         StreamBuilder<QuerySnapshot>(
            stream: availableStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final items = snapshot.data!.docs;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text("Available Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("No available items."),
                    ),
                  ...items.map((doc) => buildFoodCard(doc)).toList(),
                ],
              );
            },
          ),

      ],
    ),
    );
  }
  Widget buildFoodCard(DocumentSnapshot food) {
    final data = food.data() as Map<String, dynamic>;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Icon(
          data["type"] == "Veg" ? Icons.eco : Icons.no_meals,
          color: data["type"] == "Veg" ? Colors.green : Colors.red,
        ),
        title: Text(data["name"]),
        subtitle: Text("${data["description"]} • Qty: ${data["quantity"]}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (data["status"] == "draft") ...[
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.grey),
                onPressed: () async {
                  await food.reference.delete();
                },
              ),
              IconButton(
                icon: const Icon(Icons.lock_outline, color: Colors.blueAccent),
                tooltip: "Freeze Donation",
                onPressed: () async {
                  //add orders collection to firebase once frozen
                  // if(FirebaseAuth.instance.currentUser!=null) {
                  //   User? userCred = FirebaseAuth.instance.currentUser;
                  //   FirebaseFirestore.instance.collection("orders").add({"name":""});
                  // }
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Freeze Donation?"),
                      content: const Text("Once frozen, this food item cannot be edited or deleted."),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Freeze")),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await food.reference.update({"status": "available"});
                  }
                },
              ),
            ] else
              const Icon(Icons.lock, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      buildCombinedFoodList(),
      buildFoodList("picked up"),
      // buildCombinedFoodList("combined"),
      const Center(child: Text("Tracking (to be implemented)")),
      // Placeholder
      buildProfile(context),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Restaurant Dashboard - ${_tabs[_selectedIndex]}", ),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: tabs[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: addFood,
        child: const Icon(Icons.add),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: "Current"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: "Tracking"),
          BottomNavigationBarItem(icon: Icon(Icons.person),label: "Profile"),
        ],
      ),
    );
  }
}


//
// class RestaurantHome extends StatelessWidget {
//   const RestaurantHome({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Text("data");
//   }
// }
