import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/availability_toggle.dart';
import '../Profile/DeliveryPartnerProfile.dart';

class DeliveryPartnerHome extends StatefulWidget {
  const DeliveryPartnerHome({super.key});

  @override
  State<DeliveryPartnerHome> createState() => _DeliveryPartnerHomeState();
}

class _DeliveryPartnerHomeState extends State<DeliveryPartnerHome> {
  bool locationEnabled = false;
  int tabIndex = 0;

  @override
  void initState() {
    super.initState();
    checkLocationStatus();
  }

  Future<void> checkLocationStatus() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Enable Location"),
          content: const Text("Location is required to proceed. Please enable it."),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Geolocator.openLocationSettings();
                await Future.delayed(const Duration(seconds: 3));
                bool newStatus = await Geolocator.isLocationServiceEnabled();
                if (newStatus) {
                  setState(() => locationEnabled = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("✅ Location Enabled")),
                  );
                }
              },
              child: const Text("Enable"),
            ),
          ],
        ),
      );
    } else {
      setState(() => locationEnabled = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Location Enabled")),
      );
    }
  }

  void onTabTap(int index) {
    setState(() {
      tabIndex = index;
    });
  }

  final List<Widget> pages = [
    HomePageContent(),
    Center(child: Text("📜 History Page - Coming Soon")),
    Center(child: Text("📦 Tracking Page - Coming Soon")),
    DeliveryPartnerProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Delivery Partner")),
      body: pages[tabIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTap,
        currentIndex: tabIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: "Tracking"),
          BottomNavigationBarItem(icon: Icon(Icons.contact_emergency), label: "Profile"),
        ],
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("👋 Welcome Delivery Partner", style: TextStyle(fontSize: 22)),
          const SizedBox(height: 20),
          const Text("✅ Location is Enabled", style: TextStyle(color: Colors.green)),
          const SizedBox(height: 20),
          AvailabilityToggleWidget(),
        ],
      ),
    );
  }
}
