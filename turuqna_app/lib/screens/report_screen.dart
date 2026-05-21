import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class ReportScreen extends StatefulWidget {
  final String userId; // Added to handle real user session
  const ReportScreen({super.key, required this.userId});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _descController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  LatLng _selectedPos = const LatLng(26.4207, 50.0888);

  String? selectedCity;
  String? selectedDistrict;

  final Color primaryTeal = const Color(0xFF1D6B60);

  final Map<String, List<String>> locations = {
    "Dammam": [
      "Al Shatea",
      "Al Rayyan",
      "Al Jamiyin",
      "Al Faisaliyah",
      "Al Mazruiyah",
      "Al Nuzha"
    ],
    "Khobar": [
      "Golden Belt",
      "Al Buhairah",
      "Corniche",
      "Al Aqrabiyah",
      "Al Rakah",
      "Al Tahliyah"
    ],
    "Dhahran": ["Doha", "Al Dana", "Al Qusur", "West Dhahran", "Ajyal"]
  };

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image != null) setState(() => _imageFile = File(image.path));
  }

  Future<void> _submitReport() async {
    if (_descController.text.isEmpty ||
        _imageFile == null ||
        selectedCity == null ||
        selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All fields are required")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest('POST',
          Uri.parse("http://10.0.2.2:8080/turuqna_api/api_check_ai.php"));
      request.fields.addAll({
        "description": _descController.text,
        "citizen_id": widget.userId, // Sending the REAL ID of logged in user
        "city": selectedCity!,
        "district": selectedDistrict!,
        "lat": _selectedPos.latitude.toString(),
        "lng": _selectedPos.longitude.toString(),
      });
      request.files
          .add(await http.MultipartFile.fromPath('image', _imageFile!.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var data = json.decode(response.body);

      if (data['status'] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(data['message']), backgroundColor: Colors.green));
        Navigator.pop(context);
      } else {
        _showRejection(data['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Processing... Try clicking again.")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showRejection(String msg) {
    showDialog(
        context: context,
        builder: (ctx) =>
            AlertDialog(
                title:
                    const Text("Refused", style: TextStyle(color: Colors.red)),
                content: Text(msg),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("OK"))
                ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          title: const Text("Submit Traffic Report")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("1. Tap map to set location:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              height: 180,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FlutterMap(
                  options: MapOptions(
                      initialCenter: _selectedPos,
                      onTap: (tp, p) => setState(() => _selectedPos = p)),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      // FIXED: This line stops the Access Blocked error
                      userAgentPackageName: 'com.graduation.turuqna',
                    ),
                    MarkerLayer(markers: [
                      Marker(
                          point: _selectedPos,
                          child: const Icon(Icons.location_on,
                              color: Colors.red, size: 35))
                    ])
                  ],
                ),
              ),
            ),
            Row(children: [
              Expanded(
                  child: DropdownButtonFormField<String>(
                      hint: const Text("City"),
                      items: locations.keys
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() {
                            selectedCity = v;
                            selectedDistrict = null;
                          }),
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()))),
              const SizedBox(width: 10),
              Expanded(
                  child: DropdownButtonFormField<String>(
                      hint: const Text("District"),
                      value: selectedDistrict,
                      items: selectedCity == null
                          ? []
                          : locations[selectedCity]!
                              .map((d) =>
                                  DropdownMenuItem(value: d, child: Text(d)))
                              .toList(),
                      onChanged: (v) => setState(() => selectedDistrict = v),
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 20),
            const Text("2. Describe traffic:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: "Describe the traffic issue...",
                    border: OutlineInputBorder())),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                  child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Camera"))),
              const SizedBox(width: 10),
              Expanded(
                  child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.image),
                      label: const Text("Gallery"))),
            ]),
            if (_imageFile != null)
              Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_imageFile!,
                          height: 130,
                          width: double.infinity,
                          fit: BoxFit.cover))),
            const SizedBox(height: 40),
            Center(
                child: SizedBox(
                    width: 250,
                    height: 55,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primaryTeal,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            onPressed: _submitReport,
                            child: const Text("SUBMIT REPORT",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold))))),
          ],
        ),
      ),
    );
  }
}
