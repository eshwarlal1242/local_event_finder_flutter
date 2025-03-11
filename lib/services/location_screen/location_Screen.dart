import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerScreen extends StatefulWidget {
  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng _selectedLocation = const LatLng(37.7749, -122.4194); // Default location (San Francisco)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick Event Location")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _selectedLocation, zoom: 14),
        markers: {Marker(markerId: const MarkerId("picked"), position: _selectedLocation)},
        onTap: (LatLng position) {
          setState(() => _selectedLocation = position);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check),
        onPressed: () => Navigator.pop(context, _selectedLocation),
      ),
    );
  }
}
