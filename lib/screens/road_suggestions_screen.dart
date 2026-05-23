import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class RoadSuggestionsScreen extends StatefulWidget {
  final String userId;
  const RoadSuggestionsScreen({super.key, required this.userId});

  @override
  State<RoadSuggestionsScreen> createState() => _RoadSuggestionsScreenState();
}

class _RoadSuggestionsScreenState extends State<RoadSuggestionsScreen> {
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
    final image = await picker.pickImage(source: source, imageQuality: 50);
    if (image != null) setState(() => _imageFile = File(image.path));
  }

  Future<void> _submitSuggestion() async {
    if (_descController.text.isEmpty ||
        _imageFile == null ||
        selectedCity == null ||
        selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please fill all fields and add a photo")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      var url = Uri.parse(
          "http://10.0.2.2:8080/turuqna_api/api_submit_suggestion.php");
      var request = http.MultipartRequest('POST', url);

      request.fields.addAll({
        "description": _descController.text,
        "citizen_id": widget.userId,
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error connecting to server")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Road Suggestions"),
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("1. Select Location on Map:",
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
                      userAgentPackageName: 'com.graduation.turuqna',
                    ),
                    MarkerLayer(markers: [
                      Marker(
                          point: _selectedPos,
                          child: const Icon(Icons.location_on,
                              color: Colors.blue, size: 35))
                    ])
                  ],
                ),
              ),
            ),
            Row(children: [
              Expanded(
                  child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      hint: const Text("City"),
                      items: locations.keys
                          .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c,
                                  style: const TextStyle(fontSize: 14))))
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
                      isExpanded: true,
                      hint: const Text("District"),
                      value: selectedDistrict,
                      items: selectedCity == null
                          ? []
                          : locations[selectedCity]!
                              .map((d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(d,
                                      style: const TextStyle(fontSize: 14))))
                              .toList(),
                      onChanged: (v) => setState(() => selectedDistrict = v),
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 20),
            const Text("2. Your Suggestion:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                    hintText: "E.g. Broken street lights or road damage...",
                    border: OutlineInputBorder())),
            const SizedBox(height: 20),

            // --- ADDED PHOTO BUTTONS ---
            const Text("3. Upload Supporting Photo:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: Icon(Icons.camera_alt, color: primaryTeal),
                        label: Text("Camera",
                            style: TextStyle(color: primaryTeal)))),
                const SizedBox(width: 10),
                Expanded(
                    child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: Icon(Icons.image, color: primaryTeal),
                        label: Text("Gallery",
                            style: TextStyle(color: primaryTeal)))),
              ],
            ),
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
                        onPressed: _submitSuggestion,
                        child: const Text("SUBMIT",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
