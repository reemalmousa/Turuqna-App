import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'report_screen.dart';
import 'my_reports_screen.dart';
import 'profile_screen.dart';
import 'road_suggestions_screen.dart';
import 'notifications_screen.dart';
import 'welcome_screen.dart';

class MapScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const MapScreen({super.key, this.userId = "1131897342", this.userName = "User"});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(26.4207, 50.0888); // default fallback
  bool _locationLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception("GPS timeout"),
      );

      final newLocation = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _currentLocation = newLocation;
        _locationLoaded = true;
      });
      _mapController.move(newLocation, 15);
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF1D6B60);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        title: const Text("Turuqna Live Map"),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _fetchLocation,
            tooltip: "Go to my location",
          )
        ],
      ),
      drawer: Drawer(
        backgroundColor: primaryTeal,
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text(widget.userName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const Divider(color: Colors.white24, indent: 20, endIndent: 20),
            _drawerTile(context, Icons.map, "Live Map", null),
            _drawerTile(context, Icons.add_location, "Send Report",
                ReportScreen(userId: widget.userId)),
            _drawerTile(context, Icons.lightbulb, "Road Suggestions",
                RoadSuggestionsScreen(userId: widget.userId)),
            _drawerTile(context, Icons.history, "My Reports",
                MyReportsScreen(userId: widget.userId)),
            _drawerTile(context, Icons.notifications, "Notifications",
                NotificationsScreen(userId: widget.userId)),
            _drawerTile(context, Icons.person, "Profile",
                ProfileScreen(userId: widget.userId)),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text("Logout", style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (c) => const WelcomeScreen()),
                      (r) => false),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
                initialCenter: _currentLocation,
                initialZoom: 12),
            children: [
              TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.turuqna'),
              MarkerLayer(markers: [
                Marker(
                  point: _currentLocation,
                  child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
                )
              ]),
            ],
          ),

          // Loading indicator while fetching location
          if (!_locationLoaded)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 14, height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 8),
                      Text("Detecting location..."),
                    ],
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: 30,
            left: 50,
            right: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  padding: const EdgeInsets.all(15)),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) => ReportScreen(userId: widget.userId))),
              child: const Text("REPORT TRAFFIC",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _drawerTile(BuildContext context, IconData i, String t, Widget? p) {
    return ListTile(
      leading: Icon(i, color: Colors.white),
      title: Text(t, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        if (p != null)
          Navigator.push(context, MaterialPageRoute(builder: (c) => p));
      },
    );
  }
}