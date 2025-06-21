import 'package:flutter/material.dart';

class ActiveDeliveryPage extends StatelessWidget {
  final String orderId;
  final String restaurantName;
  final String orderName;
  final double orderLat;
  final double orderLng;
  final double deliveryPersonLat;
  final double deliveryPersonLng;

  const ActiveDeliveryPage({
    super.key,
    required this.orderId,
    required this.restaurantName,
    required this.orderName,
    required this.orderLat,
    required this.orderLng,
    required this.deliveryPersonLat,
    required this.deliveryPersonLng,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Active Delivery"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📦 Order ID: $orderId", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("🍴 Restaurant: $restaurantName", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("🧾 Order: $orderName", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Text("📍 Order Location:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Latitude: $orderLat, Longitude: $orderLng"),
            const SizedBox(height: 10),
            Text("🚴 Delivery Partner Location:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Latitude: $deliveryPersonLat, Longitude: $deliveryPersonLng"),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.done),
                label: const Text("Mark as Delivered"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
