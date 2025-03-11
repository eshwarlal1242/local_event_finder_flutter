import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  LatLng? _destination;
  List<LatLng> _routePoints = [];
  final TextEditingController _locationController = TextEditingController();
  final String _apiKey = 'AIzaSyC-gEOhHqgjnIhdX_xowK_jMQhzhBo0iSE';

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // Get the user's current location
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });
  }

  // Search for a location and fetch coordinates
  Future<void> _searchLocation(String location) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=$location&key=$_apiKey');
    final response = await http.get(url);
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      final lat = data['results'][0]['geometry']['location']['lat'];
      final lng = data['results'][0]['geometry']['location']['lng'];
      setState(() {
        _destination = LatLng(lat, lng);
      });
      _fetchRoute();
    } else {
      _showError('Location not found. Try again.');
    }
  }

  // Fetch the route using Google Directions API
  Future<void> _fetchRoute() async {
    if (_currentPosition == null || _destination == null) return;

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=${_destination!.latitude},${_destination!.longitude}&key=$_apiKey');
    final response = await http.get(url);
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      List<PointLatLng> points = PolylinePoints().decodePolyline(
          data['routes'][0]['overview_polyline']['points']);
      setState(() {
        _routePoints = points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      });
    } else {
      _showError('Failed to fetch route. Try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Google Maps")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _currentPosition != null
                ? CameraPosition(
              target:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              zoom: 15,
            )
                : const CameraPosition(target: LatLng(0, 0), zoom: 2),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            markers: {
              if (_currentPosition != null)
                Marker(
                  markerId: const MarkerId("currentLocation"),
                  position: LatLng(
                      _currentPosition!.latitude, _currentPosition!.longitude),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                ),
              if (_destination != null)
                Marker(
                  markerId: const MarkerId("destination"),
                  position: _destination!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                ),
            },
            polylines: {
              if (_routePoints.isNotEmpty)
                Polyline(
                  polylineId: const PolylineId("route"),
                  points: _routePoints,
                  color: Colors.blue,
                  width: 5,
                ),
            },
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Enter destination',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.blue),
                  onPressed: () {
                    if (_locationController.text.isNotEmpty) {
                      _searchLocation(_locationController.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _determinePosition,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
