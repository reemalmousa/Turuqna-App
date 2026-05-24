import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class ReportScreen extends StatefulWidget {
  final String userId;
  const ReportScreen({super.key, required this.userId});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _descController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  LatLng _selectedPos = const LatLng(26.4207, 50.0888);
  final MapController _mapController = MapController();

  String? selectedCity;
  String? selectedDistrict;

  final Color primaryTeal = const Color(0xFF1D6B60);

  final Map<String, List<String>> locations = {
    "Dammam": ["Al Shatea","Al Rayyan","Al Jamiyin","Al Faisaliyah","Al Mazruiyah","Al Nuzha"],
    "Khobar": ["Golden Belt","Al Buhairah","Corniche","Al Aqrabiyah","Al Rakah","Al Tahliyah"],
    "Dhahran": ["Doha","Al Dana","Al Qusur","West Dhahran","Ajyal"]
  };

  final Map<String, LatLng> districtCoordinates = {
    // Dhahran
    "Doha":          LatLng(26.338399, 50.168036),
    "Al Dana":       LatLng(26.332489, 50.149309),
    "Al Qusur":      LatLng(26.346020, 50.152107),
    "West Dhahran":  LatLng(26.315038, 50.127842),
    "Ajyal":         LatLng(26.265744, 50.074363),
    // Dammam
    "Al Shatea":     LatLng(26.478346, 50.129872),
    "Al Rayyan":     LatLng(26.413159, 50.092942),
    "Al Jamiyin":    LatLng(26.397849, 50.099695),
    "Al Faisaliyah": LatLng(26.396526, 50.071206),
    "Al Mazruiyah":  LatLng(26.448608, 50.119563),
    "Al Nuzha":      LatLng(26.401797, 50.109271),
    // Khobar
    "Golden Belt":   LatLng(26.317119, 50.197037),
    "Al Buhairah":   LatLng(26.189997, 50.178769),
    "Corniche":      LatLng(26.332621, 50.239568),
    "Al Aqrabiyah":  LatLng(26.298660, 50.192822),
    "Al Rakah":      LatLng(26.363909, 50.272146),
    "Al Tahliyah":   LatLng(26.189394, 50.197654),
  };

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image != null) setState(() => _imageFile = File(image.path));
  }

  void _onDistrictSelected(String? district) {
    setState(() => selectedDistrict = district);
    if (district != null && districtCoordinates.containsKey(district)) {
      final newPos = districtCoordinates[district]!;
      setState(() => _selectedPos = newPos);
      _mapController.move(newPos, 14.0);
    }
  }

  Future<void> _submitReport() async {
    if (_descController.text.isEmpty || _imageFile == null || selectedCity == null || selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All fields are required")));
      return;
    }
    setState(() => _isLoading = true);
    try {
      var url = Uri.parse("http://10.0.2.2:8080/turuqna_api/api_check_ai.php");
      var request = http.MultipartRequest('POST', url);
      request.fields.addAll({
        "description": _descController.text,
        "citizen_id": widget.userId,
        "city": selectedCity!,
        "district": selectedDistrict!,
        "lat": _selectedPos.latitude.toString(),
        "lng": _selectedPos.longitude.toString(),
      });
      request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var data = json.decode(response.body);
      if (data['status'] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message']), backgroundColor: Colors.green));
        Navigator.pop(context);
      } else {
        _showRejectionDialog(data['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Processing... wait 10 seconds and try again.")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showRejectionDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Submission Refused", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: primaryTeal, foregroundColor: Colors.white, title: const Text("New Report"), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("1. Tap map to set location:", style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              height: 180,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedPos,
                    initialZoom: 13.0,
                    onTap: (tp, p) => setState(() => _selectedPos = p),
                  ),
                  children: [
                    TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.graduation.turuqna'),
                    MarkerLayer(markers: [
                      Marker(point: _selectedPos, child: const Icon(Icons.location_on, color: Colors.red, size: 35))
                    ])
                  ],
                ),
              ),
            ),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  hint: const Text("City"),
                  items: locations.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() { selectedCity = v; selectedDistrict = null; }),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  hint: const Text("District"),
                  value: selectedDistrict,
                  items: selectedCity == null ? [] : locations[selectedCity]!.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: _onDistrictSelected,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            const Text("2. Description:", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: _descController, maxLines: 3, decoration: const InputDecoration(hintText: "Describe the traffic situation...", border: OutlineInputBorder())),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.camera), icon: Icon(Icons.camera_alt, color: primaryTeal), label: Text("Camera", style: TextStyle(color: primaryTeal)))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.gallery), icon: Icon(Icons.image, color: primaryTeal), label: Text("Gallery", style: TextStyle(color: primaryTeal)))),
            ]),
            if (_imageFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(_imageFile!, height: 130, width: double.infinity, fit: BoxFit.cover)),
              ),
            const SizedBox(height: 40),
            Center(
              child: SizedBox(
                width: 250,
                height: 65,
                child: _isLoading
                    ? Column(children: [CircularProgressIndicator(color: primaryTeal), const Text("AI Scanning...", style: TextStyle(fontSize: 10))])
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  onPressed: _submitReport,
                  child: const Text("SUBMIT REPORT", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}