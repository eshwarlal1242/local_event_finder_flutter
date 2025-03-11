import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local_event/pages/home.dart';
import 'package:local_event/pages/splash_screen.dart';
import 'package:local_event/services/event_list.dart';

import 'MapDemo.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'add_event.dart';
import 'google_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home:  SplashScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> events = [];

  void _addEvent(String name, String category, File? image, LatLng? location) {
    setState(() {
      events.add({
        'name': name,
        'category': category,
        'image': image,
        'location': location,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Manager')),
      body: EventListScreen(events: events),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEventScreen(onEventAdded: _addEvent),
            ),
          );
        },
      ),
    );
  }
}

