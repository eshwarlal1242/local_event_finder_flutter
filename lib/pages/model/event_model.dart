import 'package:latlong2/latlong.dart';

class Event {
  String name;
  String locationName;
  LatLng location;
  String imageUrl;

  Event({
    required this.name,
    required this.locationName,
    required this.location,
    required this.imageUrl,
  });
}
