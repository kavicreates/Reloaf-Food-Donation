import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ActiveDeliveryPage extends StatefulWidget {
  final String orderId;
  final String restaurantName;
  final String orderName;
  final double orderLat;
  final double orderLng;
  final double deliveryPersonLat;
  final double deliveryPersonLng;

  const ActiveDeliveryPage({
    required this.orderId,
    required this.restaurantName,
    required this.orderName,
    required this.orderLat,
    required this.orderLng,
    required this.deliveryPersonLat,
    required this.deliveryPersonLng,
    super.key,
  });

  @override
  _ActiveDeliveryPageState createState() => _ActiveDeliveryPageState();
}

class _ActiveDeliveryPageState extends State<ActiveDeliveryPage> {
  late LatLng _orderLocation;
  late LatLng _deliveryPersonLocation;

  @override
  void initState() {
    super.initState();
    _orderLocation = LatLng(widget.orderLat, widget.orderLng);
    _deliveryPersonLocation = LatLng(widget.deliveryPersonLat, widget.deliveryPersonLng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Active Delivery"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Active Delivery Header
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Delivery',
                  style: Theme.of(context).textTheme.headlineMedium, // Updated
                ),
                Text(
                  'Restaurant: ${widget.restaurantName}',
                  style: Theme.of(context).textTheme.bodyLarge, // Updated
                ),
                Text(
                  'Order: ${widget.orderName}',
                  style: Theme.of(context).textTheme.bodyMedium, // Updated
                ),
              ],
            ),
          ),

          // OpenStreetMap
          Container(
            height: 300,
            child: FlutterMap(
              options: MapOptions(
                center: _orderLocation,
                zoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _orderLocation,
                      builder: (ctx) => Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                    Marker(
                      point: _deliveryPersonLocation,
                      builder: (ctx) => Icon(
                        Icons.delivery_dining,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
