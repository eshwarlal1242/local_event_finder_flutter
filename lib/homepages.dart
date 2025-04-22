import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_event/pages/bottombar/MyEvent_screen.dart';
import 'package:local_event/pages/bottombar/profile_screen.dart';
import 'package:local_event/pages/bottombar/search_screen.dart';
import 'package:local_event/pages/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

import 'add_event.dart';
import 'eventDetail.dart';

// Uncomment if you have an external SearchScreen implementation
// import 'package:local_event/pages/bottombar/search_screen.dart';


class EventFinderHomePage extends StatefulWidget {
  const EventFinderHomePage({super.key});

  @override
  State<EventFinderHomePage> createState() => _EventFinderHomePageState();
}

class _EventFinderHomePageState extends State<EventFinderHomePage> {
  // Fields used by the Home screen (Event Finder)
  String _location = 'Fetching location...';
  bool _isLoading = true;
  Position? _currentPosition;
  List<Map<String, dynamic>> _events = [];

  // Index for the bottom navigation bar
  int _currentIndex = 0;
  String userName = 'Hi, User 👋';
  String? imagePath;

  @override
  void initState() {
    super.initState();
    fetchAndSetLocation();
    _loadUserData();
  }

  // -------------------- Home Screen Functions --------------------

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = 'Hi, ${prefs.getString('name') ?? 'User'} 👋';
      imagePath = prefs.getString('imagePath');
    });
  }


  Future<void> fetchAndSetLocation() async {
    setState(() => _isLoading = true);
    String location = await getCurrentLocation();
    await fetchEventsFromFirestore();
    setState(() {
      _location = location;
      _isLoading = false;
    });
  }

  Future<String> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return 'Location services are disabled';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Location permission denied';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return 'Location permissions are permanently denied';
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = position;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];
        return '${place.locality ?? ''}, ${place.country ?? ''}';
      } else {
        return 'No placemarks found';
      }
    } catch (e) {
      debugPrint('Location error: $e');
      return 'Error getting location: $e';
    }
  }

  Future<void> fetchEventsFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('events').get();
      final allEvents = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['name'] ?? 'Unnamed',
          'description': data['description'] ?? 'No description',
          'date': data['date'] ?? 'No date',
          'latitude': data['latitude'] ?? 0.0,
          'longitude': data['longitude'] ?? 0.0,
          'image_base64': data['image_base64'] ?? '',
        };
      }).toList();

      if (_currentPosition != null) {
        _events = allEvents.where((event) {
          double distance = calculateDistance(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            event['latitude'],
            event['longitude'],
          );
          return distance <= 25; // Only keep events within 25 km
        }).toList();
      } else {
        _events = [];
      }
    } catch (e) {
      debugPrint('Firestore fetch error: $e');
    }
  }

  double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371; // km
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degToRad(double degree) => degree * pi / 180;

  // -------------------- Screen Widgets --------------------

  /// Home screen widget that shows event finder functionality.
  Widget _buildHomeScreen() {
    final screenWidth = MediaQuery.of(context).size.width;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // A search text field at the top of the home page with orange color.
        const TextField(
          decoration: InputDecoration(
            hintText: 'Search events...',
            hintStyle: TextStyle(color: Colors.orange),  // Orange hint text color
            prefixIcon: Icon(Icons.search, color: Colors.orange),  // Orange search icon
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.orange),  // Orange border
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Location information and refresh button with orange styling.
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.orange),  // Orange location icon
            const SizedBox(width: 4),
            Expanded(
              child: _isLoading
                  ? const LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.orange),  // Orange progress bar
              )
                  : Text(
                _location,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,  // Keep text black for contrast
                ),
              ),
            ),
            TextButton(
              onPressed: fetchAndSetLocation,
              child: const Text(
                "Refresh",
                style: TextStyle(color: Colors.orange),  // Orange refresh button
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Featured events with tabs and orange tab selection.
        DefaultTabController(
          length: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TabBar(
                isScrollable: true,
                labelColor: Colors.orange,  // Orange selected tab text
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.orange,  // Orange indicator
                tabs: [
                  Tab(text: 'Today'),
                  Tab(text: 'This Week'),
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Past'),
                ],
              ),
              SizedBox(
                height: screenWidth * 0.45,
                child: TabBarView(
                  children: List.generate(
                    4,
                        (_) => _buildFeaturedEvents(screenWidth),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Popular categories chips with orange background and white text.
        const Text(
          'Popular Categories',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              CategoryChip(label: '🎵 Music'),
              CategoryChip(label: '🍔 Food'),
              CategoryChip(label: '🏃 Sports'),
              CategoryChip(label: '🎨 Art'),
              CategoryChip(label: '💻 Tech'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // List of nearby events with card styling.
        const Text(
          'Events Near You',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._events.map((event) {
          final lat = event['latitude'];
          final lng = event['longitude'];
          final distance = _currentPosition != null
              ? '${calculateDistance(_currentPosition!.latitude, _currentPosition!.longitude, lat, lng).toStringAsFixed(1)} km'
              : 'Distance unavailable';

          return _buildEventCard(
            title: event['name'],
            venue: event['description'],
            time: event['date'],
            distance: distance,
            base64Image: event['image_base64'],
          );
        }).toList(),
      ],
    );

  }

  /// Placeholder Search screen (replace with your own implementation)
  Widget _buildSearchScreen() {
    return  SearchScreen();
  }

  /// Placeholder My Events screen (replace with your own implementation)
  Widget _buildMyEventsScreen() {

return LoginScreen();
  }

  /// Placeholder Profile screen (replace with your own implementation)
  Widget _buildProfileScreen() {
    return  ProfileScreen();
  }

  /// A helper method to build featured events horizontal list.
  Widget _buildFeaturedEvents(double screenWidth) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Clicked featured event ${index + 1}',
                  style: const TextStyle(color: Colors.white),  // White text for the SnackBar
                ),
                backgroundColor: Colors.orange,  // Orange background for the SnackBar
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            width: screenWidth * 0.75,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: AssetImage('assets/logo.jpg'),
                fit: BoxFit.cover,
                opacity: 0.8,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                   // Orange overlay for text visibility
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Text(
                    "Live Concert Night",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,  // White text for the title
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

  }

  /// A helper method to build an event card.
  Widget _buildEventCard({
    required String title,
    required String venue,
    required String time,
    required String distance,
    required String base64Image,
  }) {
    Uint8List? imageBytes;
    if (base64Image.isNotEmpty) {
      imageBytes = base64Decode(base64Image);
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      color: Colors.white,  // Set background color to white
      child: ListTile(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Tapped on $title',
                style: const TextStyle(color: Colors.white),  // White text for SnackBar
              ),
              backgroundColor: Colors.orange,  // Orange SnackBar background
            ),
          );
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageBytes != null
              ? Image.memory(imageBytes,
              width: 60, height: 60, fit: BoxFit.cover)
              : Image.asset('assets/logo.jpg',
              width: 60, height: 60, fit: BoxFit.cover),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange,  // Orange title text
          ),
        ),
        subtitle: Text(
          '$venue\n$time',
          style: const TextStyle(color: Colors.black),  // Black subtitle text
        ),
        trailing: Text(
          distance,
          style: const TextStyle(color: Colors.orange),  // Orange distance text
        ),
        isThreeLine: true,
      ),
    );

  }

  // -------------------- Build Method with Bottom Navigation --------------------

  @override
  Widget build(BuildContext context) {
    // Determine which screen to show based on _currentIndex:
    Widget currentScreen;
    switch (_currentIndex) {
      case 0:
        currentScreen = _buildHomeScreen();
        break;
      case 1:
      // If you have an external SearchScreen widget, you could replace _buildSearchScreen()
        currentScreen = _buildSearchScreen();
        break;
      case 2:
        currentScreen = _buildMyEventsScreen();
        break;
      case 3:
        currentScreen = _buildProfileScreen();
        break;
      default:
        currentScreen = _buildHomeScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
        appBar: _currentIndex == 0
            ? AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: imagePath == null
                      ? const AssetImage('assets/logo.jpg')
                      : FileImage(File(imagePath!)) as ImageProvider,
                  radius: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.orange),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications tapped'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: const Text(
                        '3',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
            : null,



      body: currentScreen,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,  // Orange selected item color
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.event), label: 'Add Events'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );

  }
}

/// -------------------- Helper Widget: CategoryChip --------------------
class CategoryChip extends StatelessWidget {
  final String label;

  const CategoryChip({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: Colors.orange, // Orange text color
          ),
        ),
        backgroundColor: Colors.white, // White background for the chip
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        side: BorderSide(
          color: Colors.orange, // Orange border color
          width: 1, // Optional: if you want a border
        ),
      ),
    );
  }
}

