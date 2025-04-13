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

  final List<String> _tabs = ['Current', 'History', 'Tracking'];

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
                    if (user != null &&
                        nameController.text.isNotEmpty &&
                        quantityController.text.isNotEmpty) {
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
                        "status": "available",
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
    return _firestore
        .collection("users")
        .doc(user.uid)
        .collection("food")
        .where("status", isEqualTo: filter)
        .orderBy("timestamp", descending: true)
        .snapshots();
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
                trailing: filter == "available"
                    ? IconButton(
                  icon: const Icon(Icons.delete, color: Colors.grey),
                  onPressed: () async {
                    await food.reference.delete();
                  },
                )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      buildFoodList("available"),
      buildFoodList("picked up"),
      const Center(child: Text("Tracking (to be implemented)")), // Placeholder
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Restaurant Dashboard - ${_tabs[_selectedIndex]}", ),
        backgroundColor: Colors.redAccent,
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
