import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// --- Imports for all connected pages ---
import 'report_screen.dart';
import 'my_reports_screen.dart';
import 'profile_screen.dart';
import 'road_suggestions_screen.dart';
import 'notifications_screen.dart';
import 'welcome_screen.dart';

class MapScreen extends StatelessWidget {
  final String userId;
  final String userName;

  // Real constructor to handle your login session
  MapScreen({super.key, required this.userId, required this.userName});

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF1D6B60);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        title: const Text("Turuqna Live Map"),
        elevation: 0,
      ),

      // --- THE SIDEBAR (Connected to Real DB) ---
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
            const Text("Citizen ID: Verified",
                style: TextStyle(color: Colors.white70, fontSize: 12)),
            const Divider(
                color: Colors.white24, indent: 30, endIndent: 30, height: 40),

            _drawerTile(context, Icons.map_outlined, "Live Map", null),

            _drawerTile(context, Icons.add_location_alt_outlined,
                "Send Traffic Report", ReportScreen(userId: userId)),

            _drawerTile(context, Icons.lightbulb_outline, "Road Suggestions",
                RoadSuggestionsScreen(userId: userId)),

            _drawerTile(context, Icons.history, "My Reports & Feedback",
                MyReportsScreen(userId: userId)),

            _drawerTile(context, Icons.notifications_none, "Notifications",
                NotificationsScreen(userId: userId)),

            _drawerTile(context, Icons.person_outline, "My Profile",
                ProfileScreen(userId: userId)),

            const Spacer(),

            // RED LOGOUT BUTTON
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                  onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (c) => const WelcomeScreen()),
                      (route) => false),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text("Logout",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),

      // --- MAIN BODY: FIXED MAP & BUTTON ---
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter:
                  LatLng(26.4207, 50.0888), // Centered on Dammam/Dhahran
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // --- THE CRITICAL FIX FOR 403 ERROR ---
                userAgentPackageName: 'com.graduation.turuqna_app',
              ),
              const MarkerLayer(
                markers: [
                  Marker(
                      point: LatLng(26.4207, 50.0888),
                      child: Icon(Icons.location_on,
                          color: Colors.blue, size: 45)),
                ],
              ),
            ],
          ),

          // Floating Report Button
          Positioned(
            bottom: 40,
            left: 50,
            right: 50,
            child: SizedBox(
              height: 60,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 8,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ReportScreen(userId: userId)));
                },
                icon: const Icon(Icons.add_circle_outline, size: 28),
                label: const Text("REPORT TRAFFIC",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerTile(
      BuildContext context, IconData icon, String title, Widget? page) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title,
          style: const TextStyle(color: Colors.white, fontSize: 16)),
      onTap: () {
        Navigator.pop(context); // Close Drawer
        if (page != null) {
          Navigator.push(context, MaterialPageRoute(builder: (c) => page));
        }
      },
    );
  }
}
