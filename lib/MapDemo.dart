// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
//

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class GoogleMapScreen extends StatefulWidget {
  final double eventLatitude;
  final double eventLongitude;

  const GoogleMapScreen({super.key, required this.eventLatitude, required this.eventLongitude});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  LatLng? _eventLocation;
  LatLng? _currentLocation;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    _setEventLocation();
  }

  void _setEventLocation() {
    setState(() {
      _eventLocation = LatLng(widget.eventLatitude, widget.eventLongitude);
      isLoading = false;
    });
    fetchRoute();
  }

  Future<void> fetchRoute() async {
    if (_currentLocation == null || _eventLocation == null) return;

    final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
            '${_currentLocation!.longitude},${_currentLocation!.latitude};'
            '${_eventLocation!.longitude},${_eventLocation!.latitude}?overview=full&geometries=polyline');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry'];
      List<LatLng> routeCoordinates = _decodePolyline(geometry);

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: PolylineId('route'),
            points: routeCoordinates,
            color: Colors.blue,
            width: 5,
          ),
        );
        // Adding markers for the current location and event location
        _markers.add(Marker(
          markerId: MarkerId('currentLocation'),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));

        _markers.add(Marker(
          markerId: MarkerId('eventLocation'),
          position: _eventLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ));
      });
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polylineCoordinates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event Location')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _eventLocation!,
          zoom: 12,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        markers: _markers,
        polylines: _polylines,
      ),
    );
  }
}

