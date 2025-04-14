import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'activedeliverypage.dart'; // Make sure this import is correct

class AvailableOrdersPage extends StatefulWidget {
  const AvailableOrdersPage({super.key});

  @override
  _AvailableOrdersPageState createState() => _AvailableOrdersPageState();
}

class _AvailableOrdersPageState extends State<AvailableOrdersPage> {
  Position? _deliveryPersonPosition;
  bool _loading = true;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _getDeliveryPersonPosition();
  }

  Future<void> _getDeliveryPersonPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw Exception("Location permission not granted");
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _deliveryPersonPosition = position;
      });

      await _fetchOrders();
    } catch (e) {
      print("⚠️ Error getting location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location: $e")),
      );
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _fetchOrders() async {
    try {
      if (_deliveryPersonPosition == null) {
        print("⛔ Position is null, skipping fetch.");
        return;
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore.collection('orders').get();

      List<Map<String, dynamic>> nearbyOrders = [];

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        if (data['accept'] == false &&
            data['delivered'] == false &&
            data['source'] != null) {
          GeoPoint source = data['source'];

          double distanceInMeters = Geolocator.distanceBetween(
            _deliveryPersonPosition!.latitude,
            _deliveryPersonPosition!.longitude,
            source.latitude,
            source.longitude,
          );

          double distanceInKm = distanceInMeters / 1000;

          if (distanceInKm <= 5) {
            nearbyOrders.add({
              'docId': doc.id,
              'orderId': data['orid'],
              'restaurantName': data['restname'],
              'orderName': data['orname'],
              'distance': distanceInKm,
              'orderLat': source.latitude,
              'orderLng': source.longitude,
            });
          }
        }
      }

      nearbyOrders.sort((a, b) => a['distance'].compareTo(b['distance']));

      setState(() {
        _orders = nearbyOrders;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error fetching orders: $e")),
      );
    }
  }

  Future<void> _acceptOrder(String docId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('orders').doc(docId);
      await docRef.update({'accept': true});

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActiveDeliveryPage(
            orderId: docId,
            restaurantName: "Dummy Restaurant", // Update this with actual data
            orderName: "Dummy Order", // Update this with actual data
            orderLat: 13.3266681, // Example latitude
            orderLng: 80.195746, // Example longitude
            deliveryPersonLat: _deliveryPersonPosition?.latitude ?? 0.0,
            deliveryPersonLng: _deliveryPersonPosition?.longitude ?? 0.0,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to accept order: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Orders"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? const Center(child: Text("No nearby orders available"))
          : ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          var order = _orders[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("🏨 Restaurant: ${order['restaurantName']}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("🏠 Orphanage: ${order['orderName']}",
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Text("📏 Distance: ${order['distance'].toStringAsFixed(2)} km",
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _acceptOrder(order['docId']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text("Accept"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            _loading = true;
          });
          await _getDeliveryPersonPosition();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
