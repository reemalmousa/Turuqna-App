import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'report_screen.dart';
import 'my_reports_screen.dart';
import 'profile_screen.dart';
import 'road_suggestions_screen.dart';
import 'notifications_screen.dart';
import 'welcome_screen.dart';

class MapScreen extends StatelessWidget {
  final String userId;
  final String userName;

  // FIXED: Constructor now correctly accepts data
  MapScreen({super.key, this.userId = "1131897342", this.userName = "User"});

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF1D6B60);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        title: const Text("Turuqna Live Map"),
      ),
      drawer: Drawer(
        backgroundColor: primaryTeal,
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text(userName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const Divider(color: Colors.white24, indent: 20, endIndent: 20),
            _drawerTile(context, Icons.map, "Live Map", null),
            _drawerTile(context, Icons.add_location, "Send Report",
                ReportScreen(userId: userId)),
            _drawerTile(context, Icons.lightbulb, "Road Suggestions",
                RoadSuggestionsScreen(userId: userId)),
            _drawerTile(context, Icons.history, "My Reports",
                MyReportsScreen(userId: userId)),
            _drawerTile(context, Icons.notifications, "Notifications",
                NotificationsScreen(userId: userId)),
            _drawerTile(context, Icons.person, "Profile",
                ProfileScreen(userId: userId)),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title:
                  const Text("Logout", style: TextStyle(color: Colors.white)),
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
            options: const MapOptions(
                initialCenter: LatLng(26.4207, 50.0888), initialZoom: 12),
            children: [
              TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.turuqna'),
              const MarkerLayer(markers: [
                Marker(
                    point: LatLng(26.4207, 50.0888),
                    child:
                        Icon(Icons.location_on, color: Colors.blue, size: 40))
              ]),
            ],
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
                      builder: (c) => ReportScreen(userId: userId))),
              child: const Text("REPORT TRAFFIC",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  // FIXED: Moved this inside the class
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
