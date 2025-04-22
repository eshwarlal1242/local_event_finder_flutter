// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';


import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      Navigator.pop(context, _selectedLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a location")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Location")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(26.2389, 68.3822), // Default location
          zoom: 14,
        ),
        onTap: _onMapTapped,
        markers: _selectedLocation == null
            ? {}
            : {
          Marker(
            markerId: MarkerId("selected"),
            position: _selectedLocation!,
          ),
        },
        onMapCreated: (controller) {
          _mapController = controller;
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _confirmLocation,
        label: Text("Confirm Location"),
        icon: Icon(Icons.check),
      ),
    );
  }
}























// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:http/http.dart' as http;
//
// class GoogleMapScreen extends StatefulWidget {
//   const GoogleMapScreen({super.key});
//
//   @override
//   State<GoogleMapScreen> createState() => _GoogleMapScreenState();
// }
//
// class _GoogleMapScreenState extends State<GoogleMapScreen> {
//   GoogleMapController? _mapController;
//   Position? _currentPosition;
//   LatLng? _destination;
//   List<LatLng> _routePoints = [];
//   final String _apiKey = 'AIzaSyC-gEOhHqgjnIhdX_xowK_jMQhzhBo0iSE'; // Replace with a valid API Key
//
//   final Map<String, LatLng> cities = {
//     'Karachi': LatLng(24.8607, 67.0011),
//     'Lahore': LatLng(31.5497, 74.3436),
//     'Islamabad': LatLng(33.6844, 73.0479),
//     'Quetta': LatLng(30.1798, 66.9750),
//     'Peshawar': LatLng(34.0151, 71.5249),
//   };
//
//   String? _selectedCity;
//
//   @override
//   void initState() {
//     super.initState();
//     _determinePosition();
//   }
//
//   Future<void> _determinePosition() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       _showError('Location services are disabled.');
//       return;
//     }
//
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.deniedForever) {
//         _showError('Location permissions are permanently denied.');
//         return;
//       }
//     }
//
//     Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     setState(() {
//       _currentPosition = position;
//     });
//
//     // Move camera to current position
//     if (_mapController != null) {
//       _mapController!.animateCamera(
//         CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
//       );
//     }
//   }
//
//   void _setDestination(String city) {
//     setState(() {
//       _destination = cities[city];
//       _selectedCity = city;
//       _routePoints.clear();
//     });
//     _fetchRoute();
//   }
//
//   Future<void> _fetchRoute() async {
//     if (_currentPosition == null || _destination == null) return;
//
//     final url = Uri.parse(
//         'https://maps.googleapis.com/maps/api/directions/json?origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=${_destination!.latitude},${_destination!.longitude}&key=$_apiKey');
//
//     final response = await http.get(url);
//     final data = json.decode(response.body);
//
//     if (data['status'] == 'OK') {
//       List<PointLatLng> points = PolylinePoints().decodePolyline(
//           data['routes'][0]['overview_polyline']['points']);
//
//       setState(() {
//         _routePoints = points
//             .map((point) => LatLng(point.latitude, point.longitude))
//             .toList();
//       });
//
//       // Move camera to fit the route
//       _mapController!.animateCamera(
//         CameraUpdate.newLatLngBounds(
//           LatLngBounds(
//             southwest: LatLng(
//               _currentPosition!.latitude < _destination!.latitude
//                   ? _currentPosition!.latitude
//                   : _destination!.latitude,
//               _currentPosition!.longitude < _destination!.longitude
//                   ? _currentPosition!.longitude
//                   : _destination!.longitude,
//             ),
//             northeast: LatLng(
//               _currentPosition!.latitude > _destination!.latitude
//                   ? _currentPosition!.latitude
//                   : _destination!.latitude,
//               _currentPosition!.longitude > _destination!.longitude
//                   ? _currentPosition!.longitude
//                   : _destination!.longitude,
//             ),
//           ),
//           100.0, // Padding
//         ),
//       );
//
//     } else {
//       _showError('Failed to fetch route. Try again.');
//     }
//   }
//
//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Google Maps")),
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: _currentPosition != null
//                 ? CameraPosition(
//               target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
//               zoom: 15,
//             )
//                 : const CameraPosition(target: LatLng(0, 0), zoom: 2),
//             onMapCreated: (GoogleMapController controller) {
//               _mapController = controller;
//             },
//             markers: {
//               if (_currentPosition != null)
//                 Marker(
//                   markerId: const MarkerId("currentLocation"),
//                   position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
//                   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//                 ),
//               if (_destination != null)
//                 Marker(
//                   markerId: const MarkerId("destination"),
//                   position: _destination!,
//                   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//                 ),
//             },
//             polylines: {
//               if (_routePoints.isNotEmpty)
//                 Polyline(
//                   polylineId: const PolylineId("route"),
//                   points: _routePoints,
//                   color: Colors.blue,
//                   width: 5,
//                 ),
//             },
//           ),
//           Positioned(
//             top: 10,
//             left: 10,
//             right: 10,
//             child: DropdownButtonFormField<String>(
//               value: _selectedCity,
//               hint: const Text("Select a city"),
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//               items: cities.keys.map((String city) {
//                 return DropdownMenuItem<String>(
//                   value: city,
//                   child: Text(city),
//                 );
//               }).toList(),
//               onChanged: (String? city) {
//                 if (city != null) {
//                   _setDestination(city);
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _determinePosition,
//         child: const Icon(Icons.my_location),
//       ),
//     );
//   }
// }
