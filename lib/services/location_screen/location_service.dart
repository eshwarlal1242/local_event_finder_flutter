import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  static const String apiKey = "AIzaSyC-gEOhHqgjnIhdX_xowK_jMQhzhBo0iSE";

  static Future<LatLng?> getCoordinatesFromAddress(String address) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$apiKey",
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (data["status"] == "OK") {
      final lat = data["results"][0]["geometry"]["location"]["lat"];
      final lng = data["results"][0]["geometry"]["location"]["lng"];
      return LatLng(lat, lng);
    }

    return null;
  }
}
