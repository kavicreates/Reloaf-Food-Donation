import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../delipages/AvailableOrdersPage.dart'; // Import the new page

class DeliveryPartnerHome extends StatefulWidget {
  const DeliveryPartnerHome({super.key});

  @override
  State<DeliveryPartnerHome> createState() => _DeliveryPartnerHomeState();
}

class _DeliveryPartnerHomeState extends State<DeliveryPartnerHome> {
  bool _locationEnabled = false;
  bool _availability = false;
  int _selectedIndex = 0;
  Position? _currentPosition;
  Stream<Position>? _positionStream;

  final List<String> _tabs = ['Current', 'History', 'Tracking'];

  @override
  void initState() {
    super.initState();
    _showLocationPopup();
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _showLocationPopup() async {
    await Future.delayed(const Duration(milliseconds: 500));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enable Location"),
        content: const Text("This app requires your location to continue."),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _enableLocation();
            },
            child: const Text("Enable"),
          ),
        ],
      ),
    );
  }

  Future<void> _enableLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Location services are disabled.")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Location permission permanently denied.")),
      );
      return;
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      _positionStream?.listen((Position position) async {
        print("📍 Latitude: ${position.latitude}, Longitude: ${position.longitude}");

        setState(() {
          _locationEnabled = true;
          _currentPosition = position;
        });

        await _saveLocationToFirestore(position);
      });
    }
  }

  Future<void> _saveLocationToFirestore(Position position) async {
    String userId = "FL75iibXHBWXUhFWckDaG4IMzKf2";  // Example user ID
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('users').doc(userId).set({
        'location': GeoPoint(position.latitude, position.longitude),
        'available': _availability,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Location successfully updated!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to save location: $e")),
      );
      print("Error updating location: $e");
    }
  }

  // Function to toggle availability and navigate to available orders page
  void _toggleAvailability() {
    setState(() {
      _availability = !_availability;
    });
    if (_currentPosition != null) {
      _saveLocationToFirestore(_currentPosition!);
    }

    // After enabling availability, navigate to available orders page
    if (_availability) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AvailableOrdersPage()),
      );
    }
  }

  Widget buildCurrentTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("👋 Welcome Delivery Partner", style: TextStyle(fontSize: 22)),
          const SizedBox(height: 20),
          Text(
            _locationEnabled ? "📍 Location Enabled" : "📍 Location Not Enabled",
            style: TextStyle(
              fontSize: 18,
              color: _locationEnabled ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("🟢 Availability for Delivery", style: TextStyle(fontSize: 18)),
              ElevatedButton(
                onPressed: _locationEnabled && _currentPosition != null
                    ? _toggleAvailability
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _availability ? Colors.green : Colors.grey,
                ),
                child: Text(_availability ? "Enabled" : "Enable"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      buildCurrentTab(),
      const Center(child: Text("📜 Delivery History - To be implemented")),
      const Center(child: Text("🚚 Tracking Deliveries - To be implemented")),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Delivery Dashboard - ${_tabs[_selectedIndex]}"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      drawer: _locationEnabled
          ? Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text("Delivery Menu", style: TextStyle(color: Colors.white)),
            ),
            ListTile(title: Text("Profile")),
            ListTile(title: Text("Logout")),
          ],
        ),
      )
          : null,
      body: tabs[_selectedIndex],
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