// class GoogleMapScreen extends StatefulWidget {
//   final String cityName;
//
//   const GoogleMapScreen({super.key, required this.cityName});
//
//   @override
//   State<GoogleMapScreen> createState() => _GoogleMapScreenState();
// }
//
// class _GoogleMapScreenState extends State<GoogleMapScreen> {
//   LatLng? _cityLocation;
//   LatLng? _currentLocation;
//   Set<Polyline> _polylines = {};
//   GoogleMapController? _mapController;
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _determinePosition();
//   }
//
//   Future<void> _determinePosition() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) return;
//
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.deniedForever) return;
//     }
//
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     setState(() {
//       _currentLocation = LatLng(position.latitude, position.longitude);
//     });
//
//     _fetchCoordinates(widget.cityName);
//   }
//
//   Future<void> _fetchCoordinates(String city) async {
//     final url = Uri.parse(
//         'https://nominatim.openstreetmap.org/search?q=$city&format=json&limit=1');
//     final response = await http.get(url);
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data.isNotEmpty) {
//         setState(() {
//           _cityLocation =
//               LatLng(double.parse(data[0]['lat']), double.parse(data[0]['lon']));
//           isLoading = false;
//           fetchRoute();
//         });
//       }
//     }
//   }
//
//   Future<void> fetchRoute() async {
//     if (_currentLocation == null || _cityLocation == null) return;
//     final url = Uri.parse(
//         'https://router.project-osrm.org/route/v1/driving/'
//             '${_currentLocation!.longitude},${_currentLocation!.latitude};'
//             '${_cityLocation!.longitude},${_cityLocation!.latitude}?overview=full&geometries=polyline');
//     final response = await http.get(url);
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final geometry = data['routes'][0]['geometry'];
//       List<LatLng> routeCoordinates = _decodePolyline(geometry);
//       setState(() {
//         _polylines = {
//           Polyline(
//             polylineId: PolylineId('route'),
//             points: routeCoordinates,
//             color: Colors.blue,
//             width: 5,
//           ),
//         };
//       });
//     }
//   }
//
//   List<LatLng> _decodePolyline(String encoded) {
//     List<LatLng> polylineCoordinates = [];
//     int index = 0, len = encoded.length;
//     int lat = 0, lng = 0;
//
//     while (index < len) {
//       int shift = 0, result = 0;
//       int b;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1F) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
//       lat += dlat;
//
//       shift = 0;
//       result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1F) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
//       lng += dlng;
//
//       polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
//     }
//     return polylineCoordinates;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.cityName)),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target: _cityLocation!,
//           zoom: 12,
//         ),
//         onMapCreated: (GoogleMapController controller) {
//           _mapController = controller;
//         },
//         markers: {
//           Marker(
//             markerId: const MarkerId('currentLocation'),
//             position: _currentLocation!,
//             icon: BitmapDescriptor.defaultMarkerWithHue(
//                 BitmapDescriptor.hueBlue),
//           ),
//           Marker(
//             markerId: const MarkerId('cityLocation'),
//             position: _cityLocation!,
//             icon: BitmapDescriptor.defaultMarkerWithHue(
//                 BitmapDescriptor.hueRed),
//           ),
//         },
//         polylines: _polylines,
//       ),
//     );
//   }
// }
//
//
//
//
//
//
//
//
//
//
//
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:http/http.dart' as http;
// //
// // class GoogleMapScreen extends StatefulWidget {
// //   final String cityName;
// //
// //   const GoogleMapScreen({super.key, required this.cityName});
// //
// //   @override
// //   State<GoogleMapScreen> createState() => _GoogleMapScreenState();
// // }
// //
// // class _GoogleMapScreenState extends State<GoogleMapScreen> {
// //   LatLng? _cityLocation;
// //   LatLng? _currentLocation;
// //   GoogleMapController? _mapController;
// //   List<LatLng> routeCoordinates = [];
// //   bool isLoading = true;
// //   String errorMessage = "";
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _initMap();
// //   }
// //
// //   Future<void> _initMap() async {
// //     try {
// //       await _determinePosition();
// //       await _fetchCoordinates(widget.cityName);
// //     } catch (e) {
// //       setState(() {
// //         isLoading = false;
// //         errorMessage = "Error loading map: ${e.toString()}";
// //       });
// //     }
// //   }
// //
// //   Future<void> _determinePosition() async {
// //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
// //     if (!serviceEnabled) {
// //       _showMessage("Location services are disabled.");
// //       return;
// //     }
// //
// //     LocationPermission permission = await Geolocator.checkPermission();
// //     if (permission == LocationPermission.denied) {
// //       permission = await Geolocator.requestPermission();
// //       if (permission == LocationPermission.deniedForever) {
// //         _showMessage("Location permissions are permanently denied.");
// //         return;
// //       }
// //     }
// //
// //     Position position = await Geolocator.getCurrentPosition(
// //         desiredAccuracy: LocationAccuracy.high);
// //     setState(() {
// //       _currentLocation = LatLng(position.latitude, position.longitude);
// //     });
// //   }
// //
// //   Future<void> _fetchCoordinates(String city) async {
// //     try {
// //       const String apiKey = 'YOUR_GOOGLE_API_KEY';
// //       final url = Uri.parse(
// //           'https://maps.googleapis.com/maps/api/geocode/json?address=$city&key=$apiKey');
// //
// //       final response = await http.get(url);
// //
// //       if (response.statusCode == 200) {
// //         final data = json.decode(response.body);
// //         if (data['results'].isNotEmpty) {
// //           setState(() {
// //             _cityLocation = LatLng(
// //               data['results'][0]['geometry']['location']['lat'],
// //               data['results'][0]['geometry']['location']['lng'],
// //             );
// //             isLoading = false;
// //           });
// //           _fetchRoute();
// //         } else {
// //           _showMessage("No results found for $city.");
// //         }
// //       } else {
// //         _showMessage("Failed to fetch coordinates.");
// //       }
// //     } catch (e) {
// //       _showMessage("Error fetching coordinates: ${e.toString()}");
// //     }
// //   }
// //
// //   Future<void> _fetchRoute() async {
// //     if (_currentLocation == null || _cityLocation == null) return;
// //
// //     try {
// //       const String apiKey = 'YOUR_GOOGLE_API_KEY';
// //       final url = Uri.parse(
// //           'https://maps.googleapis.com/maps/api/directions/json?origin=${_currentLocation!.latitude},${_currentLocation!.longitude}&destination=${_cityLocation!.latitude},${_cityLocation!.longitude}&key=$apiKey');
// //
// //       final response = await http.get(url);
// //
// //       if (response.statusCode == 200) {
// //         final data = json.decode(response.body);
// //         if (data['routes'].isNotEmpty) {
// //           String polyline = data['routes'][0]['overview_polyline']['points'];
// //           setState(() {
// //             routeCoordinates = _decodePolyline(polyline);
// //           });
// //         } else {
// //           _showMessage("No route found.");
// //         }
// //       } else {
// //         _showMessage("Failed to fetch route.");
// //       }
// //     } catch (e) {
// //       _showMessage("Error fetching route: ${e.toString()}");
// //     }
// //   }
// //
// //   List<LatLng> _decodePolyline(String encoded) {
// //     List<LatLng> polylineCoordinates = [];
// //     int index = 0, len = encoded.length;
// //     int lat = 0, lng = 0;
// //
// //     while (index < len) {
// //       int shift = 0, result = 0;
// //       int b;
// //       do {
// //         b = encoded.codeUnitAt(index++) - 63;
// //         result |= (b & 0x1F) << shift;
// //         shift += 5;
// //       } while (b >= 0x20);
// //       int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
// //       lat += dlat;
// //
// //       shift = 0;
// //       result = 0;
// //       do {
// //         b = encoded.codeUnitAt(index++) - 63;
// //         result |= (b & 0x1F) << shift;
// //         shift += 5;
// //       } while (b >= 0x20);
// //       int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
// //       lng += dlng;
// //
// //       polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
// //     }
// //     return polylineCoordinates;
// //   }
// //
// //   void _showMessage(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text(message)),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text(widget.cityName)),
// //       body: isLoading
// //           ? const Center(child: CircularProgressIndicator())
// //           : errorMessage.isNotEmpty
// //           ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
// //           : GoogleMap(
// //         initialCameraPosition: CameraPosition(
// //           target: _cityLocation!,
// //           zoom: 12,
// //         ),
// //         onMapCreated: (controller) {
// //           _mapController = controller;
// //         },
// //         markers: {
// //           if (_currentLocation != null)
// //             Marker(
// //               markerId: const MarkerId('current'),
// //               position: _currentLocation!,
// //               icon: BitmapDescriptor.defaultMarkerWithHue(
// //                   BitmapDescriptor.hueBlue),
// //               infoWindow: const InfoWindow(title: "Current Location"),
// //             ),
// //           if (_cityLocation != null)
// //             Marker(
// //               markerId: const MarkerId('city'),
// //               position: _cityLocation!,
// //               icon: BitmapDescriptor.defaultMarkerWithHue(
// //                   BitmapDescriptor.hueRed),
// //               infoWindow: InfoWindow(title: widget.cityName),
// //             ),
// //         },
// //         polylines: {
// //           if (routeCoordinates.isNotEmpty)
// //             Polyline(
// //               polylineId: const PolylineId('route'),
// //               points: routeCoordinates,
// //               color: Colors.blue,
// //               width: 5,
// //             ),
// //         },
// //       ),
// //     );
// //   }
// // }
